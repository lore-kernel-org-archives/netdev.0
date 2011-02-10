From: Ian Molton <ian.molton@collabora.co.uk>
Subject: [PATCH] Add JMEMCMP to Berkeley Packet Filters
Date: Thu, 10 Feb 2011 12:31:07 +0000
Message-ID: <1297341067-12264-2-git-send-email-ian.molton@collabora.co.uk>
References: <1297341067-12264-1-git-send-email-ian.molton@collabora.co.uk>
Cc: rdunlap@xenotime.net, isdn@linux-pingi.de, paulus@samba.org,
	arnd@arndb.de, davem@davemloft.net, herbert@gondor.apana.org.au,
	ebiederm@xmission.com, alban.crequy@collabora.co.uk,
	Ian Molton <ian.molton@collabora.co.uk>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from bhuna.collabora.co.uk ([93.93.128.226]:44261 "EHLO
	bhuna.collabora.co.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751591Ab1BJMbk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Feb 2011 07:31:40 -0500
In-Reply-To: <1297341067-12264-1-git-send-email-ian.molton@collabora.co.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch allows a data section to be specified for BPF.

This is made use of by a MEMCMP like instruction.

Testsuite here:
http://git.collabora.co.uk/?p=user/ian/check-bpf.git;a=summary

Issues:
* Do I need to update the headers for all arches, or just generic
* Can sk_run_filter() be called in a context where kmalloc(GFP_KERNEL) is
  not allowed (I think not)
* Data section allocated with second call to sock_kmalloc().
* Should the patch be broken into two - one to add the data uploading,
  one to add the JMEMCMP insn. ?
---
 Documentation/networking/filter.txt |    9 +++
 drivers/isdn/i4l/isdn_ppp.c         |    2 +-
 drivers/net/ppp_generic.c           |    2 +-
 include/asm-generic/socket.h        |    2 +
 include/linux/filter.h              |   17 +++++-
 include/linux/ptp_classify.h        |    2 +-
 net/core/filter.c                   |  115 +++++++++++++++++++++++++++++++++-
 net/core/sock.c                     |   14 ++++
 net/core/timestamping.c             |    4 +-
 net/packet/af_packet.c              |    3 +-
 10 files changed, 158 insertions(+), 12 deletions(-)

diff --git a/Documentation/networking/filter.txt b/Documentation/networking/filter.txt
index bbf2005..d6efb5f 100644
--- a/Documentation/networking/filter.txt
+++ b/Documentation/networking/filter.txt
@@ -31,6 +31,15 @@ the old one and placing your new one in its place, assuming your
 filter has passed the checks, otherwise if it fails the old filter
 will remain on that socket.
 
+Linux packet filters also provide a facility to upload a data section
+for use with the JMEMCMP instruction. This is done using the 
+SO_ATTACH_FILTER_WITH_DATA parameter to setsockopt().
+
+The JMEMCMP instruction allows arbitrary comparisons between the packet
+data and the filters data. The K, A, and X registers provide the offset
+into the data, the number of bytes to compare, and the offset into the
+packet, respectively.
+
 Examples
 ========
 
diff --git a/drivers/isdn/i4l/isdn_ppp.c b/drivers/isdn/i4l/isdn_ppp.c
index 9e8162c..1a0d513 100644
--- a/drivers/isdn/i4l/isdn_ppp.c
+++ b/drivers/isdn/i4l/isdn_ppp.c
@@ -453,7 +453,7 @@ static int get_filter(void __user *arg, struct sock_filter **p)
 	if (IS_ERR(code))
 		return PTR_ERR(code);
 
-	err = sk_chk_filter(code, uprog.len);
+	err = sk_chk_filter(code, uprog.len, NULL);
 	if (err) {
 		kfree(code);
 		return err;
diff --git a/drivers/net/ppp_generic.c b/drivers/net/ppp_generic.c
index 9f6d670..345c3ac 100644
--- a/drivers/net/ppp_generic.c
+++ b/drivers/net/ppp_generic.c
@@ -542,7 +542,7 @@ static int get_filter(void __user *arg, struct sock_filter **p)
 	if (IS_ERR(code))
 		return PTR_ERR(code);
 
-	err = sk_chk_filter(code, uprog.len);
+	err = sk_chk_filter(code, uprog.len, NULL);
 	if (err) {
 		kfree(code);
 		return err;
diff --git a/include/asm-generic/socket.h b/include/asm-generic/socket.h
index 9a6115e..83458b9 100644
--- a/include/asm-generic/socket.h
+++ b/include/asm-generic/socket.h
@@ -64,4 +64,6 @@
 #define SO_DOMAIN		39
 
 #define SO_RXQ_OVFL             40
+
+#define SO_ATTACH_FILTER_WITH_DATA	41
 #endif /* __ASM_GENERIC_SOCKET_H */
diff --git a/include/linux/filter.h b/include/linux/filter.h
index 45266b7..c290e17 100644
--- a/include/linux/filter.h
+++ b/include/linux/filter.h
@@ -35,6 +35,13 @@ struct sock_fprog {	/* Required for SO_ATTACH_FILTER. */
 	struct sock_filter __user *filter;
 };
 
+struct sock_fprog_with_data { /* Required for SO_ATTACH_FILTER_WITH_DATA. */
+	unsigned short			len;    /* Number of filter blocks */
+	unsigned short			data_len;
+	__u8 __user			*data; /* Program data section */
+	struct sock_filter __user	*filter;
+};
+
 /*
  * Instruction classes
  */
@@ -78,6 +85,7 @@ struct sock_fprog {	/* Required for SO_ATTACH_FILTER. */
 #define         BPF_JGT         0x20
 #define         BPF_JGE         0x30
 #define         BPF_JSET        0x40
+#define         BPF_JMEMCMP     0x50
 #define BPF_SRC(code)   ((code) & 0x08)
 #define         BPF_K           0x00
 #define         BPF_X           0x08
@@ -136,6 +144,8 @@ struct sk_filter
 	atomic_t		refcnt;
 	unsigned int         	len;	/* Number of filter blocks */
 	struct rcu_head		rcu;
+	u8			*data;
+	unsigned int		data_len;
 	struct sock_filter     	insns[0];
 };
 
@@ -149,10 +159,13 @@ struct sock;
 
 extern int sk_filter(struct sock *sk, struct sk_buff *skb);
 extern unsigned int sk_run_filter(const struct sk_buff *skb,
-				  const struct sock_filter *filter);
+				  const struct sock_filter *filter,
+				  const u8 *data, const unsigned int data_len);
 extern int sk_attach_filter(struct sock_fprog *fprog, struct sock *sk);
+extern int sk_attach_filter_with_data(struct sock_fprog_with_data *fprog,
+					struct sock *sk);
 extern int sk_detach_filter(struct sock *sk);
-extern int sk_chk_filter(struct sock_filter *filter, int flen);
+extern int sk_chk_filter(struct sock_filter *filter, int flen, u8 *data);
 #endif /* __KERNEL__ */
 
 #endif /* __LINUX_FILTER_H__ */
diff --git a/include/linux/ptp_classify.h b/include/linux/ptp_classify.h
index 943a85a..bfe8f7a 100644
--- a/include/linux/ptp_classify.h
+++ b/include/linux/ptp_classify.h
@@ -79,7 +79,7 @@
 static inline int ptp_filter_init(struct sock_filter *f, int len)
 {
 	if (OP_LDH == f[0].code)
-		return sk_chk_filter(f, len);
+		return sk_chk_filter(f, len, NULL);
 	else
 		return 0;
 }
diff --git a/net/core/filter.c b/net/core/filter.c
index 232b187..eb5f4e2 100644
--- a/net/core/filter.c
+++ b/net/core/filter.c
@@ -85,6 +85,7 @@ enum {
 	BPF_S_JMP_JGT_X,
 	BPF_S_JMP_JSET_K,
 	BPF_S_JMP_JSET_X,
+	BPF_S_JMP_MEMCMP,
 	/* Ancillary data */
 	BPF_S_ANC_PROTOCOL,
 	BPF_S_ANC_PKTTYPE,
@@ -145,7 +146,9 @@ int sk_filter(struct sock *sk, struct sk_buff *skb)
 	rcu_read_lock();
 	filter = rcu_dereference(sk->sk_filter);
 	if (filter) {
-		unsigned int pkt_len = sk_run_filter(skb, filter->insns);
+		unsigned int pkt_len = sk_run_filter(skb, filter->insns,
+							filter->data,
+							filter->data_len);
 
 		err = pkt_len ? pskb_trim(skb, pkt_len) : -EPERM;
 	}
@@ -168,7 +171,8 @@ EXPORT_SYMBOL(sk_filter);
  * flen. (We used to pass to this function the length of filter)
  */
 unsigned int sk_run_filter(const struct sk_buff *skb,
-			   const struct sock_filter *fentry)
+			   const struct sock_filter *fentry,
+			   const u8 *data, const unsigned int data_len)
 {
 	void *ptr;
 	u32 A = 0;			/* Accumulator */
@@ -268,6 +272,46 @@ unsigned int sk_run_filter(const struct sk_buff *skb,
 		case BPF_S_JMP_JSET_X:
 			fentry += (A & X) ? fentry->jt : fentry->jf;
 			continue;
+		case BPF_S_JMP_MEMCMP: {
+			u8 *pkt_data, *tmp_data;
+
+			/* A = Comparison length.
+			 * K = Offset into the data
+			 * X = Offset into the packet
+			 */
+			if (K + A > data_len || X + A > skb->len)
+				return 0;
+
+			/* We should write a skb aware memcmp() and avoid
+			 * copying the contents of the skb
+			 */
+			tmp_data = (u8*)kmalloc(A, GFP_KERNEL);
+
+			if(!tmp_data)
+				return 0;
+
+			/* Load enough bytes to analyse already offset by K */
+			ptr = load_pointer(skb, X, A, tmp_data);
+
+			if (!ptr) {
+				kfree(tmp_data);
+				return 0;
+			}
+
+			pkt_data = (u8 *)ptr;
+
+			/* data will not be NULL here if sk_chk_filter() has
+			 * been called. Since SO_ATTACH_FILTER{,_WITH_DATA}
+			 * both call this, only broken kernel code can cause
+			 * trouble
+			 */
+			fentry += (!memcmp(data + K, pkt_data, A))
+				? fentry->jt : fentry->jf;
+
+			kfree(tmp_data);
+
+			continue;
+		}
 		case BPF_S_LD_W_ABS:
 			k = K;
 load_w:
@@ -492,7 +536,7 @@ error:
  *
  * Returns 0 if the rule set is legal or -EINVAL if not.
  */
-int sk_chk_filter(struct sock_filter *filter, int flen)
+int sk_chk_filter(struct sock_filter *filter, int flen, u8 *data)
 {
 	/*
 	 * Valid instructions are initialized to non-0.
@@ -544,6 +588,7 @@ int sk_chk_filter(struct sock_filter *filter, int flen)
 		[BPF_JMP|BPF_JGT|BPF_X]  = BPF_S_JMP_JGT_X,
 		[BPF_JMP|BPF_JSET|BPF_K] = BPF_S_JMP_JSET_K,
 		[BPF_JMP|BPF_JSET|BPF_X] = BPF_S_JMP_JSET_X,
+		[BPF_JMP|BPF_JMEMCMP|BPF_K|BPF_X|BPF_A] = BPF_S_JMP_MEMCMP,
 	};
 	int pc;
 
@@ -585,6 +630,10 @@ int sk_chk_filter(struct sock_filter *filter, int flen)
 			if (ftest->k >= (unsigned)(flen-pc-1))
 				return -EINVAL;
 			break;
+		case BPF_S_JMP_MEMCMP:
+			if (!data)
+				return -EINVAL;
+			/* Fall through */
 		case BPF_S_JMP_JEQ_K:
 		case BPF_S_JMP_JEQ_X:
 		case BPF_S_JMP_JGE_K:
@@ -672,8 +721,10 @@ int sk_attach_filter(struct sock_fprog *fprog, struct sock *sk)
 
 	atomic_set(&fp->refcnt, 1);
 	fp->len = fprog->len;
+	fp->data = NULL;
+	fp->data_len = 0;
 
-	err = sk_chk_filter(fp->insns, fp->len);
+	err = sk_chk_filter(fp->insns, fp->len, NULL);
 	if (err) {
 		sk_filter_uncharge(sk, fp);
 		return err;
@@ -689,6 +740,62 @@ int sk_attach_filter(struct sock_fprog *fprog, struct sock *sk)
 }
 EXPORT_SYMBOL_GPL(sk_attach_filter);
 
+int sk_attach_filter_with_data(struct sock_fprog_with_data *fprog, struct sock *sk)
+{
+	struct sk_filter *fp, *old_fp;
+	unsigned int fsize = sizeof(struct sock_filter) * fprog->len;
+	unsigned int dsize = fprog->data_len;
+	int err = -ENOMEM;
+
+	/* Make sure new filter is there and in the right amounts. */
+	if (fprog->filter == NULL)
+		return -EINVAL;
+
+	fp = sock_kmalloc(sk, fsize+sizeof(*fp), GFP_KERNEL);
+
+	if (!fp)
+		goto out;
+
+	fp->data = sock_kmalloc(sk, dsize, GFP_KERNEL);
+
+	if(!fp->data)
+		goto out_free;
+
+	if (copy_from_user(fp->data, fprog->data, dsize))
+		goto out_free;
+
+	fp->data_len = dsize;
+
+	if (copy_from_user(fp->insns, fprog->filter, fsize))
+		goto out_free_data;
+
+	atomic_set(&fp->refcnt, 1);
+	fp->len = fprog->len;
+
+	err = sk_chk_filter(fp->insns, fp->len, fp->data);
+	if (err)
+		goto out_uncharge;
+
+	old_fp = rcu_dereference_protected(sk->sk_filter,
+					   sock_owned_by_user(sk));
+	rcu_assign_pointer(sk->sk_filter, fp);
+
+	if (old_fp)
+		sk_filter_uncharge(sk, old_fp);
+
+	return 0;
+
+out_uncharge:
+	sk_filter_uncharge(sk, fp);
+out_free_data:
+	sock_kfree_s(sk, fp->data, dsize);
+out_free:
+	sock_kfree_s(sk, fp, fsize+sizeof(*fp));
+out:
+	return err;
+}
+EXPORT_SYMBOL_GPL(sk_attach_filter_with_data);
+
 int sk_detach_filter(struct sock *sk)
 {
 	int ret = -ENOENT;
diff --git a/net/core/sock.c b/net/core/sock.c
index 7dfed79..627f731 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -714,6 +714,20 @@ set_rcvbuf:
 			ret = sk_attach_filter(&fprog, sk);
 		}
 		break;
+	
+	case SO_ATTACH_FILTER_WITH_DATA:
+		ret = -EINVAL;
+		if (optlen == sizeof(struct sock_fprog_with_data)) {
+			struct sock_fprog_with_data fprog;
+
+			ret = -EFAULT;
+			if (copy_from_user(&fprog, optval,
+						sizeof(fprog)))
+				break;
+
+			ret = sk_attach_filter_with_data(&fprog, sk);
+		}
+		break;
 
 	case SO_DETACH_FILTER:
 		ret = sk_detach_filter(sk);
diff --git a/net/core/timestamping.c b/net/core/timestamping.c
index 7e7ca37..efb9a44 100644
--- a/net/core/timestamping.c
+++ b/net/core/timestamping.c
@@ -31,7 +31,7 @@ static unsigned int classify(const struct sk_buff *skb)
 	if (likely(skb->dev &&
 		   skb->dev->phydev &&
 		   skb->dev->phydev->drv))
-		return sk_run_filter(skb, ptp_filter);
+		return sk_run_filter(skb, ptp_filter, NULL, 0);
 	else
 		return PTP_CLASS_NONE;
 }
@@ -124,5 +124,5 @@ bool skb_defer_rx_timestamp(struct sk_buff *skb)
 
 void __init skb_timestamping_init(void)
 {
-	BUG_ON(sk_chk_filter(ptp_filter, ARRAY_SIZE(ptp_filter)));
+	BUG_ON(sk_chk_filter(ptp_filter, ARRAY_SIZE(ptp_filter), NULL));
 }
diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
index c60649e..7b8bb1b 100644
--- a/net/packet/af_packet.c
+++ b/net/packet/af_packet.c
@@ -525,7 +525,8 @@ static inline unsigned int run_filter(const struct sk_buff *skb,
 	rcu_read_lock();
 	filter = rcu_dereference(sk->sk_filter);
 	if (filter != NULL)
-		res = sk_run_filter(skb, filter->insns);
+		res = sk_run_filter(skb, filter->insns, filter->data,
+					filter->data_len);
 	rcu_read_unlock();
 
 	return res;
-- 
1.7.2.3

