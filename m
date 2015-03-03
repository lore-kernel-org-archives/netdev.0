From: Christian Seiler <christian@iwakd.de>
Subject: [PATCH] net: add SO_MAX_DGRAM_QLEN for AF_UNIX SOCK_DGRAM sockets
Date: Tue,  3 Mar 2015 01:32:54 +0100
Message-ID: <1425342774-32667-1-git-send-email-christian@iwakd.de>
Cc: Christian Seiler <christian@iwakd.de>,
	Dan Ballard <dan@mindstab.net>,
	Eric Dumazet <edumazet@google.com>,
	"David S. Miller" <davem@davemloft.net>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	linux-api@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from arafel.iwakd.de ([78.46.72.57]:46575 "EHLO arafel.iwakd.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754262AbbCCAmB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 2 Mar 2015 19:42:01 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Allow applications to set their own value for the maximum length of the
receive queue of SOCK_DGRAM AF_UNIX sockets. The default remains the
current value of /proc/sys/net/unix/max_dgram_qlen, which is kept at a
initial value of 10.

Rationale: applications may want to control how many datagrams the
kernel buffers before senders are blocked. A prominent example would be
to create a socket for syslog early at boot but only consume messages
once enough of the system has been set up. The default queue length of
11 messages (= 10 + 1) is too low for this kind of application.

Details:

The value chosen by applications may at most be the limit defined by
the new sysctl max_dgram_qlen_limit. The limit defaults to 2047
(allowing 2048 datagrams to be queued). If the value specified exceeds
the limit, the limit will be used, so applications don't need to try to
guess what the limit is before trying to set it, in analogy to
SO_SNDBUF/SO_RCVBUF.

Also, in analogy to SO_SNDBUF/SO_RCVBUF, a SO_MAX_DGRAM_QLEN_FORCE
option is provided for privileged users to force a higher limit. As
with SO_SNDBUF/SO_RCVBUF, CAP_NET_ADMIN in the init_user_ns is required
for this.

The setsockopt/getsockopt implementations explicitly check to see if
the socket is a UNIX domain socket of type SOCK_DGRAM, otherwise both
will fail. This ensures that listen() for non-datagram sockets is not
broken, since the datagram receive code internally uses the
sk->sk_max_ack_backlog field.

This is inspired by a patch previously submitted to LKML:
<https://lkml.org/lkml/2014/1/22/256>

Cc: Dan Ballard <dan@mindstab.net>
Cc: Eric Dumazet <edumazet@google.com>
Cc: David S. Miller <davem@davemloft.net>
Cc: Hannes Frederic Sowa <hannes@stressinduktion.org>
Cc: linux-api@vger.kernel.org
Signed-off-by: Christian Seiler <christian@iwakd.de>

---

Addendum for the rationale: this has been on the wishlist of the
systemd developers for quite a while. If one wants to configure systemd
to forward log messages  to syslog, the only way to do that reliably
now is to increase max_dgram_qlen globally.

I have hopefully addressed the issues brought up in the review of the
patch that inspired this change (arch-stuff, listen(), configurable
limit, unsigned short range check).

I only have access to x86. I've touched all of the corresponding arch
files where I could find other SO_ options, but this has only been
compiled and tested on x86_64.

checkpatch.pl gives me one error, i.e. that there are no spaces before
and after an equal sign in sysctl.h, but there I just followed the rest
of the code. The two warnings it shows me are lines longer than 80
characters; in sysctl_binary.c it follows the rest of the code and in
sock.c I don't think I could make that more readable with less.

OPEN ISSUE: this is somewhat of a generic problem with network
namespaces: upon creation, the parameters are initialized by their
defaults, so each network namespace has the same initial parameters.
This means that for net_ns created within user_ns != init_user_ns,
where sysctls are not exported, the max_dgram_qlen{,_limit} settings
can't be changed at all and will always take the hard-coded default
values, which may or may not be desirable, depending on your
standpoint.

Documentation: this patch updates the documentation in Documentation/,
and I have also prepared a draft update to the man pages, should this
patch be accepted, pushed to github at:
<https://github.com/chris-se/linux-kernel-man-pages/commit/116ebc1e8a14ea0eaffd749c8d19e66c597dabc7>

Note that this is my first submission to the Linux kernel and since
this modfies a lot of arch-specific files, get_maintainer.pl was
decidedly unhelpful (unless I really should write to the maintainers of
every single arch?). If I should have added somebody else to Cc or sent
this somewhere else, please tell me.

 Documentation/networking/ip-sysctl.txt |  6 +++++
 arch/alpha/include/uapi/asm/socket.h   |  3 +++
 arch/avr32/include/uapi/asm/socket.h   |  3 +++
 arch/cris/include/uapi/asm/socket.h    |  3 +++
 arch/frv/include/uapi/asm/socket.h     |  3 +++
 arch/ia64/include/uapi/asm/socket.h    |  3 +++
 arch/m32r/include/uapi/asm/socket.h    |  3 +++
 arch/mips/include/uapi/asm/socket.h    |  3 +++
 arch/mn10300/include/uapi/asm/socket.h |  3 +++
 arch/parisc/include/uapi/asm/socket.h  |  3 +++
 arch/powerpc/include/uapi/asm/socket.h |  3 +++
 arch/s390/include/uapi/asm/socket.h    |  3 +++
 arch/sparc/include/uapi/asm/socket.h   |  3 +++
 arch/xtensa/include/uapi/asm/socket.h  |  3 +++
 include/net/netns/unix.h               |  1 +
 include/uapi/asm-generic/socket.h      |  3 +++
 include/uapi/linux/sysctl.h            |  1 +
 kernel/sysctl_binary.c                 |  1 +
 net/core/sock.c                        | 49 ++++++++++++++++++++++++++++++++++
 net/unix/af_unix.c                     |  1 +
 net/unix/sysctl_net_unix.c             | 41 ++++++++++++++++++++++++++++
 21 files changed, 142 insertions(+)

diff --git a/Documentation/networking/ip-sysctl.txt b/Documentation/networking/ip-sysctl.txt
index 1b8c964..208132b 100644
--- a/Documentation/networking/ip-sysctl.txt
+++ b/Documentation/networking/ip-sysctl.txt
@@ -1794,6 +1794,12 @@ max_dgram_qlen - INTEGER
 
 	Default: 10
 
+max_dgram_qlen_limit - INTEGER
+	The maximum length a non-privileged user may set the dgram socket
+	receive queue to.
+
+	Default: 2047
+
 
 UNDOCUMENTED:
 
diff --git a/arch/alpha/include/uapi/asm/socket.h b/arch/alpha/include/uapi/asm/socket.h
index 9a20821..20c5fa5 100644
--- a/arch/alpha/include/uapi/asm/socket.h
+++ b/arch/alpha/include/uapi/asm/socket.h
@@ -92,4 +92,7 @@
 #define SO_ATTACH_BPF		50
 #define SO_DETACH_BPF		SO_DETACH_FILTER
 
+#define SO_MAX_DGRAM_QLEN       51
+#define SO_MAX_DGRAM_QLEN_FORCE 52
+
 #endif /* _UAPI_ASM_SOCKET_H */
diff --git a/arch/avr32/include/uapi/asm/socket.h b/arch/avr32/include/uapi/asm/socket.h
index 2b65ed6..2a59ca2 100644
--- a/arch/avr32/include/uapi/asm/socket.h
+++ b/arch/avr32/include/uapi/asm/socket.h
@@ -85,4 +85,7 @@
 #define SO_ATTACH_BPF		50
 #define SO_DETACH_BPF		SO_DETACH_FILTER
 
+#define SO_MAX_DGRAM_QLEN       51
+#define SO_MAX_DGRAM_QLEN_FORCE 52
+
 #endif /* _UAPI__ASM_AVR32_SOCKET_H */
diff --git a/arch/cris/include/uapi/asm/socket.h b/arch/cris/include/uapi/asm/socket.h
index e2503d9f..b7a3b5d 100644
--- a/arch/cris/include/uapi/asm/socket.h
+++ b/arch/cris/include/uapi/asm/socket.h
@@ -87,6 +87,9 @@
 #define SO_ATTACH_BPF		50
 #define SO_DETACH_BPF		SO_DETACH_FILTER
 
+#define SO_MAX_DGRAM_QLEN       51
+#define SO_MAX_DGRAM_QLEN_FORCE 52
+
 #endif /* _ASM_SOCKET_H */
 
 
diff --git a/arch/frv/include/uapi/asm/socket.h b/arch/frv/include/uapi/asm/socket.h
index 4823ad1..f656613 100644
--- a/arch/frv/include/uapi/asm/socket.h
+++ b/arch/frv/include/uapi/asm/socket.h
@@ -85,5 +85,8 @@
 #define SO_ATTACH_BPF		50
 #define SO_DETACH_BPF		SO_DETACH_FILTER
 
+#define SO_MAX_DGRAM_QLEN       51
+#define SO_MAX_DGRAM_QLEN_FORCE 52
+
 #endif /* _ASM_SOCKET_H */
 
diff --git a/arch/ia64/include/uapi/asm/socket.h b/arch/ia64/include/uapi/asm/socket.h
index 59be3d8..dea5bf6 100644
--- a/arch/ia64/include/uapi/asm/socket.h
+++ b/arch/ia64/include/uapi/asm/socket.h
@@ -94,4 +94,7 @@
 #define SO_ATTACH_BPF		50
 #define SO_DETACH_BPF		SO_DETACH_FILTER
 
+#define SO_MAX_DGRAM_QLEN       51
+#define SO_MAX_DGRAM_QLEN_FORCE 52
+
 #endif /* _ASM_IA64_SOCKET_H */
diff --git a/arch/m32r/include/uapi/asm/socket.h b/arch/m32r/include/uapi/asm/socket.h
index 7bc4cb2..876ba82 100644
--- a/arch/m32r/include/uapi/asm/socket.h
+++ b/arch/m32r/include/uapi/asm/socket.h
@@ -85,4 +85,7 @@
 #define SO_ATTACH_BPF		50
 #define SO_DETACH_BPF		SO_DETACH_FILTER
 
+#define SO_MAX_DGRAM_QLEN       51
+#define SO_MAX_DGRAM_QLEN_FORCE 52
+
 #endif /* _ASM_M32R_SOCKET_H */
diff --git a/arch/mips/include/uapi/asm/socket.h b/arch/mips/include/uapi/asm/socket.h
index dec3c85..20d7ece 100644
--- a/arch/mips/include/uapi/asm/socket.h
+++ b/arch/mips/include/uapi/asm/socket.h
@@ -103,4 +103,7 @@
 #define SO_ATTACH_BPF		50
 #define SO_DETACH_BPF		SO_DETACH_FILTER
 
+#define SO_MAX_DGRAM_QLEN       51
+#define SO_MAX_DGRAM_QLEN_FORCE 52
+
 #endif /* _UAPI_ASM_SOCKET_H */
diff --git a/arch/mn10300/include/uapi/asm/socket.h b/arch/mn10300/include/uapi/asm/socket.h
index cab7d6d..60fffd1 100644
--- a/arch/mn10300/include/uapi/asm/socket.h
+++ b/arch/mn10300/include/uapi/asm/socket.h
@@ -85,4 +85,7 @@
 #define SO_ATTACH_BPF		50
 #define SO_DETACH_BPF		SO_DETACH_FILTER
 
+#define SO_MAX_DGRAM_QLEN       51
+#define SO_MAX_DGRAM_QLEN_FORCE 52
+
 #endif /* _ASM_SOCKET_H */
diff --git a/arch/parisc/include/uapi/asm/socket.h b/arch/parisc/include/uapi/asm/socket.h
index a5cd40c..b155b48 100644
--- a/arch/parisc/include/uapi/asm/socket.h
+++ b/arch/parisc/include/uapi/asm/socket.h
@@ -84,4 +84,7 @@
 #define SO_ATTACH_BPF		0x402B
 #define SO_DETACH_BPF		SO_DETACH_FILTER
 
+#define SO_MAX_DGRAM_QLEN       0x402C
+#define SO_MAX_DGRAM_QLEN_FORCE 0x402D
+
 #endif /* _UAPI_ASM_SOCKET_H */
diff --git a/arch/powerpc/include/uapi/asm/socket.h b/arch/powerpc/include/uapi/asm/socket.h
index c046666..732ffb7 100644
--- a/arch/powerpc/include/uapi/asm/socket.h
+++ b/arch/powerpc/include/uapi/asm/socket.h
@@ -92,4 +92,7 @@
 #define SO_ATTACH_BPF		50
 #define SO_DETACH_BPF		SO_DETACH_FILTER
 
+#define SO_MAX_DGRAM_QLEN       51
+#define SO_MAX_DGRAM_QLEN_FORCE 52
+
 #endif	/* _ASM_POWERPC_SOCKET_H */
diff --git a/arch/s390/include/uapi/asm/socket.h b/arch/s390/include/uapi/asm/socket.h
index 296942d..3dd7e1f 100644
--- a/arch/s390/include/uapi/asm/socket.h
+++ b/arch/s390/include/uapi/asm/socket.h
@@ -91,4 +91,7 @@
 #define SO_ATTACH_BPF		50
 #define SO_DETACH_BPF		SO_DETACH_FILTER
 
+#define SO_MAX_DGRAM_QLEN       51
+#define SO_MAX_DGRAM_QLEN_FORCE 52
+
 #endif /* _ASM_SOCKET_H */
diff --git a/arch/sparc/include/uapi/asm/socket.h b/arch/sparc/include/uapi/asm/socket.h
index e6a16c4..13a6b6d 100644
--- a/arch/sparc/include/uapi/asm/socket.h
+++ b/arch/sparc/include/uapi/asm/socket.h
@@ -81,6 +81,9 @@
 #define SO_ATTACH_BPF		0x0034
 #define SO_DETACH_BPF		SO_DETACH_FILTER
 
+#define SO_MAX_DGRAM_QLEN       0x0035
+#define SO_MAX_DGRAM_QLEN_FORCE 0x0036
+
 /* Security levels - as per NRL IPv6 - don't actually do anything */
 #define SO_SECURITY_AUTHENTICATION		0x5001
 #define SO_SECURITY_ENCRYPTION_TRANSPORT	0x5002
diff --git a/arch/xtensa/include/uapi/asm/socket.h b/arch/xtensa/include/uapi/asm/socket.h
index 4120af0..79f0d2f 100644
--- a/arch/xtensa/include/uapi/asm/socket.h
+++ b/arch/xtensa/include/uapi/asm/socket.h
@@ -96,4 +96,7 @@
 #define SO_ATTACH_BPF		50
 #define SO_DETACH_BPF		SO_DETACH_FILTER
 
+#define SO_MAX_DGRAM_QLEN       51
+#define SO_MAX_DGRAM_QLEN_FORCE 52
+
 #endif	/* _XTENSA_SOCKET_H */
diff --git a/include/net/netns/unix.h b/include/net/netns/unix.h
index 284649d..4d0803c 100644
--- a/include/net/netns/unix.h
+++ b/include/net/netns/unix.h
@@ -7,6 +7,7 @@
 struct ctl_table_header;
 struct netns_unix {
 	int			sysctl_max_dgram_qlen;
+	int			sysctl_max_dgram_qlen_limit;
 	struct ctl_table_header	*ctl;
 };
 
diff --git a/include/uapi/asm-generic/socket.h b/include/uapi/asm-generic/socket.h
index 5c15c2a..fba1974 100644
--- a/include/uapi/asm-generic/socket.h
+++ b/include/uapi/asm-generic/socket.h
@@ -87,4 +87,7 @@
 #define SO_ATTACH_BPF		50
 #define SO_DETACH_BPF		SO_DETACH_FILTER
 
+#define SO_MAX_DGRAM_QLEN       51
+#define SO_MAX_DGRAM_QLEN_FORCE 52
+
 #endif /* __ASM_GENERIC_SOCKET_H */
diff --git a/include/uapi/linux/sysctl.h b/include/uapi/linux/sysctl.h
index 0956373..d62d83b 100644
--- a/include/uapi/linux/sysctl.h
+++ b/include/uapi/linux/sysctl.h
@@ -289,6 +289,7 @@ enum
 	NET_UNIX_DESTROY_DELAY=1,
 	NET_UNIX_DELETE_DELAY=2,
 	NET_UNIX_MAX_DGRAM_QLEN=3,
+	NET_UNIX_MAX_DGRAM_QLEN_LIMIT=4,
 };
 
 /* /proc/sys/net/netfilter */
diff --git a/kernel/sysctl_binary.c b/kernel/sysctl_binary.c
index 7e7746a..bce8059 100644
--- a/kernel/sysctl_binary.c
+++ b/kernel/sysctl_binary.c
@@ -203,6 +203,7 @@ static const struct bin_table bin_net_unix_table[] = {
 	/* NET_UNIX_DESTROY_DELAY unused */
 	/* NET_UNIX_DELETE_DELAY unused */
 	{ CTL_INT,	NET_UNIX_MAX_DGRAM_QLEN,	"max_dgram_qlen" },
+	{ CTL_INT,	NET_UNIX_MAX_DGRAM_QLEN_LIMIT,	"max_dgram_qlen_limit" },
 	{}
 };
 
diff --git a/net/core/sock.c b/net/core/sock.c
index 93c8b20..91af187 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -973,6 +973,42 @@ set_rcvbuf:
 					 sk->sk_max_pacing_rate);
 		break;
 
+	case SO_MAX_DGRAM_QLEN:
+#ifdef CONFIG_UNIX
+		/* Only do this for UNIX datagram sockets,
+		 * because listen() uses the same field.
+		 */
+		if (sock->ops->family == PF_UNIX &&
+		    sk->sk_type == SOCK_DGRAM) {
+			/* As with SO_SNDBUF/SO_RCVBUF, don't let
+			 * applications play a game of finding out the
+			 * largest possible value.
+			 */
+			val = min_t(u32, val, sock_net(sk)->unx.sysctl_max_dgram_qlen_limit);
+set_max_dgram_qlen:
+			if (val < 0 || val > USHRT_MAX)
+				ret = -EINVAL;
+			else
+				sk->sk_max_ack_backlog = val;
+			break;
+		}
+#endif
+		ret = -ENOPROTOOPT;
+		break;
+
+	case SO_MAX_DGRAM_QLEN_FORCE:
+#ifdef CONFIG_UNIX
+		if (sock->ops->family == PF_UNIX &&
+		    sk->sk_type == SOCK_DGRAM) {
+			if (capable(CAP_NET_ADMIN))
+				goto set_max_dgram_qlen;
+			ret = -EPERM;
+			break;
+		}
+#endif
+		ret = -ENOPROTOOPT;
+		break;
+
 	default:
 		ret = -ENOPROTOOPT;
 		break;
@@ -1233,6 +1269,19 @@ int sock_getsockopt(struct socket *sock, int level, int optname,
 		v.val = sk->sk_incoming_cpu;
 		break;
 
+	case SO_MAX_DGRAM_QLEN:
+#ifdef CONFIG_UNIX
+		/* Only do this for UNIX datagram sockets,
+		 * because listen() uses the same field.
+		 */
+		if (sock->ops->family == PF_UNIX &&
+		    sk->sk_type == SOCK_DGRAM) {
+			v.val = sk->sk_max_ack_backlog;
+			break;
+		}
+#endif
+		return -ENOPROTOOPT;
+
 	default:
 		return -ENOPROTOOPT;
 	}
diff --git a/net/unix/af_unix.c b/net/unix/af_unix.c
index 526b6ed..33fec15 100644
--- a/net/unix/af_unix.c
+++ b/net/unix/af_unix.c
@@ -2406,6 +2406,7 @@ static int __net_init unix_net_init(struct net *net)
 	int error = -ENOMEM;
 
 	net->unx.sysctl_max_dgram_qlen = 10;
+	net->unx.sysctl_max_dgram_qlen_limit = 2047;
 	if (unix_sysctl_register(net))
 		goto out;
 
diff --git a/net/unix/sysctl_net_unix.c b/net/unix/sysctl_net_unix.c
index b3d5150..b4c75a7 100644
--- a/net/unix/sysctl_net_unix.c
+++ b/net/unix/sysctl_net_unix.c
@@ -15,12 +15,23 @@
 
 #include <net/af_unix.h>
 
+static int proc_unix_do_dgram_qlen(struct ctl_table *ctl, int write,
+				   void __user *buffer, size_t *lenp,
+				   loff_t *ppos);
+
 static struct ctl_table unix_table[] = {
 	{
 		.procname	= "max_dgram_qlen",
 		.data		= &init_net.unx.sysctl_max_dgram_qlen,
 		.maxlen		= sizeof(int),
 		.mode		= 0644,
+		.proc_handler	= proc_unix_do_dgram_qlen
+	},
+	{
+		.procname	= "max_dgram_qlen_limit",
+		.data		= &init_net.unx.sysctl_max_dgram_qlen_limit,
+		.maxlen		= sizeof(int),
+		.mode		= 0644,
 		.proc_handler	= proc_dointvec
 	},
 	{ }
@@ -39,6 +50,7 @@ int __net_init unix_sysctl_register(struct net *net)
 		table[0].procname = NULL;
 
 	table[0].data = &net->unx.sysctl_max_dgram_qlen;
+	table[1].data = &net->unx.sysctl_max_dgram_qlen_limit;
 	net->unx.ctl = register_net_sysctl(net, "net/unix", table);
 	if (net->unx.ctl == NULL)
 		goto err_reg;
@@ -59,3 +71,32 @@ void unix_sysctl_unregister(struct net *net)
 	unregister_net_sysctl_table(net->unx.ctl);
 	kfree(table);
 }
+
+int proc_unix_do_dgram_qlen(struct ctl_table *ctl, int write,
+			    void __user *buffer, size_t *lenp,
+			    loff_t *ppos)
+{
+	struct net *net = current->nsproxy->net_ns;
+	struct ctl_table tbl;
+	int ret, new_value;
+
+	memset(&tbl, 0, sizeof(struct ctl_table));
+	tbl.maxlen = sizeof(unsigned int);
+
+	if (write)
+		tbl.data = &new_value;
+	else
+		tbl.data = &net->unx.sysctl_max_dgram_qlen;
+
+	ret = proc_dointvec(&tbl, write, buffer, lenp, ppos);
+	if (write && ret == 0) {
+		if (new_value > net->unx.sysctl_max_dgram_qlen_limit) {
+			pr_warn_once("New value of max_dgram_qlen higher than max_dgram_qlen_limit, also adjusting the latter.");
+			net->unx.sysctl_max_dgram_qlen_limit = new_value;
+		}
+
+		net->unx.sysctl_max_dgram_qlen = new_value;
+	}
+
+	return ret;
+}
-- 
2.1.4
