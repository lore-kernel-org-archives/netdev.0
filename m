From: "Andreas Herrmann" <AHERRMAN@de.ibm.com>
Subject: [PATCH] new net device feature: shared-ipv6-cards
Date: Mon, 19 Aug 2002 10:20:19 +0200
Sender: owner-netdev@oss.sgi.com
Message-ID: <OFA9FA0A49.89F0FA84-ONC1256C16.004D221E@de.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@redhat.com>,
   Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>, Andi Kleen <ak@suse.de>
Return-path: <owner-netdev@oss.sgi.com>
To: Pekka Savola <pekkas@netcore.fi>, netdev@oss.sgi.com
List-Id: netdev.vger.kernel.org

(Obviously, I've forgotten to address the networking kernel
maintainers in my previous mail. So here we go again ...;-)


Hi,

I ask for integration of the attached patch into the
stock kernel. The patch is against kernel version 2.4.19.

This patch allows to replace the part 0xFFFE of an EUI-64 based
interface identifier by another 16 bit value.  The new net device
feature is needed to avoid duplicate address conflicts on Linux for
z/Series when shared OSA cards are used with IPv6.

The following changes are performed:

 o Documentation/Configure.help
   net/Config.in
        Configure option and help text for the new feature.
 o arch/s390/defconfig
   arch/s390x/defconfig
        Set option on by default for Linux for z/Series.
 o include/linux/netdevice.h
        Changed struct net_device to store an id for the card user
        instance. Introduced macro for the new net device feature.
 o net/ipv6/addrconf.c
        Replace 0xFFFE by a card user instance id in function
        ipv6_generate_eui64().
 o net/8021q/vlan.c
        Take new feature into account for VLAN devices in function
        register_802_1Q_vlan_device().

On Linux for zSeries OSA network cards can be shared among various
Linuxes. The OSA card has only one MAC address. This leads to
duplicate address conflicts in conjunction with IPv6 and a vanilla
kernel if more than one Linux use the same card.  But the device
driver for the card can deliver a unique 16-bit identifier for each
Linux sharing the same card. This identifier is placed instead of the
part 0xFFFE in the interface identifier.

The "u" bit of the interface identifier is not inverted when the new
feature is used. Hence the resulting interface identifier has local
scope according to RFC2373.  Consequently this change of the
autoconfiguration does not violate any RFCs.


Regards,

Andreas

--
Linux for eServer Development
Tel :  +49-7031-16-4640
Notes mail :  Andreas Herrmann/GERMANY/IBM@IBMDE
email :  aherrman@de.ibm.com


diff -Naur linux-2.4.19.old/Documentation/Configure.help linux-2.4.19/Documentation/Configure.help
--- linux-2.4.19.old/Documentation/Configure.help     Mon Aug  5 10:54:29 2002
+++ linux-2.4.19/Documentation/Configure.help   Mon Aug  5 10:56:50 2002
@@ -5404,6 +5404,16 @@

   It is safe to say N here for now.

+Prepare net_device struct for shared IPv6 cards
+CONFIG_SHARED_IPV6_CARDS
+  This prepares the net_device structure to contain a card user instance
+  id. On some systems, e.g. IBM zSeries, networking cards can be shared.
+  In order to make IPv6 autoconfiguration useful, each user of the
+  networking card will get a different id which is used for unique
+  address generation (the id is used in the EUI-64 generation).
+
+  Only say yes on IBM zSeries or S/390 systems.
+
 # 2.5 tree only
 IPv6: routing messages via old netlink
 CONFIG_IPV6_NETLINK
diff -Naur linux-2.4.19.old/arch/s390/defconfig linux-2.4.19/arch/s390/defconfig
--- linux-2.4.19.old/arch/s390/defconfig  Mon Aug  5 10:54:28 2002
+++ linux-2.4.19/arch/s390/defconfig      Mon Aug  5 12:22:33 2002
@@ -146,6 +146,7 @@
 # CONFIG_INET_ECN is not set
 # CONFIG_SYN_COOKIES is not set
 CONFIG_IPV6=m
+CONFIG_SHARED_IPV6_CARDS=y
 # CONFIG_KHTTPD is not set
 # CONFIG_ATM is not set
 # CONFIG_VLAN_8021Q is not set
diff -Naur linux-2.4.19.old/arch/s390x/defconfig linux-2.4.19/arch/s390x/defconfig
--- linux-2.4.19.old/arch/s390x/defconfig Mon Aug  5 10:54:29 2002
+++ linux-2.4.19/arch/s390x/defconfig     Mon Aug  5 12:23:29 2002
@@ -146,6 +146,7 @@
 # CONFIG_INET_ECN is not set
 # CONFIG_SYN_COOKIES is not set
 CONFIG_IPV6=m
+CONFIG_SHARED_IPV6_CARDS=y
 # CONFIG_KHTTPD is not set
 # CONFIG_ATM is not set
 # CONFIG_VLAN_8021Q is not set
diff -Naur linux-2.4.19.old/include/linux/netdevice.h linux-2.4.19/include/linux/netdevice.h
--- linux-2.4.19.old/include/linux/netdevice.h  Mon Aug  5 10:54:19 2002
+++ linux-2.4.19/include/linux/netdevice.h      Mon Aug  5 12:18:41 2002
@@ -362,6 +362,9 @@
 #define NETIF_F_HW_VLAN_RX   256   /* Receive VLAN hw acceleration */
 #define NETIF_F_HW_VLAN_FILTER     512   /* Receive filtering on VLAN */
 #define NETIF_F_VLAN_CHALLENGED    1024  /* Device cannot handle VLAN packets */
+#define NETIF_F_SHARED_IPV6  2048  /* make IPv6 address autogeneration
+                              * network card instance aware
+                              */

      /* Called after device is detached from network. */
      void              (*uninit)(struct net_device *dev);
@@ -431,6 +434,9 @@
      /* this will get initialized at each interface type init routine */
      struct divert_blk *divert;
 #endif /* CONFIG_NET_DIVERT */
+#ifdef CONFIG_SHARED_IPV6_CARDS
+     unsigned short          dev_id;
+#endif /* CONFIG_SHARED_IPV6_CARDS */
 };


diff -Naur linux-2.4.19.old/net/8021q/vlan.c linux-2.4.19/net/8021q/vlan.c
--- linux-2.4.19.old/net/8021q/vlan.c     Mon Aug  5 10:54:19 2002
+++ linux-2.4.19/net/8021q/vlan.c   Mon Aug  5 10:56:50 2002
@@ -437,6 +437,10 @@
      /* IFF_BROADCAST|IFF_MULTICAST; ??? */
      new_dev->flags = real_dev->flags;
      new_dev->flags &= ~IFF_UP;
+#ifdef CONFIG_SHARED_IPV6_CARDS
+     new_dev->features |= (real_dev->features & NETIF_F_SHARED_IPV6);
+     new_dev->dev_id = real_dev->dev_id;
+#endif

      /* Make this thing known as a VLAN device */
      new_dev->priv_flags |= IFF_802_1Q_VLAN;
diff -Naur linux-2.4.19.old/net/Config.in linux-2.4.19/net/Config.in
--- linux-2.4.19.old/net/Config.in  Mon Aug  5 10:54:19 2002
+++ linux-2.4.19/net/Config.in      Mon Aug  5 10:56:50 2002
@@ -25,6 +25,7 @@
       if [ "$CONFIG_IPV6" != "n" ]; then
       source net/ipv6/Config.in
       fi
+      bool '  Prepare net_device struct for shared IPv6 cards' CONFIG_SHARED_IPV6_CARDS
    fi
    if [ "$CONFIG_EXPERIMENTAL" = "y" ]; then
       source net/khttpd/Config.in
diff -Naur linux-2.4.19.old/net/ipv6/addrconf.c linux-2.4.19/net/ipv6/addrconf.c
--- linux-2.4.19.old/net/ipv6/addrconf.c  Mon Aug  5 10:54:19 2002
+++ linux-2.4.19/net/ipv6/addrconf.c      Mon Aug  5 10:56:50 2002
@@ -690,9 +690,20 @@
                  return -1;
            memcpy(eui, dev->dev_addr, 3);
            memcpy(eui + 5, dev->dev_addr+3, 3);
+#ifdef CONFIG_SHARED_IPV6_CARDS
+           if (dev->features&NETIF_F_SHARED_IPV6) {
+                 eui[3] = (dev->dev_id>>8)&0xff;
+                 eui[4] = dev->dev_id&0xff;
+           } else {
+                 eui[3] = 0xFF;
+                 eui[4] = 0xFE;
+                 eui[0] ^= 2;
+           }
+#else /* CONFIG_SHARED_IPV6_CARDS */
            eui[3] = 0xFF;
            eui[4] = 0xFE;
            eui[0] ^= 2;
+#endif /* CONFIG_SHARED_IPV6_CARDS */
            return 0;
      }
      return -1;
