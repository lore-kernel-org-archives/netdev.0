From: Naohiro Aota <naota@elisp.net>
Subject: [PATCH][RFC] ipconfig: Add new kernel parameter to force MAC address
Date: Fri, 21 Oct 2011 02:27:30 +0900
Message-ID: <878vofr2t9.fsf@elisp.net>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Naohiro Aota <naota@elisp.net>, masami.hiramatsu.pt@hitachi.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kabe
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

There are some boards (such as Pandaboard) that doesn't have
persistent MAC address and so the kernel generate random MAC for
it. Usually you can configure the device to use some static MAC
address with userland tools. However it's not possible when you are
using NFS root since the kernel already set the random MAC address and
you cannot change it after system boot up process.

This patch add new kernel parameter "mac". When this parameter is
used, the kernel auto configuration routine force the network device
to use the specified MAC address.

Signed-off-by: Naohiro Aota <naota@elisp.net>
---

Here is Pandaboard block diagram. http://pandaboard.org/node/223/

As you can see, the ethernet device is connected via USB so that the
kernel use smsc95xx to configure this device. Since the device lacks
EEPROM, it doesn't have its own MAC and the kernel specify some random
MAC for it.

I've also considered a way to force random_ether_addr() to use kernel
parameter specified MAC. However there are two problems with it.

1. There are much use of the function among Linux kernel tree so that it
   should be difficult and hard way to take.

2. If there are more than one ethernet device available, one cannot
   distinguish which device get the MAC address.

 Documentation/filesystems/nfs/nfsroot.txt |    8 +++
 Documentation/kernel-parameters.txt       |    3 +
 net/ipv4/Kconfig                          |   13 ++++
 net/ipv4/ipconfig.c                       |   91 +++++++++++++++++++++++++++++
 4 files changed, 115 insertions(+), 0 deletions(-)

diff --git a/Documentation/filesystems/nfs/nfsroot.txt b/Documentation/filesystems/nfs/nfsroot.txt
index ffdd9d8..fa2bea3 100644
--- a/Documentation/filesystems/nfs/nfsroot.txt
+++ b/Documentation/filesystems/nfs/nfsroot.txt
@@ -159,6 +159,14 @@ ip=<client-ip>:<server-ip>:<gw-ip>:<netmask>:<hostname>:<device>:<autoconf>
                 Default: any
 
 
+mac=<mac-address>
+
+  This parameter tells the kernel to try using the specified MAC
+  address. This is useful when your network device does not have its
+  own MAC address and so the kernel select some random address for the
+  device.
+
+
 nfsrootdebug
 
   This parameter enables debugging messages to appear in the kernel
diff --git a/Documentation/kernel-parameters.txt b/Documentation/kernel-parameters.txt
index d6e6724..4bc7d84 100644
--- a/Documentation/kernel-parameters.txt
+++ b/Documentation/kernel-parameters.txt
@@ -1333,6 +1333,9 @@ bytes respectively. Such letter suffixes can also be entirely omitted.
 	ltpc=		[NET]
 			Format: <io>,<irq>,<dma>
 
+	mac=		[IP_PNP]
+			See Documentation/filesystems/nfs/nfsroot.txt.
+
 	machvec=	[IA-64] Force the use of a particular machine-vector
 			(machvec) in a generic kernel.
 			Example: machvec=hpzx1_swiotlb
diff --git a/net/ipv4/Kconfig b/net/ipv4/Kconfig
index cbb505b..ac4da23 100644
--- a/net/ipv4/Kconfig
+++ b/net/ipv4/Kconfig
@@ -163,6 +163,19 @@ config IP_PNP_RARP
 	  operating on your network. Read
 	  <file:Documentation/filesystems/nfs/nfsroot.txt> for details.
 
+config IP_PNP_SPECIFIC_MAC
+       bool "IP: Specific MAC address support"
+       depends on IP_PNP
+       help
+	 If you want your Linux box to mount its whole root file system (the
+	 one containing the directory /) from some other computer over the net
+	 via NFS and you want the IP address of your computer to be discovered
+	 automatically at boot time using some protocols like DHCP, BOOTP or
+	 RARP but your network device does not have static MAC address, you may
+	 want to say Y here. This option add kernel boot parameter mac= to
+	 specify the MAC address to be used for automatic IP address
+	 configuration.
+
 # not yet ready..
 #   bool '    IP: ARP support' CONFIG_IP_PNP_ARP
 config NET_IPIP
diff --git a/net/ipv4/ipconfig.c b/net/ipv4/ipconfig.c
index 472a8c4..9075abc 100644
--- a/net/ipv4/ipconfig.c
+++ b/net/ipv4/ipconfig.c
@@ -82,6 +82,9 @@
 #if defined(CONFIG_IP_PNP_RARP)
 #define IPCONFIG_RARP
 #endif
+#if defined(CONFIG_IP_PNP_SPECIFIC_MAC)
+#define IPCONFIG_MAC
+#endif
 #if defined(IPCONFIG_BOOTP) || defined(IPCONFIG_RARP)
 #define IPCONFIG_DYNAMIC
 #endif
@@ -145,6 +148,11 @@ u32 ic_dev_xid;		/* Device under configuration */
 /* vendor class identifier */
 static char vendor_class_identifier[253] __initdata;
 
+#ifdef IPCONFIG_MAC
+static int ic_mac_addr_set __initdata;
+static u8 ic_mac[ETH_ALEN] __initdata;
+#endif
+
 /* Persistent data: */
 
 static int ic_proto_used;			/* Protocol used, if any */
@@ -1120,6 +1128,26 @@ drop:
 
 #ifdef IPCONFIG_DYNAMIC
 
+#ifdef IPCONFIG_MAC
+static int __init change_mac(struct ic_device *d, u8 *new_mac)
+{
+	struct sockaddr s_addr;
+	int err;
+
+	memcpy(s_addr.sa_data, new_mac, ETH_ALEN);
+	s_addr.sa_family = d->dev->type;
+
+	rtnl_lock();
+	dev_change_flags(d->dev, d->flags);
+	err = dev_set_mac_address(d->dev, &s_addr);
+	dev_change_flags(d->dev, d->flags | IFF_UP);
+	rtnl_unlock();
+	msleep(CONF_POST_OPEN);
+
+	return err;
+}
+#endif
+
 static int __init ic_dynamic(void)
 {
 	int retries;
@@ -1127,6 +1155,10 @@ static int __init ic_dynamic(void)
 	unsigned long start_jiffies, timeout, jiff;
 	int do_bootp = ic_proto_have_if & IC_BOOTP;
 	int do_rarp = ic_proto_have_if & IC_RARP;
+#ifdef IPCONFIG_MAC
+	u8 mac_before[ETH_ALEN];
+	struct ic_device *mac_changed_dev = NULL;
+#endif
 
 	/*
 	 * If none of DHCP/BOOTP/RARP was selected, return with an error.
@@ -1183,6 +1215,31 @@ static int __init ic_dynamic(void)
 	get_random_bytes(&timeout, sizeof(timeout));
 	timeout = CONF_BASE_TIMEOUT + (timeout % (unsigned) CONF_TIMEOUT_RANDOM);
 	for (;;) {
+#ifdef IPCONFIG_MAC
+		if (ic_mac_addr_set && d != mac_changed_dev) {
+			/* restore MAC */
+			if (mac_changed_dev) {
+				if (change_mac(mac_changed_dev,
+					       mac_before) == 0) {
+					printk(KERN_INFO "MAC address on %s restored to %pM\n",
+					       mac_changed_dev->dev->name,
+					       mac_before);
+				}
+			}
+
+			/* backup MAC */
+			memcpy(mac_before, d->dev->dev_addr, ETH_ALEN);
+
+			mac_changed_dev = NULL;
+			/* set MAC address to specified one */
+			if (change_mac(d, ic_mac) == 0) {
+				printk(KERN_INFO "MAC address on %s changed to %pM\n",
+				       d->dev->name, ic_mac);
+				mac_changed_dev = d;
+			}
+		}
+#endif
+
 		/* Track the device we are configuring */
 		ic_dev_xid = d->xid;
 
@@ -1242,6 +1299,15 @@ static int __init ic_dynamic(void)
 
 	if (!ic_got_reply) {
 		ic_myaddr = NONE;
+#ifdef IPCONFIG_MAC
+		/* restore MAC */
+		if (mac_changed_dev) {
+			if (change_mac(mac_changed_dev, mac_before) == 0) {
+				printk(KERN_INFO "MAC address on %s restored to %pM\n",
+				       mac_changed_dev->dev->name, mac_before);
+			}
+		}
+#endif
 		return -1;
 	}
 
@@ -1630,6 +1696,32 @@ static int __init vendor_class_identifier_setup(char *addrs)
 	return 1;
 }
 
+#ifdef IPCONFIG_MAC
+static int __init mac_config_setup(char *addrs)
+{
+	char buf[ETH_ALEN*3];
+	if (strlcpy(buf, addrs, sizeof(buf)) >= sizeof(buf))
+		goto fail;
+
+	buf[sizeof(buf)-1] = '\0';
+	if (mac_pton(buf, ic_mac) == 0)
+		goto fail;
+
+	printk(KERN_INFO "Using specified MAC address %s to set Auto-IP\n",
+	       addrs);
+
+	ic_mac_addr_set = 1;
+	return 1;
+fail:
+	printk(KERN_WARNING "Invalid MAC address\n");
+	return 1;
+}
+#endif
+
 __setup("ip=", ip_auto_config_setup);
 __setup("nfsaddrs=", nfsaddrs_config_setup);
 __setup("dhcpclass=", vendor_class_identifier_setup);
+#ifdef IPCONFIG_MAC
+__setup("mac=", mac_config_setup);
+#endif
+
-- 
1.7.6.1
