From: Eric Dumazet <dada1@cosmosbay.com>
Subject: [PATCH] NET : Introduce SIOCGSTAMPNS ioctl to get timestamps with nanosec resolution
Date: Thu, 8 Mar 2007 15:17:57 +0100
Message-ID: <200703081517.57539.dada1@cosmosbay.com>
References: <45E5570E.7050301@free.fr> <45E6F744.8070106@linux-foundation.org> <200703021538.41284.dada1@cosmosbay.com>
Mime-Version: 1.0
Content-Type: Multipart/Mixed;
  boundary="Boundary-00=_VsB8F4TqpiXSAt4"
Cc: Stephen Hemminger <shemminger@linux-foundation.org>,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pfx2.jmh.fr ([194.153.89.55]:42904 "EHLO pfx2.jmh.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751943AbXCHORx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 8 Mar 2007 09:17:53 -0500
In-Reply-To: <200703021538.41284.dada1@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Boundary-00=_VsB8F4TqpiXSAt4
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

Hi David

This patch is for net-2.6.22 git tree.

A separate patch will follow for  SO_TIMESTAMPNS / SCM_TIMESTAMPNS support.

Thank you

[PATCH] NET : Introduce SIOCGSTAMPNS ioctl to get timestamps with nanosec 
resolution

Now network timestamps use ktime_t infrastructure, we can add a new ioctl() 
SIOCGSTAMPNS  command to get timestamps in 'struct timespec'.
User programs can thus access to nanosecond resolution.

Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>
CC: Stephen Hemminger <shemminger@linux-foundation.org>

 fs/compat_ioctl.c             |   18 ++++++++++++++++++
 include/asm-alpha/sockios.h   |    3 ++-
 include/asm-arm/sockios.h     |    3 ++-
 include/asm-arm26/sockios.h   |    3 ++-
 include/asm-avr32/sockios.h   |    3 ++-
 include/asm-cris/sockios.h    |    3 ++-
 include/asm-frv/sockios.h     |    3 ++-
 include/asm-h8300/sockios.h   |    3 ++-
 include/asm-i386/sockios.h    |    3 ++-
 include/asm-ia64/sockios.h    |    3 ++-
 include/asm-m32r/sockios.h    |    3 ++-
 include/asm-m68k/sockios.h    |    3 ++-
 include/asm-mips/sockios.h    |    3 ++-
 include/asm-parisc/sockios.h  |    3 ++-
 include/asm-powerpc/sockios.h |    3 ++-
 include/asm-s390/sockios.h    |    3 ++-
 include/asm-sh/sockios.h      |    3 ++-
 include/asm-sh64/sockios.h    |    3 ++-
 include/asm-sparc/sockios.h   |    3 ++-
 include/asm-sparc64/sockios.h |    3 ++-
 include/asm-v850/sockios.h    |    3 ++-
 include/asm-x86_64/sockios.h  |    3 ++-
 include/asm-xtensa/sockios.h  |    3 ++-
 include/net/compat.h          |    1 +
 include/net/sock.h            |    1 +
 net/appletalk/ddp.c           |    3 +++
 net/atm/ioctl.c               |    3 +++
 net/ax25/af_ax25.c            |    4 ++++
 net/compat.c                  |   24 ++++++++++++++++++++++++
 net/core/sock.c               |   16 ++++++++++++++++
 net/econet/af_econet.c        |    3 +++
 net/ipv4/af_inet.c            |    3 +++
 net/ipv6/af_inet6.c           |    3 +++
 net/netrom/af_netrom.c        |    6 ++++++
 net/packet/af_packet.c        |    2 ++
 net/rose/af_rose.c            |    3 +++
 net/wanrouter/af_wanpipe.c    |    3 +++
 net/x25/af_x25.c              |   12 ++++++++++++
 38 files changed, 149 insertions(+), 22 deletions(-)

--Boundary-00=_VsB8F4TqpiXSAt4
Content-Type: text/plain;
  charset="utf-8";
  name="SIOCGSTAMPNS.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
	filename="SIOCGSTAMPNS.patch"

diff --git a/fs/compat_ioctl.c b/fs/compat_ioctl.c
index c81c958..e9e5965 100644
--- a/fs/compat_ioctl.c
+++ b/fs/compat_ioctl.c
@@ -266,6 +266,23 @@ static int do_siocgstamp(unsigned int fd
 	return err;
 }
 
+static int do_siocgstampns(unsigned int fd, unsigned int cmd, unsigned long arg)
+{
+	struct compat_timespec __user *up = compat_ptr(arg);
+	struct timespec kts;
+	mm_segment_t old_fs = get_fs();
+	int err;
+
+	set_fs(KERNEL_DS);
+	err = sys_ioctl(fd, cmd, (unsigned long)&kts);
+	set_fs(old_fs);
+	if (!err) {
+		err = put_user(kts.tv_sec, &up->tv_sec);
+		err |= __put_user(kts.tv_nsec, &up->tv_nsec);
+	}
+	return err;
+}
+
 struct ifmap32 {
 	compat_ulong_t mem_start;
 	compat_ulong_t mem_end;
@@ -2437,6 +2454,7 @@ HANDLE_IOCTL(SIOCBRDELIF, dev_ifsioc)
 /* Note SIOCRTMSG is no longer, so this is safe and * the user would have seen just an -EINVAL anyways. */
 HANDLE_IOCTL(SIOCRTMSG, ret_einval)
 HANDLE_IOCTL(SIOCGSTAMP, do_siocgstamp)
+HANDLE_IOCTL(SIOCGSTAMPNS, do_siocgstampns)
 #endif
 #ifdef CONFIG_BLOCK
 HANDLE_IOCTL(HDIO_GETGEO, hdio_getgeo)
diff --git a/include/asm-alpha/sockios.h b/include/asm-alpha/sockios.h
index e4961a7..7932c7a 100644
--- a/include/asm-alpha/sockios.h
+++ b/include/asm-alpha/sockios.h
@@ -10,6 +10,7 @@ #define SIOCATMARK	_IOR('s', 7, int)
 #define SIOCSPGRP	_IOW('s', 8, pid_t)
 #define SIOCGPGRP	_IOR('s', 9, pid_t)
 
-#define SIOCGSTAMP	0x8906		/* Get stamp - linux-specific */
+#define SIOCGSTAMP	0x8906		/* Get stamp (timeval) */
+#define SIOCGSTAMPNS	0x8907		/* Get stamp (timespec) */
 
 #endif /* _ASM_ALPHA_SOCKIOS_H */
diff --git a/include/asm-arm/sockios.h b/include/asm-arm/sockios.h
index 77c3408..a2588a2 100644
--- a/include/asm-arm/sockios.h
+++ b/include/asm-arm/sockios.h
@@ -7,6 +7,7 @@ #define SIOCSPGRP	0x8902
 #define FIOGETOWN	0x8903
 #define SIOCGPGRP	0x8904
 #define SIOCATMARK	0x8905
-#define SIOCGSTAMP	0x8906		/* Get stamp */
+#define SIOCGSTAMP	0x8906		/* Get stamp (timeval) */
+#define SIOCGSTAMPNS	0x8907		/* Get stamp (timespec) */
 
 #endif
diff --git a/include/asm-arm26/sockios.h b/include/asm-arm26/sockios.h
index 77c3408..a2588a2 100644
--- a/include/asm-arm26/sockios.h
+++ b/include/asm-arm26/sockios.h
@@ -7,6 +7,7 @@ #define SIOCSPGRP	0x8902
 #define FIOGETOWN	0x8903
 #define SIOCGPGRP	0x8904
 #define SIOCATMARK	0x8905
-#define SIOCGSTAMP	0x8906		/* Get stamp */
+#define SIOCGSTAMP	0x8906		/* Get stamp (timeval) */
+#define SIOCGSTAMPNS	0x8907		/* Get stamp (timespec) */
 
 #endif
diff --git a/include/asm-avr32/sockios.h b/include/asm-avr32/sockios.h
index 84f3d65..0802d74 100644
--- a/include/asm-avr32/sockios.h
+++ b/include/asm-avr32/sockios.h
@@ -7,6 +7,7 @@ #define SIOCSPGRP	0x8902
 #define FIOGETOWN	0x8903
 #define SIOCGPGRP	0x8904
 #define SIOCATMARK	0x8905
-#define SIOCGSTAMP	0x8906		/* Get stamp */
+#define SIOCGSTAMP	0x8906		/* Get stamp (timeval) */
+#define SIOCGSTAMPNS	0x8907		/* Get stamp (timespec) */
 
 #endif /* __ASM_AVR32_SOCKIOS_H */
diff --git a/include/asm-cris/sockios.h b/include/asm-cris/sockios.h
index 6c4012f..cfe7bfe 100644
--- a/include/asm-cris/sockios.h
+++ b/include/asm-cris/sockios.h
@@ -7,6 +7,7 @@ #define SIOCSPGRP	0x8902
 #define FIOGETOWN	0x8903
 #define SIOCGPGRP	0x8904
 #define SIOCATMARK	0x8905
-#define SIOCGSTAMP	0x8906		/* Get stamp */
+#define SIOCGSTAMP	0x8906		/* Get stamp (timeval) */
+#define SIOCGSTAMPNS	0x8907		/* Get stamp (timespec) */
 
 #endif
diff --git a/include/asm-frv/sockios.h b/include/asm-frv/sockios.h
index 8a6e4b2..5dbdd13 100644
--- a/include/asm-frv/sockios.h
+++ b/include/asm-frv/sockios.h
@@ -7,7 +7,8 @@ #define SIOCSPGRP	0x8902
 #define FIOGETOWN	0x8903
 #define SIOCGPGRP	0x8904
 #define SIOCATMARK	0x8905
-#define SIOCGSTAMP	0x8906		/* Get stamp */
+#define SIOCGSTAMP	0x8906		/* Get stamp (timeval) */
+#define SIOCGSTAMPNS	0x8907		/* Get stamp (timespec) */
 
 #endif /* _ASM_SOCKIOS__ */
 
diff --git a/include/asm-h8300/sockios.h b/include/asm-h8300/sockios.h
index d005d95..e9c7ec8 100644
--- a/include/asm-h8300/sockios.h
+++ b/include/asm-h8300/sockios.h
@@ -7,6 +7,7 @@ #define SIOCSPGRP	0x8902
 #define FIOGETOWN	0x8903
 #define SIOCGPGRP	0x8904
 #define SIOCATMARK	0x8905
-#define SIOCGSTAMP	0x8906		/* Get stamp */
+#define SIOCGSTAMP	0x8906		/* Get stamp (timeval) */
+#define SIOCGSTAMPNS	0x8907		/* Get stamp (timespec) */
 
 #endif /* __ARCH_H8300_SOCKIOS__ */
diff --git a/include/asm-i386/sockios.h b/include/asm-i386/sockios.h
index 6b747f8..ff528c7 100644
--- a/include/asm-i386/sockios.h
+++ b/include/asm-i386/sockios.h
@@ -7,6 +7,7 @@ #define SIOCSPGRP	0x8902
 #define FIOGETOWN	0x8903
 #define SIOCGPGRP	0x8904
 #define SIOCATMARK	0x8905
-#define SIOCGSTAMP	0x8906		/* Get stamp */
+#define SIOCGSTAMP	0x8906		/* Get stamp (timeval) */
+#define SIOCGSTAMPNS	0x8907		/* Get stamp (timespec) */
 
 #endif
diff --git a/include/asm-ia64/sockios.h b/include/asm-ia64/sockios.h
index cf94857..15c9246 100644
--- a/include/asm-ia64/sockios.h
+++ b/include/asm-ia64/sockios.h
@@ -14,6 +14,7 @@ #define SIOCSPGRP	0x8902
 #define FIOGETOWN	0x8903
 #define SIOCGPGRP	0x8904
 #define SIOCATMARK	0x8905
-#define SIOCGSTAMP	0x8906		/* Get stamp */
+#define SIOCGSTAMP	0x8906		/* Get stamp (timeval) */
+#define SIOCGSTAMPNS	0x8907		/* Get stamp (timespec) */
 
 #endif /* _ASM_IA64_SOCKIOS_H */
diff --git a/include/asm-m32r/sockios.h b/include/asm-m32r/sockios.h
index f89962e..6c1fb9b 100644
--- a/include/asm-m32r/sockios.h
+++ b/include/asm-m32r/sockios.h
@@ -7,6 +7,7 @@ #define SIOCSPGRP	0x8902
 #define FIOGETOWN	0x8903
 #define SIOCGPGRP	0x8904
 #define SIOCATMARK	0x8905
-#define SIOCGSTAMP	0x8906		/* Get stamp */
+#define SIOCGSTAMP	0x8906		/* Get stamp (timeval) */
+#define SIOCGSTAMPNS	0x8907		/* Get stamp (timespec) */
 
 #endif  /* _ASM_M32R_SOCKIOS_H */
diff --git a/include/asm-m68k/sockios.h b/include/asm-m68k/sockios.h
index 9b9ed97..c04a239 100644
--- a/include/asm-m68k/sockios.h
+++ b/include/asm-m68k/sockios.h
@@ -7,6 +7,7 @@ #define SIOCSPGRP	0x8902
 #define FIOGETOWN	0x8903
 #define SIOCGPGRP	0x8904
 #define SIOCATMARK	0x8905
-#define SIOCGSTAMP	0x8906		/* Get stamp */
+#define SIOCGSTAMP	0x8906		/* Get stamp (timeval) */
+#define SIOCGSTAMPNS	0x8907		/* Get stamp (timespec) */
 
 #endif /* __ARCH_M68K_SOCKIOS__ */
diff --git a/include/asm-mips/sockios.h b/include/asm-mips/sockios.h
index 87a50bf..ed1a5f7 100644
--- a/include/asm-mips/sockios.h
+++ b/include/asm-mips/sockios.h
@@ -20,6 +20,7 @@ #define SIOCATMARK	_IOR('s', 7, int)
 #define SIOCSPGRP	_IOW('s', 8, pid_t)
 #define SIOCGPGRP	_IOR('s', 9, pid_t)
 
-#define SIOCGSTAMP	0x8906			/* Get stamp - linux-specific */
+#define SIOCGSTAMP	0x8906		/* Get stamp (timeval) */
+#define SIOCGSTAMPNS	0x8907		/* Get stamp (timespec) */
 
 #endif /* _ASM_SOCKIOS_H */
diff --git a/include/asm-parisc/sockios.h b/include/asm-parisc/sockios.h
index aace496..dabfbc7 100644
--- a/include/asm-parisc/sockios.h
+++ b/include/asm-parisc/sockios.h
@@ -7,6 +7,7 @@ #define SIOCSPGRP	0x8902
 #define FIOGETOWN	0x8903
 #define SIOCGPGRP	0x8904
 #define SIOCATMARK	0x8905
-#define SIOCGSTAMP	0x8906		/* Get stamp */
+#define SIOCGSTAMP	0x8906		/* Get stamp (timeval) */
+#define SIOCGSTAMPNS	0x8907		/* Get stamp (timespec) */
 
 #endif
diff --git a/include/asm-powerpc/sockios.h b/include/asm-powerpc/sockios.h
index 590078d..55cef76 100644
--- a/include/asm-powerpc/sockios.h
+++ b/include/asm-powerpc/sockios.h
@@ -14,6 +14,7 @@ #define SIOCSPGRP	0x8902
 #define FIOGETOWN	0x8903
 #define SIOCGPGRP	0x8904
 #define SIOCATMARK	0x8905
-#define SIOCGSTAMP	0x8906		/* Get stamp */
+#define SIOCGSTAMP	0x8906		/* Get stamp (timeval) */
+#define SIOCGSTAMPNS	0x8907		/* Get stamp (timespec) */
 
 #endif	/* _ASM_POWERPC_SOCKIOS_H */
diff --git a/include/asm-s390/sockios.h b/include/asm-s390/sockios.h
index 412aeb4..f4fc16c 100644
--- a/include/asm-s390/sockios.h
+++ b/include/asm-s390/sockios.h
@@ -15,6 +15,7 @@ #define SIOCSPGRP	0x8902
 #define FIOGETOWN	0x8903
 #define SIOCGPGRP	0x8904
 #define SIOCATMARK	0x8905
-#define SIOCGSTAMP	0x8906		/* Get stamp */
+#define SIOCGSTAMP	0x8906		/* Get stamp (timeval) */
+#define SIOCGSTAMPNS	0x8907		/* Get stamp (timespec) */
 
 #endif
diff --git a/include/asm-sh/sockios.h b/include/asm-sh/sockios.h
index 08a71df..cf8b96b 100644
--- a/include/asm-sh/sockios.h
+++ b/include/asm-sh/sockios.h
@@ -9,5 +9,6 @@ #define SIOCATMARK	_IOR('s', 7, int)
 #define SIOCSPGRP	_IOW('s', 8, pid_t)
 #define SIOCGPGRP	_IOR('s', 9, pid_t)
 
-#define SIOCGSTAMP	_IOR('s', 100, struct timeval) /* Get stamp - linux-specific */
+#define SIOCGSTAMP	_IOR('s', 100, struct timeval) /* Get stamp (timeval) */
+#define SIOCGSTAMPNS	_IOR('s', 101, struct timespec) /* Get stamp (timespec) */
 #endif /* __ASM_SH_SOCKIOS_H */
diff --git a/include/asm-sh64/sockios.h b/include/asm-sh64/sockios.h
index 1ae23ae..419e76f 100644
--- a/include/asm-sh64/sockios.h
+++ b/include/asm-sh64/sockios.h
@@ -20,5 +20,6 @@ #define SIOCATMARK	_IOR('s', 7, int)
 #define SIOCSPGRP	_IOW('s', 8, pid_t)
 #define SIOCGPGRP	_IOR('s', 9, pid_t)
 
-#define SIOCGSTAMP	_IOR('s', 100, struct timeval) /* Get stamp - linux-specific */
+#define SIOCGSTAMP	_IOR('s', 100, struct timeval) /* Get stamp (timeval) */
+#define SIOCGSTAMPNS	_IOR('s', 101, struct timespec) /* Get stamp (timespec) */
 #endif /* __ASM_SH64_SOCKIOS_H */
diff --git a/include/asm-sparc/sockios.h b/include/asm-sparc/sockios.h
index 0c01b59..990ea74 100644
--- a/include/asm-sparc/sockios.h
+++ b/include/asm-sparc/sockios.h
@@ -7,7 +7,8 @@ #define SIOCSPGRP	0x8902
 #define FIOGETOWN	0x8903
 #define SIOCGPGRP	0x8904
 #define SIOCATMARK	0x8905
-#define SIOCGSTAMP	0x8906		/* Get stamp */
+#define SIOCGSTAMP	0x8906		/* Get stamp (timeval) */
+#define SIOCGSTAMPNS	0x8907		/* Get stamp (timespec) */
 
 #endif /* !(_ASM_SPARC_SOCKIOS_H) */
 
diff --git a/include/asm-sparc64/sockios.h b/include/asm-sparc64/sockios.h
index 6735bab..c7d9900 100644
--- a/include/asm-sparc64/sockios.h
+++ b/include/asm-sparc64/sockios.h
@@ -7,7 +7,8 @@ #define SIOCSPGRP	0x8902
 #define FIOGETOWN	0x8903
 #define SIOCGPGRP	0x8904
 #define SIOCATMARK	0x8905
-#define SIOCGSTAMP	0x8906		/* Get stamp */
+#define SIOCGSTAMP	0x8906		/* Get stamp (timeval) */
+#define SIOCGSTAMPNS	0x8907		/* Get stamp (timespec) */
 
 #endif /* !(_ASM_SPARC64_SOCKIOS_H) */
 
diff --git a/include/asm-v850/sockios.h b/include/asm-v850/sockios.h
index cf4874c..823e106 100644
--- a/include/asm-v850/sockios.h
+++ b/include/asm-v850/sockios.h
@@ -7,6 +7,7 @@ #define SIOCSPGRP	0x8902
 #define FIOGETOWN	0x8903
 #define SIOCGPGRP	0x8904
 #define SIOCATMARK	0x8905
-#define SIOCGSTAMP	0x8906		/* Get stamp */
+#define SIOCGSTAMP	0x8906		/* Get stamp (timeval) */
+#define SIOCGSTAMPNS	0x8907		/* Get stamp (timespec) */
 
 #endif /* __V850_SOCKIOS_H__ */
diff --git a/include/asm-x86_64/sockios.h b/include/asm-x86_64/sockios.h
index 2eefd10..d726ba2 100644
--- a/include/asm-x86_64/sockios.h
+++ b/include/asm-x86_64/sockios.h
@@ -7,6 +7,7 @@ #define SIOCSPGRP	0x8902
 #define FIOGETOWN	0x8903
 #define SIOCGPGRP	0x8904
 #define SIOCATMARK	0x8905
-#define SIOCGSTAMP	0x8906		/* Get stamp */
+#define SIOCGSTAMP	0x8906		/* Get stamp (timeval) */
+#define SIOCGSTAMPNS	0x8907		/* Get stamp (timespec) */
 
 #endif
diff --git a/include/asm-xtensa/sockios.h b/include/asm-xtensa/sockios.h
index 20d2ba1..efe0af3 100644
--- a/include/asm-xtensa/sockios.h
+++ b/include/asm-xtensa/sockios.h
@@ -25,6 +25,7 @@ #define SIOCATMARK	_IOR('s', 7, int)
 #define SIOCSPGRP	_IOW('s', 8, pid_t)
 #define SIOCGPGRP	_IOR('s', 9, pid_t)
 
-#define SIOCGSTAMP	0x8906		/* Get stamp - linux-specific */
+#define SIOCGSTAMP	0x8906		/* Get stamp (timeval) */
+#define SIOCGSTAMPNS	0x8907		/* Get stamp (timespec) */
 
 #endif	/* _XTENSA_SOCKIOS_H */
diff --git a/include/net/compat.h b/include/net/compat.h
index 9859b60..406db24 100644
--- a/include/net/compat.h
+++ b/include/net/compat.h
@@ -25,6 +25,7 @@ struct compat_cmsghdr {
 };
 
 extern int compat_sock_get_timestamp(struct sock *, struct timeval __user *);
+extern int compat_sock_get_timestampns(struct sock *, struct timespec __user *);
 
 #else /* defined(CONFIG_COMPAT) */
 #define compat_msghdr	msghdr		/* to avoid compiler warnings */
diff --git a/include/net/sock.h b/include/net/sock.h
index 2974bac..d093e49 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -1329,6 +1329,7 @@ #endif
 
 extern void sock_enable_timestamp(struct sock *sk);
 extern int sock_get_timestamp(struct sock *, struct timeval __user *);
+extern int sock_get_timestampns(struct sock *, struct timespec __user *);
 
 /* 
  *	Enable debug/info messages 
diff --git a/net/appletalk/ddp.c b/net/appletalk/ddp.c
index 113c175..53247be 100644
--- a/net/appletalk/ddp.c
+++ b/net/appletalk/ddp.c
@@ -1768,6 +1768,9 @@ static int atalk_ioctl(struct socket *so
 		case SIOCGSTAMP:
 			rc = sock_get_timestamp(sk, argp);
 			break;
+		case SIOCGSTAMPNS:
+			rc = sock_get_timestampns(sk, argp);
+			break;
 		/* Routing */
 		case SIOCADDRT:
 		case SIOCDELRT:
diff --git a/net/atm/ioctl.c b/net/atm/ioctl.c
index 8ccee45..7afd8e7 100644
--- a/net/atm/ioctl.c
+++ b/net/atm/ioctl.c
@@ -82,6 +82,9 @@ int vcc_ioctl(struct socket *sock, unsig
 		case SIOCGSTAMP: /* borrowed from IP */
 			error = sock_get_timestamp(sk, argp);
 			goto done;
+		case SIOCGSTAMPNS: /* borrowed from IP */
+			error = sock_get_timestampns(sk, argp);
+			goto done;
 		case ATM_SETSC:
 			printk(KERN_WARNING "ATM_SETSC is obsolete\n");
 			error = 0;
diff --git a/net/ax25/af_ax25.c b/net/ax25/af_ax25.c
index 1c07c6a..62605dc 100644
--- a/net/ax25/af_ax25.c
+++ b/net/ax25/af_ax25.c
@@ -1711,6 +1711,10 @@ static int ax25_ioctl(struct socket *soc
 		res = sock_get_timestamp(sk, argp);
 		break;
 
+	case SIOCGSTAMPNS:
+		res = sock_get_timestampns(sk, argp);
+		break;
+
 	case SIOCAX25ADDUID:	/* Add a uid to the uid/call map table */
 	case SIOCAX25DELUID:	/* Delete a uid from the uid/call map table */
 	case SIOCAX25GETUID: {
diff --git a/net/compat.c b/net/compat.c
index 17c2710..2fc6d9b 100644
--- a/net/compat.c
+++ b/net/compat.c
@@ -564,6 +564,30 @@ int compat_sock_get_timestamp(struct soc
 }
 EXPORT_SYMBOL(compat_sock_get_timestamp);
 
+int compat_sock_get_timestampns(struct sock *sk, struct timespec __user *userstamp)
+{
+	struct compat_timespec __user *ctv =
+			(struct compat_timespec __user*) userstamp;
+	int err = -ENOENT;
+	struct timespec ts;
+
+	if (!sock_flag(sk, SOCK_TIMESTAMP))
+		sock_enable_timestamp(sk);
+	ts = ktime_to_timespec(sk->sk_stamp);
+	if (ts.tv_sec == -1)
+		return err;
+	if (ts.tv_sec == 0) {
+		sk->sk_stamp = ktime_get_real();
+		ts = ktime_to_timespec(sk->sk_stamp);
+	}
+	err = 0;
+	if (put_user(ts.tv_sec, &ctv->tv_sec) ||
+			put_user(ts.tv_nsec, &ctv->tv_nsec))
+		err = -EFAULT;
+	return err;
+}
+EXPORT_SYMBOL(compat_sock_get_timestampns);
+
 asmlinkage long compat_sys_getsockopt(int fd, int level, int optname,
 				char __user *optval, int __user *optlen)
 {
diff --git a/net/core/sock.c b/net/core/sock.c
index 6c92ec4..c1fc8cc 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -1567,6 +1567,22 @@ int sock_get_timestamp(struct sock *sk, 
 }
 EXPORT_SYMBOL(sock_get_timestamp);
 
+int sock_get_timestampns(struct sock *sk, struct timespec __user *userstamp)
+{
+	struct timespec ts;
+	if (!sock_flag(sk, SOCK_TIMESTAMP))
+		sock_enable_timestamp(sk);
+	ts = ktime_to_timespec(sk->sk_stamp);
+	if (ts.tv_sec == -1)
+		return -ENOENT;
+	if (ts.tv_sec == 0) {
+		sk->sk_stamp = ktime_get_real();
+		ts = ktime_to_timespec(sk->sk_stamp);
+	}
+	return copy_to_user(userstamp, &ts, sizeof(ts)) ? -EFAULT : 0;
+}
+EXPORT_SYMBOL(sock_get_timestampns);
+
 void sock_enable_timestamp(struct sock *sk)
 {
 	if (!sock_flag(sk, SOCK_TIMESTAMP)) {
diff --git a/net/econet/af_econet.c b/net/econet/af_econet.c
index f573edd..487f879 100644
--- a/net/econet/af_econet.c
+++ b/net/econet/af_econet.c
@@ -727,6 +727,9 @@ static int econet_ioctl(struct socket *s
 		case SIOCGSTAMP:
 			return sock_get_timestamp(sk, argp);
 
+		case SIOCGSTAMPNS:
+			return sock_get_timestampns(sk, argp);
+
 		case SIOCSIFADDR:
 		case SIOCGIFADDR:
 			return ec_dev_ioctl(sock, cmd, argp);
diff --git a/net/ipv4/af_inet.c b/net/ipv4/af_inet.c
index cf358c8..df41856 100644
--- a/net/ipv4/af_inet.c
+++ b/net/ipv4/af_inet.c
@@ -755,6 +755,9 @@ int inet_ioctl(struct socket *sock, unsi
 		case SIOCGSTAMP:
 			err = sock_get_timestamp(sk, (struct timeval __user *)arg);
 			break;
+		case SIOCGSTAMPNS:
+			err = sock_get_timestampns(sk, (struct timespec __user *)arg);
+			break;
 		case SIOCADDRT:
 		case SIOCDELRT:
 		case SIOCRTMSG:
diff --git a/net/ipv6/af_inet6.c b/net/ipv6/af_inet6.c
index fed3758..2ff0704 100644
--- a/net/ipv6/af_inet6.c
+++ b/net/ipv6/af_inet6.c
@@ -443,6 +443,9 @@ int inet6_ioctl(struct socket *sock, uns
 	case SIOCGSTAMP:
 		return sock_get_timestamp(sk, (struct timeval __user *)arg);
 
+	case SIOCGSTAMPNS:
+		return sock_get_timestampns(sk, (struct timespec __user *)arg);
+
 	case SIOCADDRT:
 	case SIOCDELRT:
 
diff --git a/net/netrom/af_netrom.c b/net/netrom/af_netrom.c
index bf9837d..a54e7ef 100644
--- a/net/netrom/af_netrom.c
+++ b/net/netrom/af_netrom.c
@@ -1209,6 +1209,12 @@ static int nr_ioctl(struct socket *sock,
 		release_sock(sk);
 		return ret;
 
+	case SIOCGSTAMPNS:
+		lock_sock(sk);
+		ret = sock_get_timestampns(sk, argp);
+		release_sock(sk);
+		return ret;
+
 	case SIOCGIFADDR:
 	case SIOCSIFADDR:
 	case SIOCGIFDSTADDR:
diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
index f9866a8..6f8c72d 100644
--- a/net/packet/af_packet.c
+++ b/net/packet/af_packet.c
@@ -1545,6 +1545,8 @@ static int packet_ioctl(struct socket *s
 		}
 		case SIOCGSTAMP:
 			return sock_get_timestamp(sk, (struct timeval __user *)arg);
+		case SIOCGSTAMPNS:
+			return sock_get_timestampns(sk, (struct timespec __user *)arg);
 
 #ifdef CONFIG_INET
 		case SIOCADDRT:
diff --git a/net/rose/af_rose.c b/net/rose/af_rose.c
index 8c34f1c..8fa7e47 100644
--- a/net/rose/af_rose.c
+++ b/net/rose/af_rose.c
@@ -1272,6 +1272,9 @@ static int rose_ioctl(struct socket *soc
 	case SIOCGSTAMP:
 		return sock_get_timestamp(sk, (struct timeval __user *) argp);
 
+	case SIOCGSTAMPNS:
+		return sock_get_timestampns(sk, (struct timespec __user *) argp);
+
 	case SIOCGIFADDR:
 	case SIOCSIFADDR:
 	case SIOCGIFDSTADDR:
diff --git a/net/wanrouter/af_wanpipe.c b/net/wanrouter/af_wanpipe.c
index 41d7e32..02c09e7 100644
--- a/net/wanrouter/af_wanpipe.c
+++ b/net/wanrouter/af_wanpipe.c
@@ -1770,6 +1770,9 @@ static int wanpipe_ioctl(struct socket *
 		case SIOCGSTAMP:
 			return sock_get_timestamp(sk, (struct timeval __user *)arg);
 
+		case SIOCGSTAMPNS:
+			return sock_get_timestampns(sk, (struct timespec __user *)arg);
+
 		case SIOC_WANPIPE_CHECK_TX:
 
 			return atomic_read(&sk->sk_wmem_alloc);
diff --git a/net/x25/af_x25.c b/net/x25/af_x25.c
index e62ba41..a198843 100644
--- a/net/x25/af_x25.c
+++ b/net/x25/af_x25.c
@@ -1280,6 +1280,12 @@ static int x25_ioctl(struct socket *sock
 				rc = sock_get_timestamp(sk,
 						(struct timeval __user *)argp);
 			break;
+		case SIOCGSTAMPNS:
+			rc = -EINVAL;
+			if (sk)
+				rc = sock_get_timestampns(sk,
+						(struct timespec __user *)argp);
+			break;
 		case SIOCGIFADDR:
 		case SIOCSIFADDR:
 		case SIOCGIFDSTADDR:
@@ -1521,6 +1527,12 @@ static int compat_x25_ioctl(struct socke
 			rc = compat_sock_get_timestamp(sk,
 					(struct timeval __user*)argp);
 		break;
+	case SIOCGSTAMPNS:
+		rc = -EINVAL;
+		if (sk)
+			rc = compat_sock_get_timestampns(sk,
+					(struct timespec __user*)argp);
+		break;
 	case SIOCGIFADDR:
 	case SIOCSIFADDR:
 	case SIOCGIFDSTADDR:

--Boundary-00=_VsB8F4TqpiXSAt4--
