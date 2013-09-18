From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCH v2.39 7/7] datapath: Add basic MPLS support to kernel
Date: Wed, 18 Sep 2013 17:07:59 -0500
Message-ID: <20130918220756.GA24919@verge.net.au>
References: <1378711207-29890-1-git-send-email-horms@verge.net.au>
 <1378711207-29890-8-git-send-email-horms@verge.net.au>
 <CALnjE+p9g+GO71yjcNVG+y9ZzvT_==SLSqAAqGHU_jg=sx7Ynw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "dev@openvswitch.org" <dev@openvswitch.org>,
	netdev <netdev@vger.kernel.org>, Ravi K <rkerur@gmail.com>,
	Isaku Yamahata <yamahata@valinux.co.jp>,
	Jesse Gross <jesse@nicira.com>, Joe Stringer <joe@wand.net.nz>
To: Pravin Shelar <pshelar@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kirsty.vergenet.net ([202.4.237.240]:52718 "EHLO
	kirsty.vergenet.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753226Ab3IRWIa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Sep 2013 18:08:30 -0400
Content-Disposition: inline
In-Reply-To: <CALnjE+p9g+GO71yjcNVG+y9ZzvT_==SLSqAAqGHU_jg=sx7Ynw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Sep 17, 2013 at 11:38:18AM -0700, Pravin Shelar wrote:
> On Mon, Sep 9, 2013 at 12:20 AM, Simon Horman <horms@verge.net.au> wrote:
> > Allow datapath to recognize and extract MPLS labels into flow keys
> > and execute actions which push, pop, and set labels on packets.
> >
> > Based heavily on work by Leo Alterman, Ravi K, Isaku Yamahata and Joe Stringer.
> >
> > Cc: Ravi K <rkerur@gmail.com>
> > Cc: Leo Alterman <lalterman@nicira.com>
> > Cc: Isaku Yamahata <yamahata@valinux.co.jp>
> > Cc: Joe Stringer <joe@wand.net.nz>
> > Signed-off-by: Simon Horman <horms@verge.net.au>
> >
> > ---
> ....
> > diff --git a/datapath/datapath.h b/datapath/datapath.h
> > index 5d50dd4..babae3b 100644
> > --- a/datapath/datapath.h
> > +++ b/datapath/datapath.h
> > @@ -36,6 +36,10 @@
> >
> >  #define SAMPLE_ACTION_DEPTH 3
> >
> > +#if LINUX_VERSION_CODE >= KERNEL_VERSION(3,11,0)
> > +#define HAVE_INNER_PROTOCOL
> > +#endif
> > +
> >  /**
> >   * struct dp_stats_percpu - per-cpu packet processing statistics for a given
> >   * datapath.
> > @@ -93,11 +97,16 @@ struct datapath {
> >   * @pkt_key: The flow information extracted from the packet.  Must be nonnull.
> >   * @tun_key: Key for the tunnel that encapsulated this packet. NULL if the
> >   * packet is not being tunneled.
> > + * @inner_protocol: Provides a substitute for the skb->inner_protocol field on
> > + * kernels before 3.11.
> >   */
> >  struct ovs_skb_cb {
> >         struct sw_flow          *flow;
> >         struct sw_flow_key      *pkt_key;
> >         struct ovs_key_ipv4_tunnel  *tun_key;
> > +#ifndef HAVE_INNER_PROTOCOL
> > +       __be16                  inner_protocol;
> > +#endif
> >  };
> >  #define OVS_CB(skb) ((struct ovs_skb_cb *)(skb)->cb)
> >
> Can you move this to compat struct ovs_gso_cb {}

I think that you are correct and inner_protocol needs
to be in struct ovs_gso_cb so that it can
be accessed via skb_network_protocol() from
rpl___skb_gso_segment().

However I think it may also need to be present in struct ovs_cb
so that it can be set correctly.

Currently it is set unconditionally
in ovs_execute_actions() and Jesse has suggested setting
it conditionally in pop_mpls() (which is called by do_execute_actions()).
But regardless it seems to me that the field would need to be available
in struct ovs_cb.

> 
> ....
> >
> > +struct sk_buff *rpl___skb_gso_segment(struct sk_buff *skb,
> > +                                     netdev_features_t features,
> > +                                     bool tx_path)
> > +{
> > +       struct sk_buff *skb_gso;
> > +       __be16 type = skb->protocol;
> > +
> > +       skb->protocol = skb_network_protocol(skb);
> > +
> > +       /* this hack needed to get regular skb_gso_segment() */
> > +#ifdef HAVE___SKB_GSO_SEGMENT
> > +#undef __skb_gso_segment
> > +       skb_gso = __skb_gso_segment(skb, features, tx_path);
> > +#else
> > +#undef skb_gso_segment
> > +       skb_gso = skb_gso_segment(skb, features);
> > +#endif
> > +
> > +       if (!skb_gso || IS_ERR(skb_gso))
> > +           return skb_gso;
> > +
> > +       skb = skb_gso;
> > +       while (skb) {
> > +               skb->protocol = type;
> > +               skb = skb->next;
> > +       }
> > +
> 
> Protocol set is required if there is MPLS header, which is rare case.
> So I think we can skip this loop if there is no mpls.

I'm not sure I see the benefit but I do agree with your analysis and
I'll make it so.

> 
> > +       return skb_gso;
> > +}
> > +
> > +struct sk_buff *rpl_skb_gso_segment(struct sk_buff *skb,
> .....
> > +
> > +       if (vlan_tx_tag_present(skb) && !dev_supports_vlan_tx(skb->dev))
> > +               vlan = true;
> > +
> > +       if (vlan || mpls) {
> > +               netdev_features_t features;
> >
> >                 features = netif_skb_features(skb);
> >
> > @@ -296,6 +309,20 @@ static int netdev_send(struct vport *vport, struct sk_buff *skb)
> >                         features &= ~(NETIF_F_TSO | NETIF_F_TSO6 |
> >                                       NETIF_F_UFO | NETIF_F_FSO);
> >
> > +               /* As of v3.11 the kernel provides an mpls_features field in
> > +                * struct net_device which allows devices to advertise which
> > +                * features its supports for MPLS. This value defaults to
> > +                * NETIF_F_SG and as of v3.11.
> > +                *
> > +                * This compatibility code is intended for kernels older
> > +                * than v3.11 that do not support MPLS GSO and thus do not
> > +                * provide mpls_features. Thus this code uses NETIF_F_SG
> > +                * directly in place of mpls_features.
> > +                */
> > +
> > +               if (mpls)
> > +                       features &= NETIF_F_SG;
> > +
> >                 if (netif_needs_gso(skb, features)) {
> >                         struct sk_buff *nskb;
> >
> > @@ -319,10 +346,12 @@ static int netdev_send(struct vport *vport, struct sk_buff *skb)
> >                                 nskb = skb->next;
> >                                 skb->next = NULL;
> >
> > -                               skb = __vlan_put_tag(skb, skb->vlan_proto, vlan_tx_tag_get(skb));
> > +                               if (vlan)
> > +                                       skb = __vlan_put_tag(skb, skb->vlan_proto, vlan_tx_tag_get(skb));
> >                                 if (likely(skb)) {
> >                                         len += skb->len;
> > -                                       vlan_set_tci(skb, 0);
> > +                                       if (vlan)
> > +                                               vlan_set_tci(skb, 0);
> >                                         dev_queue_xmit(skb);
> >                                 }
> >
> > @@ -333,10 +362,12 @@ static int netdev_send(struct vport *vport, struct sk_buff *skb)
> >                 }
> >
> >  tag:
> > -               skb = __vlan_put_tag(skb, skb->vlan_proto, vlan_tx_tag_get(skb));
> > -               if (unlikely(!skb))
> > -                       return 0;
> > -               vlan_set_tci(skb, 0);
> > +               if (vlan) {
> > +                       skb = __vlan_put_tag(skb, skb->vlan_proto, vlan_tx_tag_get(skb));
> > +                       if (unlikely(!skb))
> > +                               return 0;
> > +                       vlan_set_tci(skb, 0);
> > +               }
> >         }
> >
> I think we can simplify code by pushing vlan and then segmenting skb,
> the way we do it for MPLS.

Are you thinking of something like the following which applies
prior to the MPLS code.


[RFC] datapath: simplify VLAN segmentation

*** Do not apply: for informational purposes only

Push vlan tag onto packet before segmentation to simplify the code.
As suggested by Pravin Shelar.

Compile tested only.

Signed-off-by: Simon Horman <horms@verge.net.au>
---
 datapath/vport-netdev.c | 24 +++++++++---------------
 1 file changed, 9 insertions(+), 15 deletions(-)

diff --git a/datapath/vport-netdev.c b/datapath/vport-netdev.c
index 215a47e..31680fd 100644
--- a/datapath/vport-netdev.c
+++ b/datapath/vport-netdev.c
@@ -296,6 +296,11 @@ static int netdev_send(struct vport *vport, struct sk_buff *skb)
 			features &= ~(NETIF_F_TSO | NETIF_F_TSO6 |
 				      NETIF_F_UFO | NETIF_F_FSO);
 
+		skb = __vlan_put_tag(skb, skb->vlan_proto, vlan_tx_tag_get(skb));
+		if (unlikely(!skb))
+			return 0;
+		vlan_set_tci(skb, 0);
+
 		if (netif_needs_gso(skb, features)) {
 			struct sk_buff *nskb;
 
@@ -306,7 +311,7 @@ static int netdev_send(struct vport *vport, struct sk_buff *skb)
 					goto drop;
 
 				skb_shinfo(skb)->gso_type &= ~SKB_GSO_DODGY;
-				goto tag;
+				goto xmit;
 			}
 
 			if (IS_ERR(nskb))
@@ -318,27 +323,16 @@ static int netdev_send(struct vport *vport, struct sk_buff *skb)
 			do {
 				nskb = skb->next;
 				skb->next = NULL;
-
-				skb = __vlan_put_tag(skb, skb->vlan_proto, vlan_tx_tag_get(skb));
-				if (likely(skb)) {
-					len += skb->len;
-					vlan_set_tci(skb, 0);
-					dev_queue_xmit(skb);
-				}
-
+				len += skb->len;
+				dev_queue_xmit(skb);
 				skb = nskb;
 			} while (skb);
 
 			return len;
 		}
-
-tag:
-		skb = __vlan_put_tag(skb, skb->vlan_proto, vlan_tx_tag_get(skb));
-		if (unlikely(!skb))
-			return 0;
-		vlan_set_tci(skb, 0);
 	}
 
+xmit:
 	len = skb->len;
 	dev_queue_xmit(skb);
 
-- 
1.8.4
