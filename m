From: Amir Noam <amir.noam@intel.com>
Subject: [PATCH 1/4] [bonding 2.6] Add bonding ioctl hook
Date: Thu, 8 Jan 2004 18:27:24 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200401081827.26718.amir.noam@intel.com>
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
--- a/include/linux/sockios.h	Thu Jan  8 18:06:41 2004
+++ b/include/linux/sockios.h	Thu Jan  8 18:06:42 2004
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
--- a/net/core/dev.c	Thu Jan  8 18:06:41 2004
+++ b/net/core/dev.c	Thu Jan  8 18:06:42 2004
@@ -2408,6 +2408,7 @@ static int dev_ifsioc(struct ifreq *ifr,
 			    cmd == SIOCBONDSLAVEINFOQUERY ||
 			    cmd == SIOCBONDINFOQUERY ||
 			    cmd == SIOCBONDCHANGEACTIVE ||
+			    cmd == SIOCBONDDEVICE ||
 			    cmd == SIOCGMIIPHY ||
 			    cmd == SIOCGMIIREG ||
 			    cmd == SIOCSMIIREG ||
@@ -2565,6 +2566,7 @@ int dev_ioctl(unsigned int cmd, void *ar
 		case SIOCBONDSLAVEINFOQUERY:
 		case SIOCBONDINFOQUERY:
 		case SIOCBONDCHANGEACTIVE:
+		case SIOCBONDDEVICE:
 			if (!capable(CAP_NET_ADMIN))
 				return -EPERM;
 			dev_load(ifr.ifr_name);
diff -Nuarp a/net/socket.c b/net/socket.c
--- a/net/socket.c	Thu Jan  8 18:06:41 2004
+++ b/net/socket.c	Thu Jan  8 18:06:42 2004
@@ -754,6 +754,17 @@ void dlci_ioctl_set(int (*hook)(unsigned
 }
 EXPORT_SYMBOL(dlci_ioctl_set);
 
+static DECLARE_MUTEX(bond_ioctl_mutex);
+static int (*bond_ioctl_hook)(unsigned long arg);
+
+void bond_ioctl_set(int (*hook)(unsigned long))
+{
+	down(&bond_ioctl_mutex);
+	bond_ioctl_hook = hook;
+	up(&bond_ioctl_mutex);
+}
+EXPORT_SYMBOL(bond_ioctl_set);
+
 /*
  *	With an ioctl, arg may well be a user mode pointer, but we don't know
  *	what to do with it - that's up to the protocol still.
@@ -826,6 +837,17 @@ static int sock_ioctl(struct inode *inod
 				up(&dlci_ioctl_mutex);
 			}
 			break;
+		case SIOCBONDING:
+			err = -ENOPKG;
+			if (!bond_ioctl_hook)
+				request_module("bonding");
+
+			down(&bond_ioctl_mutex);
+			if (bond_ioctl_hook) {
+				err = bond_ioctl_hook(arg);
+			}
+			up(&bond_ioctl_mutex);
+			break;
 		default:
 			err = sock->ops->ioctl(sock, cmd, arg);
 			break;
