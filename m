From: Thomas Graf <tgraf-G/eBtMaohhA@public.gmane.org>
Subject: Re: [PATCH 2/2 net-next] openvswitch: Use skb_zerocopy()
	for upcall
Date: Sun, 10 Nov 2013 23:40:33 +0000
Message-ID: <20131110234033.GA18099@casper.infradead.org>
References: <cover.1383901577.git.tgraf@suug.ch>
	<63f4476190ef4044f7c09b225b4e93cd929bf0be.1383901577.git.tgraf@suug.ch>
	<1384034549.3802.41.camel@bwh-desktop.uk.level5networks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org,
	eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
To: Ben Hutchings <bhutchings-s/n/eUQHGBpZroRs9YW3xA@public.gmane.org>
Return-path: <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1384034549.3802.41.camel-/LGg1Z1CJKQ+9kgCwbf1HqK4ta4zdZpAajtMo4Cw6ucAvxtiuMwx3w@public.gmane.org>
List-Unsubscribe: <http://openvswitch.org/mailman/options/dev>,
	<mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=unsubscribe>
List-Archive: <http://openvswitch.org/pipermail/dev>
List-Post: <mailto:dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
List-Help: <mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=help>
List-Subscribe: <http://openvswitch.org/mailman/listinfo/dev>,
	<mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=subscribe>
Sender: dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
Errors-To: dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
List-Id: netdev.vger.kernel.org

On 11/09/13 at 10:02pm, Ben Hutchings wrote:
> On Fri, 2013-11-08 at 10:15 +0100, Thomas Graf wrote:
> > Use of skb_zerocopy() avoids the expensive call to memcpy() when
> > copying the packet data into the Netlink skb. Completes checksum
> > through skb_checksum_help() if needed.
> > 
> > Netlink messaged must be properly padded and aligned to meet
> > sanity checks of the user space counterpart.
> > 
> > Cost of memcpy is significantly reduced from:
> > +   7.48%       vhost-8471  [k] memcpy
> > +   5.57%     ovs-vswitchd  [k] memcpy
> > +   2.81%       vhost-8471  [k] csum_partial_copy_generic
> > 
> > to:
> > +   5.72%     ovs-vswitchd  [k] memcpy
> > +   3.32%       vhost-5153  [k] memcpy
> > +   0.68%       vhost-5153  [k] skb_zerocopy
> > 
> > (megaflows disabled)
> > 
> > Signed-off-by: Thomas Graf <tgraf-G/eBtMaohhA@public.gmane.org>
> > ---
> >  net/openvswitch/datapath.c | 52 +++++++++++++++++++++++++++++++++++++++-------
> >  1 file changed, 45 insertions(+), 7 deletions(-)
> > 
> > diff --git a/net/openvswitch/datapath.c b/net/openvswitch/datapath.c
> > index 1408adc..3f170e3 100644
> > --- a/net/openvswitch/datapath.c
> > +++ b/net/openvswitch/datapath.c
> [...]
> > @@ -441,13 +449,43 @@ static int queue_userspace_packet(struct net *net, int dp_ifindex,
> >  			  nla_len(upcall_info->userdata),
> >  			  nla_data(upcall_info->userdata));
> >  
> > -	nla = __nla_reserve(user_skb, OVS_PACKET_ATTR_PACKET, skb->len);
> > +	/* Only reserve room for attribute header, packet data is added
> > +	 * in skb_zerocopy() */
> > +	if (!(nla = nla_reserve(user_skb, OVS_PACKET_ATTR_PACKET, 0)))
> > +		goto out;
> > +	nla->nla_len = nla_attr_size(skb->len);
> >  
> > -	skb_copy_and_csum_dev(skb, nla_data(nla));
> > +	skb_zerocopy(user_skb, skb, skb->len, hlen);
> >  
> > -	genlmsg_end(user_skb, upcall);
> > -	err = genlmsg_unicast(net, user_skb, upcall_info->portid);
> > +	/* OVS user space expects the size of the message to be aligned to
> > +	 * NLA_ALIGNTO. Aligning nlmsg_len is not enough, the actual bytes
> > +	 * read must match nlmsg_len.
> > +	 */
> > +	plen = NLA_ALIGN(user_skb->len) - user_skb->len;
> > +	if (plen > 0) {
> > +		int nr_frags = skb_shinfo(user_skb)->nr_frags;
> > +
> > +		if (nr_frags) {
> > +			skb_frag_t *frag;
> > +
> > +			frag = &skb_shinfo(user_skb)->frags[nr_frags -1];
> > +			skb_frag_size_add(frag, plen);
> 
> It looks like this is effectively padding with whatever happens to
> follow the original packet content.  This could result in a small
> information leak.  If the fragment has non-zero offset and already
> extends to the end of a page, this could result in a segfault as the
> next page may be unmapped.
> 
> Perhaps you could add the padding as an extra fragment pointing to a
> preallocated zero page.  If the skb already has the maximum number of
> fragments, you would have to copy the last fragment in order to add
> padding.

You are right and thanks for the review Ben.

Realizing how complex this becomes I'm leaning towards avoiding
padding alltogether by fixing OVS user space to no longer enforce
it, signal this capability via a flag to the kernel and only
perform zerocopy for enabled OVS user space counterparts.
