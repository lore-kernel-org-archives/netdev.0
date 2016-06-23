From: Simon Horman <simon.horman@netronome.com>
Subject: Re: [PATCH net-next v10 2/5] openvswitch: set skb protocol and
 mac_len when receiving on internal device
Date: Thu, 23 Jun 2016 11:04:38 +0900
Message-ID: <20160623020436.GA28594@vergenet.net>
References: <1464848686-7656-1-git-send-email-simon.horman@netronome.com>
 <1464848686-7656-3-git-send-email-simon.horman@netronome.com>
 <CAOrHB_Aqdkr-26GxGh=W0AsojOMzDXYf5zif=kaFbWBty5uHKA@mail.gmail.com>
 <20160607030809.GE31696@vergenet.net>
 <CAOrHB_Cp4bw1beQb8tCk+cR9k2Nv5kBMVD-a8SYRVkOeeQYJvA@mail.gmail.com>
 <20160617055331.GA24833@vergenet.net>
 <CAOrHB_BWfLk8yba2XkF43Hm-czGUZnVWQQ=HW3-vvpFEH7GNpA@mail.gmail.com>
 <20160621022458.GA28358@vergenet.net>
 <CAOrHB_B2mUqUOgwZroRqaYwsHCKd-Vj5nMWMvPxfF=quxhJ2cA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
	ovs dev <dev@openvswitch.org>, Jiri Benc <jbenc@redhat.com>
To: pravin shelar <pshelar@ovn.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f174.google.com ([209.85.192.174]:34799 "EHLO
	mail-pf0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750850AbcFWCEy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Jun 2016 22:04:54 -0400
Received: by mail-pf0-f174.google.com with SMTP id h14so23288513pfe.1
        for <netdev@vger.kernel.org>; Wed, 22 Jun 2016 19:04:54 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <CAOrHB_B2mUqUOgwZroRqaYwsHCKd-Vj5nMWMvPxfF=quxhJ2cA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jun 21, 2016 at 09:30:17AM -0700, pravin shelar wrote:
> On Mon, Jun 20, 2016 at 7:25 PM, Simon Horman
> <simon.horman@netronome.com> wrote:
> > [Cc Jiri Benc]
> >
> > On Sat, Jun 18, 2016 at 06:38:54PM -0700, pravin shelar wrote:
> >> On Thu, Jun 16, 2016 at 10:53 PM, Simon Horman
> >> <simon.horman@netronome.com> wrote:
> >> > On Tue, Jun 07, 2016 at 03:45:27PM -0700, pravin shelar wrote:
> >> >> On Mon, Jun 6, 2016 at 8:08 PM, Simon Horman <simon.horman@netronome.com> wrote:
> >> >> > On Thu, Jun 02, 2016 at 03:01:47PM -0700, pravin shelar wrote:
> >> >> >> On Wed, Jun 1, 2016 at 11:24 PM, Simon Horman
> >> >> >> <simon.horman@netronome.com> wrote:
> >> >> >> > * Set skb protocol based on contents of packet. I have observed this is
> >> >> >> >   necessary to get actual protocol of a packet when it is injected into an
> >> >> >> >   internal device e.g. by libnet in which case skb protocol will be set to
> >> >> >> >   ETH_ALL.
> >> ....
> >> ....
> >> >> >         eth_type = eth_type_trans(skb, skb->dev);
> >> >> >         skb->mac_len = skb->data - skb_mac_header(skb);
> >> >> >         __skb_push(skb, skb->mac_len);
> >> >> >
> >> >> >         if (eth_type == htons(ETH_P_8021Q))
> >> >> >                 skb->mac_len += VLAN_HLEN;
> >> >> >
> >> >> > Perhaps that logic ought to be in a helper used by both internal_dev_xmit()
> >> >> > and netdev_port_receive(). Or somehow centralised in ovs_vport_receive().
> >> >>
> >> >> This does looks bit complex. Can we use other skb metadata like
> >> >> skb_mac_header_was_set()?
> >> >
> >> > Yes, I think that can be made to work if skb->mac_header is unset
> >> > for l3 packets in netdev_port_receive(). The following is an incremental
> >> > patch on the entire series. Is this the kind of thing you had in mind?
> >> >
> >> > diff --git a/net/openvswitch/flow.c b/net/openvswitch/flow.c
> >> > index 86f2cfb19de3..42587d5bf894 100644
> >> > --- a/net/openvswitch/flow.c
> >> > +++ b/net/openvswitch/flow.c
> >> > @@ -729,7 +729,7 @@ int ovs_flow_key_extract(const struct ip_tunnel_info *tun_info,
> >> >         key->phy.skb_mark = skb->mark;
> >> >         ovs_ct_fill_key(skb, key);
> >> >         key->ovs_flow_hash = 0;
> >> > -       key->phy.is_layer3 = skb->mac_len == 0;
> >> > +       key->phy.is_layer3 = skb_mac_header_was_set(skb) == 0;
> >> >         key->recirc_id = 0;
> >> >
> >> >         err = key_extract(skb, key);
> >> > diff --git a/net/openvswitch/vport-internal_dev.c b/net/openvswitch/vport-internal_dev.c
> >> > index 484ba529c682..8973d4db509b 100644
> >> > --- a/net/openvswitch/vport-internal_dev.c
> >> > +++ b/net/openvswitch/vport-internal_dev.c
> >> > @@ -50,7 +50,6 @@ static int internal_dev_xmit(struct sk_buff *skb, struct net_device *netdev)
> >> >
> >> >         skb->protocol = eth_type_trans(skb, netdev);
> >> >         skb_push(skb, ETH_HLEN);
> >> > -       skb_reset_mac_len(skb);
> >> >
> >> >         len = skb->len;
> >> >         rcu_read_lock();
> >> > diff --git a/net/openvswitch/vport-netdev.c b/net/openvswitch/vport-netdev.c
> >> > index 3df36df62ee9..4cf3f12ffc99 100644
> >> > --- a/net/openvswitch/vport-netdev.c
> >> > +++ b/net/openvswitch/vport-netdev.c
> >> > @@ -60,22 +60,9 @@ static void netdev_port_receive(struct sk_buff *skb)
> >> >         if (vport->dev->type == ARPHRD_ETHER) {
> >> >                 skb_push(skb, ETH_HLEN);
> >> >                 skb_postpush_rcsum(skb, skb->data, ETH_HLEN);
> >> > -       } else if (vport->dev->type == ARPHRD_NONE) {
> >> > -               if (skb->protocol == htons(ETH_P_TEB)) {
> >> > -                       __be16 eth_type;
> >> > -
> >> > -                       if (unlikely(skb->len < ETH_HLEN))
> >> > -                               goto error;
> >> > -
> >> > -                       eth_type = eth_type_trans(skb, skb->dev);
> >> > -                       skb->mac_len = skb->data - skb_mac_header(skb);
> >> > -                       __skb_push(skb, skb->mac_len);
> >> > -
> >> > -                       if (eth_type == htons(ETH_P_8021Q))
> >> > -                               skb->mac_len += VLAN_HLEN;
> >> > -               } else {
> >> > -                       skb->mac_len = 0;
> >> > -               }
> >> > +       } else if (vport->dev->type == ARPHRD_NONE &&
> >> > +                  skb->protocol != htons(ETH_P_TEB)) {
> >> > +               skb->mac_header = (typeof(skb->mac_header))~0U;
> >> >         }
> >> >
> >> >         ovs_vport_receive(vport, skb, skb_tunnel_info(skb));
> >>
> >> This certainly looks better. I was wondering if we can unset the mac
> >> header offset in L3 tunnel devices itself. So there is no need to have
> >> this check here.
> >
> > I think that might be possible for GRE by modifying the following in
> > __ipgre_rcv().
> >
> >                 if (tunnel->dev->type != ARPHRD_NONE)
> >                         skb_pop_mac_header(skb);
> >                 else
> >                         skb_reset_mac_header(skb);
> >
> > But I am unsure what side effects this might have on other users of the
> > code.
> >
> I think it is fine with device of type ARPHRD_NONE. metadata tunnel
> devices would be of this type anyways.
> 
> > Jiri, do you have any thoughts on this?

I think you are right as IIRC the call to skb_reset_mac_header was
added for this use-case. Its unfortunate that we can't use it in
internal_dev_xmit() because of loosing track of MPLS as you mentioned
earlier. But it does seem that setting mac_header to ~0 works well
in conjunction with updates to OvS posted earlier in this sub-therad.

I have the following working. Jiri, is the ip_gre portion acceptable to you?


diff --git a/net/ipv4/ip_gre.c b/net/ipv4/ip_gre.c
index 58d323289872..e6772b6934a3 100644
--- a/net/ipv4/ip_gre.c
+++ b/net/ipv4/ip_gre.c
@@ -279,7 +279,7 @@ static int __ipgre_rcv(struct sk_buff *skb, const struct tnl_ptk_info *tpi,
 		if (tunnel->dev->type != ARPHRD_NONE)
 			skb_pop_mac_header(skb);
 		else
-			skb_reset_mac_header(skb);
+			skb->mac_header = (typeof(skb->mac_header))~0U;
 		if (tunnel->collect_md) {
 			__be16 flags;
 			__be64 tun_id;
diff --git a/net/openvswitch/vport-netdev.c b/net/openvswitch/vport-netdev.c
index 4cf3f12ffc99..82b10802abe6 100644
--- a/net/openvswitch/vport-netdev.c
+++ b/net/openvswitch/vport-netdev.c
@@ -60,9 +60,6 @@ static void netdev_port_receive(struct sk_buff *skb)
 	if (vport->dev->type == ARPHRD_ETHER) {
 		skb_push(skb, ETH_HLEN);
 		skb_postpush_rcsum(skb, skb->data, ETH_HLEN);
-	} else if (vport->dev->type == ARPHRD_NONE &&
-		   skb->protocol != htons(ETH_P_TEB)) {
-		skb->mac_header = (typeof(skb->mac_header))~0U;
 	}
 
 	ovs_vport_receive(vport, skb, skb_tunnel_info(skb));
