From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH net-next 2/2] openvswitch: Use skb_zerocopy() to prepare
 skb for upcall
Date: Fri, 26 Jul 2013 11:15:58 +0100
Message-ID: <20130726101558.GA22120@casper.infradead.org>
References: <cover.1374756042.git.tgraf@suug.ch>
 <9d4aaa5319c684e14721e0bed2ef22ddc409caf1.1374756042.git.tgraf@suug.ch>
 <CAEP_g=_ExeJ+pJ4KU7+=vdyFgLQtY2v6fiK0GzLKpeNF8NULbw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	"dev@openvswitch.org" <dev@openvswitch.org>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: Jesse Gross <jesse@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:43902 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758483Ab3GZKQB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Jul 2013 06:16:01 -0400
Content-Disposition: inline
In-Reply-To: <CAEP_g=_ExeJ+pJ4KU7+=vdyFgLQtY2v6fiK0GzLKpeNF8NULbw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/25/13 at 06:39pm, Jesse Gross wrote:
> On Thu, Jul 25, 2013 at 5:43 AM, Thomas Graf <tgraf@suug.ch> wrote:
> > From: Thomas Graf <tgraf@rhlap.localdomain>
> >
> > Use of skb_zerocopy() avoids the expensive call to memcpy() when
> > copying the packet data into the Netlink skb. Completes checksum
> > through skb_checksum_help() if needed (typicall packet input from
> > software device) which invalidates some of the gains again.
> >
> > Stock-RX
> > -  38.30%       swapper  [kernel.kallsyms]  [k] memcpy
> >    - memcpy
> >       + 87.46% queue_userspace_packet
> >       + 12.54% nla_put
> > +  24.72%  ovs-vswitchd  libc-2.17.so       [.] __memcpy_ssse3_back
> > +  13.80%  ovs-vswitchd  [kernel.kallsyms]  [k] memcpy
> > -   7.68%   ksoftirqd/2  [kernel.kallsyms]  [k] memcpy
> >    - memcpy
> >       + 85.83% queue_userspace_packet
> >       + 14.17% nla_put
> > -   7.06%   ksoftirqd/3  [kernel.kallsyms]  [k] memcpy
> >    - memcpy
> >       + 84.85% queue_userspace_packet
> >       + 15.15% nla_put
> > -   4.41%   ksoftirqd/0  [kernel.kallsyms]  [k] memcpy
> >    - memcpy
> >       + 83.48% queue_userspace_packet
> >       + 16.52% nla_put
> >
> > Zerocopy-RX
> > +  50.35%  ovs-vswitchd  libc-2.17.so       [.] __memcpy_ssse3_back
> > -  27.78%  ovs-vswitchd  [kernel.kallsyms]  [k] memcpy
> >    - memcpy
> >       + 74.53% ovs_packet_cmd_execute
> >       + 24.11% nla_put
> >       + 0.93% ovs_flow_cmd_new_or_set
> > +  13.49%       swapper  [kernel.kallsyms]  [k] memcpy
> > +   1.45%   ksoftirqd/3  [kernel.kallsyms]  [k] memcpy
> > +   1.20%   ksoftirqd/2  [kernel.kallsyms]  [k] memcpy
> >
> > 10Gb remote pktgen, 1200 bytes, randomized flows, w/ UDPCSUM:
> >                                 Hits               Missed          Lost
> > Stock RX                     731'945            6'315'739     3'606'678
> > Zerocopy RX                  764'041            6'442'761     3'947'451
> >
> > local pktgen, 4/6 CPUs, 1200 bytes, randomized flows, UDPCSUM:
> >                                 Hits               Missed          Lost
> > Stock TX                   2'071'030           17'929'192    16'807'785
> > Zerocopy TX                1'951'142           18'049'056    16'977'296
> >
> > Signed-off-by: Thomas Graf <tgraf@suug.ch>
> > Cc: Jesse Gross <jesse@nicira.com>
> > Cc: Eric Dumazet <eric.dumazet@gmail.com>
> 
> Thanks for the new version and performance numbers.
> 
> Reading the numbers that you provided it seems like this is a win for
> received packets and basically a wash for outgoing packets (assuming
> that they are using checksum offloading, which I suspect is most of
> them). Is that also your conclusion?

It's a wash for TX due to checksumming. You may have seen my patch to
pktgen to produce udp checksum skbs. It'swhat I have used to produce
the above numbers. It will will generate CHECKSUM_PARTIAL skbs due to
vport internal announcing hw capability (which is fine). Leaving out
the call to skb_checksum_help() increases the number of hits to 2.6M
which would be a nice gain.

The question is, can we move checksum completion to user space? We only
need to complete the checksum if the packet is sent to a controller at
which point performance does not matter anymore. What do you think
about a datapath flag indicating whether user space supports checksum
completion and if so skipping the checksum completion in the fast
path?

> > @@ -443,11 +450,39 @@ static int queue_userspace_packet(struct net *net, int dp_ifindex,
> >                           nla_len(upcall_info->userdata),
> >                           nla_data(upcall_info->userdata));
> >
> > -       nla = __nla_reserve(user_skb, OVS_PACKET_ATTR_PACKET, skb->len);
> > +       if (!(nla = nla_reserve(user_skb, OVS_PACKET_ATTR_PACKET, 0)))
> > +               goto out;
> 
> Do we expect that this might fail now?

It can fail if the message size is miscalculated. I don't like BUG()
but WARN() would help here I guess.

> > +       nla->nla_len = nla_attr_size(skb->len);
> > +
> > +       skb_zerocopy(user_skb, skb, skb->len, hlen);
> > +
> > +       /* Align the end of the attribute to NLA_ALIGNTO */
> > +       plen = NLA_ALIGN(user_skb->len) - user_skb->len;
> > +       if (plen > 0) {
> > +               int nr_frags = skb_shinfo(user_skb)->nr_frags;
> >
> > -       skb_copy_and_csum_dev(skb, nla_data(nla));
> > +               if (nr_frags) {
> > +                       skb_frag_t *frag;
> > +
> > +                       /* Assumption is made that PAGE_SIZE is always alligned
> > +                        * to at least NLA_ALIGNTO (4) which means that we it
> > +                        * should be safe to add the padding bytes to the frag
> > +                        */
> 
> I agree that it should be safe to assume that PAGE_SIZE is a multiple
> of the netlink alignment requirements. However, we are calculating the
> alignment over the total packet payload but applying the alignment to
> the paged portion. Couldn't we have a non-aligned potion in the linear
> data area followed by a full page?

I was also assuming that headlen is always a multiple of 4 due to the
2 byte shift accounting for the ethernet header but thinking about
this harder this may not be the case after all. OTOH I ran a test with
randomized packet sizes and didn't hit any walls.

But you are right in general, the headlen we allocate will always be
alligned but not the amount copy.

> > +       /* Fix alignment of .nlmsg_len, OVS user space enforces a strict
> > +        * total message size alignment.
> > +        */
> > +       ((struct nlmsghdr *) user_skb->data)->nlmsg_len = NLA_ALIGN(user_skb->len);
> 
> Do we still need to do this manually now that we are enforcing
> alignment of the payload above?

We could use genlmsg_end() again if we also fix the skb-> pointer
above. But we could drop the NLA_ALIGN() because user_skb->len is
not always aligned.
