From: "Andreas Herrmann" <AHERRMAN@de.ibm.com>
Subject: Re: [PATCH] new net device feature: shared-ipv6-cards
Date: Wed, 21 Aug 2002 17:28:52 +0200
Sender: owner-netdev@oss.sgi.com
Message-ID: <OF6E059725.5F49923C-ONC1256C1C.0054532B@de.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: ak@suse.de, kuznet@ms2.inr.ac.ru, netdev@oss.sgi.com,
   owner-netdev@oss.sgi.com, pekkas@netcore.fi
Return-path: <owner-netdev@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
List-Id: netdev.vger.kernel.org

Hi,


I removed the config option, added documentation to
Documentation/networking/netdevices.txt
and created a new patch for the new net device feature.


Regards,

Andreas

--


diff -Naur linux-2.4.19.old/Documentation/networking/netdevices.txt linux-2.4.19/Documentation/networking/netdevices.txt
--- linux-2.4.19.old/Documentation/networking/netdevices.txt      Thu Nov  9 03:09:49 2000
+++ linux-2.4.19/Documentation/networking/netdevices.txt    Wed Aug 21 17:11:28 2002
@@ -40,3 +40,18 @@
      Sleeping: NO


+struct net_device feature NETIF_F_SHARED_IPV6
+=============================================
+
+On some systems, e.g. IBM zSeries, networking cards can be shared.
+In order to make IPv6 autoconfiguration useful, each user of the
+networking card will get a different id ("card user instance id")
+which is used for unique address generation in ipv6_generate_eui64().
+
+Using this feature, the part 0xFFFE of an EUI-64 based interface
+identifier is replaced by the id, and the "u" bit is not inverted.
+So the "u" bit will indicate local scope.
+
+The id is stored in:
+
+       dev->dev_id
diff -Naur linux-2.4.19.old/include/linux/netdevice.h linux-2.4.19/include/linux/netdevice.h
--- linux-2.4.19.old/include/linux/netdevice.h  Sat Aug  3 00:39:45 2002
+++ linux-2.4.19/include/linux/netdevice.h      Wed Aug 21 16:01:54 2002
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
+
+     /* for feature NETIF_F_SHARED_IPV6 to store id of shared card */
+     unsigned short          dev_id;
 };


diff -Naur linux-2.4.19.old/net/8021q/vlan.c linux-2.4.19/net/8021q/vlan.c
--- linux-2.4.19.old/net/8021q/vlan.c     Sat Aug  3 00:39:46 2002
+++ linux-2.4.19/net/8021q/vlan.c   Wed Aug 21 15:45:31 2002
@@ -437,6 +437,8 @@
      /* IFF_BROADCAST|IFF_MULTICAST; ??? */
      new_dev->flags = real_dev->flags;
      new_dev->flags &= ~IFF_UP;
+     new_dev->features |= (real_dev->features & NETIF_F_SHARED_IPV6);
+     new_dev->dev_id = real_dev->dev_id;

      /* Make this thing known as a VLAN device */
      new_dev->priv_flags |= IFF_802_1Q_VLAN;
diff -Naur linux-2.4.19.old/net/ipv6/addrconf.c linux-2.4.19/net/ipv6/addrconf.c
--- linux-2.4.19.old/net/ipv6/addrconf.c  Sat Aug  3 00:39:46 2002
+++ linux-2.4.19/net/ipv6/addrconf.c      Wed Aug 21 15:37:03 2002
@@ -690,9 +690,14 @@
                  return -1;
            memcpy(eui, dev->dev_addr, 3);
            memcpy(eui + 5, dev->dev_addr+3, 3);
-           eui[3] = 0xFF;
-           eui[4] = 0xFE;
-           eui[0] ^= 2;
+           if (dev->features&NETIF_F_SHARED_IPV6) {
+                 eui[3] = (dev->dev_id>>8)&0xff;
+                 eui[4] = dev->dev_id&0xff;
+           } else {
+                 eui[3] = 0xFF;
+                 eui[4] = 0xFE;
+                 eui[0] ^= 2;
+           }
            return 0;
      }
      return -1;
