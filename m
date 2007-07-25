From: Dan Williams <dcbw@redhat.com>
Subject: Re: Proposed interface for per-packet mesh-ttl
Date: Wed, 25 Jul 2007 16:58:57 -0400
Message-ID: <1185397138.16664.0.camel@xo-13-A4-25.localdomain>
References: <445f43ac0707031149o2b50fc0en48aef4130b4b60ec@mail.gmail.com>
	 <445f43ac0707031229m4ed60e0cg7960437c3e373c8e@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Javier Cardona <javier@cozybit.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:43651 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756978AbXGYVAx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 25 Jul 2007 17:00:53 -0400
In-Reply-To: <445f43ac0707031229m4ed60e0cg7960437c3e373c8e@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2007-07-03 at 12:29 -0700, Javier Cardona wrote:
> David Woodhouse suggested that this list is a more appropriate forum
> for my message...

Attached is Javier's proposed patch for this.  Please flame away.

Dan

-----------------------------------
Resent per Dan's request.

Support for using setsockpt() to change the mesh-ttl on a network flow, i.e.

<snip>
    sock = socket (PF_INET, SOCK_STREAM, 0);
    setsockopt(sock, SOL_IP, MESH_SO_SET_TTL, &ttl, optlen);
    ttl = 0;
    getsockopt(sock, SOL_IP, MESH_SO_GET_TTL, &ttl, &optlen);
</snip>

Signed-off-by: Javier Cardona <javier@cozybit.com>
---
 drivers/net/wireless/Kconfig              |    7 +
 drivers/net/wireless/libertas/Makefile    |    1 +
 drivers/net/wireless/libertas/decl.h      |    3 +
 drivers/net/wireless/libertas/hostcmd.h   |    6 +
 drivers/net/wireless/libertas/mesh_opts.c |  174 +++++++++++++++++++++++++++++
 drivers/net/wireless/libertas/mesh_opts.h |    5 +
 drivers/net/wireless/libertas/tx.c        |   46 +++++++-
 include/linux/in.h                        |    3 +
 8 files changed, 241 insertions(+), 4 deletions(-)

diff --git a/drivers/net/wireless/Kconfig b/drivers/net/wireless/Kconfig
index 1146f3d..f4123c3 100644
--- a/drivers/net/wireless/Kconfig
+++ b/drivers/net/wireless/Kconfig
@@ -294,6 +294,13 @@ config LIBERTAS_USB
 	---help---
 	  A driver for Marvell Libertas 8388 USB devices.
 
+config LIBERTAS_MESH_OPTS
+	tristate "Mesh Configuration Options for Libertas USB 802.11b/g cards"
+	depends on LIBERTAS_USB && NETFILTER
+	---help---
+	  This module enables the configuration of mesh parameters on a
+	  per-socket basis, via setsockopt() calls. 
+
 config LIBERTAS_DEBUG
 	bool "Enable full debugging output in the Libertas module."
 	depends on LIBERTAS
diff --git a/drivers/net/wireless/libertas/Makefile b/drivers/net/wireless/libertas/Makefile
index 71c5a25..a31d4f7 100644
--- a/drivers/net/wireless/libertas/Makefile
+++ b/drivers/net/wireless/libertas/Makefile
@@ -18,3 +18,4 @@ usb8xxx-objs += if_usb.o
 
 obj-$(CONFIG_LIBERTAS)     += libertas.o
 obj-$(CONFIG_LIBERTAS_USB) += usb8xxx.o
+obj-m			   += mesh_opts.o
diff --git a/drivers/net/wireless/libertas/decl.h b/drivers/net/wireless/libertas/decl.h
index 4d553da..2cbc137 100644
--- a/drivers/net/wireless/libertas/decl.h
+++ b/drivers/net/wireless/libertas/decl.h
@@ -14,6 +14,7 @@
 struct wlan_private;
 struct sk_buff;
 struct net_device;
+struct mesh_options;
 
 extern char *libertas_fw_name;
 
@@ -86,6 +87,8 @@ int libertas_activate_card(wlan_private *priv, char *fw_name);
 int libertas_remove_card(wlan_private *priv);
 int libertas_add_mesh(wlan_private *priv, struct device *dev);
 void libertas_remove_mesh(wlan_private *priv);
+int libertas_register_mesh_opts(struct mesh_options *);
+int libertas_unregister_mesh_opts(struct mesh_options *);
 
 
 #endif				/* _WLAN_DECL_H_ */
diff --git a/drivers/net/wireless/libertas/hostcmd.h b/drivers/net/wireless/libertas/hostcmd.h
index 0f67cba..bc86ed0 100644
--- a/drivers/net/wireless/libertas/hostcmd.h
+++ b/drivers/net/wireless/libertas/hostcmd.h
@@ -34,6 +34,12 @@ struct txpd {
 	u8 reserved1;
 };
 
+struct txpd_mesh {
+	__le16 reserved;
+	/* mesh ttl */
+	u8 ttl;
+} __attribute__ ((packed));
+
 /* RxPD Descriptor */
 struct rxpd {
 	/* Current Rx packet status */
diff --git a/drivers/net/wireless/libertas/mesh_opts.c b/drivers/net/wireless/libertas/mesh_opts.c
new file mode 100644
index 0000000..118eaed
--- /dev/null
+++ b/drivers/net/wireless/libertas/mesh_opts.c
@@ -0,0 +1,174 @@
+/*
+ * mesh_opts
+ *
+ * Author: Javier Cardona <javier@cozybit.com>
+ * Copyright: Marvell Semiconductors Inc., 2007
+ *
+ * Apply mesh-layer specific configuration to network flows.  Currently this
+ * only supports the mesh TTL parameter.
+ *
+ * Users call setsockopt on sockets to configure mesh parameters.  This module
+ * maintains a list of sockets (mesh_sks) that have different mesh parameters
+ * than the per-interface defaults.  The driver will modify the mesh
+ * configuration for each outgoing frame that belongs to one of the sockets in
+ * the mesh_sks list.
+ */
+
+#include <linux/module.h>
+#include <linux/list.h>
+#include <linux/net.h>
+#include <linux/in.h>
+#include <linux/netfilter.h>
+#include <linux/netfilter_ipv4.h>
+#include <linux/netfilter_ipv6.h>
+#include <linux/spinlock.h>
+#include <net/sock.h>
+
+#include <asm/uaccess.h>
+
+#include "mesh_opts.h"
+
+#define MESH_SO_BASE_CTL 	MESH_SO_SET_TTL
+
+static struct list_head mesh_sks = LIST_HEAD_INIT(mesh_sks);
+static DEFINE_RWLOCK(mesh_sks_lock);
+
+struct mesh_sock {
+	struct list_head list;
+
+	struct sock *sk;
+	unsigned char ttl;
+	void (*orig_sk_destruct) (struct sock *sk);
+};
+
+static struct mesh_sock * lookup_socket(struct sock *sk)
+{
+	struct mesh_sock *mesh_sk;
+	struct mesh_sock *found_sk = NULL;
+
+	read_lock(&mesh_sks_lock);
+	list_for_each_entry(mesh_sk, &mesh_sks, list) 
+		if (mesh_sk->sk == sk) {
+			found_sk = mesh_sk;
+			break;
+		}
+	read_unlock(&mesh_sks_lock);
+	return found_sk;
+}
+
+static void mesh_sk_destruct(struct sock *sk)
+{
+	struct mesh_sock *mesh_sk;
+	void (*orig_sk_destruct) (struct sock *sk);
+
+	mesh_sk = lookup_socket(sk);
+
+	if (mesh_sk) {
+		orig_sk_destruct = mesh_sk->orig_sk_destruct;
+		write_lock(&mesh_sks_lock);
+		list_del(&mesh_sk->list);
+		write_unlock(&mesh_sks_lock);
+		kfree(mesh_sk);
+		(*orig_sk_destruct)(sk);
+	}
+}
+
+static int do_mesh_set_mesh_ttl(struct sock *sk, void __user *user, unsigned int len)
+{
+	struct mesh_sock *mesh_sk;
+	unsigned char ttl;
+
+
+	if (len) {
+		if (get_user(ttl, (unsigned char *) user))
+			return -EFAULT;
+	} else
+		return -EINVAL;
+
+	mesh_sk = (struct mesh_sock*) kmalloc(sizeof(struct mesh_sock), GFP_KERNEL);
+	mesh_sk->ttl = ttl;
+	mesh_sk->sk = sk;
+	mesh_sk->orig_sk_destruct = sk->sk_destruct;
+	sk->sk_destruct = mesh_sk_destruct;
+	write_lock(&mesh_sks_lock);
+	list_add(&mesh_sk->list, &mesh_sks);
+	write_unlock(&mesh_sks_lock);
+
+	return 0;
+}
+
+static int do_mesh_get_mesh_ttl(struct sock *sk, void __user *user, int *len)
+{
+	struct mesh_sock *mesh_sk;
+	int rc = 0;
+
+	if ((mesh_sk = lookup_socket(sk)) == NULL)
+		return -ENODATA;	
+
+	if (put_user(mesh_sk->ttl, (unsigned char*) user))
+		return -EFAULT;
+
+	/* netfilter wrapper does the copy to user of len */
+	*len = sizeof(unsigned char);
+
+	return rc;
+}
+
+static int do_mesh_set_ctl(struct sock *sk, int optval, void __user *user,
+		unsigned int len) 
+{
+	return do_mesh_set_mesh_ttl(sk, user, len);
+}
+
+static int do_mesh_get_ctl(struct sock *sk, int optval, void __user *user, 
+		int *len) 
+{
+	return do_mesh_get_mesh_ttl(sk, user, len);
+}
+
+static unsigned char get_sock_mesh_ttl(struct sock *sk)
+{
+	struct mesh_sock *mesh_sk;
+
+	mesh_sk = lookup_socket(sk);
+
+	/* zero ttl results in using the network interface default */
+	return mesh_sk ? mesh_sk->ttl : 0;	
+}
+
+static struct mesh_options mesh_opts =
+{
+	.get_sock_ttl = get_sock_mesh_ttl,
+};
+
+static struct nf_sockopt_ops mesh_sockopt_ops =
+{
+	.pf		= PF_INET,
+	.set_optmin     = MESH_SO_BASE_CTL,
+	.set_optmax     = MESH_SO_BASE_CTL + 1,
+	.set		= do_mesh_set_ctl,
+	.get_optmin     = MESH_SO_BASE_CTL,
+	.get_optmax     = MESH_SO_BASE_CTL + 1,
+	.get		= do_mesh_get_ctl,
+};
+
+static int __init mesh_opts_init(void)
+{
+	int ret;
+
+	if ((ret = nf_register_sockopt(&mesh_sockopt_ops)) < 0) {
+		return ret;
+	}
+	libertas_register_mesh_opts(&mesh_opts);
+	return ret;
+}
+
+static void __exit mesh_opts_fini(void)
+{
+	nf_unregister_sockopt(&mesh_sockopt_ops);
+	libertas_unregister_mesh_opts(&mesh_opts);
+}
+
+module_init(mesh_opts_init);
+module_exit(mesh_opts_fini);
+MODULE_LICENSE("GPL");
diff --git a/drivers/net/wireless/libertas/mesh_opts.h b/drivers/net/wireless/libertas/mesh_opts.h
new file mode 100644
index 0000000..cd18fb1
--- /dev/null
+++ b/drivers/net/wireless/libertas/mesh_opts.h
@@ -0,0 +1,5 @@
+
+struct mesh_options {
+	unsigned char (*get_sock_ttl)(struct sock*);
+};
+
diff --git a/drivers/net/wireless/libertas/tx.c b/drivers/net/wireless/libertas/tx.c
index 194f033..497c227 100644
--- a/drivers/net/wireless/libertas/tx.c
+++ b/drivers/net/wireless/libertas/tx.c
@@ -9,6 +9,10 @@
 #include "defs.h"
 #include "dev.h"
 #include "wext.h"
+#include "mesh_opts.h"
+
+
+static struct mesh_options mesh_opts = { NULL };
 
 /**
  *  @brief This function converts Tx/Rx rates from IEEE80211_RADIOTAP_RATE 
@@ -122,15 +126,34 @@ static int SendSinglePacket(wlan_private * priv, struct sk_buff *skb)
 	lbs_dbg_hex("txpd", (u8 *) plocaltxpd, sizeof(struct txpd));
 	
 	if (IS_MESH_FRAME(skb)) {
-		plocaltxpd->tx_control |= TxPD_MESH_FRAME;
+		struct txpd_mesh msh_txpd;
+ 		plocaltxpd->tx_control |= cpu_to_le32(TxPD_MESH_FRAME);
+
+		memset(&msh_txpd, 0, sizeof(msh_txpd));
+
+		if (mesh_opts.get_sock_ttl)
+			msh_txpd.ttl = (*mesh_opts.get_sock_ttl)(skb->sk);
+
+		/* ttl of zero is never sent to the hardware */
+		if (msh_txpd.ttl) {
+			/* make room for the mesh descriptor that follows */
+			plocaltxpd->tx_packet_location = cpu_to_le32(
+				sizeof(struct txpd) + sizeof(msh_txpd));
+
+			memcpy(ptr + sizeof(struct txpd), &msh_txpd, 
+					sizeof(msh_txpd));
+			lbs_dbg_hex("txpd_mesh", (u8 *) &msh_txpd, 
+					sizeof(msh_txpd));
+		}
 	}
 
 	memcpy(ptr, plocaltxpd, sizeof(struct txpd));
 
-	ptr += sizeof(struct txpd);
+	ptr += le32_to_cpu(plocaltxpd->tx_packet_location);
 
-	lbs_dbg_hex("Tx Data", (u8 *) p802x_hdr, plocaltxpd->tx_packet_length);
-	memcpy(ptr, p802x_hdr, plocaltxpd->tx_packet_length);
+	lbs_dbg_hex("Tx Data", (u8 *) p802x_hdr, 
+			le16_to_cpu(plocaltxpd->tx_packet_length));
+	memcpy(ptr, p802x_hdr, le16_to_cpu(plocaltxpd->tx_packet_length));
 	ret = priv->hw_host_to_card(priv, MVMS_DAT,
 		priv->adapter->tmptxbuf,
 		plocaltxpd->tx_packet_length +
@@ -287,4 +310,19 @@ void libertas_send_tx_feedback(wlan_private * priv)
 		netif_wake_queue(priv->mesh_dev);
 	}
 }
+
+int libertas_register_mesh_opts(struct mesh_options *opts)
+{
+	mesh_opts.get_sock_ttl = opts->get_sock_ttl;
+	return 0;
+}
+
+int libertas_unregister_mesh_opts(struct mesh_options *opts)
+{
+	mesh_opts.get_sock_ttl = NULL;
+	return 0;
+}
+
+EXPORT_SYMBOL_GPL(libertas_register_mesh_opts);
+EXPORT_SYMBOL_GPL(libertas_unregister_mesh_opts);
 EXPORT_SYMBOL_GPL(libertas_send_tx_feedback);
diff --git a/include/linux/in.h b/include/linux/in.h
index 1912e7c..a69e2ab 100644
--- a/include/linux/in.h
+++ b/include/linux/in.h
@@ -102,6 +102,9 @@ struct in_addr {
 #define MCAST_LEAVE_SOURCE_GROUP	47
 #define MCAST_MSFILTER			48
 
+#define MESH_SO_SET_TTL 		50
+#define MESH_SO_GET_TTL 		50	
+
 #define MCAST_EXCLUDE	0
 #define MCAST_INCLUDE	1


