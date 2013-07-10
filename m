From: Eliezer Tamir <eliezer.tamir@linux.intel.com>
Subject: [PATCH net-next 3/3] net: rename busy poll socket op
	and globals
Date: Wed, 10 Jul 2013 14:55:18 +0300
Message-ID: <20130710115518.12715.14118.stgit@ladj378.jer.intel.com>
References: <20130710115459.12715.80492.stgit@ladj378.jer.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Willem de Bruijn <willemb@google.com>, Jonathan Corbet <corbet@lwn.net>,
	e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	Amir Vadai <amirv@mellanox.com>, linux-kernel@vger.kernel.org,
	Eliezer Tamir <eliezer@tamir.org.il>,
	Eilon Greenstein <eilong@broadcom.com>, Eric Dumazet <erdnetdev@gmail.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Linus Torvalds <torvalds@linux-foundation.org>
To: David Miller <davem@davemloft.net>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <20130710115459.12715.80492.stgit@ladj378.jer.intel.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

Rename LL_SO to BUSY_POLL_SO
Rename sysctl_net_ll_{read,poll} to sysctl_busy_{read,poll}
Fix up users of these variables.
Fix documentation for sysctl.

a patch for the socket.7  man page will follow separately,
because of limitations of my mail setup.

Signed-off-by: Eliezer Tamir <eliezer.tamir@linux.intel.com>
---

 Documentation/sysctl/net.txt           |   17 +++++++++--------
 arch/alpha/include/uapi/asm/socket.h   |    2 +-
 arch/avr32/include/uapi/asm/socket.h   |    2 +-
 arch/cris/include/uapi/asm/socket.h    |    2 +-
 arch/frv/include/uapi/asm/socket.h     |    2 +-
 arch/h8300/include/uapi/asm/socket.h   |    2 +-
 arch/ia64/include/uapi/asm/socket.h    |    2 +-
 arch/m32r/include/uapi/asm/socket.h    |    2 +-
 arch/mips/include/uapi/asm/socket.h    |    2 +-
 arch/mn10300/include/uapi/asm/socket.h |    2 +-
 arch/parisc/include/uapi/asm/socket.h  |    2 +-
 arch/powerpc/include/uapi/asm/socket.h |    2 +-
 arch/s390/include/uapi/asm/socket.h    |    2 +-
 arch/sparc/include/uapi/asm/socket.h   |    2 +-
 arch/xtensa/include/uapi/asm/socket.h  |    2 +-
 include/net/busy_poll.h                |    8 ++++----
 include/uapi/asm-generic/socket.h      |    2 +-
 net/core/sock.c                        |    6 +++---
 net/core/sysctl_net_core.c             |    8 ++++----
 net/socket.c                           |    4 ++--
 20 files changed, 37 insertions(+), 36 deletions(-)

diff --git a/Documentation/sysctl/net.txt b/Documentation/sysctl/net.txt
index 7323b88..2ac378f 100644
--- a/Documentation/sysctl/net.txt
+++ b/Documentation/sysctl/net.txt
@@ -50,26 +50,27 @@ The maximum number of packets that kernel can handle on a NAPI interrupt,
 it's a Per-CPU variable.
 Default: 64
 
-low_latency_read
+busy_read
 ----------------
 Low latency busy poll timeout for socket reads. (needs CONFIG_NET_LL_RX_POLL)
 Approximate time in us to busy loop waiting for packets on the device queue.
-This sets the default value of the SO_LL socket option.
-Can be set or overridden per socket by setting socket option SO_LL, which is
-the preferred method of enabling.
-If you need to enable the feature globally via sysctl, a value of 50 is recommended.
+This sets the default value of the SO_BUSY_POLL socket option.
+Can be set or overridden per socket by setting socket option SO_BUSY_POLL,
+which is the preferred method of enabling. If you need to enable the feature
+globally via sysctl, a value of 50 is recommended.
 Will increase power usage.
 Default: 0 (off)
 
-low_latency_poll
+busy_poll
 ----------------
 Low latency busy poll timeout for poll and select. (needs CONFIG_NET_LL_RX_POLL)
 Approximate time in us to busy loop waiting for events.
 Recommended value depends on the number of sockets you poll on.
 For several sockets 50, for several hundreds 100.
 For more than that you probably want to use epoll.
-Note that only sockets with SO_LL set will be busy polled, so you want to either
-selectively set SO_LL on those sockets or set sysctl.net.low_latency_read globally.
+Note that only sockets with SO_BUSY_POLL set will be busy polled,
+so you want to either selectively set SO_BUSY_POLL on those sockets or set
+sysctl.net.busy_read globally.
 Will increase power usage.
 Default: 0 (off)
 
diff --git a/arch/alpha/include/uapi/asm/socket.h b/arch/alpha/include/uapi/asm/socket.h
index 4885825..467de01 100644
--- a/arch/alpha/include/uapi/asm/socket.h
+++ b/arch/alpha/include/uapi/asm/socket.h
@@ -81,6 +81,6 @@
 
 #define SO_SELECT_ERR_QUEUE	45
 
-#define SO_LL			46
+#define SO_BUSY_POLL			46
 
 #endif /* _UAPI_ASM_SOCKET_H */
diff --git a/arch/avr32/include/uapi/asm/socket.h b/arch/avr32/include/uapi/asm/socket.h
index 79b6179..11c4259 100644
--- a/arch/avr32/include/uapi/asm/socket.h
+++ b/arch/avr32/include/uapi/asm/socket.h
@@ -74,6 +74,6 @@
 
 #define SO_SELECT_ERR_QUEUE	45
 
-#define SO_LL			46
+#define SO_BUSY_POLL		46
 
 #endif /* __ASM_AVR32_SOCKET_H */
diff --git a/arch/cris/include/uapi/asm/socket.h b/arch/cris/include/uapi/asm/socket.h
index 47b1ec5..eb723e5 100644
--- a/arch/cris/include/uapi/asm/socket.h
+++ b/arch/cris/include/uapi/asm/socket.h
@@ -76,7 +76,7 @@
 
 #define SO_SELECT_ERR_QUEUE	45
 
-#define SO_LL			46
+#define SO_BUSY_POLL		46
 
 #endif /* _ASM_SOCKET_H */
 
diff --git a/arch/frv/include/uapi/asm/socket.h b/arch/frv/include/uapi/asm/socket.h
index dbc0852..f0cb1c3 100644
--- a/arch/frv/include/uapi/asm/socket.h
+++ b/arch/frv/include/uapi/asm/socket.h
@@ -74,7 +74,7 @@
 
 #define SO_SELECT_ERR_QUEUE	45
 
-#define SO_LL			46
+#define SO_BUSY_POLL		46
 
 #endif /* _ASM_SOCKET_H */
 
diff --git a/arch/h8300/include/uapi/asm/socket.h b/arch/h8300/include/uapi/asm/socket.h
index a38d38a..9490758 100644
--- a/arch/h8300/include/uapi/asm/socket.h
+++ b/arch/h8300/include/uapi/asm/socket.h
@@ -74,6 +74,6 @@
 
 #define SO_SELECT_ERR_QUEUE	45
 
-#define SO_LL			46
+#define SO_BUSY_POLL		46
 
 #endif /* _ASM_SOCKET_H */
diff --git a/arch/ia64/include/uapi/asm/socket.h b/arch/ia64/include/uapi/asm/socket.h
index d3358b7..556d070 100644
--- a/arch/ia64/include/uapi/asm/socket.h
+++ b/arch/ia64/include/uapi/asm/socket.h
@@ -83,6 +83,6 @@
 
 #define SO_SELECT_ERR_QUEUE	45
 
-#define SO_LL			46
+#define SO_BUSY_POLL		46
 
 #endif /* _ASM_IA64_SOCKET_H */
diff --git a/arch/m32r/include/uapi/asm/socket.h b/arch/m32r/include/uapi/asm/socket.h
index 44aaf46..24be7c8 100644
--- a/arch/m32r/include/uapi/asm/socket.h
+++ b/arch/m32r/include/uapi/asm/socket.h
@@ -74,6 +74,6 @@
 
 #define SO_SELECT_ERR_QUEUE	45
 
-#define SO_LL			46
+#define SO_BUSY_POLL		46
 
 #endif /* _ASM_M32R_SOCKET_H */
diff --git a/arch/mips/include/uapi/asm/socket.h b/arch/mips/include/uapi/asm/socket.h
index 6a07992..61c01f0 100644
--- a/arch/mips/include/uapi/asm/socket.h
+++ b/arch/mips/include/uapi/asm/socket.h
@@ -92,6 +92,6 @@
 
 #define SO_SELECT_ERR_QUEUE	45
 
-#define SO_LL			46
+#define SO_BUSY_POLL		46
 
 #endif /* _UAPI_ASM_SOCKET_H */
diff --git a/arch/mn10300/include/uapi/asm/socket.h b/arch/mn10300/include/uapi/asm/socket.h
index db80fd3..e2a2b203 100644
--- a/arch/mn10300/include/uapi/asm/socket.h
+++ b/arch/mn10300/include/uapi/asm/socket.h
@@ -74,6 +74,6 @@
 
 #define SO_SELECT_ERR_QUEUE	45
 
-#define SO_LL			46
+#define SO_BUSY_POLL		46
 
 #endif /* _ASM_SOCKET_H */
diff --git a/arch/parisc/include/uapi/asm/socket.h b/arch/parisc/include/uapi/asm/socket.h
index f866fff..71700e6 100644
--- a/arch/parisc/include/uapi/asm/socket.h
+++ b/arch/parisc/include/uapi/asm/socket.h
@@ -73,7 +73,7 @@
 
 #define SO_SELECT_ERR_QUEUE	0x4026
 
-#define SO_LL			0x4027
+#define SO_BUSY_POLL		0x4027
 
 /* O_NONBLOCK clashes with the bits used for socket types.  Therefore we
  * have to define SOCK_NONBLOCK to a different value here.
diff --git a/arch/powerpc/include/uapi/asm/socket.h b/arch/powerpc/include/uapi/asm/socket.h
index 405fb09..a6d7446 100644
--- a/arch/powerpc/include/uapi/asm/socket.h
+++ b/arch/powerpc/include/uapi/asm/socket.h
@@ -81,6 +81,6 @@
 
 #define SO_SELECT_ERR_QUEUE	45
 
-#define SO_LL			46
+#define SO_BUSY_POLL		46
 
 #endif	/* _ASM_POWERPC_SOCKET_H */
diff --git a/arch/s390/include/uapi/asm/socket.h b/arch/s390/include/uapi/asm/socket.h
index 0c5105fb..9249449 100644
--- a/arch/s390/include/uapi/asm/socket.h
+++ b/arch/s390/include/uapi/asm/socket.h
@@ -80,6 +80,6 @@
 
 #define SO_SELECT_ERR_QUEUE	45
 
-#define SO_LL			46
+#define SO_BUSY_POLL		46
 
 #endif /* _ASM_SOCKET_H */
diff --git a/arch/sparc/include/uapi/asm/socket.h b/arch/sparc/include/uapi/asm/socket.h
index b46c3fa..4e1d66c 100644
--- a/arch/sparc/include/uapi/asm/socket.h
+++ b/arch/sparc/include/uapi/asm/socket.h
@@ -70,7 +70,7 @@
 
 #define SO_SELECT_ERR_QUEUE	0x0029
 
-#define SO_LL			0x0030
+#define SO_BUSY_POLL		0x0030
 
 /* Security levels - as per NRL IPv6 - don't actually do anything */
 #define SO_SECURITY_AUTHENTICATION		0x5001
diff --git a/arch/xtensa/include/uapi/asm/socket.h b/arch/xtensa/include/uapi/asm/socket.h
index b21ace4..c114483 100644
--- a/arch/xtensa/include/uapi/asm/socket.h
+++ b/arch/xtensa/include/uapi/asm/socket.h
@@ -85,6 +85,6 @@
 
 #define SO_SELECT_ERR_QUEUE	45
 
-#define SO_LL			46
+#define SO_BUSY_POLL		46
 
 #endif	/* _XTENSA_SOCKET_H */
diff --git a/include/net/busy_poll.h b/include/net/busy_poll.h
index ab71831..23e4515 100644
--- a/include/net/busy_poll.h
+++ b/include/net/busy_poll.h
@@ -30,8 +30,8 @@
 #ifdef CONFIG_NET_LL_RX_POLL
 
 struct napi_struct;
-extern unsigned int sysctl_net_ll_read __read_mostly;
-extern unsigned int sysctl_net_ll_poll __read_mostly;
+extern unsigned int sysctl_net_busy_read __read_mostly;
+extern unsigned int sysctl_net_busy_poll __read_mostly;
 
 /* return values from ndo_ll_poll */
 #define LL_FLUSH_FAILED		-1
@@ -39,7 +39,7 @@ extern unsigned int sysctl_net_ll_poll __read_mostly;
 
 static inline bool net_busy_loop_on(void)
 {
-	return sysctl_net_ll_poll;
+	return sysctl_net_busy_poll;
 }
 
 /* a wrapper to make debug_smp_processor_id() happy
@@ -72,7 +72,7 @@ static inline unsigned long sk_busy_loop_end_time(struct sock *sk)
 /* in poll/select we use the global sysctl_net_ll_poll value */
 static inline unsigned long busy_loop_end_time(void)
 {
-	return busy_loop_us_clock() + ACCESS_ONCE(sysctl_net_ll_poll);
+	return busy_loop_us_clock() + ACCESS_ONCE(sysctl_net_busy_poll);
 }
 
 static inline bool sk_can_busy_loop(struct sock *sk)
diff --git a/include/uapi/asm-generic/socket.h b/include/uapi/asm-generic/socket.h
index ca3a20d..f04b69b 100644
--- a/include/uapi/asm-generic/socket.h
+++ b/include/uapi/asm-generic/socket.h
@@ -76,6 +76,6 @@
 
 #define SO_SELECT_ERR_QUEUE	45
 
-#define SO_LL			46
+#define SO_BUSY_POLL		46
 
 #endif /* __ASM_GENERIC_SOCKET_H */
diff --git a/net/core/sock.c b/net/core/sock.c
index 9bfe83f..548d716 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -901,7 +901,7 @@ set_rcvbuf:
 		break;
 
 #ifdef CONFIG_NET_LL_RX_POLL
-	case SO_LL:
+	case SO_BUSY_POLL:
 		/* allow unprivileged users to decrease the value */
 		if ((val > sk->sk_ll_usec) && !capable(CAP_NET_ADMIN))
 			ret = -EPERM;
@@ -1171,7 +1171,7 @@ int sock_getsockopt(struct socket *sock, int level, int optname,
 		break;
 
 #ifdef CONFIG_NET_LL_RX_POLL
-	case SO_LL:
+	case SO_BUSY_POLL:
 		v.val = sk->sk_ll_usec;
 		break;
 #endif
@@ -2294,7 +2294,7 @@ void sock_init_data(struct socket *sock, struct sock *sk)
 
 #ifdef CONFIG_NET_LL_RX_POLL
 	sk->sk_napi_id		=	0;
-	sk->sk_ll_usec		=	sysctl_net_ll_read;
+	sk->sk_ll_usec		=	sysctl_net_busy_read;
 #endif
 
 	/*
diff --git a/net/core/sysctl_net_core.c b/net/core/sysctl_net_core.c
index 1a298cb..6609686 100644
--- a/net/core/sysctl_net_core.c
+++ b/net/core/sysctl_net_core.c
@@ -300,15 +300,15 @@ static struct ctl_table net_core_table[] = {
 #endif /* CONFIG_NET_FLOW_LIMIT */
 #ifdef CONFIG_NET_LL_RX_POLL
 	{
-		.procname	= "low_latency_poll",
-		.data		= &sysctl_net_ll_poll,
+		.procname	= "busy_poll",
+		.data		= &sysctl_net_busy_poll,
 		.maxlen		= sizeof(unsigned int),
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec
 	},
 	{
-		.procname	= "low_latency_read",
-		.data		= &sysctl_net_ll_read,
+		.procname	= "busy_read",
+		.data		= &sysctl_net_busy_read,
 		.maxlen		= sizeof(unsigned int),
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec
diff --git a/net/socket.c b/net/socket.c
index 6a3e9a3..829b460 100644
--- a/net/socket.c
+++ b/net/socket.c
@@ -107,8 +107,8 @@
 #include <net/busy_poll.h>
 
 #ifdef CONFIG_NET_LL_RX_POLL
-unsigned int sysctl_net_ll_read __read_mostly;
-unsigned int sysctl_net_ll_poll __read_mostly;
+unsigned int sysctl_net_busy_read __read_mostly;
+unsigned int sysctl_net_busy_poll __read_mostly;
 #endif
 
 static int sock_no_open(struct inode *irrelevant, struct file *dontcare);


------------------------------------------------------------------------------
See everything from the browser to the database with AppDynamics
Get end-to-end visibility with application monitoring from AppDynamics
Isolate bottlenecks and diagnose root cause in seconds.
Start your free trial of AppDynamics Pro today!
http://pubads.g.doubleclick.net/gampad/clk?id=48808831&iu=/4140/ostg.clktrk
_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired
