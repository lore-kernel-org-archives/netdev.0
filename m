From: Andrew Gallatin <gallatin@myri.com>
Subject: [PATCH net-next 2.6] myri10ge: DCA update
Date: Tue, 28 Sep 2010 09:41:02 -0400
Message-ID: <4CA1F06E.3070109@myri.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------010609040206030104040404"
Cc: netdev@vger.kernel.org, Loic Prylli <loic@myri.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailbox2.myri.com ([64.172.73.26]:1838 "EHLO myri.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1754845Ab0I1OK5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 28 Sep 2010 10:10:57 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------010609040206030104040404
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

This patch contains the following DCA improvements to myri10ge:

1) Finally move myri10ge to use dca3 API

2) Disable PCIe relaxed ordering when enabling DCA on
     myri10ge.  This provides a performance boost on Nehalem
     based Xeons

3) Make sure to properly initialize NIC's DCA state when it is enabled,
     rather than giving the NIC a bogus tag (0) and waiting for
     the first received packet to trigger an update.  Not using a
     real tag can cause hardware exceptions on some motherboards
     when a CPU socket is empty.

3) Always update the cached CPU when our interrupt affinity changes
     so as to avoid excessive calls to dca3_get_tag()

Signed-off-by: Andrew Gallatin <gallatin@myri.com>
Signed-off-by: Loic Prylli <loic@myri.com>

--------------010609040206030104040404
Content-Type: text/x-diff;
 name="myri10ge_dca.diff"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="myri10ge_dca.diff"

diff --git a/drivers/net/myri10ge/myri10ge.c b/drivers/net/myri10ge/myri10ge.c
index 4f3a3c0..545d481 100644
--- a/drivers/net/myri10ge/myri10ge.c
+++ b/drivers/net/myri10ge/myri10ge.c
@@ -225,6 +225,7 @@ struct myri10ge_priv {
 	struct msix_entry *msix_vectors;
 #ifdef CONFIG_MYRI10GE_DCA
 	int dca_enabled;
+	int relaxed_order;
 #endif
 	u32 link_state;
 	unsigned int rdma_tags_available;
@@ -1074,10 +1075,29 @@ static int myri10ge_reset(struct myri10ge_priv *mgp)
 }
 
 #ifdef CONFIG_MYRI10GE_DCA
+static int
+myri10ge_toggle_relaxed(struct pci_dev *pdev, int on)
+{
+	int ret, cap, err;
+	u16 ctl;
+
+	cap = pci_find_capability(pdev, PCI_CAP_ID_EXP);
+	if (!cap)
+		return (0);
+
+	err = pci_read_config_word(pdev, cap + PCI_EXP_DEVCTL, &ctl);
+	ret = (ctl & PCI_EXP_DEVCTL_RELAX_EN) >> 4;
+	if (ret != on) {
+		ctl &= ~PCI_EXP_DEVCTL_RELAX_EN;
+		ctl |= (on << 4);
+		pci_write_config_word(pdev, cap + PCI_EXP_DEVCTL, ctl);
+	}
+	return (ret);	
+}
+
 static void
 myri10ge_write_dca(struct myri10ge_slice_state *ss, int cpu, int tag)
 {
-	ss->cpu = cpu;
 	ss->cached_dca_tag = tag;
 	put_be32(htonl(tag), ss->dca_tag);
 }
@@ -1088,9 +1108,10 @@ static inline void myri10ge_update_dca(struct myri10ge_slice_state *ss)
 	int tag;
 
 	if (cpu != ss->cpu) {
-		tag = dca_get_tag(cpu);
+		tag = dca3_get_tag(&ss->mgp->pdev->dev, cpu);
 		if (ss->cached_dca_tag != tag)
 			myri10ge_write_dca(ss, cpu, tag);
+		ss->cpu = cpu;
 	}
 	put_cpu();
 }
@@ -1113,9 +1134,13 @@ static void myri10ge_setup_dca(struct myri10ge_priv *mgp)
 				"dca_add_requester() failed, err=%d\n", err);
 		return;
 	}
+	mgp->relaxed_order = myri10ge_toggle_relaxed(pdev, 0);
 	mgp->dca_enabled = 1;
-	for (i = 0; i < mgp->num_slices; i++)
-		myri10ge_write_dca(&mgp->ss[i], -1, 0);
+	for (i = 0; i < mgp->num_slices; i++) {
+		mgp->ss[i].cpu = -1;
+		mgp->ss[i].cached_dca_tag = -1;
+		myri10ge_update_dca(&mgp->ss[i]);
+	 }
 }
 
 static void myri10ge_teardown_dca(struct myri10ge_priv *mgp)
@@ -1126,6 +1151,8 @@ static void myri10ge_teardown_dca(struct myri10ge_priv *mgp)
 	if (!mgp->dca_enabled)
 		return;
 	mgp->dca_enabled = 0;
+	if (mgp->relaxed_order)
+		myri10ge_toggle_relaxed(pdev, 1);
 	err = dca_remove_requester(&pdev->dev);
 }
 

--------------010609040206030104040404--
