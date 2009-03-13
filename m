From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: FW: Kernel panic during stress with igb in the upstream kernel
Date: Fri, 13 Mar 2009 19:52:45 +0800
Message-ID: <20090313115245.GA31949@gondor.apana.org.au>
References: <EA929A9653AAE14F841771FB1DE5A1365F69CA4280@rrsmsx501.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Duyck, Alexander H" <alexander.h.duyck@intel.com>,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: "Tantilov, Emil S" <emil.s.tantilov@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:41543 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752591AbZCMLw4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Mar 2009 07:52:56 -0400
Content-Disposition: inline
In-Reply-To: <EA929A9653AAE14F841771FB1DE5A1365F69CA4280@rrsmsx501.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Mar 12, 2009 at 09:31:18AM -0600, Tantilov, Emil S wrote:
> 
> Yeah - that's probably the case. I will restart the test with LRO off to make sure.
> 
> I was also able to reproduce the panic with the master branch, so I think we should notify netdev. I can't figure out how I missed this before ... Something must be different about this configuration. I am running all kinds of stress tests in parallel with igb/igbvf drivers and I don't see this.
> 
> Here's the trace:
> 
> general protection fault: 0000 [#1] PREEMPT SMP DEBUG_PAGEALLOC
> last sysfs file: /sys/devices/pci0000:00/0000:00:04.0/0000:0b:00.0/local_cpus
> CPU 3 
> Modules linked in: igb nfsd lockd exportfs sunrpc pci_slot [last unloaded: igb]
> Pid: 28747, comm: netperf Not tainted 2.6.29-rc7-net-next-igb-master #3 X7DA8
> RIP: 0010:[<ffffffff804d4316>]  [<ffffffff804d4316>] netpoll_receive_skb+0xe/0x1e

Sorry, it seems that I've managed to get the net/net-next patches
mixed up.  Does this help?

GRO: Move netpoll checks to correct location

As my netpoll fix for net doesn't really work for net-next, we
need this update to move the checks into the right place.  As it
stands we may pass freed skbs to netpoll_receive_skb.

This patch also introduces a netpoll_rx_on function to avoid GRO
completely if we're invoked through netpoll.  This might seem
paranoid but as netpoll may have an external receive hook it's
better to be safe than sorry.  I don't think we need this for
2.6.29 though since there's nothing immediately broken by it.

This patch also moves the GRO_* return values to netdevice.h since
VLAN needs them too (I tried to avoid this originally but alas
this seems to be the easiest way out).  This fixes a bug in VLAN
where it continued to use the old return value 2 instead of the
correct GRO_DROP.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 493b065..be3ebd7 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -330,6 +330,14 @@ enum
 	NAPI_STATE_NPSVC,	/* Netpoll - don't dequeue from poll_list */
 };
 
+enum {
+	GRO_MERGED,
+	GRO_MERGED_FREE,
+	GRO_HELD,
+	GRO_NORMAL,
+	GRO_DROP,
+};
+
 extern void __napi_schedule(struct napi_struct *n);
 
 static inline int napi_disable_pending(struct napi_struct *n)
diff --git a/include/linux/netpoll.h b/include/linux/netpoll.h
index e38d3c9..5f239dc 100644
--- a/include/linux/netpoll.h
+++ b/include/linux/netpoll.h
@@ -63,6 +63,13 @@ static inline int netpoll_rx(struct sk_buff *skb)
 	return ret;
 }
 
+static inline int netpoll_rx_on(struct sk_buff *skb)
+{
+	struct netpoll_info *npinfo = skb->dev->npinfo;
+
+	return npinfo && (npinfo->rx_np || npinfo->rx_flags);
+}
+
 static inline int netpoll_receive_skb(struct sk_buff *skb)
 {
 	if (!list_empty(&skb->dev->napi_list))
diff --git a/net/8021q/vlan_core.c b/net/8021q/vlan_core.c
index 2d6e405..6227248 100644
--- a/net/8021q/vlan_core.c
+++ b/net/8021q/vlan_core.c
@@ -79,6 +79,9 @@ static int vlan_gro_common(struct napi_struct *napi, struct vlan_group *grp,
 {
 	struct sk_buff *p;
 
+	if (netpoll_rx_on(skb))
+		return GRO_NORMAL;
+
 	if (skb_bond_should_drop(skb))
 		goto drop;
 
@@ -98,7 +101,7 @@ static int vlan_gro_common(struct napi_struct *napi, struct vlan_group *grp,
 	return dev_gro_receive(napi, skb);
 
 drop:
-	return 2;
+	return GRO_DROP;
 }
 
 int vlan_gro_receive(struct napi_struct *napi, struct vlan_group *grp,
@@ -106,9 +109,6 @@ int vlan_gro_receive(struct napi_struct *napi, struct vlan_group *grp,
 {
 	skb_gro_reset_offset(skb);
 
-	if (netpoll_receive_skb(skb))
-		return NET_RX_DROP;
-
 	return napi_skb_finish(vlan_gro_common(napi, grp, vlan_tci, skb), skb);
 }
 EXPORT_SYMBOL(vlan_gro_receive);
@@ -121,9 +121,6 @@ int vlan_gro_frags(struct napi_struct *napi, struct vlan_group *grp,
 	if (!skb)
 		return NET_RX_DROP;
 
-	if (netpoll_receive_skb(skb))
-		return NET_RX_DROP;
-
 	return napi_frags_finish(napi, skb,
 				 vlan_gro_common(napi, grp, vlan_tci, skb));
 }
diff --git a/net/core/dev.c b/net/core/dev.c
index 033d7ca..7bd3c29 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -135,14 +135,6 @@
 /* This should be increased if a protocol with a bigger head is added. */
 #define GRO_MAX_HEAD (MAX_HEADER + 128)
 
-enum {
-	GRO_MERGED,
-	GRO_MERGED_FREE,
-	GRO_HELD,
-	GRO_NORMAL,
-	GRO_DROP,
-};
-
 /*
  *	The list of packet types we will receive (as opposed to discard)
  *	and the routines to invoke.
@@ -2474,6 +2466,9 @@ static int __napi_gro_receive(struct napi_struct *napi, struct sk_buff *skb)
 {
 	struct sk_buff *p;
 
+	if (netpoll_rx_on(skb))
+		return GRO_NORMAL;
+
 	for (p = napi->gro_list; p; p = p->next) {
 		NAPI_GRO_CB(p)->same_flow = !compare_ether_header(
 			skb_mac_header(p), skb_gro_mac_header(skb));
@@ -2487,9 +2482,6 @@ int napi_skb_finish(int ret, struct sk_buff *skb)
 {
 	int err = NET_RX_SUCCESS;
 
-	if (netpoll_receive_skb(skb))
-		return NET_RX_DROP;
-
 	switch (ret) {
 	case GRO_NORMAL:
 		return netif_receive_skb(skb);
@@ -2587,9 +2579,6 @@ int napi_frags_finish(struct napi_struct *napi, struct sk_buff *skb, int ret)
 {
 	int err = NET_RX_SUCCESS;
 
-	if (netpoll_receive_skb(skb))
-		return NET_RX_DROP;
-
 	switch (ret) {
 	case GRO_NORMAL:
 	case GRO_HELD:

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
