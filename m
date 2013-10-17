From: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>
Subject: Re: [PATCH v2 net 4/4] bridge: Fix updating FDB entries when the
 PVID is applied
Date: Thu, 17 Oct 2013 21:52:36 +0900
Message-ID: <1382014356.3746.70.camel@ubuntu-vm-makita>
References: <1381910836-718-1-git-send-email-makita.toshiaki@lab.ntt.co.jp>
	 <1381910836-718-5-git-send-email-makita.toshiaki@lab.ntt.co.jp>
	 <20131016085715.3442e8c3@nehalam.linuxnetplumber.net>
	 <525EBABF.6030304@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <stephen@networkplumber.org>,
	"David S . Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Toshiaki Makita <toshiaki.makita1@gmail.com>,
	Fernando Luis Vazquez Cao <fernando_b1@lab.ntt.co.jp>
To: vyasevic@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from tama50.ecl.ntt.co.jp ([129.60.39.147]:32963 "EHLO
	tama50.ecl.ntt.co.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755385Ab3JQMxC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Oct 2013 08:53:02 -0400
In-Reply-To: <525EBABF.6030304@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2013-10-16 at 12:11 -0400, Vlad Yasevich wrote:
> On 10/16/2013 11:57 AM, Stephen Hemminger wrote:
> > On Wed, 16 Oct 2013 17:07:16 +0900
> > Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp> wrote:
> >
> >> We currently set the value that variable vid is pointing, which will be
> >> used in FDB later, to 0 at br_allowed_ingress() when we receive untagged
> >> or priority-tagged frames, even though the PVID is valid.
> >> This leads to FDB updates in such a wrong way that they are learned with
> >> VID 0.
> >> Update the value to that of PVID if the PVID is applied.
> >>
> >> Signed-off-by: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>
> >> Reviewed-by: Vlad Yasevich <vyasevic@redhat.com>
> >> ---
> >>   net/bridge/br_vlan.c | 1 +
> >>   1 file changed, 1 insertion(+)
> >>
> >> diff --git a/net/bridge/br_vlan.c b/net/bridge/br_vlan.c
> >> index 5a9c44a..53f0990 100644
> >> --- a/net/bridge/br_vlan.c
> >> +++ b/net/bridge/br_vlan.c
> >> @@ -217,6 +217,7 @@ bool br_allowed_ingress(struct net_bridge *br, struct net_port_vlans *v,
> >>   		/* PVID is set on this port.  Any untagged or priority-tagged
> >>   		 * ingress frame is considered to belong to this vlan.
> >>   		 */
> >> +		*vid = pvid;
> >>   		if (likely(err))
> >>   			/* Untagged Frame. */
> >>   			__vlan_hwaccel_put_tag(skb, htons(ETH_P_8021Q), pvid);
> >
> >
> > Ok, but side-effects seem like an indication of poor code logic
> > flow design. Not your fault but part of the the per-vlan filtering code.
> >
> 
> I'll see if I can re-work the code to get rid of the side-effects.

I'm thinking br_allowed_ingress() might have too many roles.
- Determine whether an incoming frame is acceptable.
- Update skb->vlan_tci if PVID is applied.
- Update the argument 'vid'.

Besides, 'vid' is actually updated by not br_allowed_ingress() but
br_vlan_get_tag().

I think this complicated implementation could lead to missing expected
code for updating vid.

At least we can remove the third role from br_allowed_ingress() because
the required vid is recorded in skb->vlan_tci when we exit the function.

So, we can write the caller of br_allowed_ingress() like
	...
	if (!br_allowed_ingress(br, v, skb))
		goto drop;
	vid = br_vlan_get_tag(skb);

(Assuming br_vlan_get_tag() has been changed to return vid.)

However, this will require br_vlan_get_tag() to check br->vlan_enabled.
Does this change reduce complexity of current implementation?

BTW, some codes in mdb, such as br_multicast_ipv4_rcv(), seem to call
br_vlan_get_tag() without checking br->vlan_enabled.
Is this right way?
Or does br_vlan_get_tag() originally need to check br->vlan_enabled?

Thanks,

Toshiaki Makita

> 
> -vlad
