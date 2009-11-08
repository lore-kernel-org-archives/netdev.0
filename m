From: Arnd Bergmann <arnd@arndb.de>
Subject: [PATCH 2/2] net/compat_ioctl: support SIOCWANDEV
Date: Sun, 8 Nov 2009 22:39:24 +0100
Message-ID: <200911082239.24698.arnd@arndb.de>
References: <1257530949-9695-1-git-send-email-arnd@arndb.de> <20091106.204753.223665411.davem@davemloft.net> <200911082231.48060.arnd@arndb.de>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, hch@lst.de, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>,
	Krzysztof Halasa <khc@pm.waw.pl>,
	Daniel Walker <dwalker@fifo99.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1755401AbZKHVj0@vger.kernel.org>
In-Reply-To: <200911082231.48060.arnd@arndb.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This adds compat_ioctl support for SIOCWANDEV, which has
always been missing.

The definition of struct compat_ifreq was missing an
ifru_settings fields that is needed to support SIOCWANDEV,
so add that and clean up the whitespace damage in the
struct definition.

Signed-off-by: Arnd Bergmann <arnd@arndb.de>
Cc: Krzysztof Halasa <khc@pm.waw.pl>
Cc: Daniel Walker <dwalker@fifo99.com>
---

Krzysztof, can you verify that this is really needed and that it
does the right thing?

Daniel, I didn't want to add another patch just for the broken
whitespace I copied, but since we needed another fix in this area...

---
 include/linux/compat.h |   41 ++++++++++++++++++++++++-----------------
 net/socket.c           |   23 +++++++++++++++++++++++
 2 files changed, 47 insertions(+), 17 deletions(-)

diff --git a/include/linux/compat.h b/include/linux/compat.h
index 224c7a8..4dff55a 100644
--- a/include/linux/compat.h
+++ b/include/linux/compat.h
@@ -165,25 +165,32 @@ struct compat_ifmap {
 	unsigned char port;
 };
 
+struct compat_if_settings
+{
+	unsigned int type;	/* Type of physical device or protocol */
+	unsigned int size;	/* Size of the data allocated by the caller */
+	compat_uptr_t ifs_ifsu;	/* union of pointers */
+};
+
 struct compat_ifreq {
-        union {
-                char    ifrn_name[IFNAMSIZ];            /* if name, e.g. "en0" */
-        } ifr_ifrn;
-        union {
-                struct  sockaddr ifru_addr;
-                struct  sockaddr ifru_dstaddr;
-                struct  sockaddr ifru_broadaddr;
-                struct  sockaddr ifru_netmask;
-                struct  sockaddr ifru_hwaddr;
-                short   ifru_flags;
-                compat_int_t     ifru_ivalue;
-                compat_int_t     ifru_mtu;
-                struct  compat_ifmap ifru_map;
-                char    ifru_slave[IFNAMSIZ];   /* Just fits the size */
+	union {
+		char	ifrn_name[IFNAMSIZ];    /* if name, e.g. "en0" */
+	} ifr_ifrn;
+	union {
+		struct	sockaddr ifru_addr;
+		struct	sockaddr ifru_dstaddr;
+		struct	sockaddr ifru_broadaddr;
+		struct	sockaddr ifru_netmask;
+		struct	sockaddr ifru_hwaddr;
+		short	ifru_flags;
+		compat_int_t	ifru_ivalue;
+		compat_int_t	ifru_mtu;
+		struct	compat_ifmap ifru_map;
+		char	ifru_slave[IFNAMSIZ];   /* Just fits the size */
 		char	ifru_newname[IFNAMSIZ];
-                compat_caddr_t ifru_data;
-	    /* XXXX? ifru_settings should be here */
-        } ifr_ifru;
+		compat_caddr_t	ifru_data;
+		struct	compat_if_settings ifru_settings;
+	} ifr_ifru;
 };
 
 struct compat_ifconf {
diff --git a/net/socket.c b/net/socket.c
index 28a0263..17c98a5 100644
--- a/net/socket.c
+++ b/net/socket.c
@@ -2468,6 +2468,27 @@ static int ethtool_ioctl(struct net *net, struct compat_ifreq __user *ifr32)
 	return dev_ioctl(net, SIOCETHTOOL, ifr);
 }
 
+static int compat_siocwandev(struct net *net, struct compat_ifreq __user *uifr32)
+{
+	void __user *uptr;
+	compat_uptr_t uptr32;
+	struct ifreq __user *uifr;
+
+	uifr = compat_alloc_user_space(sizeof (*uifr));
+	if (copy_in_user(uifr, uifr32, sizeof(struct compat_ifreq)))
+		return -EFAULT;
+
+	if (get_user(uptr32, &uifr32->ifr_settings.ifs_ifsu))
+		return -EFAULT;
+
+	uptr = compat_ptr(uptr32);
+
+	if (put_user(uptr, &uifr->ifr_settings.ifs_ifsu.raw_hdlc))
+		return -EFAULT;
+
+	return dev_ioctl(net, SIOCWANDEV, uifr);
+}
+
 static int bond_ioctl(struct net *net, unsigned int cmd,
 			 struct compat_ifreq __user *ifr32)
 {
@@ -2900,6 +2921,8 @@ static int compat_sock_ioctl_trans(struct file *file, struct socket *sock,
 		return dev_ifconf(net, argp);
 	case SIOCETHTOOL:
 		return ethtool_ioctl(net, argp);
+	case SIOCWANDEV:
+		return compat_siocwandev(net, argp);
 	case SIOCBONDENSLAVE:
 	case SIOCBONDRELEASE:
 	case SIOCBONDSETHWADDR:
-- 
1.6.3.3
