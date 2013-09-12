From: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>
Subject: Re: [PATCH net 2/4] bridge: Handle priority-tagged frames properly
Date: Thu, 12 Sep 2013 17:08:39 +0900
Message-ID: <1378973319.4472.68.camel@ubuntu-vm-makita>
References: <1378808874.3988.2.camel@ubuntu-vm-makita>
	 <1378809280.3988.8.camel@ubuntu-vm-makita> <522F26B3.60709@redhat.com>
	 <1378882832.3495.12.camel@ubuntu-vm-makita> <52309B01.4060607@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Fernando Luis Vazquez Cao <fernando_b1@lab.ntt.co.jp>,
	Patrick McHardy <kaber@trash.net>
To: vyasevic@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from tama500.ecl.ntt.co.jp ([129.60.39.148]:46143 "EHLO
	tama500.ecl.ntt.co.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753197Ab3ILIJl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Sep 2013 04:09:41 -0400
In-Reply-To: <52309B01.4060607@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2013-09-11 at 12:32 -0400, Vlad Yasevich wrote:
> On 09/11/2013 03:00 AM, Toshiaki Makita wrote:
> > On Tue, 2013-09-10 at 10:03 -0400, Vlad Yasevich wrote:
> >> On 09/10/2013 06:34 AM, Toshiaki Makita wrote:
> >>> IEEE 802.1Q says that when we receive priority-tagged (VID 0) frames
> >>> use the PVID for the port as its VID.
> >>> (See IEEE 802.1Q-2005 6.7.1 and Table 9-2)
> >>>
> >>> Apply the PVID to not only untagged frames but also priority-tagged frames.
> >>>
> >>> Signed-off-by: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>
> >>> ---
> >>>    net/bridge/br_vlan.c | 27 ++++++++++++++++++++-------
> >>>    1 file changed, 20 insertions(+), 7 deletions(-)
> >>>
> >>> diff --git a/net/bridge/br_vlan.c b/net/bridge/br_vlan.c
> >>> index 21b6d21..5a9c44a 100644
> >>> --- a/net/bridge/br_vlan.c
> >>> +++ b/net/bridge/br_vlan.c
> >>> @@ -189,6 +189,8 @@ out:
> >>>    bool br_allowed_ingress(struct net_bridge *br, struct net_port_vlans *v,
> >>>    			struct sk_buff *skb, u16 *vid)
> >>>    {
> >>> +	int err;
> >>> +
> >>>    	/* If VLAN filtering is disabled on the bridge, all packets are
> >>>    	 * permitted.
> >>>    	 */
> >>> @@ -201,20 +203,31 @@ bool br_allowed_ingress(struct net_bridge *br, struct net_port_vlans *v,
> >>>    	if (!v)
> >>>    		return false;
> >>>
> >>> -	if (br_vlan_get_tag(skb, vid)) {
> >>> +	err = br_vlan_get_tag(skb, vid);
> >>> +	if (!*vid) {
> >>>    		u16 pvid = br_get_pvid(v);
> >>>
> >>> -		/* Frame did not have a tag.  See if pvid is set
> >>> -		 * on this port.  That tells us which vlan untagged
> >>> -		 * traffic belongs to.
> >>> +		/* Frame had a tag with VID 0 or did not have a tag.
> >>> +		 * See if pvid is set on this port.  That tells us which
> >>> +		 * vlan untagged or priority-tagged traffic belongs to.
> >>>    		 */
> >>>    		if (pvid == VLAN_N_VID)
> >>>    			return false;
> >>>
> >>> -		/* PVID is set on this port.  Any untagged ingress
> >>> -		 * frame is considered to belong to this vlan.
> >>> +		/* PVID is set on this port.  Any untagged or priority-tagged
> >>> +		 * ingress frame is considered to belong to this vlan.
> >>>    		 */
> >>> -		__vlan_hwaccel_put_tag(skb, htons(ETH_P_8021Q), pvid);
> >>> +		if (likely(err))
> >>> +			/* Untagged Frame. */
> >>> +			__vlan_hwaccel_put_tag(skb, htons(ETH_P_8021Q), pvid);
> >>> +		else
> >>> +			/* Priority-tagged Frame.
> >>> +			 * At this point, We know that skb->vlan_tci had
> >>> +			 * VLAN_TAG_PRESENT bit and its VID field was 0x000.
> >>> +			 * We update only VID field and preserve PCP field.
> >>> +			 */
> >>> +			skb->vlan_tci |= pvid;
> >>> +
> >>
> >> In the case of a priority tagged frame, we should unroll the
> >> modification above and restore the VID field to 0.  Otherwise, you
> >> may end up either stripping the vlan header completely or forwarding
> >> with pvid of the ingress port.
> >
> > Thank you for reviewing.
> >
> > It is my intended behavior that an incoming priority-tagged frame is
> > forwarded as a frame untagged or tagged with pvid.
> >
> > IEEE 802.1Q-2011:
> >
> >    section 8.1.7 Conversion of frame formats
> >
> >    NOTE - As all incoming frames, including priority-tagged frames, are
> >    classified as belonging to a VLAN, the transmitting Port transmits
> >    VLAN-tagged frames or untagged frames. Hence, a station sending a
> >    priority-tagged frame via a Bridge will receive a response that is
> >    either VLAN-tagged or untagged, as described in 8.5.
> >
> >    3. Definitions
> >
> >    3.132 Priority-tagged frame: A tagged frame whose tag header carries
> >    priority information but carries no VLAN identification information.
> >
> >    3.203 VLAN-tagged frame: A VLAN-tagged frame is a tagged frame whose
> >    tag header carries *both* VLAN identification and priority
> >    information.
> >
> > Toshiaki Makita
> >
> 
> Hmm..  The problem is that if a system attached to a port configures a
> vlan interface with vid 0 and some priority mappings, then that
> interface will not be able to properly receive traffic, as the bridge 
> now will never transmit priority tagged frames.
> 
> -vlad

I see.  As you say, for example, if we configure vnet0.0 and attach
vnet0 to a bridge with vlan_filtering enabled, even though we are
sending priority-tagged frames from vnet0.0 and they are successfully
forwarded by the bridge to another port, we cannot receive any frame on
vnet0.0 because all incoming frames from a bridge port are not
priority-tagged and never passed to vnet0.0.

I think this might be a problem as an end station that cannot receive
incoming untagged frames and priority-tagged frames on the same
interface when vlan 0 interface is defined.
(We can receive both untagged and priority-tagged frames on the same
interface that is not configured vlan 0.)

If we assume it as a problem of vlan interface, I guess we should enable
vlan 0 interface to receive untagged frames (treat vnet0.0 as an alias
of vnet0), or add a setting of egress priority map to vnet0 so that vlan
0 interface can become unnecessary.

If it is preferable to deal with it by bridge, I don't think a
priority-tagged frame's VID field should be restored to 0 on the egress
port.  If we do so, we may receive both untagged frames and
priority-tagged frames from a bridge port when another end station sends
both untagged and priority-tagged frames by mixture.
IMO, it will be resolved by adding a new per-port policy that enables us
to send priority-tagged frames instead of untagged frames, like the
"priority-tags" option of openvswitch.
This solution, however, makes the bridge not be conformed with IEEE
802.1Q, and the problem remains that we cannot receive any frames on a
vlan 0 interface such as eth0.0 when we connect eth0 to another 802.1Q
conformed switch.

I'd like to hear further comments or suggestions, everyone :)

Thanks,

Toshiaki Makita

> 
> >>
> >> -vlad
> >>>    		return true;
> >>>    	}
> >>>
> >>>
> >
> >
