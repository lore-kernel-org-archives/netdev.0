From: Ralf Baechle DL5RB <ralf@linux-mips.org>
Subject: [PATCH] AX.25 patches for strace
Date: Thu, 31 Mar 2005 14:04:01 +0100
Message-ID: <20050331130401.GA28466@linux-mips.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com, strace-devel@lists.sourceforge.net
Return-path: <netdev-bounce@oss.sgi.com>
To: linux-hams@vger.kernel.org
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

So far strace is lacking support for AX.25 making debugging of AX.25
software harder for no good reason.  Below the first cut of a patch
to add AX.25 support.  The patch is against Sourceforge CVS.  Please test.

73 de DL5RB op Ralf

--
Loc. JN47BS / CQ 14 / ITU 28 / DOK A21

Index: configure.ac
===================================================================
RCS file: /cvsroot/strace/strace/configure.ac,v
retrieving revision 1.41
diff -u -r1.41 configure.ac
--- configure.ac	22 Mar 2005 23:12:39 -0000	1.41
+++ configure.ac	31 Mar 2005 12:56:25 -0000
@@ -193,8 +193,7 @@
 
 AC_CHECK_FUNCS(sigaction strerror strsignal pread sys_siglist _sys_siglist getdents mctl prctl sendmsg inet_ntop if_indextoname)
 AC_CHECK_HEADERS([sys/reg.h sys/filio.h sys/acl.h sys/asynch.h sys/door.h stropts.h sys/conf.h sys/stream.h sys/tihdr.h sys/tiuser.h sys/sysconfig.h ioctls.h sys/ioctl.h sys/ptrace.h termio.h linux/ptrace.h asm/reg.h sys/uio.h sys/aio.h  poll.h sys/poll.h sys/vfs.h asm/sysmips.h linux/utsname.h sys/nscsys.h mqueue.h sys/epoll.h], [], [])
-AC_CHECK_HEADERS([linux/icmp.h linux/in6.h linux/netlink.h linux/if_packet.h],
-                 [], [], [#include <linux/socket.h>])
+AC_CHECK_HEADERS([linux/icmp.h linux/in6.h linux/netlink.h linux/if_packet.h netax25/ax25.h], [], [], [#include <linux/socket.h>])
 AC_CHECK_HEADERS([asm/sigcontext.h], [], [], [#include <signal.h>])
 AC_CHECK_HEADERS([netinet/tcp.h netinet/udp.h],,, [#include <netinet/in.h>])
 
Index: defs.h
===================================================================
RCS file: /cvsroot/strace/strace/defs.h,v
retrieving revision 1.55
diff -u -r1.55 defs.h
--- defs.h	6 Feb 2005 01:16:32 -0000	1.55
+++ defs.h	31 Mar 2005 12:56:27 -0000
@@ -459,6 +459,7 @@
 extern void call_summary P((FILE *));
 extern void printtv32 P((struct tcb*, long));
 extern void tprint_iov P((struct tcb *, int, long));
+extern void tprint_ax25_address P((char *ax));
 
 #ifdef LINUX
 extern int internal_clone P((struct tcb *));
Index: net.c
===================================================================
RCS file: /cvsroot/strace/strace/net.c,v
retrieving revision 1.46
diff -u -r1.46 net.c
--- net.c	2 Feb 2005 03:11:32 -0000	1.46
+++ net.c	31 Mar 2005 12:56:29 -0000
@@ -98,6 +98,10 @@
 #include <linux/icmp.h>
 #endif
 
+#if defined(HAVE_NETAX25_AX25_H)
+#include <netax25/ax25.h>
+#endif
+
 #ifndef PF_UNSPEC
 #define PF_UNSPEC AF_UNSPEC
 #endif
@@ -436,6 +440,7 @@
 #endif
 	{ 0,		NULL		},
 };
+
 static const struct xlat msg_flags[] = {
 	{ MSG_OOB,	"MSG_OOB"	},
 #ifdef MSG_DONTROUTE
@@ -780,6 +785,24 @@
 };
 #endif /* SOL_IPX */
 
+#if defined(LINUX) && defined(AF_AX25)
+static const struct xlat sockax25options[] = {
+	{ AX25_WINDOW,		"AX25_WINDOW"		},
+	{ AX25_T1,		"AX25_T1"		},
+	{ AX25_T2,		"AX25_T2"		},
+	{ AX25_N2,		"AX25_N2"		},
+	{ AX25_T3,		"AX25_T3"		},
+	{ AX25_IDLE,		"AX25_IDLE"		},
+	{ AX25_BACKOFF,		"AX25_BACKOFF"		},
+	{ AX25_EXTSEQ,		"AX25_EXTSEQ"		},
+	{ AX25_PIDINCL,		"AX25_PIDINCL"		},
+	{ AX25_IAMDIGI,		"AX25_IAMDIGI"		},
+	{ AX25_PACLEN,		"AX25_PACLEN"		},
+	{ SO_BINDTODEVICE,	"SO_BINDTODEVICE"	},
+	{ 0,			NULL			}
+};
+#endif
+
 #ifdef SOL_RAW
 static const struct xlat sockrawoptions[] = {
 #if defined(ICMP_FILTER)
@@ -923,6 +946,22 @@
 };
 #endif /* defined(AF_PACKET) */
 
+#if defined(LINUX) && defined(AF_AX25)
+void tprint_ax25_address(char *ax)
+{
+	int len, i;
+
+	for (len = 5; len; len--)
+		if (ax[len] != (' ' << 1))
+			break;
+
+	for (i = 0; i <= len; i++)
+		tprintf("%c", (ax[i] >> 1) & 0x7f);
+
+	tprintf("-%d", ax[6]);
+}
+#endif
+
 
 void
 printsock(tcp, addr, addrlen)
@@ -934,6 +973,9 @@
 		char pad[128];
 		struct sockaddr sa;
 		struct sockaddr_in sin;
+#if defined(LINUX) && defined(AF_AX25)
+		struct full_sockaddr_ax25 sax25;
+#endif
 		struct sockaddr_un sau;
 #ifdef HAVE_INET_NTOP
 		struct sockaddr_in6 sa6;
@@ -984,6 +1026,28 @@
 		tprintf("sin_port=htons(%u), sin_addr=inet_addr(\"%s\")",
 			ntohs(addrbuf.sin.sin_port), inet_ntoa(addrbuf.sin.sin_addr));
 		break;
+#if defined(LINUX) && defined(AF_AX25)
+	case AF_AX25: {
+		int i;
+
+		tprintf("sax25_call=");
+		tprint_ax25_address(addrbuf.sax25.fsa_ax25.sax25_call.ax25_call);
+		tprintf(", sax25_ndigis=%d", addrbuf.sax25.fsa_ax25.sax25_ndigis);
+
+		if (addrbuf.sax25.fsa_ax25.sax25_ndigis) {
+			tprintf(" {");
+
+			for (i = 0; i < addrbuf.sax25.fsa_ax25.sax25_ndigis; i++) {
+				tprintf(" ");
+				tprint_ax25_address(addrbuf.sax25.fsa_digipeater[i].ax25_call);
+			}
+
+			tprintf("}");
+		}
+		tprintf("}");
+		}
+		break;
+#endif
 #ifdef HAVE_INET_NTOP
 	case AF_INET6:
 		inet_ntop(AF_INET6, &addrbuf.sa6.sin6_addr, string_addr, sizeof(string_addr));
@@ -1053,8 +1117,8 @@
 		tprintf("pid=%d, groups=%08x", addrbuf.nl.nl_pid, addrbuf.nl.nl_groups);
 		break;
 #endif /* AF_NETLINK */
-	/* AF_AX25 AF_APPLETALK AF_NETROM AF_BRIDGE AF_AAL5
-	AF_X25 AF_ROSE etc. still need to be done */
+	/* AF_APPLETALK AF_NETROM AF_BRIDGE AF_AAL5
+	AF_ROSE etc. still need to be done */
 
 	default:
 		tprintf("sa_data=");
@@ -1541,6 +1605,11 @@
 			printxval(sockipxoptions, tcp->u_arg[2], "IPX_???");
 			break;
 #endif
+#ifdef SOL_AX25
+		case SOL_AX25:
+			printxval(sockax25options, tcp->u_arg[2], "AX25_???");
+			break;
+#endif
 #ifdef SOL_PACKET
 		case SOL_PACKET:
 			printxval(sockpacketoptions, tcp->u_arg[2], "PACKET_???");
@@ -1552,7 +1621,7 @@
 			break;
 #endif
 
-		/* SOL_AX25 SOL_ROSE SOL_ATALK SOL_NETROM SOL_UDP SOL_DECNET SOL_X25
+		/* SOL_ROSE SOL_ATALK SOL_NETROM SOL_UDP SOL_DECNET SOL_X25
 		 * etc. still need work */
 		default:
 			tprintf("%lu", tcp->u_arg[2]);
@@ -1588,6 +1657,41 @@
 #endif
 			}
 			break;
+
+#ifdef SOL_AX25
+		case SOL_AX25:
+			switch (tcp->u_arg[2]) {
+			case AX25_WINDOW:
+			case AX25_T1:
+			case AX25_T2:
+			case AX25_N2:
+			case AX25_T3:
+			case AX25_IDLE:
+			case AX25_BACKOFF:
+			case AX25_EXTSEQ:
+			case AX25_PIDINCL:
+			case AX25_IAMDIGI:
+			case AX25_PACLEN:
+			        if (len == sizeof (int)) {
+					int val;
+
+					if (umove (tcp, tcp->u_arg[3],
+						   &val) < 0)
+						break;
+					tprintf(", { %d }", val);
+				}
+				break;
+			case SO_BINDTODEVICE:
+				/* The argument is limited to at most IFNAMSIZ
+				   characters but we display the full length of
+				   whatever the user passed  */
+				tprintf(", {");
+				printstr(tcp, tcp->u_arg[3], len);
+				tprintf("}");
+				break;
+			}
+			break;
+#endif
 		}
 
 		tprintf (", ");
@@ -1673,6 +1777,11 @@
 		printxval(sockipxoptions, name, "IPX_???");
 		break;
 #endif
+#ifdef SOL_AX25
+	    case SOL_AX25:
+		printxval(sockax25options, name, "AX25_???");
+		break;
+#endif
 #ifdef SOL_PACKET
 	    case SOL_PACKET:
 		printxval(sockpacketoptions, name, "PACKET_???");
@@ -1698,7 +1807,7 @@
 		break;
 #endif
 
-		/* SOL_AX25 SOL_ATALK SOL_NETROM SOL_UDP SOL_DECNET SOL_X25
+		/* SOL_ATALK SOL_NETROM SOL_UDP SOL_DECNET SOL_X25
 		 * etc. still need work  */
 
 	    default:
Index: sock.c
===================================================================
RCS file: /cvsroot/strace/strace/sock.c,v
retrieving revision 1.10
diff -u -r1.10 sock.c
--- sock.c	2 Feb 2005 20:25:17 -0000	1.10
+++ sock.c	31 Mar 2005 12:56:30 -0000
@@ -184,12 +184,18 @@
 				tprintf("}");
 				break;
 			case SIOCGIFHWADDR:
-				/* XXX Are there other hardware addresses
-				   than 6-byte MACs?  */
-				bytes = (unsigned char *) &ifr.ifr_hwaddr.sa_data;
-				tprintf("ifr_hwaddr=%02x:%02x:%02x:%02x:%02x:%02x",
-					bytes[0], bytes[1], bytes[2],
-					bytes[3], bytes[4], bytes[5]);
+				switch (ifr.ifr_hwaddr.sa_family) {
+				case AF_AX25:
+					tprintf("ifr_hwaddr=");
+					tprint_ax25_address((char *) &ifr.ifr_hwaddr.sa_data);
+					break;
+				default:
+					bytes = (unsigned char *) &ifr.ifr_hwaddr.sa_data;
+					tprintf("ifr_hwaddr=%02x:%02x:%02x:%02x:%02x:%02x",
+						bytes[0], bytes[1], bytes[2],
+						bytes[3], bytes[4], bytes[5]);
+					break;
+				}
 				break;
 			case SIOCGIFFLAGS:
 				tprintf("ifr_flags=");
