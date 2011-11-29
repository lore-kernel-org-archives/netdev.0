From: Joe Perches <joe@perches.com>
Subject: [PATCH 1/4] nfc: Use standard logging styles
Date: Tue, 29 Nov 2011 11:37:32 -0800
Message-ID: <6c89a76ddb76926febe36fe5be514cb186e39a76.1322595343.git.joe@perches.com>
References: <cover.1322595343.git.joe@perches.com>
Cc: "David S. Miller" <davem@davemloft.net>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Lauro Ramos Venancio <lauro.venancio@openbossa.org>,
	Aloisio Almeida Jr <aloisio.almeida@openbossa.org>,
	Samuel Ortiz <sameo@linux.intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1322595343.git.joe@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Using the normal logging styles is preferred over
subsystem specific styles when the subsystem does
not take a specific struct.

Convert nfc_<level> specific messages to pr_<level>
Add newlines to uses.

Signed-off-by: Joe Perches <joe@perches.com>
---
 net/nfc/core.c     |    4 +++-
 net/nfc/nci/core.c |   28 +++++++++++++++-------------
 net/nfc/nci/data.c |    8 +++++---
 net/nfc/nci/ntf.c  |   16 +++++++++-------
 net/nfc/nci/rsp.c  |    4 +++-
 net/nfc/rawsock.c  |    4 +++-
 6 files changed, 38 insertions(+), 26 deletions(-)

diff --git a/net/nfc/core.c b/net/nfc/core.c
index 47e02c1..03e4571 100644
--- a/net/nfc/core.c
+++ b/net/nfc/core.c
@@ -21,6 +21,8 @@
  * 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.
  */
 
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
+
 #include <linux/init.h>
 #include <linux/kernel.h>
 #include <linux/module.h>
@@ -500,7 +502,7 @@ static int __init nfc_init(void)
 {
 	int rc;
 
-	nfc_info("NFC Core ver %s", VERSION);
+	pr_info("NFC Core ver %s\n", VERSION);
 
 	rc = class_register(&nfc_class);
 	if (rc)
diff --git a/net/nfc/nci/core.c b/net/nfc/nci/core.c
index fe5ca89..30032b2 100644
--- a/net/nfc/nci/core.c
+++ b/net/nfc/nci/core.c
@@ -25,6 +25,8 @@
  *
  */
 
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
+
 #include <linux/types.h>
 #include <linux/workqueue.h>
 #include <linux/completion.h>
@@ -96,8 +98,8 @@ static int __nci_request(struct nci_dev *ndev,
 			break;
 		}
 	} else {
-		nfc_err("wait_for_completion_interruptible_timeout failed %ld",
-			completion_rc);
+		pr_err("wait_for_completion_interruptible_timeout failed %ld\n",
+		       completion_rc);
 
 		rc = ((completion_rc == 0) ? (-ETIMEDOUT) : (completion_rc));
 	}
@@ -355,12 +357,12 @@ static int nci_start_poll(struct nfc_dev *nfc_dev, __u32 protocols)
 	nfc_dbg("entry");
 
 	if (test_bit(NCI_DISCOVERY, &ndev->flags)) {
-		nfc_err("unable to start poll, since poll is already active");
+		pr_err("unable to start poll, since poll is already active\n");
 		return -EBUSY;
 	}
 
 	if (ndev->target_active_prot) {
-		nfc_err("there is an active target");
+		pr_err("there is an active target\n");
 		return -EBUSY;
 	}
 
@@ -389,7 +391,7 @@ static void nci_stop_poll(struct nfc_dev *nfc_dev)
 	nfc_dbg("entry");
 
 	if (!test_bit(NCI_DISCOVERY, &ndev->flags)) {
-		nfc_err("unable to stop poll, since poll is not active");
+		pr_err("unable to stop poll, since poll is not active\n");
 		return;
 	}
 
@@ -405,18 +407,18 @@ static int nci_activate_target(struct nfc_dev *nfc_dev, __u32 target_idx,
 	nfc_dbg("entry, target_idx %d, protocol 0x%x", target_idx, protocol);
 
 	if (!test_bit(NCI_POLL_ACTIVE, &ndev->flags)) {
-		nfc_err("there is no available target to activate");
+		pr_err("there is no available target to activate\n");
 		return -EINVAL;
 	}
 
 	if (ndev->target_active_prot) {
-		nfc_err("there is already an active target");
+		pr_err("there is already an active target\n");
 		return -EBUSY;
 	}
 
 	if (!(ndev->target_available_prots & (1 << protocol))) {
-		nfc_err("target does not support the requested protocol 0x%x",
-			protocol);
+		pr_err("target does not support the requested protocol 0x%x\n",
+		       protocol);
 		return -EINVAL;
 	}
 
@@ -433,7 +435,7 @@ static void nci_deactivate_target(struct nfc_dev *nfc_dev, __u32 target_idx)
 	nfc_dbg("entry, target_idx %d", target_idx);
 
 	if (!ndev->target_active_prot) {
-		nfc_err("unable to deactivate target, no active target");
+		pr_err("unable to deactivate target, no active target\n");
 		return;
 	}
 
@@ -456,7 +458,7 @@ static int nci_data_exchange(struct nfc_dev *nfc_dev, __u32 target_idx,
 	nfc_dbg("entry, target_idx %d, len %d", target_idx, skb->len);
 
 	if (!ndev->target_active_prot) {
-		nfc_err("unable to exchange data, no active target");
+		pr_err("unable to exchange data, no active target\n");
 		return -EINVAL;
 	}
 
@@ -685,7 +687,7 @@ int nci_send_cmd(struct nci_dev *ndev, __u16 opcode, __u8 plen, void *payload)
 
 	skb = nci_skb_alloc(ndev, (NCI_CTRL_HDR_SIZE + plen), GFP_KERNEL);
 	if (!skb) {
-		nfc_err("no memory for command");
+		pr_err("no memory for command\n");
 		return -ENOMEM;
 	}
 
@@ -760,7 +762,7 @@ static void nci_rx_work(struct work_struct *work)
 			break;
 
 		default:
-			nfc_err("unknown MT 0x%x", nci_mt(skb->data));
+			pr_err("unknown MT 0x%x\n", nci_mt(skb->data));
 			kfree_skb(skb);
 			break;
 		}
diff --git a/net/nfc/nci/data.c b/net/nfc/nci/data.c
index 511fb96..7d8a125 100644
--- a/net/nfc/nci/data.c
+++ b/net/nfc/nci/data.c
@@ -21,6 +21,8 @@
  *
  */
 
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
+
 #include <linux/types.h>
 #include <linux/interrupt.h>
 #include <linux/wait.h>
@@ -49,7 +51,7 @@ void nci_data_exchange_complete(struct nci_dev *ndev,
 		/* forward skb to nfc core */
 		cb(cb_context, skb, err);
 	} else if (skb) {
-		nfc_err("no rx callback, dropping rx data...");
+		pr_err("no rx callback, dropping rx data...\n");
 
 		/* no waiting callback, free skb */
 		kfree_skb(skb);
@@ -161,7 +163,7 @@ int nci_send_data(struct nci_dev *ndev, __u8 conn_id, struct sk_buff *skb)
 		/* fragment packet and queue the fragments */
 		rc = nci_queue_tx_data_frags(ndev, conn_id, skb);
 		if (rc) {
-			nfc_err("failed to fragment tx data packet");
+			pr_err("failed to fragment tx data packet\n");
 			goto free_exit;
 		}
 	}
@@ -191,7 +193,7 @@ static void nci_add_rx_data_frag(struct nci_dev *ndev,
 
 		/* first, make enough room for the already accumulated data */
 		if (skb_cow_head(skb, reassembly_len)) {
-			nfc_err("error adding room for accumulated rx data");
+			pr_err("error adding room for accumulated rx data\n");
 
 			kfree_skb(skb);
 			skb = 0;
diff --git a/net/nfc/nci/ntf.c b/net/nfc/nci/ntf.c
index c1bf541..c704350 100644
--- a/net/nfc/nci/ntf.c
+++ b/net/nfc/nci/ntf.c
@@ -25,6 +25,8 @@
  *
  */
 
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
+
 #include <linux/types.h>
 #include <linux/interrupt.h>
 #include <linux/bitops.h>
@@ -114,8 +116,8 @@ static int nci_extract_activation_params_iso_dep(struct nci_dev *ndev,
 		break;
 
 	default:
-		nfc_err("unsupported activation_rf_tech_and_mode 0x%x",
-			ntf->activation_rf_tech_and_mode);
+		pr_err("unsupported activation_rf_tech_and_mode 0x%x\n",
+		       ntf->activation_rf_tech_and_mode);
 		return -EPROTO;
 	}
 
@@ -182,8 +184,8 @@ static void nci_rf_intf_activated_ntf_packet(struct nci_dev *ndev,
 			break;
 
 		default:
-			nfc_err("unsupported activation_rf_tech_and_mode 0x%x",
-				ntf.activation_rf_tech_and_mode);
+			pr_err("unsupported activation_rf_tech_and_mode 0x%x\n",
+			       ntf.activation_rf_tech_and_mode);
 			return;
 		}
 	}
@@ -214,8 +216,8 @@ static void nci_rf_intf_activated_ntf_packet(struct nci_dev *ndev,
 			break;
 
 		default:
-			nfc_err("unsupported rf_interface_type 0x%x",
-				ntf.rf_interface_type);
+			pr_err("unsupported rf_interface_type 0x%x\n",
+			       ntf.rf_interface_type);
 			return;
 		}
 	}
@@ -278,7 +280,7 @@ void nci_ntf_packet(struct nci_dev *ndev, struct sk_buff *skb)
 		break;
 
 	default:
-		nfc_err("unknown ntf opcode 0x%x", ntf_opcode);
+		pr_err("unknown ntf opcode 0x%x\n", ntf_opcode);
 		break;
 	}
 
diff --git a/net/nfc/nci/rsp.c b/net/nfc/nci/rsp.c
index 0591f5a..6f51a28 100644
--- a/net/nfc/nci/rsp.c
+++ b/net/nfc/nci/rsp.c
@@ -25,6 +25,8 @@
  *
  */
 
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
+
 #include <linux/types.h>
 #include <linux/interrupt.h>
 #include <linux/bitops.h>
@@ -200,7 +202,7 @@ void nci_rsp_packet(struct nci_dev *ndev, struct sk_buff *skb)
 		break;
 
 	default:
-		nfc_err("unknown rsp opcode 0x%x", rsp_opcode);
+		pr_err("unknown rsp opcode 0x%x\n", rsp_opcode);
 		break;
 	}
 
diff --git a/net/nfc/rawsock.c b/net/nfc/rawsock.c
index ee7b2b3..feb235b 100644
--- a/net/nfc/rawsock.c
+++ b/net/nfc/rawsock.c
@@ -21,6 +21,8 @@
  * 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.
  */
 
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
+
 #include <net/tcp_states.h>
 #include <linux/nfc.h>
 #include <linux/export.h>
@@ -294,7 +296,7 @@ static void rawsock_destruct(struct sock *sk)
 	skb_queue_purge(&sk->sk_receive_queue);
 
 	if (!sock_flag(sk, SOCK_DEAD)) {
-		nfc_err("Freeing alive NFC raw socket %p", sk);
+		pr_err("Freeing alive NFC raw socket %p\n", sk);
 		return;
 	}
 }
-- 
1.7.6.405.gc1be0
