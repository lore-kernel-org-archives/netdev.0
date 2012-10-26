From: Pavel Emelyanov <xemul@parallels.com>
Subject: [PATCH net-next] sk-filter: Add ability to get socket filter program
Date: Fri, 26 Oct 2012 21:15:31 +0400
Message-ID: <508AC533.4000809@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: Linux Netdev List <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:9071 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756705Ab2JZRPl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 26 Oct 2012 13:15:41 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The SO_ATTACH_FILTER option is set only. I propose to add the get
ability by using SO_ATTACH_FILTER in getsockopt. To be less irritating
to eyes the SO_GET_FILTER alias to it is declared.


There are two issues with getting filter back.

First, kernel modifies the sock_filter->code on filter load, thus in
order to return the filter element back to user we have to decode it
into user-visible constants. Fortunately the modification in question
is interconvertible.

Second, the BPF_S_ALU_DIV_K code modifies the command argument k to
speed up the run-time division by doing kernel_k = reciprocal(user_k).
Bad news is that different user_k may result in same kernel_k, so we 
can't get the original user_k back. Good news is that we don't have 
to do it. What we need to is calculate a user2_k so, that

  reciprocal(user2_k) == reciprocal(user_k) == kernel_k

i.e. if it's re-loaded back the compiled again value will be exactly
the same as it was. That said, the user2_k can be calculated like this

  user2_k = reciprocal(kernel_k)

with an exception, that if kernel_k == 0, then user2_k == 1.


The optlen argument is treated like this -- when zero, kernel returns
the amount of sock_fprog elements in filter, otherwise it should be
large enough for the sock_fprog array.

Signed-off-by: Pavel Emelyanov <xemul@parallels.com>
---

diff --git a/include/linux/filter.h b/include/linux/filter.h
index 24d251f..6ca0085 100644
--- a/include/linux/filter.h
+++ b/include/linux/filter.h
@@ -45,6 +45,7 @@ extern void sk_unattached_filter_destroy(struct sk_filter *fp);
 extern int sk_attach_filter(struct sock_fprog *fprog, struct sock *sk);
 extern int sk_detach_filter(struct sock *sk);
 extern int sk_chk_filter(struct sock_filter *filter, unsigned int flen);
+extern int sk_get_filter(struct sock *sk, struct sock_filter __user *filter, unsigned len);
 
 #ifdef CONFIG_BPF_JIT
 extern void bpf_jit_compile(struct sk_filter *fp);
diff --git a/include/uapi/asm-generic/socket.h b/include/uapi/asm-generic/socket.h
index b1bea03..2d32d07 100644
--- a/include/uapi/asm-generic/socket.h
+++ b/include/uapi/asm-generic/socket.h
@@ -43,6 +43,7 @@
 /* Socket filtering */
 #define SO_ATTACH_FILTER	26
 #define SO_DETACH_FILTER	27
+#define SO_GET_FILTER		SO_ATTACH_FILTER
 
 #define SO_PEERNAME		28
 #define SO_TIMESTAMP		29
diff --git a/net/core/filter.c b/net/core/filter.c
index 3d92ebb..0a8cb99 100644
--- a/net/core/filter.c
+++ b/net/core/filter.c
@@ -751,3 +751,131 @@ int sk_detach_filter(struct sock *sk)
 	return ret;
 }
 EXPORT_SYMBOL_GPL(sk_detach_filter);
+
+static void sk_decode_filter(struct sock_filter *filt, struct sock_filter *to)
+{
+	static const u16 decodes[] = {
+		[BPF_S_ALU_ADD_K]	= BPF_ALU|BPF_ADD|BPF_K,
+		[BPF_S_ALU_ADD_X]	= BPF_ALU|BPF_ADD|BPF_X,
+		[BPF_S_ALU_SUB_K]	= BPF_ALU|BPF_SUB|BPF_K,
+		[BPF_S_ALU_SUB_X]	= BPF_ALU|BPF_SUB|BPF_X,
+		[BPF_S_ALU_MUL_K]	= BPF_ALU|BPF_MUL|BPF_K,
+		[BPF_S_ALU_MUL_X]	= BPF_ALU|BPF_MUL|BPF_X,
+		[BPF_S_ALU_DIV_X]	= BPF_ALU|BPF_DIV|BPF_X,
+		[BPF_S_ALU_MOD_K]	= BPF_ALU|BPF_MOD|BPF_K,
+		[BPF_S_ALU_MOD_X]	= BPF_ALU|BPF_MOD|BPF_X,
+		[BPF_S_ALU_AND_K]	= BPF_ALU|BPF_AND|BPF_K,
+		[BPF_S_ALU_AND_X]	= BPF_ALU|BPF_AND|BPF_X,
+		[BPF_S_ALU_OR_K]	= BPF_ALU|BPF_OR|BPF_K,
+		[BPF_S_ALU_OR_X]	= BPF_ALU|BPF_OR|BPF_X,
+		[BPF_S_ALU_XOR_K]	= BPF_ALU|BPF_XOR|BPF_K,
+		[BPF_S_ALU_XOR_X]	= BPF_ALU|BPF_XOR|BPF_X,
+		[BPF_S_ALU_LSH_K]	= BPF_ALU|BPF_LSH|BPF_K,
+		[BPF_S_ALU_LSH_X]	= BPF_ALU|BPF_LSH|BPF_X,
+		[BPF_S_ALU_RSH_K]	= BPF_ALU|BPF_RSH|BPF_K,
+		[BPF_S_ALU_RSH_X]	= BPF_ALU|BPF_RSH|BPF_X,
+		[BPF_S_ALU_NEG]		= BPF_ALU|BPF_NEG,
+		[BPF_S_LD_W_ABS]	= BPF_LD|BPF_W|BPF_ABS,
+		[BPF_S_LD_H_ABS]	= BPF_LD|BPF_H|BPF_ABS,
+		[BPF_S_LD_B_ABS]	= BPF_LD|BPF_B|BPF_ABS,
+		[BPF_S_ANC_PROTOCOL]	= BPF_LD|BPF_B|BPF_ABS,
+		[BPF_S_ANC_PKTTYPE]	= BPF_LD|BPF_B|BPF_ABS,
+		[BPF_S_ANC_IFINDEX]	= BPF_LD|BPF_B|BPF_ABS,
+		[BPF_S_ANC_NLATTR]	= BPF_LD|BPF_B|BPF_ABS,
+		[BPF_S_ANC_NLATTR_NEST]	= BPF_LD|BPF_B|BPF_ABS,
+		[BPF_S_ANC_MARK]	= BPF_LD|BPF_B|BPF_ABS,
+		[BPF_S_ANC_QUEUE]	= BPF_LD|BPF_B|BPF_ABS,
+		[BPF_S_ANC_HATYPE]	= BPF_LD|BPF_B|BPF_ABS,
+		[BPF_S_ANC_RXHASH]	= BPF_LD|BPF_B|BPF_ABS,
+		[BPF_S_ANC_CPU]		= BPF_LD|BPF_B|BPF_ABS,
+		[BPF_S_ANC_ALU_XOR_X]	= BPF_LD|BPF_B|BPF_ABS,
+		[BPF_S_ANC_SECCOMP_LD_W] = BPF_LD|BPF_B|BPF_ABS,
+		[BPF_S_LD_W_LEN]	= BPF_LD|BPF_W|BPF_LEN,
+		[BPF_S_LD_W_IND]	= BPF_LD|BPF_W|BPF_IND,
+		[BPF_S_LD_H_IND]	= BPF_LD|BPF_H|BPF_IND,
+		[BPF_S_LD_B_IND]	= BPF_LD|BPF_B|BPF_IND,
+		[BPF_S_LD_IMM]		= BPF_LD|BPF_IMM,
+		[BPF_S_LDX_W_LEN]	= BPF_LDX|BPF_W|BPF_LEN,
+		[BPF_S_LDX_B_MSH]	= BPF_LDX|BPF_B|BPF_MSH,
+		[BPF_S_LDX_IMM]		= BPF_LDX|BPF_IMM,
+		[BPF_S_MISC_TAX]	= BPF_MISC|BPF_TAX,
+		[BPF_S_MISC_TXA]	= BPF_MISC|BPF_TXA,
+		[BPF_S_RET_K]		= BPF_RET|BPF_K,
+		[BPF_S_RET_A]		= BPF_RET|BPF_A,
+		[BPF_S_ALU_DIV_K]	= BPF_ALU|BPF_DIV|BPF_K,
+		[BPF_S_LD_MEM]		= BPF_LD|BPF_MEM,
+		[BPF_S_LDX_MEM]		= BPF_LDX|BPF_MEM,
+		[BPF_S_ST]		= BPF_ST,
+		[BPF_S_STX]		= BPF_STX,
+		[BPF_S_JMP_JA]		= BPF_JMP|BPF_JA,
+		[BPF_S_JMP_JEQ_K]	= BPF_JMP|BPF_JEQ|BPF_K,
+		[BPF_S_JMP_JEQ_X]	= BPF_JMP|BPF_JEQ|BPF_X,
+		[BPF_S_JMP_JGE_K]	= BPF_JMP|BPF_JGE|BPF_K,
+		[BPF_S_JMP_JGE_X]	= BPF_JMP|BPF_JGE|BPF_X,
+		[BPF_S_JMP_JGT_K]	= BPF_JMP|BPF_JGT|BPF_K,
+		[BPF_S_JMP_JGT_X]	= BPF_JMP|BPF_JGT|BPF_X,
+		[BPF_S_JMP_JSET_K]	= BPF_JMP|BPF_JSET|BPF_K,
+		[BPF_S_JMP_JSET_X]	= BPF_JMP|BPF_JSET|BPF_X,
+	};
+	u16 code;
+
+	code = filt->code;
+
+	to->code = decodes[code];
+	to->jt = filt->jt;
+	to->jf = filt->jf;
+
+	if (code == BPF_S_ALU_DIV_K) {
+		/*
+		 * When loaded this rule user gave us X, which was
+		 * translated into R = r(X). Now we calculate the
+		 * RR = r(R) and report it back. If next time this
+		 * value is loaded and RRR = r(RR) is calculated
+		 * then the R == RRR will be true.
+		 *
+		 * One exception. X == 1 translates into R == 0 and
+		 * we can't calculate RR out of it with r().
+		 */
+
+		if (filt->k == 0)
+			to->k = 1;
+		else
+			to->k = reciprocal_value(filt->k);
+
+		BUG_ON(reciprocal_value(to->k) != filt->k);
+	} else
+		to->k = filt->k;
+}
+
+int sk_get_filter(struct sock *sk, struct sock_filter __user *ubuf, unsigned int len)
+{
+	struct sk_filter *filter;
+	int i, ret;
+
+	lock_sock(sk);
+	filter = rcu_dereference_protected(sk->sk_filter,
+			sock_owned_by_user(sk));
+	ret = 0;
+	if (!filter)
+		goto out;
+	ret = filter->len;
+	if (!len)
+		goto out;
+	ret = -EINVAL;
+	if (len < filter->len)
+		goto out;
+
+	ret = -EFAULT;
+	for (i = 0; i < filter->len; i++) {
+		struct sock_filter fb;
+
+		sk_decode_filter(&filter->insns[i], &fb);
+		if (copy_to_user(&ubuf[i], &fb, sizeof(fb)))
+			goto out;
+	}
+
+	ret = filter->len;
+out:
+	release_sock(sk);
+	return ret;
+}
diff --git a/net/core/sock.c b/net/core/sock.c
index 0a023b8..0628600 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -1077,6 +1077,12 @@ int sock_getsockopt(struct socket *sock, int level, int optname,
 	case SO_BINDTODEVICE:
 		v.val = sk->sk_bound_dev_if;
 		break;
+	case SO_GET_FILTER:
+		len = sk_get_filter(sk, (struct sock_filter __user *)optval, len);
+		if (len < 0)
+			return len;
+
+		goto lenout;
 	default:
 		return -ENOPROTOOPT;
 	}
