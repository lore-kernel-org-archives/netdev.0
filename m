From: Simon Horman <simon.horman@netronome.com>
Subject: Re: [ovs-dev] [PATCH net-next v11 5/6] openvswitch: add layer 3
 flow/port support
Date: Mon, 18 Jul 2016 13:50:27 +0900
Message-ID: <20160718045025.GA2490@penelope.isobedori.kobe.vergenet.net>
References: <1467827996-32547-1-git-send-email-simon.horman@netronome.com>
 <1467827996-32547-6-git-send-email-simon.horman@netronome.com>
 <CAOrHB_BYD40ZkWbU0dvhPOCcaCVgooksOUkejxyFoagyoiBTNw@mail.gmail.com>
 <20160713073152.GC29661@penelope.isobedori.kobe.vergenet.net>
 <CAOrHB_A1ri6fouFH0H4KpEqg1icCmz+U1tcgn-5BoryX5pb1gw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
	ovs dev <dev@openvswitch.org>, Jiri Benc <jbenc@redhat.com>
To: pravin shelar <pshelar@ovn.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f182.google.com ([209.85.192.182]:36308 "EHLO
	mail-pf0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750837AbcGREud (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Jul 2016 00:50:33 -0400
Received: by mail-pf0-f182.google.com with SMTP id h186so8367123pfg.3
        for <netdev@vger.kernel.org>; Sun, 17 Jul 2016 21:50:33 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <CAOrHB_A1ri6fouFH0H4KpEqg1icCmz+U1tcgn-5BoryX5pb1gw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[CC Jiri Benc for portion regarding GRE]

Hi Pravin,

On Fri, Jul 15, 2016 at 02:07:37PM -0700, pravin shelar wrote:
> On Wed, Jul 13, 2016 at 12:31 AM, Simon Horman
> <simon.horman@netronome.com> wrote:
> > Hi Pravin,
> >
> > On Thu, Jul 07, 2016 at 01:54:15PM -0700, pravin shelar wrote:
> >> On Wed, Jul 6, 2016 at 10:59 AM, Simon Horman
> >> <simon.horman@netronome.com> wrote:
> >
> > ...
> 
> >
> >> > diff --git a/net/openvswitch/flow.c b/net/openvswitch/flow.c
> >> > index 0ea128eeeab2..86f2cfb19de3 100644
> >> > --- a/net/openvswitch/flow.c
> >> > +++ b/net/openvswitch/flow.c
> >> ...
> >>
> >> > @@ -723,9 +729,17 @@ int ovs_flow_key_extract(const struct ip_tunnel_info *tun_info,
> >> >         key->phy.skb_mark = skb->mark;
> >> >         ovs_ct_fill_key(skb, key);
> >> >         key->ovs_flow_hash = 0;
> >> > +       key->phy.is_layer3 = skb->mac_len == 0;
> >>
> >> I do not think mac_len can be used. mac_header needs to be checked.
> >> ...
> >
> > Yes, indeed. The update to use skb_mac_header_was_set() here accidently
> > slipped into the following patch, sorry about that.
> >
> > With that change in place I believe that this patch is internally
> > consistent because mac_header and mac_len are set correctly by the
> > call to key_extract() which is called by ovs_flow_key_extract() just
> > after where the excerpt above ends.
> >
> > That said, I do think that it is possible to rely on skb_mac_header_was_set
> > throughout the datapath, including action processing etc... I have provided
> > an incremental patch - which I created on top of this entire series - at
> > the end of this email. If you prefer that approach I am happy to take it,
> > though I do feel that using mac_len leads to slightly cleaner code. Let me
> > know what you think.
> >
> 
> 
> I am not sure if you can use only mac_len to detect L3 packet. This
> does not work with MPLS packets, mac_len is used to account MPLS
> headers pushed on skb. Therefore in case of a MPLS header on L3
> packet, mac_len would be non zero and we have to look at either
> mac_header or some other metadata like is_layer3 flag from key to
> check for L3 packet.

At least within OvS mac_len does not include the length of the MPLS label
stack. Rather, the MPLS label stack length is the difference between the
end of (mac_header + mac_len) and network_header.

So I think that the scheme does work as mac_len is 0 if there is no L2
header regardless of if an MPLS label stack is present or not.

> >> > diff --git a/net/openvswitch/vport-netdev.c b/net/openvswitch/vport-netdev.c
> >> > index 4e3972344aa6..733e7914f6bd 100644
> >> > --- a/net/openvswitch/vport-netdev.c
> >> > +++ b/net/openvswitch/vport-netdev.c
> >> > @@ -57,8 +57,10 @@ static void netdev_port_receive(struct sk_buff *skb)
> >> >         if (unlikely(!skb))
> >> >                 return;
> >> >
> >> > -       skb_push(skb, ETH_HLEN);
> >> > -       skb_postpush_rcsum(skb, skb->data, ETH_HLEN);
> >> > +       if (vport->dev->type == ARPHRD_ETHER) {
> >> > +               skb_push(skb, ETH_HLEN);
> >> > +               skb_postpush_rcsum(skb, skb->data, ETH_HLEN);
> >> > +       }
> >> This is still required for tunnel device of ARPHRD_NONE which can
> >> handle l2 packets.
> >
> > That is not necessary given the current implementation (of ipgre) as it
> > supplies an skb with the mac header in place if the inner packet was an
> > Ethernet packet. This scheme could of course be adjusted.
> >
> > ...
> >
> 
> I think we should send L2 header with l2 header pushed on skb. This is
> what OVS expect. The skb-push should be done for all l2 packets rather
> than for particular type of device.

The following seems to achieve that.
Jiri, what do you think?

diff --git a/net/ipv4/ip_gre.c b/net/ipv4/ip_gre.c
index a20248355da0..edbc10690b60 100644
--- a/net/ipv4/ip_gre.c
+++ b/net/ipv4/ip_gre.c
@@ -281,10 +281,9 @@ static int __ipgre_rcv(struct sk_buff *skb, const struct tnl_ptk_info *tpi,
 					   raw_proto, false) < 0)
 			goto drop;
 
-		if (tunnel->dev->type != ARPHRD_NONE)
+		if (tunnel->dev->type != ARPHRD_NONE ||
+		    tpi->proto == htons(ETH_P_TEB))
 			skb_pop_mac_header(skb);
-		else if (tpi->proto != htons(ETH_P_TEB))
-			skb_unset_mac_header(skb);
 		else
 			skb_reset_mac_header(skb);
 		if (tunnel->collect_md) {
@@ -326,7 +325,7 @@ static int ipgre_rcv(struct sk_buff *skb, const struct tnl_ptk_info *tpi,
 		 * also ETH_P_TEB traffic.
 		 */
 		itn = net_generic(net, ipgre_net_id);
-		res = __ipgre_rcv(skb, tpi, itn, hdr_len, true);
+		res = __ipgre_rcv(skb, tpi, itn, hdr_len, false);
 	}
 	return res;
 }
diff --git a/net/openvswitch/vport-netdev.c b/net/openvswitch/vport-netdev.c
index 05985209f611..933ac46db53a 100644
--- a/net/openvswitch/vport-netdev.c
+++ b/net/openvswitch/vport-netdev.c
@@ -57,7 +57,8 @@ static void netdev_port_receive(struct sk_buff *skb)
 	if (unlikely(!skb))
 		return;
 
-	if (vport->dev->type == ARPHRD_ETHER) {
+	if (vport->dev->type != ARPHRD_NONE ||
+	    skb->protocol == htons(ETH_P_TEB)) {
 		skb_push(skb, ETH_HLEN);
 		skb_postpush_rcsum(skb, skb->data, ETH_HLEN);
 	}

> > Update to use skb_mac_header_was_set() more as mentioned above.
> > Please let me know what you think about this approach.
> >
> >  include/net/mpls.h                   |    4 ++-
> >  net/openvswitch/actions.c            |   42 ++++++++++++++++++++---------------
> >  net/openvswitch/flow.c               |   23 +++++++++++--------
> >  net/openvswitch/vport-internal_dev.c |    2 -
> >  net/openvswitch/vport-netdev.c       |    4 +--
> >  5 files changed, 44 insertions(+), 31 deletions(-)
> >
> > diff --git a/include/net/mpls.h b/include/net/mpls.h
> > index 5b3b5addfb08..296b68661be0 100644
> > --- a/include/net/mpls.h
> > +++ b/include/net/mpls.h
> > @@ -34,6 +34,8 @@ static inline bool eth_p_mpls(__be16 eth_type)
> >   */
> >  static inline unsigned char *skb_mpls_header(struct sk_buff *skb)
> >  {
> > -       return skb_mac_header(skb) + skb->mac_len;
> > +       return skb_mac_header_was_set(skb) ?
> > +               skb_mac_header(skb) + skb->mac_len :
> > +               skb->data;
> >  }
> 
> This function is also called from GSO layer. issue is in GSO layer, it
> does reset mac header and mac length and then calls mpls-gso-handler.
> So all subsequent check for L3 packet fails.
> So far we have explored three different ways to detect L3 packet but
> each has its own issue.
> 1. skb mac header : GSO can reset mac header.
> 2. skb mac length : MPLS uses mac_len to account for MPLS header
> length along with L2 header
> 3. skb protocol: ETH_P_TEB is not set for all L2 frames, networking
> stack is not ready to handle this type for given skb.
> 
> So none of them works consistently. I think the only option to detect
> L3 packet reliably (and without adding field to skb) is to use
> skb-protocol along with ARPHRD_NONE device type. If ARPHRD_NONE type
> device generates L2 packet it needs to set protocol to ETH_P_TEB. Some
> networking stack function also needs to be fixed to handle this
> protocol type, e.g. vlan_get_protocol(), br_dev_queue_push_xmit(),
> etc.
