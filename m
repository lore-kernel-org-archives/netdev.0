From: Amir Noam <amir.noam@intel.com>
Subject: [PATCH 1/4] [bonding 2.4] Add bonding ioctl hook
Date: Thu, 8 Jan 2004 18:21:23 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200401081821.24881.amir.noam@intel.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: <bonding-devel@lists.sourceforge.net>, <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: "Jeff Garzik" <jgarzik@pobox.com>, "Jay Vosburgh" <fubar@us.ibm.com>
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Add two bonding ioctls:

SIOCBONDING: ioctl hook to handle commands not directed at a
specific bond interface.

SIOCBONDDEVICE: ioctl to handle commands for a bond interface. This
ioctl can also handle all existing commands, so we can regard them as
obsolete in the future.

All future bonding operations will be a sub-command of one of these
ioctls.


diff -Nuarp a/include/linux/sockios.h b/include/linux/sockios.h
--- a/include/linux/sockios.h	Tue Jan  6 20:40:06 2004
+++ b/include/linux/sockios.h	Tue Jan  6 20:40:08 2004
@@ -115,7 +115,9 @@
 #define SIOCBONDSLAVEINFOQUERY 0x8993   /* rtn info about slave state   */
 #define SIOCBONDINFOQUERY      0x8994	/* rtn info about bond state    */
 #define SIOCBONDCHANGEACTIVE   0x8995   /* update to a new active slave */
-			
+#define SIOCBONDING     0x8996          /* deviceless bonding commands */
+#define SIOCBONDDEVICE  0x8997          /* device oriented bonding commands */
+
 /* Device private ioctl calls */
 
 /*
diff -Nuarp a/net/core/dev.c b/net/core/dev.c
--- a/net/core/dev.c	Tue Jan  6 20:40:06 2004
+++ b/net/core/dev.c	Tue Jan  6 20:40:08 2004
@@ -2199,6 +2199,7 @@ static int dev_ifsioc(struct ifreq *ifr,
 			    cmd == SIOCBONDSLAVEINFOQUERY ||
 			    cmd == SIOCBONDINFOQUERY ||
 			    cmd == SIOCBONDCHANGEACTIVE ||
+			    cmd == SIOCBONDDEVICE ||
 			    cmd == SIOCGMIIPHY ||
 			    cmd == SIOCGMIIREG ||
 			    cmd == SIOCSMIIREG ||
@@ -2358,6 +2359,7 @@ int dev_ioctl(unsigned int cmd, void *ar
 		case SIOCBONDSLAVEINFOQUERY:
 		case SIOCBONDINFOQUERY:
 		case SIOCBONDCHANGEACTIVE:
+		case SIOCBONDDEVICE:
 			if (!capable(CAP_NET_ADMIN))
 				return -EPERM;
 			dev_load(ifr.ifr_name);
diff -Nuarp a/net/ipv4/af_inet.c b/net/ipv4/af_inet.c
--- a/net/ipv4/af_inet.c	Tue Jan  6 20:40:06 2004
+++ b/net/ipv4/af_inet.c	Tue Jan  6 20:40:08 2004
@@ -147,6 +147,16 @@ int (*br_ioctl_hook)(unsigned long);
 int (*vlan_ioctl_hook)(unsigned long arg);
 #endif
 
+static DECLARE_MUTEX(bond_ioctl_mutex);
+int (*bond_ioctl_hook)(unsigned long arg);
+
+void bond_ioctl_set(int (*hook)(unsigned long))
+{
+	down(&bond_ioctl_mutex);
+	bond_ioctl_hook = hook;
+	up(&bond_ioctl_mutex);
+}
+
 /* The inetsw table contains everything that inet_create needs to
  * build a new socket.
  */
@@ -924,6 +934,21 @@ int inet_ioctl(struct socket *sock, unsi
 #endif
 			return -ENOPKG;
 
+		case SIOCBONDING:
+			err = -ENOPKG;
+
+#ifdef CONFIG_KMOD
+			if (bond_ioctl_hook == NULL)
+				request_module("bonding");
+#endif
+
+			down(&bond_ioctl_mutex);
+			if (bond_ioctl_hook != NULL)
+				err = bond_ioctl_hook(arg);
+			up(&bond_ioctl_mutex);
+
+			return err;
+
 		default:
 			if ((cmd >= SIOCDEVPRIVATE) &&
 			    (cmd <= (SIOCDEVPRIVATE + 15)))
diff -Nuarp a/net/netsyms.c b/net/netsyms.c
--- a/net/netsyms.c	Tue Jan  6 20:40:06 2004
+++ b/net/netsyms.c	Tue Jan  6 20:40:08 2004
@@ -296,6 +296,9 @@ extern int (*dlci_ioctl_hook)(unsigned i
 EXPORT_SYMBOL(dlci_ioctl_hook);
 #endif
 
+extern void bond_ioctl_set(int (*hook)(unsigned long));
+EXPORT_SYMBOL(bond_ioctl_set);
+
 
 #if defined (CONFIG_IPV6_MODULE) || defined (CONFIG_KHTTPD) || defined (CONFIG_KHTTPD_MODULE) || defined (CONFIG_IP_SCTP_MODULE)
 /* inet functions common to v4 and v6 */
