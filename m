From: Cong Wang <amwang@redhat.com>
Subject: Re: [Patch net] bridge: do not expire mdb entry when
 bridge still uses it
Date: Fri, 08 Mar 2013 10:44:06 +0800
Message-ID: <1362710646.9773.25.camel@cr0>
References: <1362708423-23932-1-git-send-email-amwang@redhat.com>
	<20130308023151.GA27155@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <stephen@networkplumber.org>, netdev@vger.kernel.org,
	bridge@lists.linux-foundation.org, "David S. Miller" <davem@davemloft.net>,
	Adam Baker <linux@baker-net.org.uk>
To: Herbert Xu <herbert@gondor.hengli.com.au>
Return-path: <bridge-bounces@lists.linux-foundation.org>
In-Reply-To: <20130308023151.GA27155@gondor.apana.org.au>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/bridge/>
List-Post: <mailto:bridge@lists.linux-foundation.org>
List-Help: <mailto:bridge-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=subscribe>
Sender: bridge-bounces@lists.linux-foundation.org
Errors-To: bridge-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

On Fri, 2013-03-08 at 10:31 +0800, Herbert Xu wrote:
> On Fri, Mar 08, 2013 at 10:07:03AM +0800, Cong Wang wrote:
> > From: Cong Wang <amwang@redhat.com>
> > 
> > This is a long-standing bug and reported several times:
> > https://bugzilla.redhat.com/show_bug.cgi?id=880035
> > http://marc.info/?l=linux-netdev&m=136164389416341&w=2
> > 
> > This bug can be observed in virt environment, when a KVM guest
> > communicates with the host via multicast. After some time (should
> > be 260 sec, I didn't measure), the multicast traffic suddenly
> > terminates.
> > 
> > This is due to the mdb entry for bridge itself expires automatically,
> > it should not expire as long as the bridge still generates multicast
> > traffic. It should expire when the bridge leaves the multicast group,
> > OR when there is no multicast traffic on this bridge.
> > 
> > I fix this by adding another bool which is set when there is
> > multicast traffic goes to the bridge, cleared in the expire timer and
> > when IGMP leave is received. I ran omping for 15 minutes, everything
> > looks good now.
> 
> I gather from the bugzilla entry that this happens where there is
> no querier in the network.
> 
> So my question is why does this only affect the bridge port and
> not other ports on the bridge?
> 

This is a good question. It is due to inside br_handle_frame_finish() we
use 'skb2' to decide if we deliver packets to bridge itself, and in this
case 'skb2' is non-NULL only when:

                if (mdst || BR_INPUT_SKB_CB_MROUTERS_ONLY(skb)) {
                        if ((mdst && mdst->mglist) ||
                            br_multicast_is_router(br))
                                skb2 = skb; //        <======== HERE
                        br_multicast_forward(mdst, skb, skb2);

For other ports, br_multicast_forward() will always forward 'skb' to
them.

Thanks.
