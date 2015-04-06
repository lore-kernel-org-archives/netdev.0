From: Dan Williams <dcbw@redhat.com>
Subject: Re: [PATCH] ipvlan: fix up broadcast MAC filtering for ARP and DHCP
Date: Mon, 06 Apr 2015 12:17:18 -0500
Message-ID: <1428340638.16890.15.camel@redhat.com>
References: <1427409698.18540.11.camel@redhat.com>
	 <CAF2d9jjF20puZvoAD502rAzYAaraRtpZZRK-=vcZGu-Uv4wZMA@mail.gmail.com>
	 <1427749308.1913.28.camel@redhat.com>
	 <CAF2d9jipTV4f4NOgGRY-kGOyRBe5HAH6T-mj4G9FYnc7oyc+NA@mail.gmail.com>
	 <1427771158.1913.35.camel@redhat.com> <1427775770.30696.3.camel@redhat.com>
	 <CAF2d9jikrJU0k3sS=awZQN+SD46qnN4r0bubjXZiY7K9vQieEQ@mail.gmail.com>
	 <1427921700.6874.8.camel@redhat.com>
	 <CAF2d9jgqJBfWVnX1mye5xMfYznA_NFte3dEEKG5CyogXTM73Rw@mail.gmail.com>
	 <1427985636.5282.9.camel@redhat.com>
	 <CAF2d9jjBtSptfmFY2BDF7ULNxAz=WtUVpNz0iExyd-h+v+4GSQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: linux-netdev <netdev@vger.kernel.org>, jbenc@redhat.com
To: Mahesh Bandewar <maheshb@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:35282 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750796AbbDFRQo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 6 Apr 2015 13:16:44 -0400
In-Reply-To: <CAF2d9jjBtSptfmFY2BDF7ULNxAz=WtUVpNz0iExyd-h+v+4GSQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2015-04-02 at 18:39 -0700, Mahesh Bandewar wrote:
> On Thu, Apr 2, 2015 at 7:40 AM, Dan Williams <dcbw@redhat.com> wrote:
> > On Wed, 2015-04-01 at 18:30 -0700, Mahesh Bandewar wrote:
> >> On Wed, Apr 1, 2015 at 1:55 PM, Dan Williams <dcbw@redhat.com> wrote:
> >> > On Wed, 2015-04-01 at 13:24 -0700, Mahesh Bandewar wrote:
> >> >> On Mon, Mar 30, 2015 at 9:22 PM, Dan Williams <dcbw@redhat.com> wrote:
> >> >> > The broadcast MAC is supposed to be allowed whenever the device
> >> >> > has an IPv4 address, otherwise ARP requests get dropped on the
> >> >> > floor.  If ndo_set_rx_mode (and thus
> >> >> > ipvlan_set_multicast_mac_filter()) got called after the address
> >> >> > was added, it would blow away the broadcast MAC address in
> >> >> > mac_filters that was added at IPv4 address addition.
> >> >> >
> >> >> > Next, ipvlan currently fails DHCP addressing for two reasons:
> >> >> >
> >> >> I would prefer DHCPv4 instead of DHCP since it could also mean DHCPv6
> >> >> which does not use broadcast.
> >> >>
> >> >> > 1) DHCP offers are typically unicast back to the device's MAC
> >> >> > address, and at the IP layer have a destination IP address
> >> >> > matching the new lease address.  In ipvlan unicast packets
> >> >> > are checked against existing addresses assigned to the ipvlan
> >> >> > interface, so clearly this fails hard because the ipvlan
> >> >> > interface has no IP addresses yet.  Workaround: request
> >> >> > that the server broadcast replies (-B for dhclient) which
> >> >> > don't get checked against the address list.
> >> >> >
> >> >> > 2) Even when that's done, mac_filters only allows the
> >> >> > broadcast MAC address when the interface has >= 1 IPv4
> >> >> > addresses, so double-fail, and the incoming DHCP offer
> >> >> > gets dropped on the floor again.
> >> >> >
> >> >> > To fix these issues, Watch for outgoing DHCP requests and
> >> >> > enable the broadcast MAC address indefinitely when one is seen.
> >> >> >
> >> >> This approach will work but adds a performance drag for all UDP
> >> >> traffic whether the link needs DHCPv4 or not (especially when it does
> >> >> not need). Logic works well only when the link (always) needs DHCPv4.
> >> >> When the link does not care about DHCPv4 the packet-inspection always
> >> >> happens.
> >> >
> >> > If DHCPv4 is detected on a link, doesn't that mean the link needs the
> >> > broadcast filter enabled?
> >> Yes and it should stay enabled as it's going to have IPv4. Also once
> >> broadcast bit is set there should not be any additional jugglery /
> >> packet inspection which hurts performance.
> >
> > Yes, which is why my patch includes the check for dhcp4_seen and skips
> > inspecting the packet.  I could modify it to skip the L3 header check
> > too in that case.
> >
> dhcp4_seen works correctly when there is dhcpv4 happening, but
> snooping continues if autoconf is not used.
> 
> >> > If you start DHCPv4 on the link you obviously
> >> > expect it to work, unless there's no DHCPv4 server available.  The patch
> >> > should also reset the broadcast filter on close, so network management
> >> > could simply start DHCPv4, watch it fail, close/open and set static IP.
> >> >
> >> > Alternatively we could have the broadcast filter on a 2 minute timer
> >> > that starts when DHCPv4 is seen.
> >> >
> >> Well, but this would be error-prone. I don't remember but DHCP timeout
> >> is not just 2 minutes.
> >
> > 2m is IIRC an RFC recommended timeout for initial DHCPv4 requests.  If
> > you don't get a reply to your requests within 2m, you aren't likely to
> > get one ever on this network and you can stop trying for a while.  You
> > either get a reply in which case you get an IPv4 address and broadcast
> > is always enabled, or you don't, in which case you don't really need
> > broadcast.  Then when userspace next tries DHCP, the timer would allow
> > broadcast for another 2 minutes.
> >
> >> >> Do we really need to special case DHCPv4? Do you see problems in
> >> >> inverting the current logic of adding broadcast bit (i.e. from
> >> >> enable-if-IPv4 to disable-if-IPv6-only)?
> >> >
> >> > The problem with this is dual-stack configuration.  Typically both
> >> > DHCPv4 and SLAAC are started in this case, and often SLAAC will complete
> >> > earlier.  So now the interface only has an IPv6 address but DHCPv4 is
> >> > still ongoing; as I understand your proposal the filter would now block
> >> > broadcast packets that DHCPv4 is listening for.
> >> >
> >> That was a proposal and we can tweak it if necessary. My primary
> >> concern is that the solution should not make us pay per packet penalty
> >> once (and even if not) the DHCPv4 handshake is complete, which is not
> >> the case as it stands now.
> >
> > I'm not sure what you mean by "not make us pay a per packet penalty once
> > DHCPv4 is complete".  Once an IPv4 address is assigned, the broadcast
> > filter must allow broadcast packets.  Before an IPv4 address is
> > assigned, the driver must watch for DHCPv4 and allow broadcast packets
> > so that the DHCP reply isn't missed.
> >
> If the link is not using DHCPv4 to configure, the snooping continues
> and that is per packet cost the needs to be paid. Probably this can be
> avoided by setting dhcp4_seen = true in add_addr4 handler.
> 
> > If DHCPv4 gets no response, then there are two options:
> >
> > a) down the interface (which resets the broadcast filter to block
> > broadcast packets) and re-up it, and don't do DHCPv4 again
> >
> > b) have a timer in the driver that waits a period of time for an IPv4
> > address after a DHCPv4 request, and blocks broadcast when the timer
> > expires
> >
> Probably something similar where turn on the broadcast bit and wait
> for the interface to get configured (2 min timer) and at the expiry
> decide what is to be done about braodcast bit. If the addresses
> configured are all IPv6, then eliminate it and if any of them are IPv4
> then don't change it. In this case no special casing nor snooping is
> required and this should work for dual-stack scenario as well.

This does not work for the case where, after configuring, the DHCPv4
address lease expires and the IPv4 address is removed, and then DHCPv4
is started again.  Possibly because the DHCP server was gone for a short
time.  The only way to handle that is to snoop again.

Reaching for maximum performance is great, but if that is done by
ignoring/breaking a whole class of normal use-cases, I don't think
that's reasonable.  It's like saying "gee, I'd love UDP to be faster, so
I'll remove anything TCP-related in the kernel".

Also, I don't think the snooping is as bad for performance as you may
think.  The only relevant issue here is L2 + IPv6-only, and in that case
it's 4 extra compares (dhcp4_seen, ipv4cnt, lyr3h, and addr_type) for
the external case.  How much is that really going to slow things down,
versus breaking a huge part of IPv4 address configuration?

Dan

> > Dan
> >
> >> > Dan
> >> >
> >> >> > Signed-off-by: Dan Williams <dcbw@redhat.com>
> >> >> > ---
> >> >> > NOTE: this patch supercedes my previous two ipvlan patches:
> >> >> > [PATCH 1/2] ipvlan: don't loose broadcast MAC when setting MAC filters
> >> >> > [PATCH 2/2] ipvlan: always allow the broadcast MAC address
> >> >> >
> >> >> >  drivers/net/ipvlan/ipvlan.h      |  2 ++
> >> >> >  drivers/net/ipvlan/ipvlan_core.c | 36 ++++++++++++++++++++++++++++++++++--
> >> >> >  drivers/net/ipvlan/ipvlan_main.c | 12 +++++++++---
> >> >> >  3 files changed, 45 insertions(+), 5 deletions(-)
> >> >> >
> >> >> > diff --git a/drivers/net/ipvlan/ipvlan.h b/drivers/net/ipvlan/ipvlan.h
> >> >> > index 924ea98..7e0b8ff 100644
> >> >> > --- a/drivers/net/ipvlan/ipvlan.h
> >> >> > +++ b/drivers/net/ipvlan/ipvlan.h
> >> >> > @@ -67,6 +67,7 @@ struct ipvl_dev {
> >> >> >         struct list_head        addrs;
> >> >> >         int                     ipv4cnt;
> >> >> >         int                     ipv6cnt;
> >> >> > +       bool                    dhcp4_seen;
> >> >> >         struct ipvl_pcpu_stats  __percpu *pcpu_stats;
> >> >> >         DECLARE_BITMAP(mac_filters, IPVLAN_MAC_FILTER_SIZE);
> >> >> >         netdev_features_t       sfeatures;
> >> >> > @@ -118,4 +119,5 @@ bool ipvlan_addr_busy(struct ipvl_dev *ipvlan, void *iaddr, bool is_v6);
> >> >> >  struct ipvl_addr *ipvlan_ht_addr_lookup(const struct ipvl_port *port,
> >> >> >                                         const void *iaddr, bool is_v6);
> >> >> >  void ipvlan_ht_addr_del(struct ipvl_addr *addr, bool sync);
> >> >> > +void ipvlan_set_broadcast_mac_filter(struct ipvl_dev *ipvlan, bool set);
> >> >> >  #endif /* __IPVLAN_H */
> >> >> > diff --git a/drivers/net/ipvlan/ipvlan_core.c b/drivers/net/ipvlan/ipvlan_core.c
> >> >> > index 2a17500..6dd992b 100644
> >> >> > --- a/drivers/net/ipvlan/ipvlan_core.c
> >> >> > +++ b/drivers/net/ipvlan/ipvlan_core.c
> >> >> > @@ -126,6 +126,12 @@ static void *ipvlan_get_L3_hdr(struct sk_buff *skb, int *type)
> >> >> >                 lyr3h = arph;
> >> >> >                 break;
> >> >> >         }
> >> >> > +       case htons(ETH_P_ALL): {
> >> >> > +               /* Raw sockets */
> >> >> > +               if (eth_hdr(skb)->h_proto != htons(ETH_P_IP))
> >> >> > +                       break;
> >> >> > +               /* Fall through */
> >> >> > +       }
> >> >> >         case htons(ETH_P_IP): {
> >> >> >                 u32 pktlen;
> >> >> >                 struct iphdr *ip4h;
> >> >> > @@ -454,16 +460,42 @@ out:
> >> >> >         return ipvlan_process_outbound(skb, ipvlan);
> >> >> >  }
> >> >> >
> >> >> > +#define DHCP_PACKET_MIN_LEN 282
> >> >> > +
> >> >> > +static bool is_dhcp(struct sk_buff *skb)
> >> >> > +{
> >> >> > +       struct iphdr *ip4h = ip_hdr(skb);
> >> >> > +       struct udphdr *udph;
> >> >> > +
> >> >> > +       if (skb->len < DHCP_PACKET_MIN_LEN || ip4h->protocol != IPPROTO_UDP
> >> >> > +               || ip_is_fragment(ip4h))
> >> >> > +               return false;
> >> >> > +
> >> >> > +       /* In the case of RAW sockets the transport header is not set by
> >> >> > +        * the IP stack so we must set it ourselves.
> >> >> > +        */
> >> >> > +       if (skb->transport_header == skb->network_header)
> >> >> > +               skb_set_transport_header(skb, ETH_HLEN + sizeof(struct iphdr));
> >> >> > +       udph = udp_hdr(skb);
> >> >> > +       return udph && udph->dest == htons(67) && udph->source == htons(68);
> >> >> > +}
> >> >> > +
> >> >> >  static int ipvlan_xmit_mode_l2(struct sk_buff *skb, struct net_device *dev)
> >> >> >  {
> >> >> > -       const struct ipvl_dev *ipvlan = netdev_priv(dev);
> >> >> > +       struct ipvl_dev *ipvlan = netdev_priv(dev);
> >> >> >         struct ethhdr *eth = eth_hdr(skb);
> >> >> >         struct ipvl_addr *addr;
> >> >> >         void *lyr3h;
> >> >> >         int addr_type;
> >> >> >
> >> >> > +       lyr3h = ipvlan_get_L3_hdr(skb, &addr_type);
> >> >> > +       if (!ipvlan->dhcp4_seen && lyr3h && addr_type == IPVL_IPV4
> >> >> > +           && is_dhcp(skb)) {
> >> >> > +               ipvlan->dhcp4_seen = true;
> >> >> > +               ipvlan_set_broadcast_mac_filter(ipvlan, true);
> >> >> > +       }
> >> >> > +
> >> >> >         if (ether_addr_equal(eth->h_dest, eth->h_source)) {
> >> >> > -               lyr3h = ipvlan_get_L3_hdr(skb, &addr_type);
> >> >> >                 if (lyr3h) {
> >> >> >                         addr = ipvlan_addr_lookup(ipvlan->port, lyr3h, addr_type, true);
> >> >> >                         if (addr)
> >> >> > diff --git a/drivers/net/ipvlan/ipvlan_main.c b/drivers/net/ipvlan/ipvlan_main.c
> >> >> > index 4f4099d..a497fb9 100644
> >> >> > --- a/drivers/net/ipvlan/ipvlan_main.c
> >> >> > +++ b/drivers/net/ipvlan/ipvlan_main.c
> >> >> > @@ -167,6 +167,8 @@ static int ipvlan_stop(struct net_device *dev)
> >> >> >
> >> >> >         dev_uc_del(phy_dev, phy_dev->dev_addr);
> >> >> >
> >> >> > +       ipvlan->dhcp4_seen = false;
> >> >> > +
> >> >> >         if (ipvlan->ipv6cnt > 0 || ipvlan->ipv4cnt > 0) {
> >> >> >                 list_for_each_entry(addr, &ipvlan->addrs, anode)
> >> >> >                         ipvlan_ht_addr_del(addr, !dev->dismantle);
> >> >> > @@ -214,7 +216,7 @@ static void ipvlan_change_rx_flags(struct net_device *dev, int change)
> >> >> >                 dev_set_allmulti(phy_dev, dev->flags & IFF_ALLMULTI? 1 : -1);
> >> >> >  }
> >> >> >
> >> >> > -static void ipvlan_set_broadcast_mac_filter(struct ipvl_dev *ipvlan, bool set)
> >> >> > +void ipvlan_set_broadcast_mac_filter(struct ipvl_dev *ipvlan, bool set)
> >> >> >  {
> >> >> >         struct net_device *dev = ipvlan->dev;
> >> >> >         unsigned int hashbit = ipvlan_mac_hash(dev->broadcast);
> >> >> > @@ -239,6 +241,9 @@ static void ipvlan_set_multicast_mac_filter(struct net_device *dev)
> >> >> >                 netdev_for_each_mc_addr(ha, dev)
> >> >> >                         __set_bit(ipvlan_mac_hash(ha->addr), mc_filters);
> >> >> >
> >> >> > +               if (ipvlan->ipv4cnt || ipvlan->dhcp4_seen)
> >> >> > +                       __set_bit(ipvlan_mac_hash(dev->broadcast), mc_filters);
> >> >> > +
> >> >> >                 bitmap_copy(ipvlan->mac_filters, mc_filters,
> >> >> >                             IPVLAN_MAC_FILTER_SIZE);
> >> >> >         }
> >> >> > @@ -467,6 +472,7 @@ static int ipvlan_link_new(struct net *src_net, struct net_device *dev,
> >> >> >         INIT_LIST_HEAD(&ipvlan->addrs);
> >> >> >         ipvlan->ipv4cnt = 0;
> >> >> >         ipvlan->ipv6cnt = 0;
> >> >> > +       ipvlan->dhcp4_seen = false;
> >> >> >
> >> >> >         /* TODO Probably put random address here to be presented to the
> >> >> >          * world but keep using the physical-dev address for the outgoing
> >> >> > @@ -708,8 +714,8 @@ static void ipvlan_del_addr4(struct ipvl_dev *ipvlan, struct in_addr *ip4_addr)
> >> >> >         list_del_rcu(&addr->anode);
> >> >> >         ipvlan->ipv4cnt--;
> >> >> >         WARN_ON(ipvlan->ipv4cnt < 0);
> >> >> > -       if (!ipvlan->ipv4cnt)
> >> >> > -           ipvlan_set_broadcast_mac_filter(ipvlan, false);
> >> >> > +       if (!ipvlan->ipv4cnt && !ipvlan->dhcp4_seen)
> >> >> > +               ipvlan_set_broadcast_mac_filter(ipvlan, false);
> >> >> >         kfree_rcu(addr, rcu);
> >> >> >
> >> >> >         return;
> >> >> > --
> >> >> > 2.1.0
> >> >> >
> >> >> >
> >> >> --
> >> >> To unsubscribe from this list: send the line "unsubscribe netdev" in
> >> >> the body of a message to majordomo@vger.kernel.org
> >> >> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> >> >
> >> >
> >> --
> >> To unsubscribe from this list: send the line "unsubscribe netdev" in
> >> the body of a message to majordomo@vger.kernel.org
> >> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> >
> >
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
