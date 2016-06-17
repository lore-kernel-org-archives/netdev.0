From: Simon Horman <simon.horman@netronome.com>
Subject: Re: [PATCH net-next v10 2/5] openvswitch: set skb protocol and
 mac_len when receiving on internal device
Date: Fri, 17 Jun 2016 14:53:34 +0900
Message-ID: <20160617055331.GA24833@vergenet.net>
References: <1464848686-7656-1-git-send-email-simon.horman@netronome.com>
 <1464848686-7656-3-git-send-email-simon.horman@netronome.com>
 <CAOrHB_Aqdkr-26GxGh=W0AsojOMzDXYf5zif=kaFbWBty5uHKA@mail.gmail.com>
 <20160607030809.GE31696@vergenet.net>
 <CAOrHB_Cp4bw1beQb8tCk+cR9k2Nv5kBMVD-a8SYRVkOeeQYJvA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
	ovs dev <dev@openvswitch.org>
To: pravin shelar <pshelar@ovn.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f177.google.com ([209.85.192.177]:35924 "EHLO
	mail-pf0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752172AbcFQFxn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Jun 2016 01:53:43 -0400
Received: by mail-pf0-f177.google.com with SMTP id t190so27410968pfb.3
        for <netdev@vger.kernel.org>; Thu, 16 Jun 2016 22:53:43 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <CAOrHB_Cp4bw1beQb8tCk+cR9k2Nv5kBMVD-a8SYRVkOeeQYJvA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jun 07, 2016 at 03:45:27PM -0700, pravin shelar wrote:
> On Mon, Jun 6, 2016 at 8:08 PM, Simon Horman <simon.horman@netronome.com> wrote:
> > On Thu, Jun 02, 2016 at 03:01:47PM -0700, pravin shelar wrote:
> >> On Wed, Jun 1, 2016 at 11:24 PM, Simon Horman
> >> <simon.horman@netronome.com> wrote:
> >> > * Set skb protocol based on contents of packet. I have observed this is
> >> >   necessary to get actual protocol of a packet when it is injected into an
> >> >   internal device e.g. by libnet in which case skb protocol will be set to
> >> >   ETH_ALL.
> >> >
> >> > * Set the mac_len which has been observed to not be set up correctly when
> >> >   an ARP packet is generated and sent via an openvswitch bridge.
> >> >   My test case is a scenario where there are two open vswtich bridges.
> >> >   One outputs to a tunnel port which egresses on the other.
> >> >
> >> > The motivation for this is that support for outputting to layer 3 (non-tap)
> >> > GRE tunnels as implemented by a subsequent patch depends on protocol and
> >> > mac_len being set correctly on receive.
> >> >
> >> > Signed-off-by: Simon Horman <simon.horman@netronome.com>
> >> >
> >> > ---
> >> > v10
> >> > * Set mac_len
> >> >
> >> > v9
> >> > * New patch
> >> > ---
> >> >  net/openvswitch/vport-internal_dev.c | 4 ++++
> >> >  1 file changed, 4 insertions(+)
> >> >
> >> > diff --git a/net/openvswitch/vport-internal_dev.c b/net/openvswitch/vport-internal_dev.c
> >> > index 2ee48e447b72..f89b1efa88f1 100644
> >> > --- a/net/openvswitch/vport-internal_dev.c
> >> > +++ b/net/openvswitch/vport-internal_dev.c
> >> > @@ -48,6 +48,10 @@ static int internal_dev_xmit(struct sk_buff *skb, struct net_device *netdev)
> >> >  {
> >> >         int len, err;
> >> >
> >> > +       skb->protocol = eth_type_trans(skb, netdev);
> >> > +       skb_push(skb, ETH_HLEN);
> >> > +       skb_reset_mac_len(skb);
> >> > +
> >> resetting mac-len breaks the assumption about mac_len for referencing
> >> MPLS header ref: skb_mpls_header().
> >
> > Thanks I had overlooked this. I think it is actually safe as
> > the mac_len is recalculated quite soon in key_extract() and IIRC
> > the most important thing is for mac_len to be 0 or non-zero
> > for the benefit of ovs_flow_key_extract(). None the less it does
> > seem untidy and moreover inconsistent with the handling in
> > netdev_port_receive() by a latter patch which does the following:
> >
> >         eth_type = eth_type_trans(skb, skb->dev);
> >         skb->mac_len = skb->data - skb_mac_header(skb);
> >         __skb_push(skb, skb->mac_len);
> >
> >         if (eth_type == htons(ETH_P_8021Q))
> >                 skb->mac_len += VLAN_HLEN;
> >
> > Perhaps that logic ought to be in a helper used by both internal_dev_xmit()
> > and netdev_port_receive(). Or somehow centralised in ovs_vport_receive().
> 
> This does looks bit complex. Can we use other skb metadata like
> skb_mac_header_was_set()?

Yes, I think that can be made to work if skb->mac_header is unset
for l3 packets in netdev_port_receive(). The following is an incremental
patch on the entire series. Is this the kind of thing you had in mind?

diff --git a/net/openvswitch/flow.c b/net/openvswitch/flow.c
index 86f2cfb19de3..42587d5bf894 100644
--- a/net/openvswitch/flow.c
+++ b/net/openvswitch/flow.c
@@ -729,7 +729,7 @@ int ovs_flow_key_extract(const struct ip_tunnel_info *tun_info,
 	key->phy.skb_mark = skb->mark;
 	ovs_ct_fill_key(skb, key);
 	key->ovs_flow_hash = 0;
-	key->phy.is_layer3 = skb->mac_len == 0;
+	key->phy.is_layer3 = skb_mac_header_was_set(skb) == 0;
 	key->recirc_id = 0;
 
 	err = key_extract(skb, key);
diff --git a/net/openvswitch/vport-internal_dev.c b/net/openvswitch/vport-internal_dev.c
index 484ba529c682..8973d4db509b 100644
--- a/net/openvswitch/vport-internal_dev.c
+++ b/net/openvswitch/vport-internal_dev.c
@@ -50,7 +50,6 @@ static int internal_dev_xmit(struct sk_buff *skb, struct net_device *netdev)
 
 	skb->protocol = eth_type_trans(skb, netdev);
 	skb_push(skb, ETH_HLEN);
-	skb_reset_mac_len(skb);
 
 	len = skb->len;
 	rcu_read_lock();
diff --git a/net/openvswitch/vport-netdev.c b/net/openvswitch/vport-netdev.c
index 3df36df62ee9..4cf3f12ffc99 100644
--- a/net/openvswitch/vport-netdev.c
+++ b/net/openvswitch/vport-netdev.c
@@ -60,22 +60,9 @@ static void netdev_port_receive(struct sk_buff *skb)
 	if (vport->dev->type == ARPHRD_ETHER) {
 		skb_push(skb, ETH_HLEN);
 		skb_postpush_rcsum(skb, skb->data, ETH_HLEN);
-	} else if (vport->dev->type == ARPHRD_NONE) {
-		if (skb->protocol == htons(ETH_P_TEB)) {
-			__be16 eth_type;
-
-			if (unlikely(skb->len < ETH_HLEN))
-				goto error;
-
-			eth_type = eth_type_trans(skb, skb->dev);
-			skb->mac_len = skb->data - skb_mac_header(skb);
-			__skb_push(skb, skb->mac_len);
-
-			if (eth_type == htons(ETH_P_8021Q))
-				skb->mac_len += VLAN_HLEN;
-		} else {
-			skb->mac_len = 0;
-		}
+	} else if (vport->dev->type == ARPHRD_NONE &&
+		   skb->protocol != htons(ETH_P_TEB)) {
+		skb->mac_header = (typeof(skb->mac_header))~0U;
 	}
 
 	ovs_vport_receive(vport, skb, skb_tunnel_info(skb));
