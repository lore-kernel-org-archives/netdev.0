From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCH v2.39 7/7] datapath: Add basic MPLS support to kernel
Date: Sun, 22 Sep 2013 14:38:00 +0900
Message-ID: <20130922053800.GA4890@verge.net.au>
References: <1378711207-29890-1-git-send-email-horms@verge.net.au>
 <1378711207-29890-8-git-send-email-horms@verge.net.au>
 <CALnjE+p9g+GO71yjcNVG+y9ZzvT_==SLSqAAqGHU_jg=sx7Ynw@mail.gmail.com>
 <20130918220756.GA24919@verge.net.au>
 <CAEP_g=8+osWcHjj6pkGkid6djK9=CDf4U4qC97bY=GP0j=K3iw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Pravin Shelar <pshelar@nicira.com>,
	"dev@openvswitch.org" <dev@openvswitch.org>,
	netdev <netdev@vger.kernel.org>, Ravi K <rkerur@gmail.com>,
	Isaku Yamahata <yamahata@valinux.co.jp>,
	Joe Stringer <joe@wand.net.nz>
To: Jesse Gross <jesse@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kirsty.vergenet.net ([202.4.237.240]:34924 "EHLO
	kirsty.vergenet.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752940Ab3IVLYH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 22 Sep 2013 07:24:07 -0400
Content-Disposition: inline
In-Reply-To: <CAEP_g=8+osWcHjj6pkGkid6djK9=CDf4U4qC97bY=GP0j=K3iw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Sep 19, 2013 at 12:31:51PM -0500, Jesse Gross wrote:
> On Wed, Sep 18, 2013 at 5:07 PM, Simon Horman <horms@verge.net.au> wrote:
> > On Tue, Sep 17, 2013 at 11:38:18AM -0700, Pravin Shelar wrote:
> >> On Mon, Sep 9, 2013 at 12:20 AM, Simon Horman <horms@verge.net.au> wrote:
> >> > diff --git a/datapath/datapath.h b/datapath/datapath.h
> >> > index 5d50dd4..babae3b 100644
> >> > --- a/datapath/datapath.h
> >> > +++ b/datapath/datapath.h
> >> > @@ -36,6 +36,10 @@
> >> >
> >> >  #define SAMPLE_ACTION_DEPTH 3
> >> >
> >> > +#if LINUX_VERSION_CODE >= KERNEL_VERSION(3,11,0)
> >> > +#define HAVE_INNER_PROTOCOL
> >> > +#endif
> >> > +
> >> >  /**
> >> >   * struct dp_stats_percpu - per-cpu packet processing statistics for a given
> >> >   * datapath.
> >> > @@ -93,11 +97,16 @@ struct datapath {
> >> >   * @pkt_key: The flow information extracted from the packet.  Must be nonnull.
> >> >   * @tun_key: Key for the tunnel that encapsulated this packet. NULL if the
> >> >   * packet is not being tunneled.
> >> > + * @inner_protocol: Provides a substitute for the skb->inner_protocol field on
> >> > + * kernels before 3.11.
> >> >   */
> >> >  struct ovs_skb_cb {
> >> >         struct sw_flow          *flow;
> >> >         struct sw_flow_key      *pkt_key;
> >> >         struct ovs_key_ipv4_tunnel  *tun_key;
> >> > +#ifndef HAVE_INNER_PROTOCOL
> >> > +       __be16                  inner_protocol;
> >> > +#endif
> >> >  };
> >> >  #define OVS_CB(skb) ((struct ovs_skb_cb *)(skb)->cb)
> >> >
> >> Can you move this to compat struct ovs_gso_cb {}
> >
> > I think that you are correct and inner_protocol needs
> > to be in struct ovs_gso_cb so that it can
> > be accessed via skb_network_protocol() from
> > rpl___skb_gso_segment().
> >
> > However I think it may also need to be present in struct ovs_cb
> > so that it can be set correctly.
> >
> > Currently it is set unconditionally
> > in ovs_execute_actions() and Jesse has suggested setting
> > it conditionally in pop_mpls() (which is called by do_execute_actions()).
> > But regardless it seems to me that the field would need to be available
> > in struct ovs_cb.
> 
> Since the helper functions are also in the compat code, I think they
> should have access to ovs_gso_cb.

Pravin also believes that is the case so I have moved inner_protocol
to struct ovs_gso_cb as he requested.

> >> I think we can simplify code by pushing vlan and then segmenting skb,
> >> the way we do it for MPLS.
> >
> > Are you thinking of something like the following which applies
> > prior to the MPLS code.
> 
> This is basically what I was thinking about. We might actually be able
> to move all of this to compat code by having a replacement for
> dev_queue_xmit() similar to what we have for ip_local_out() in the
> tunnel code.

I would appreciate Pravin's opinion on this but it seems to me
that it should be possible.

The following applies on top of my previous proposed change
in this thread - simplification of segmentation - and before
the MPLS patch-set. Is this along the lines of what you were
thinking of?


From: Simon Horman <horms@verge.net.au>

datapath: Move segmentation compatibility code into a compatibility function

*** Do not apply: for informational purposes only

Move segmentation compatibility code out of netdev_send and into
rpl_dev_queue_xmit(), a compatibility function used in place
of dev_queue_xmit() as necessary.

As suggested by Jesse Gross.

Some minor though verbose implementation notes:

* This rpl_dev_queue_xmit() endeavours to return a valid error code or
  zero on success as per dev_queue_xmit(). The exception is that when
  dev_queue_xmit() is called in a loop only the status of the last call is
  taken into account, thus ignoring any errors returned by previous calls.
  This is derived from the previous calls to dev_queue_xmit() in a loop
  where netdev_send() ignores the return value of dev_queue_xmit()
  entirely.

* netdev_send() continues to ignore the value of dev_queue_xmit().
  So the discussion of the return value of rpl_dev_queue_xmit()
  above is has no bearing on run-time behaviour.

* The return value of netdev_send() may differ from the previous
  implementation in the case where segmentation is performed before
  calling the real dev_queue_xmit(). This is because previously in
  this case netdev_send() would return the combined length of the
  skbs resulting from segmentation. Whereas the current code
  always returns the length of the original skb.

Compile tested only.

Signed-off-by: Simon Horman <horms@verge.net.au>
---
 datapath/linux/compat/gso.c | 80 +++++++++++++++++++++++++++++++++++++++++++++
 datapath/linux/compat/gso.h |  5 +++
 datapath/vport-netdev.c     | 78 ++-----------------------------------------
 3 files changed, 87 insertions(+), 76 deletions(-)

diff --git a/datapath/linux/compat/gso.c b/datapath/linux/compat/gso.c
index 30332a2..d7e92fb 100644
--- a/datapath/linux/compat/gso.c
+++ b/datapath/linux/compat/gso.c
@@ -36,6 +36,86 @@
 
 #include "gso.h"
 
+#if LINUX_VERSION_CODE < KERNEL_VERSION(2,6,37) && \
+	!defined(HAVE_VLAN_BUG_WORKAROUND)
+#include <linux/module.h>
+
+static int vlan_tso __read_mostly;
+module_param(vlan_tso, int, 0644);
+MODULE_PARM_DESC(vlan_tso, "Enable TSO for VLAN packets");
+#else
+#define vlan_tso true
+#endif
+
+#if LINUX_VERSION_CODE < KERNEL_VERSION(2,6,37)
+static bool dev_supports_vlan_tx(struct net_device *dev)
+{
+#if defined(HAVE_VLAN_BUG_WORKAROUND)
+	return dev->features & NETIF_F_HW_VLAN_TX;
+#else
+	/* Assume that the driver is buggy. */
+	return false;
+#endif
+}
+
+int rpl_dev_queue_xmit(struct sk_buff *skb)
+{
+#undef dev_queue_xmit
+	int err = -ENOMEM;
+
+	if (vlan_tx_tag_present(skb) && !dev_supports_vlan_tx(skb->dev)) {
+		int features;
+
+		features = netif_skb_features(skb);
+
+		if (!vlan_tso)
+			features &= ~(NETIF_F_TSO | NETIF_F_TSO6 |
+				      NETIF_F_UFO | NETIF_F_FSO);
+
+		skb = __vlan_put_tag(skb, skb->vlan_proto, vlan_tx_tag_get(skb));
+		if (unlikely(!skb))
+			return err;
+		vlan_set_tci(skb, 0);
+
+		if (netif_needs_gso(skb, features)) {
+			struct sk_buff *nskb;
+
+			nskb = skb_gso_segment(skb, features);
+			if (!nskb) {
+				if (unlikely(skb_cloned(skb) &&
+				    pskb_expand_head(skb, 0, 0, GFP_ATOMIC)))
+					goto drop;
+
+				skb_shinfo(skb)->gso_type &= ~SKB_GSO_DODGY;
+				goto xmit;
+			}
+
+			if (IS_ERR(nskb)) {
+				err = PTR_ERR(nskb);
+				goto drop;
+			}
+			consume_skb(skb);
+			skb = nskb;
+
+			do {
+				nskb = skb->next;
+				skb->next = NULL;
+				err = dev_queue_xmit(skb);
+				skb = nskb;
+			} while (skb);
+
+			return err;
+		}
+	}
+xmit:
+	return dev_queue_xmit(skb);
+
+drop:
+	kfree_skb(skb);
+	return err;
+}
+#endif /* kernel version < 3.6.37 */
+
 static __be16 __skb_network_protocol(struct sk_buff *skb)
 {
 	__be16 type = skb->protocol;
diff --git a/datapath/linux/compat/gso.h b/datapath/linux/compat/gso.h
index 44fd213..af1aaed 100644
--- a/datapath/linux/compat/gso.h
+++ b/datapath/linux/compat/gso.h
@@ -69,4 +69,9 @@ static inline void skb_reset_inner_headers(struct sk_buff *skb)
 
 #define ip_local_out rpl_ip_local_out
 int ip_local_out(struct sk_buff *skb);
+
+#if 1 // LINUX_VERSION_CODE < KERNEL_VERSION(2,6,37)
+#define dev_queue_xmit rpl_dev_queue_xmit
+#endif
+
 #endif
diff --git a/datapath/vport-netdev.c b/datapath/vport-netdev.c
index 31680fd..4d934b5 100644
--- a/datapath/vport-netdev.c
+++ b/datapath/vport-netdev.c
@@ -34,17 +34,6 @@
 #include "vport-internal_dev.h"
 #include "vport-netdev.h"
 
-#if LINUX_VERSION_CODE < KERNEL_VERSION(2,6,37) && \
-	!defined(HAVE_VLAN_BUG_WORKAROUND)
-#include <linux/module.h>
-
-static int vlan_tso __read_mostly;
-module_param(vlan_tso, int, 0644);
-MODULE_PARM_DESC(vlan_tso, "Enable TSO for VLAN packets");
-#else
-#define vlan_tso true
-#endif
-
 static void netdev_port_receive(struct vport *vport, struct sk_buff *skb);
 
 #if LINUX_VERSION_CODE >= KERNEL_VERSION(2,6,39)
@@ -259,19 +248,6 @@ static unsigned int packet_length(const struct sk_buff *skb)
 	return length;
 }
 
-static bool dev_supports_vlan_tx(struct net_device *dev)
-{
-#if LINUX_VERSION_CODE >= KERNEL_VERSION(2,6,37)
-	/* Software fallback means every device supports vlan_tci on TX. */
-	return true;
-#elif defined(HAVE_VLAN_BUG_WORKAROUND)
-	return dev->features & NETIF_F_HW_VLAN_TX;
-#else
-	/* Assume that the driver is buggy. */
-	return false;
-#endif
-}
-
 static int netdev_send(struct vport *vport, struct sk_buff *skb)
 {
 	struct netdev_vport *netdev_vport = netdev_vport_priv(vport);
@@ -282,65 +258,15 @@ static int netdev_send(struct vport *vport, struct sk_buff *skb)
 		net_warn_ratelimited("%s: dropped over-mtu packet: %d > %d\n",
 				     netdev_vport->dev->name,
 				     packet_length(skb), mtu);
-		goto drop;
+		kfree_skb(skb);
+		return 0;
 	}
 
 	skb->dev = netdev_vport->dev;
-
-	if (vlan_tx_tag_present(skb) && !dev_supports_vlan_tx(skb->dev)) {
-		int features;
-
-		features = netif_skb_features(skb);
-
-		if (!vlan_tso)
-			features &= ~(NETIF_F_TSO | NETIF_F_TSO6 |
-				      NETIF_F_UFO | NETIF_F_FSO);
-
-		skb = __vlan_put_tag(skb, skb->vlan_proto, vlan_tx_tag_get(skb));
-		if (unlikely(!skb))
-			return 0;
-		vlan_set_tci(skb, 0);
-
-		if (netif_needs_gso(skb, features)) {
-			struct sk_buff *nskb;
-
-			nskb = skb_gso_segment(skb, features);
-			if (!nskb) {
-				if (unlikely(skb_cloned(skb) &&
-				    pskb_expand_head(skb, 0, 0, GFP_ATOMIC)))
-					goto drop;
-
-				skb_shinfo(skb)->gso_type &= ~SKB_GSO_DODGY;
-				goto xmit;
-			}
-
-			if (IS_ERR(nskb))
-				goto drop;
-			consume_skb(skb);
-			skb = nskb;
-
-			len = 0;
-			do {
-				nskb = skb->next;
-				skb->next = NULL;
-				len += skb->len;
-				dev_queue_xmit(skb);
-				skb = nskb;
-			} while (skb);
-
-			return len;
-		}
-	}
-
-xmit:
 	len = skb->len;
 	dev_queue_xmit(skb);
 
 	return len;
-
-drop:
-	kfree_skb(skb);
-	return 0;
 }
 
 /* Returns null if this device is not attached to a datapath. */
-- 
1.8.4
