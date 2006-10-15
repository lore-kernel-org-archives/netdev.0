From: Dawid Ciezarkiewicz <dpc@asn.pl>
Subject: [RFC] Ethernet Cheap Cryptography
Date: Sun, 15 Oct 2006 18:20:21 +0200
Message-ID: <200610151820.22867.dpc@asn.pl>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
Received: from apollo.asn.pl ([85.14.104.1]:62390 "HELO apollo.asn.pl")
	by vger.kernel.org with SMTP id S932134AbWJOQU2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 15 Oct 2006 12:20:28 -0400
To: netdev@vger.kernel.org
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,
 I'd be thankful for your opinions about that idea. Please forgive me any
nuances that I didn't know about.



diff --git a/Documentation/networking/ccrypt.txt b/Documentation/networking/ccrypt.txt
new file mode 100644
index 0000000..8e46f1e
--- /dev/null
+++ b/Documentation/networking/ccrypt.txt
@@ -0,0 +1,107 @@
+Ethernet Cheap Crypt (ccrypt)
+
+== Introduction.
+Ccrypt is Ethernet traffic encryption mode. What differs it from other
+solutions is it's "cheapness" - in sense of additional space used in frames
+for internal protocol needs. While other solution suffers from mtu and
+fragmentation problems ccrypt just works - because it does not need any
+additional information. Never, and at all. It may seem a kind of magic, but it
+is actually very simple. Because of that "cheapness" it has it's own weakness,
+but can be very useful in some circumstances.
+
+== How does it work
+In short - ccrypt uses Cipher-block chaining (CBC) operation mode
+
+  http://en.wikipedia.org/wiki/Cipher_block_chaining
+
+and deals with padding problem with "residual block termination"
+
+  http://en.wikipedia.org/wiki/Residual_block_termination
+
+Ccrypt is basically implemented as two structures: ccrypt_rx and ccrypt_tx.
+These structures are associated with Ethernet net_device and can be used
+separately from themselves and other ccrypt_?x associated with other interfaces.
+
+All Ethernet interfaces need to have they ccrypt_rx or ccrypt_tx activated for
+ccrypt to work. They can be switched to use ccrypt by providing just two
+values: algorithm supported by the kernel crypto api and valid key.
+
+After setting ccrypt_tx (outgoing pair) all leaving frames will be encrypted
+using supported algorithm and key. All information except mac addresses,
+packet type and hardware checksum will be unreadable for common reader. If
+frame is of 802.1Q type - vlan id and encapsulated protocol will be send
+in plain text too.
+
+Because CBC mode needs Initialization Vector (IV) it will be internally
+stored - first bytes of encrypted frame will be used as IV for next frame.
+Because this is done right before execution of hardware xmit handler,
+frames will be delivered in order, so on the other side IV can be always in
+sync.
+
+After setting ccrypt_rx (incoming pair) all arriving frames will be decrypted.
+Decryption algorithm is less trivial then encryption one.
+
+Each frame is decrypted several times (although most of the time one try is
+enough) and validated using special validation function. This is most "magical"
+functionality of ccrypt. Using information about upper layer structure of
+headers, checksums and allowed values ccrypt minimalizes chance of passing
+hostile frame. Even if such injected frame would pass there are no chances
+that it can contain any valid upper level information. Most probably it
+will be dropped by upper layer protocol handlers because of being junk.
+While author of ccrypt is not cryptography expert he believes that this
+is secure enough to be used in non-critical circumstances.
+
+Ccrypt_rx actually manages two algorithm&key values. One is considered "new"
+and second "old". This is handy when implementing key-rotation solution, so
+that ccrypt_rx can be for a short time in "transition" stage - still using old
+key but switch to new one as soon as "valid" frame using new one appears.
+
+Each algorithm&key value have two IVs associated. One is copied from last
+frame known to be "valid" and if any "invalid" frame appeared since then
+it's stored too, but in the second IV. This prevents IV de-synchronization 
+attacks using frame injection and still let synchronize both sides after
+transmission problems.
+
+== Supported protocols
+Because of validation needs, ccrypt supports only subset of protocols
+working on the top of layer 2. Currently implemented are:
+* 802.1Q (vlan)
+* IPv4
+* ARP
+* PPPoE
+
+== Drawbacks
+While ccrypt have it's strengths it got it's weakness too.
+* it's experimental
+* it's level of security is still not confirmed by wider audience
+* validation function requires implementation of checks for all
+  upper protocols (IPv4, ARP at the time of writing this) it should
+  work with
+* it requires packet linearization (shouldn't be problem because of
+  Ethernet MTU and may be implemented for fragments support in the
+  future)
+* each lost frame caring encrypted information will cause two "real"
+  frames to be lost
+* "nesting" crypt (setting ccrypt on both: slave and master device
+  eg. vlan, bonding) will not work
+
+== Usage
+For changing algorithm and keys sysfs interface is provided.
+
+To set keys:
+# echo -n "aes:0123456789abcdef0123456789abcdef" > /sys/class/net/eth0/ccrypt_tx
+# echo -n "aes:deadbeafdeadbeafdeadbeafdeadbeaf" > /sys/class/net/eth0/ccrypt_rx
+
+To stop using ccrypt on eth0:
+$ echo -n "null" > /sys/class/net/eth0/ccrypt_tx
+$ echo -n "null" > /sys/class/net/eth0/ccrypt_rx
+
+Note that key lenght must be valid for selected algorithm.
+
+== Authors
+The main idea author is Pawel Foremski <pjf@asn.pl>.
+Implementation details and implementation itself was written by
+Dawid Ciezarkiewicz <dpc@asn.pl>. Both working in ASN team.
+
+Ccrypt was written as a part of the Lintrack project.
+http://lintrack.org
diff --git a/include/linux/ccrypt.h b/include/linux/ccrypt.h
new file mode 100644
index 0000000..96f1ad6
--- /dev/null
+++ b/include/linux/ccrypt.h
@@ -0,0 +1,56 @@
+/* 
+ * Cheap crypt (ccrypt).
+ * (C) 2006 Dawid Ciezarkiewicz <dpc@asn.pl>
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License version 2 as
+ * published by the Free Software Foundation.
+ */
+
+#ifdef __KERNEL__
+#ifndef __CCRYPT_H__
+#define __CCRYPT_H__
+#ifdef CONFIG_NETDEV_CCRYPT
+
+#include <linux/crypto.h>
+
+struct ccrypt_rx
+{
+	/* tfms[0] - "new" key */
+	/* tfms[1] - "old" key */
+	struct crypto_tfm* tfms[2];
+
+	/* [key][0] => iv from last good received packet */
+	/* [key][1] => iv from last received packet */
+	u8* last_recv_iv[2][2];
+
+	/* are last_recv_iv[key][0] and [key][1] equal? */
+	u8 last_recv_iv_matched[2];
+
+	/* should receiver use reversed order of keys
+	 * until sender starts using new key? */
+	u8 after_switch;
+};
+
+
+struct ccrypt_tx
+{
+	struct crypto_tfm* tfm;
+	u8* last_sent_iv;
+};
+
+struct sk_buff;
+struct class_device;
+struct net_device;
+
+int ccrypt_encrypt(struct sk_buff **pskb);
+int ccrypt_decrypt(struct sk_buff **pskb);
+ssize_t ccrypt_rx_store(struct class_device *dev, const char *buf, size_t len);
+ssize_t ccrypt_tx_store(struct class_device *dev, const char *buf, size_t len);
+ssize_t ccrypt_rx_show(struct class_device *dev, char *buf);
+ssize_t ccrypt_tx_show(struct class_device *dev, char *buf);
+void ccrypt_tx_reset(struct net_device* dev);
+void ccrypt_rx_reset(struct net_device* dev);
+#endif /* CONFIG_NETDEV_CCRYPT */
+#endif /* __CCRYPT_H__ */
+#endif /* __KERNEL__ */
diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 50a4719..30daed3 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -38,6 +38,11 @@ #include <linux/device.h>
 #include <linux/percpu.h>
 #include <linux/dmaengine.h>
 
+#ifdef CONFIG_NETDEV_CCRYPT
+struct ccrypt_rx;
+struct ccrypt_tx;
+#endif /* CONFIG_NETDEV_CCRYPT */
+
 struct divert_blk;
 struct vlan_group;
 struct ethtool_ops;
@@ -521,6 +526,14 @@ #ifdef CONFIG_NET_DIVERT
 	struct divert_blk	*divert;
 #endif /* CONFIG_NET_DIVERT */
 
+#ifdef CONFIG_NETDEV_CCRYPT
+	/* 0 means - don't use */
+	struct ccrypt_rx* ccrypt_rx;
+	spinlock_t ccrypt_rx_lock;
+	struct ccrypt_tx* ccrypt_tx;
+	spinlock_t ccrypt_tx_lock;
+#endif /* CONFIG_NETDEV_CCRYPT */
+
 	/* class/net/name entry */
 	struct class_device	class_dev;
 	/* space for optional statistics and wireless sysfs groups */
diff --git a/net/Kconfig b/net/Kconfig
index 4959a4e..ccf6cd8 100644
--- a/net/Kconfig
+++ b/net/Kconfig
@@ -73,6 +73,16 @@ config NETWORK_SECMARK
 	  to nfmark, but designated for security purposes.
 	  If you are unsure how to answer this question, answer N.
 
+config NETDEV_CCRYPT
+	bool "Ethernet Cheap Crypt"
+	depends on CRYPTO
+	help
+	  This enables "cheap" cryptography in layer2. For more info read
+	  Documentation/networking/ccrypt.txt . This is experimental
+	  functionality and should be used with care.
+
+	  If you are unsure how to answer this question, answer N.
+
 menuconfig NETFILTER
 	bool "Network packet filtering (replaces ipchains)"
 	---help---
diff --git a/net/core/Makefile b/net/core/Makefile
index 2645ba4..1c05def 100644
--- a/net/core/Makefile
+++ b/net/core/Makefile
@@ -12,6 +12,7 @@ obj-y		     += dev.o ethtool.o dev_mcast
 
 obj-$(CONFIG_XFRM) += flow.o
 obj-$(CONFIG_SYSFS) += net-sysfs.o
+obj-$(CONFIG_NETDEV_CCRYPT) += ccrypt.o
 obj-$(CONFIG_NET_DIVERT) += dv.o
 obj-$(CONFIG_NET_PKTGEN) += pktgen.o
 obj-$(CONFIG_WIRELESS_EXT) += wireless.o
diff --git a/net/core/ccrypt.c b/net/core/ccrypt.c
new file mode 100644
index 0000000..c03ad11
--- /dev/null
+++ b/net/core/ccrypt.c
@@ -0,0 +1,941 @@
+/*
+ * Ethernet Cheap Crypt (ccrypt).
+ * (C) 2006 Dawid Ciezarkiewicz <dpc@asn.pl>
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License version 2 as
+ * published by the Free Software Foundation.
+ */
+
+#include <linux/ccrypt.h>
+
+#include <linux/if_arp.h>
+#include <linux/if_pppox.h>
+#include <linux/if_vlan.h>
+#include <linux/scatterlist.h>
+
+#include <linux/crypto.h>
+#include <linux/module.h>
+#include <linux/skbuff.h>
+#include <linux/ip.h>
+#include <net/checksum.h>
+
+#define to_net_dev(class) container_of(class, struct net_device, class_dev)
+
+/**
+ * Allocate ccrypt_rx.
+ */
+struct ccrypt_rx* ccrypt_rx_alloc(void) {
+	struct ccrypt_rx* new_cc = kmalloc(sizeof(struct ccrypt_rx), GFP_KERNEL);
+	memset(new_cc, 0, sizeof(struct ccrypt_rx));
+	return new_cc;
+}
+
+/**
+ * Allocate ccrypt_tx.
+ */
+struct ccrypt_tx* ccrypt_tx_alloc(void) {
+	struct ccrypt_tx* new_cc = kmalloc(sizeof(struct ccrypt_tx), GFP_KERNEL);
+	memset(new_cc, 0, sizeof(struct ccrypt_tx));
+	return new_cc;
+}
+
+/**
+ * Free ccrypt_rx.
+ *
+ * Caller must hold ccrypt_rx_lock.
+ */
+static void ccrypt_rx_free(struct ccrypt_rx* cc_rx)
+{
+	unsigned int key_no;
+	unsigned int iv_no;
+	
+	for (key_no = 0; key_no < 2; key_no++) {
+		if (cc_rx->tfms[key_no]) {
+			crypto_free_tfm(cc_rx->tfms[key_no]);
+			cc_rx->tfms[key_no] = 0;
+		}
+
+		for (iv_no = 0; iv_no < 2; iv_no++) {
+			if (cc_rx->last_recv_iv[key_no][iv_no]) {
+				kfree(cc_rx->last_recv_iv[key_no][iv_no]);
+				cc_rx->last_recv_iv[key_no][iv_no] = 0;
+			}
+		}
+	}
+}
+
+/**
+ * Free ccrypt_tx.
+ *
+ * Caller must hold ccrypt_tx_lock.
+ */
+void ccrypt_tx_free(struct ccrypt_tx* cc_tx)
+{
+	if (cc_tx->last_sent_iv) {
+		kfree(cc_tx->last_sent_iv);
+		cc_tx->last_sent_iv = 0;
+	}
+
+	if (cc_tx->tfm) {
+		crypto_free_tfm(cc_tx->tfm);
+		cc_tx->tfm = 0;
+	}
+}
+
+/**
+ * For key switching unification.
+ */
+typedef int key_switch_f(struct net_device* dev, char* algorithm,
+		u8* key, unsigned int keylen);
+
+/**
+ * Switch key in ccrypt_tx.
+ *
+ * Returns:
+ * 0 on success
+ *
+ * Caller must hold ccrypt_tx_lock.
+ */
+static
+int ccrypt_tx_switch_key(struct ccrypt_tx* cc_tx, char* algorithm,
+		u8* key, unsigned int keylen)
+{
+	struct crypto_tfm* new_tfm;
+	u8* new_iv;
+	unsigned int new_iv_size;
+	int res;
+
+	new_tfm = crypto_alloc_tfm(algorithm, CRYPTO_TFM_MODE_CBC);
+
+	if (!new_tfm) {
+		return -EINVAL;
+	}
+
+	res = crypto_cipher_setkey(new_tfm, key, keylen);
+
+	if (res) {
+		crypto_free_tfm(new_tfm);
+		return res;
+	}
+
+	new_iv_size = crypto_tfm_alg_ivsize(new_tfm);
+
+	if (new_iv_size != crypto_tfm_alg_blocksize(new_tfm)) {
+		printk(KERN_ERR "ccrypt: iv_len != bsize - strange\n");
+		crypto_free_tfm(new_tfm);
+		return -EINVAL;
+	}
+
+	/* allocate new iv_vectors for new key */
+	new_iv = kmalloc(new_iv_size, GFP_KERNEL);
+
+	if (!new_iv) {
+		kfree(new_iv);
+		printk(KERN_ERR "couldn't allocate %d bytes", new_iv_size);
+
+		crypto_free_tfm(new_tfm);
+		return -ENOMEM;
+	}
+
+	memset(new_iv, 0, new_iv_size);
+	if (cc_tx->last_sent_iv) {
+		kfree(cc_tx->last_sent_iv);
+	}
+
+	cc_tx->last_sent_iv = new_iv;
+	
+	if (cc_tx->tfm)	
+		crypto_free_tfm(cc_tx->tfm);
+
+	cc_tx->tfm = new_tfm;
+
+	return 0;
+}
+
+/**
+ * Switch key in ccrypt_rx.
+ *
+ * Returns:
+ * 0 on success
+ *
+ * Caller must hold ccrypt_rx_lock.
+ */
+static
+int ccrypt_rx_switch_key(struct ccrypt_rx* cc_rx, char* algorithm,
+		u8* key, unsigned int keylen)
+{
+	struct crypto_tfm* new_tfm;
+	u8* new_iv[2];
+	int res;
+	unsigned int new_iv_size;
+	unsigned int cur_iv_no;
+
+	new_tfm = crypto_alloc_tfm(algorithm, CRYPTO_TFM_MODE_CBC);
+
+	if (!new_tfm) {
+		return -EINVAL;
+	}
+
+	res = crypto_cipher_setkey(new_tfm, key, keylen);
+
+	if (res) {
+		crypto_free_tfm(new_tfm);
+		return res;
+	}
+
+	new_iv_size = crypto_tfm_alg_ivsize(new_tfm);
+	
+	/* allocate new iv_vectors for new key */
+	new_iv[0] = kmalloc(new_iv_size, GFP_KERNEL);
+	new_iv[1] = kmalloc(new_iv_size, GFP_KERNEL);
+	
+	if (!new_iv[0] || !new_iv[1]) {
+		if (new_iv[0]) {
+			kfree(new_iv[0]);
+		}
+
+		if (new_iv[1]) {
+			kfree(new_iv[1]);
+		}
+		
+		crypto_free_tfm(new_tfm);
+		printk(KERN_ERR "ccrypt: kmalloc(%d) failed.\n",
+				new_iv_size);
+		return -ENOMEM;
+	}
+
+	/* zero new ivs and free old ones, then replace them */
+	for (cur_iv_no = 0; cur_iv_no < 2; ++cur_iv_no) {
+		memset(new_iv[cur_iv_no], '\0', new_iv_size);
+
+		if (cc_rx->last_recv_iv[1][cur_iv_no]) {
+			kfree(cc_rx->last_recv_iv[1][cur_iv_no]);
+		}
+
+		cc_rx->last_recv_iv[1][cur_iv_no] =
+			cc_rx->last_recv_iv[0][cur_iv_no];
+
+		cc_rx->last_recv_iv[0][cur_iv_no] = new_iv[cur_iv_no];
+	}
+
+	if (cc_rx->tfms[1]) {
+		crypto_free_tfm(cc_rx->tfms[1]);
+	}
+
+	cc_rx->tfms[1] = cc_rx->tfms[0];
+	cc_rx->tfms[0] = new_tfm;
+
+	cc_rx->last_recv_iv_matched[1] =
+		cc_rx->last_recv_iv_matched[0];
+	cc_rx->last_recv_iv_matched[0] = 1;
+
+	cc_rx->after_switch = 1;
+
+	return 0;
+}
+
+/**
+ * Reset rx key. Stop using rx encryption.
+ */
+void ccrypt_rx_reset(struct net_device* dev)
+{
+	spin_lock(&dev->ccrypt_rx_lock);
+	if (dev->ccrypt_rx) {
+		ccrypt_rx_free(dev->ccrypt_rx);
+		dev->ccrypt_rx = 0;
+	}
+	spin_unlock(&dev->ccrypt_rx_lock);
+}
+
+/**
+ * Reset tx key. Stop using tx encryption.
+ */
+void ccrypt_tx_reset(struct net_device* dev)
+{
+	spin_lock(&dev->ccrypt_tx_lock);
+	if (dev->ccrypt_tx) {
+		ccrypt_tx_free(dev->ccrypt_tx);
+		dev->ccrypt_tx = 0;
+	}
+	spin_unlock(&dev->ccrypt_tx_lock);
+}
+
+/**
+ * Called from user context.
+ */
+static
+int rx_switch(struct net_device* dev, char* algorithm,
+		u8* key, unsigned int keylen)
+{
+	int res;
+
+	if (strcmp(algorithm, "null") == 0) {
+		ccrypt_rx_reset(dev);
+		return 0;
+	}
+
+	spin_lock(&dev->ccrypt_rx_lock);
+	if (!dev->ccrypt_rx) {
+		dev->ccrypt_rx = ccrypt_rx_alloc();
+		if (!dev->ccrypt_rx) {
+			spin_unlock(&dev->ccrypt_rx_lock);
+			return -ENOMEM;
+		}
+	}
+	res = ccrypt_rx_switch_key(dev->ccrypt_rx, algorithm, key, keylen);
+	spin_unlock(&dev->ccrypt_rx_lock);
+
+	return res;
+}
+
+/**
+ * Called from user context.
+ */
+static
+int tx_switch(struct net_device* dev, char* algorithm,
+		u8* key, unsigned int keylen)
+{
+	int res;
+
+	if (strcmp(algorithm, "null") == 0) {
+		ccrypt_tx_reset(dev);
+		return 0;
+	}
+
+	spin_lock(&dev->ccrypt_tx_lock);
+	if (!dev->ccrypt_tx) {
+		dev->ccrypt_tx = ccrypt_tx_alloc();
+		if (!dev->ccrypt_tx) {
+			spin_unlock(&dev->ccrypt_tx_lock);
+			return -ENOMEM;
+		}
+	}
+	res = ccrypt_tx_switch_key(dev->ccrypt_tx, algorithm, key, keylen);
+	spin_unlock(&dev->ccrypt_tx_lock);
+
+	return res;
+}
+
+/**
+ * Handle key writes - both rx and tx.
+ *
+ * Check permissions, copy data from user, parse it, call appropriate
+ * switch handler.
+ *
+ * Returns 0 on success.
+ */
+static
+int ccrypt_key_store_handle(struct net_device* dev,
+		const char __user *user_buffer,
+		unsigned long count,
+		key_switch_f switch_handler)
+{
+	const unsigned int max_alg_len = CRYPTO_MAX_ALG_NAME;
+
+	/* key length in bytes */
+	const unsigned int max_key_len = 64;
+
+	/* key length as string */
+	const unsigned int max_key_string_len = max_key_len * 2;
+	
+	/* alg + ':' + keystr + '\0' */
+	const unsigned int max_buffer_len =
+		max_alg_len + 1 + max_key_string_len + 1;
+
+	unsigned int a, b;
+	unsigned int i, j;
+	unsigned int key_len;
+	u8 alg_string_ok;
+	int res;
+
+	char buffer[max_buffer_len];
+	char alg_string[max_alg_len];
+	u8 key[max_key_len];
+
+	if (!capable(CAP_NET_ADMIN))
+		return -EACCES;
+
+	if (count > max_buffer_len - 1) {
+		return -EINVAL;
+	}
+
+	memcpy(buffer, user_buffer, count);
+	buffer[count] = '\0';
+
+	alg_string_ok = 0;
+	for (i = 0; i < max_alg_len && i <= count; ++i) {
+		if (buffer[i] == ':' || buffer[i] == '\0') {
+			alg_string[i] = '\0';
+			alg_string_ok = 1;
+			if (buffer[i] == ':')
+				i++;
+			break;
+		}
+		alg_string[i] = buffer[i];
+	}
+
+	if (!alg_string_ok) {
+		return -EINVAL;
+	}
+	
+	j = i;
+	key_len = 0;
+	for (i = 0; i < max_key_len; i++, key_len++, j+= 2) {
+		if (buffer[j] == 0) {
+			break;
+		}
+
+		if (buffer[j] >= '0' && buffer[j] <= '9') {
+			a = buffer[j] - '0';
+		}
+		else if (buffer[j] >= 'a' && buffer[j] <= 'f') {
+			a = buffer[j] - 'a' + 10;
+		} else {
+			return -EINVAL;
+		}
+
+		if (buffer[j + 1] >= '0' && buffer[j + 1] <= '9') {
+			b = buffer[j + 1] - '0';
+		}
+		else if (buffer[j + 1] >= 'a' && buffer[j + 1] <= 'f') {
+			b = buffer[j + 1] - 'a' + 10;
+		} else {
+			return -EINVAL;
+		}
+
+		key[i] = b * 16 + a;
+	}
+
+	res = switch_handler(dev, alg_string, key, key_len);
+
+	/* errors */
+	if (res < 0) {
+		return res;
+	}
+
+	/* ok */
+	if (res == 0) {
+		return count;
+	}
+
+	printk(KERN_ERR "Error: ccrypt error - should not be here\n");
+	return -EINVAL;
+}
+
+ssize_t ccrypt_rx_store(struct class_device *dev, const char *buf, size_t len)
+{
+	return ccrypt_key_store_handle(to_net_dev(dev), buf, len, rx_switch);
+}
+
+ssize_t ccrypt_tx_store(struct class_device *dev, const char *buf, size_t len)
+{
+	return ccrypt_key_store_handle(to_net_dev(dev), buf, len, tx_switch);
+}
+
+ssize_t ccrypt_tx_show(struct class_device *dev, char *buf)
+{
+	return -EINVAL; /* not implemented yet */
+}
+
+ssize_t ccrypt_rx_show(struct class_device *dev, char *buf)
+{
+	return -EINVAL; /* not implemented yet */
+}
+
+/**
+ * Check if buffer has right ipv4 structures.
+ */
+static
+inline int is_valid_ipv4(struct iphdr* hdr, int len)
+{
+	u16 tmp_check;
+
+	if (len < sizeof(struct iphdr)) {
+		return 0;
+	}
+
+	if (hdr->ihl < 5 || hdr->ihl > 15) {
+		return 0;
+	}
+
+	if (len < sizeof(struct iphdr) + hdr->ihl * 4) {
+		return 0;
+	}
+
+	tmp_check = hdr->check;
+	hdr->check = 0; /* required by ip_fast_csum */
+
+	if (tmp_check != ip_fast_csum((unsigned char *)hdr, hdr->ihl)) {
+		return 0;
+	}
+
+	hdr->check = tmp_check;
+
+	return 1;
+}
+
+/**
+ * IP validation.
+ */
+static
+inline int is_valid_ip(struct iphdr* hdr, int len)
+{
+	if (len < sizeof(struct iphdr)) {
+		return 0;
+	}
+
+	if (hdr->version == 4) {
+		return is_valid_ipv4(hdr, len);
+	}
+
+	return 0;
+}
+
+/**
+ * ARP validation.
+ */
+static inline int is_valid_arp(struct arphdr* hdr, int len)
+{
+	if (len < 4) {
+		return 0;
+	}
+
+	switch (hdr->ar_hrd) {
+		/* supported hardware layers */
+		case __constant_htons(ARPHRD_ETHER):
+			break;
+		default:
+			return 0;
+	}
+
+	switch (hdr->ar_pro) {
+		/* supported protocols */
+		case __constant_htons(ETH_P_IP): /* ipv4 */
+			break;
+		default:
+			return 0;
+	}
+
+	/* hardware address length
+	 * as we support only Ethernet ... */
+	if (hdr->ar_hln != 6) {
+		return 0;
+	}
+
+	return 1;
+}
+/**
+ * PPPoE validation.
+ */
+int is_valid_pppoe(u16 ethertype, struct pppoe_hdr* hdr, int len)
+{
+	if (len < sizeof(struct pppoe_hdr)) {
+		return 0;
+	}
+
+	if (hdr->type != 1) {
+		return 0;
+	}
+
+	if (hdr->ver != 1) {
+		return 0;
+	}
+
+	switch (hdr->code) {
+		case PADI_CODE:
+		case PADO_CODE:
+		case PADR_CODE:
+		case PADS_CODE:
+		case PADT_CODE:
+			if (ethertype != ETH_P_PPP_DISC) {
+				return 0;
+			}
+			break;
+		case 0:
+			if (ethertype != ETH_P_PPP_SES) {
+				return 0;
+			}
+			break;
+		default:
+			return 0;
+	}
+	return 1;
+}
+
+/**
+ * Check if decoded buffer is right in needed places.
+ *
+ * Ethertype should be after htons().
+ */
+static
+int is_decoded_buffer_valid(u16 ethertype, u8* buffer, int len)
+{
+	/* TODO: add more protocols */
+	/* XXX: keep documentation in sync */
+	switch (ethertype) {
+		case ETH_P_IP:
+			/* IP */
+			if (!is_valid_ip((struct iphdr*)buffer, len)) {
+				return 0;
+			}
+			break;
+		case ETH_P_ARP:
+			/* arp */
+			if (!is_valid_arp((struct arphdr*)buffer, len)) {
+				return 0;
+			}
+			break;
+		case ETH_P_PPP_DISC:
+		case ETH_P_PPP_SES:
+			/* pppoe */
+			if (!is_valid_pppoe(ethertype, (struct pppoe_hdr*)buffer, len)) {
+				return 0;
+			}
+			break;
+		default:
+			return 0;
+	}
+	return 1;
+}
+
+/**
+ * Save received iv vector in appropriate place.
+ */
+static
+inline void save_recv_iv(struct ccrypt_rx* cc_rx,
+		unsigned int key_no, unsigned int iv_no,
+		u8* src_buffer, unsigned int len, unsigned int iv_len)
+{
+	if (likely(len >= iv_len)) {
+		memcpy(cc_rx->last_recv_iv[key_no][iv_no],
+				src_buffer, iv_len);
+	}
+	else {
+		memset(cc_rx->last_recv_iv[key_no][iv_no] + len,
+				'\0', iv_len - len);
+		memcpy(cc_rx->last_recv_iv[key_no][iv_no],
+				src_buffer, len);
+	}
+}
+
+/**
+ * Try to decode incoming packet using skb->dev->ccrypt_rx group.
+ *
+ * Returns 0 on success.
+ *         -EINVAL on standard "drop it".
+ *
+ * Caller must hold ccrypt_rx_lock.
+ */
+int ccrypt_decrypt(struct sk_buff **pskb)
+{
+	struct ccrypt_rx* cc_rx;
+	struct crypto_tfm* tfm = 0;
+	struct sk_buff* skb = 0;
+	int res;
+	u16 len;
+   	unsigned int aligned_len, unaligned_len;
+	unsigned int bsize;
+	struct scatterlist sg_out;
+	struct scatterlist sg_residual;
+	struct scatterlist sg;
+	unsigned int iv_len;
+	int i;
+	u8* iv;
+	u8 key_no_org;
+	u8 key_no, iv_no;
+	u8* decode_buffer;
+	u16 ethertype;
+	u8* data;
+
+	/* if (skb_make_writable(pskb, (*pskb)->len) == 0) {
+		if (net_ratelimit())
+			printk(KERN_ERR "xt_CDECRYPT: Failed to make skb writable.\n");
+		return XT_DROP;
+	}*/
+
+	skb = *pskb;
+	cc_rx = skb->dev->ccrypt_rx;
+	len = skb->len;
+
+	if (len < ETH_ZLEN - sizeof(struct ethhdr) - VLAN_HLEN) {
+		/* if shorter - it couldn't have been sent by ccrypt_encode */
+		return -EINVAL;
+	}
+	data = skb->data;
+
+	ethertype = htons(*((u16*)(skb->data - 2)));
+
+	if (ethertype == ETH_P_8021Q) {
+		len -= VLAN_HLEN;
+		data += VLAN_HLEN;
+		ethertype = htons(*((u16*)(data - 2)));
+	}
+
+	/*
+	 * original stays in data, all tries will
+	 * be validated in decode_buffer
+	 */
+	decode_buffer = kmalloc(sizeof(u8) * len, GFP_ATOMIC);
+
+	if (!decode_buffer) {
+		if (net_ratelimit())
+			printk(KERN_ERR "ccrypt_decrypt: kmalloc failed.\n");
+		return -ENOMEM;
+	}
+
+	sg_set_buf(&sg_out, decode_buffer, len);
+
+	/*
+	 * be warned: fancy logic ahead
+	 */
+	for (key_no_org = 0; key_no_org < 2; ++key_no_org) {
+
+		/* if we are right after key switch, use key 2 first
+		 * until you get first msg encoded with new key */
+		if (cc_rx->after_switch) {
+			key_no = 1 - key_no_org;
+		}
+		else {
+			key_no = key_no_org;
+		}
+
+		if (!cc_rx->after_switch && key_no == 1) {
+			/* if sender used new key once - it should
+			 * not use old key anymore */
+			continue;
+		}
+
+		tfm = cc_rx->tfms[key_no];
+		if (!tfm) {
+			continue;
+		}
+
+		bsize = crypto_tfm_alg_blocksize(tfm);
+		unaligned_len = len % bsize;
+		aligned_len = len - unaligned_len;
+		iv_len = crypto_tfm_alg_ivsize(tfm);
+
+		for (iv_no = 0; iv_no < 2; ++iv_no) {
+			if (cc_rx->last_recv_iv_matched[key_no] && iv_no == 1) {
+				/* skip if there is no point trying
+				 * because there is no iv from "wrong packet"
+				 * to try */
+				continue;
+			}
+
+			iv = cc_rx->last_recv_iv[key_no][iv_no];
+
+			if (!iv) {
+				continue;
+			}
+
+			sg_set_buf(&sg, data, aligned_len);
+			crypto_cipher_set_iv(tfm, iv, iv_len);
+			res = crypto_cipher_decrypt(tfm, &sg_out, &sg, aligned_len);
+
+			if (res) {
+				printk(KERN_ERR "cipher_decrypt_iv() failed flags=%x\n",
+						tfm->crt_flags);
+				return res;
+			}
+
+			if (unaligned_len) {
+				u8 residual_block[bsize];
+				sg_set_buf(&sg_residual, residual_block, bsize);
+
+				if (unlikely(aligned_len < bsize * 2)) {
+					sg_set_buf(&sg, iv, bsize);
+				}
+				else {
+					sg_set_buf(&sg, data, bsize);
+				}
+
+				res = crypto_cipher_encrypt(tfm,
+						&sg_residual, &sg, bsize);
+
+				if (res) {
+					printk(KERN_ERR "cipher_encrypt_iv() failed flags=%x\n",
+							tfm->crt_flags);
+					return res;
+				}
+
+				for (i = 0; i < unaligned_len; ++i) {
+					decode_buffer[aligned_len + i] =
+						residual_block[i] ^ data[aligned_len + i];
+				}
+			}
+
+			/* it's a kind of magic ... magic ... magic ... */
+			if (is_decoded_buffer_valid(ethertype, decode_buffer, len)) {
+				if (key_no == 0) {
+					cc_rx->after_switch = 0;
+				}
+
+				cc_rx->last_recv_iv_matched[key_no] = 1;
+				save_recv_iv(cc_rx, key_no, 0, data, len, iv_len);
+				goto finish_match;
+			}
+
+		}
+
+		/* there was no match for both ivs for key - save "wrong iv" */
+		cc_rx->last_recv_iv_matched[key_no] = 0;
+		save_recv_iv(cc_rx, key_no, 1, data, len, iv_len);
+	}
+
+/* finish_no_match: */
+	kfree(decode_buffer);
+	return -EINVAL;
+
+finish_match:
+	memcpy(data, decode_buffer, len);
+	kfree(decode_buffer);
+	return 0;
+}
+
+/**
+ * Encode sk_buff.
+ *
+ * Returns 0 on success.
+ *
+ * Caller must hold ccrypt_tx_lock.
+ *
+ * Assumptions:
+ * (*pskb)->data points at the start of frame,
+ *            (where mac.raw should point)
+ * (*pskb)->len is overall packet len
+ * *pskb is linearized
+ */
+int ccrypt_encrypt(struct sk_buff **pskb)
+{
+	struct crypto_tfm* tfm = 0;
+	struct sk_buff* skb = 0;
+	struct sk_buff* nskb = 0;
+	int res;
+	unsigned int len;
+   	unsigned int aligned_len, unaligned_len;
+	unsigned int bsize;
+	struct scatterlist sg;
+	struct scatterlist sg_residual;
+	unsigned int iv_len;
+	unsigned int i;
+	unsigned int expand;
+	u8* iv;
+	u8* data;
+	unsigned int old_len;
+	struct ccrypt_tx* cc_tx = 0;
+
+	skb = *pskb;
+
+	cc_tx = skb->dev->ccrypt_tx;
+
+	tfm = cc_tx->tfm;
+
+	if (!tfm) {
+		return -EINVAL;
+	}
+
+	/*
+	 * we can't let packet be expanded in the future
+	 * do it now so the Ethernet device wouldn't have to
+	 */
+	if (skb->len < ETH_ZLEN) {
+		if (skb_shared(skb)) {
+			nskb = skb_clone(skb, GFP_ATOMIC);
+			if (!skb) {
+				if (net_ratelimit()) {
+					printk(KERN_ERR "ccrypt_tx: "
+					       "couldn't unshare tiny packet\n");
+				}
+				return -ENOMEM;
+			}
+			skb = nskb;
+			*pskb = nskb;
+		}
+		old_len = skb->len;
+		expand = ETH_ZLEN - old_len;
+		if (skb_tailroom(skb) < expand) {
+			res = pskb_expand_head(skb, 0, expand, GFP_ATOMIC);
+			if (res) {
+				if (net_ratelimit()) {
+					printk(KERN_ERR "ccrypt_tx: "
+							"couldn't expand tiny packet\n");
+				}
+				return res;
+			}
+		}
+		skb_put(skb, expand);
+		memset(skb->data + old_len, 0, expand);
+	}
+
+	data = skb->data + sizeof(struct ethhdr);
+	len = skb->len - sizeof(struct ethhdr);
+
+	if (((struct ethhdr*)(skb->data))->h_proto
+			== __constant_htons(ETH_P_8021Q)) {
+		data += VLAN_HLEN;
+		len  -= VLAN_HLEN;
+	}
+
+	bsize = crypto_tfm_alg_blocksize(tfm);
+	unaligned_len = len % bsize;
+	aligned_len = len - unaligned_len;
+	iv_len = crypto_tfm_alg_ivsize(tfm);
+	sg_set_buf(&sg, data, aligned_len);
+	iv = cc_tx->last_sent_iv;
+
+	crypto_cipher_set_iv(tfm, iv, iv_len);
+
+	res = crypto_cipher_encrypt(tfm, &sg, &sg, aligned_len);
+
+	if (res) {
+		printk(KERN_ERR "cipher_encrypt_iv() failed flags=%x\n",
+				tfm->crt_flags);
+		return res;
+	}
+
+	/* do residual block termination */
+	if (unaligned_len) {
+		u8 residual_block[bsize];
+		sg_set_buf(&sg_residual, residual_block, bsize);
+
+		if (unlikely(aligned_len < bsize * 2)) {
+			sg_set_buf(&sg, iv, bsize);
+		}
+		else {
+			sg_set_buf(&sg, data, bsize);
+		}
+
+		res = crypto_cipher_encrypt(tfm, &sg_residual, &sg, bsize);
+
+		if (res) {
+			printk(KERN_ERR "cipher_encrypt_iv() failed flags=%x\n",
+					tfm->crt_flags);
+			return res;
+		}
+
+		for (i = 0; i < unaligned_len; ++i) {
+			data[aligned_len + i] ^= residual_block[i];
+		}
+	}
+
+	if (likely(len >= iv_len)) {
+		memcpy(iv, data, iv_len);
+	}
+	else {
+		memset(iv + len, 0, iv_len - len);
+		memcpy(iv, data, len);
+	}
+
+	return 0;
+}
+
+EXPORT_SYMBOL(ccrypt_tx_store);
+EXPORT_SYMBOL(ccrypt_rx_store);
+EXPORT_SYMBOL(ccrypt_rx_reset);
+EXPORT_SYMBOL(ccrypt_tx_reset);
+EXPORT_SYMBOL(ccrypt_tx_show);
+EXPORT_SYMBOL(ccrypt_rx_show);
+EXPORT_SYMBOL(ccrypt_decrypt);
+EXPORT_SYMBOL(ccrypt_encrypt);
diff --git a/net/core/dev.c b/net/core/dev.c
index d4a1ec3..8a27519 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -106,6 +106,7 @@ #include <linux/highmem.h>
 #include <linux/init.h>
 #include <linux/kmod.h>
 #include <linux/module.h>
+#include <linux/ccrypt.h>
 #include <linux/kallsyms.h>
 #include <linux/netpoll.h>
 #include <linux/rcupdate.h>
@@ -1441,6 +1442,21 @@ int dev_queue_xmit(struct sk_buff *skb)
 	    __skb_linearize(skb))
 		goto out_kfree_skb;
 
+#ifdef CONFIG_NETDEV_CCRYPT
+	if (skb->dev && skb->dev->ccrypt_tx) {
+		/* TODO: implement non-linearized packet encryption */
+		if (skb_shinfo(skb)->nr_frags) {
+			__skb_linearize(skb);
+		}
+		spin_lock(&skb->dev->ccrypt_tx_lock);
+		if (ccrypt_encrypt(&skb)) {
+			spin_unlock(&skb->dev->ccrypt_tx_lock);
+			goto out_kfree_skb;
+		}
+		spin_unlock(&skb->dev->ccrypt_tx_lock);
+	}
+#endif /* CONFIG_NETDEV_CCRYPT */
+
 	/* If packet is not checksummed and device does not support
 	 * checksumming for this protocol, complete checksumming here.
 	 */
@@ -1789,6 +1805,23 @@ int netif_receive_skb(struct sk_buff *sk
 
 	rcu_read_lock();
 
+#ifdef CONFIG_NETDEV_CCRYPT
+	if (skb->dev && skb->dev->ccrypt_rx) {
+		/* TODO: implement non-linearized packet decryption */
+		if (skb_shinfo(skb)->nr_frags) {
+			__skb_linearize(skb);
+		}
+		spin_lock(&skb->dev->ccrypt_rx_lock);
+		if (ccrypt_decrypt(&skb) != 0) {
+			spin_unlock(&skb->dev->ccrypt_rx_lock);
+			kfree_skb(skb);
+			ret = NET_RX_DROP;
+			goto out;
+		}
+		spin_unlock(&skb->dev->ccrypt_rx_lock);
+	}
+#endif
+
 #ifdef CONFIG_NET_CLS_ACT
 	if (skb->tc_verd & TC_NCLS) {
 		skb->tc_verd = CLR_TC_NCLS(skb->tc_verd);
@@ -3224,6 +3257,10 @@ EXPORT_SYMBOL(alloc_netdev);
  */
 void free_netdev(struct net_device *dev)
 {
+#ifdef CONFIG_NETDEV_CCRYPT
+	ccrypt_tx_reset(dev);
+	ccrypt_rx_reset(dev);
+#endif /* CONFIG_NETDEV_CCRYPT */
 #ifdef CONFIG_SYSFS
 	/*  Compatibility with error handling in drivers */
 	if (dev->reg_state == NETREG_UNINITIALIZED) {
diff --git a/net/core/net-sysfs.c b/net/core/net-sysfs.c
index 1347276..4e828d8 100644
--- a/net/core/net-sysfs.c
+++ b/net/core/net-sysfs.c
@@ -17,6 +17,7 @@ #include <net/sock.h>
 #include <linux/rtnetlink.h>
 #include <linux/wireless.h>
 #include <net/iw_handler.h>
+#include <linux/ccrypt.h>
 
 #define to_class_dev(obj) container_of(obj,struct class_device,kobj)
 #define to_net_dev(class) container_of(class, struct net_device, class_dev)
@@ -234,6 +235,10 @@ static struct class_device_attribute net
 	__ATTR(dormant, S_IRUGO, show_dormant, NULL),
 	__ATTR(operstate, S_IRUGO, show_operstate, NULL),
 	__ATTR(mtu, S_IRUGO | S_IWUSR, show_mtu, store_mtu),
+#ifdef CONFIG_NETDEV_CCRYPT
+	__ATTR(ccrypt_rx, S_IRUGO | S_IWUSR, ccrypt_rx_show, ccrypt_rx_store),
+	__ATTR(ccrypt_tx, S_IRUGO | S_IWUSR, ccrypt_tx_show, ccrypt_tx_store),
+#endif /* CONFIG_NETDEV_CCRYPT */
 	__ATTR(flags, S_IRUGO | S_IWUSR, show_flags, store_flags),
 	__ATTR(tx_queue_len, S_IRUGO | S_IWUSR, show_tx_queue_len,
 	       store_tx_queue_len),
