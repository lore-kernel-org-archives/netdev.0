From: Frank Pavlic <pavlic@de.ibm.com>
Subject: [PATCH] introducing new net device feature NETIF_F_MC_ALL
Date: Fri, 17 Sep 2004 01:22:01 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <OF8B730F67.CB8AFC86-ONC1256F11.00802580-C1256F11.00802CCA@de.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: quoted-printable
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com, linux-net@vger.kernel.org
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi,
I introduced a new net device feature flag NETIF_F_MC_ALL.
Setting this flag network devices drivers will be triggered on every=20
multicast join and drop
regardless of already existing dev_mc_list entry .=20
The reason is that s390 device drivers lcs and qeth need to be informed=20
for every new Multicast IP
address being joined or dropped to register them at the hardware to get=20
multicast traffic running for
the specific Multicast group.
As LCS and OSA Express hardware  are able to virtualize network devices=20
and so to get a lot of systems=20
running concurrently with the same physical hardware it is not enough for=
=20
both device drivers to just get triggered=20
when a new dev_mc_list entry is allocated.
For example in case of Token Ring this would happen only once as the=20
hardware multicast address is hardcoded in=20
ip_tr_mc_map. Thus every further join of a new Multicast group p on a=20
Token Ring device would never trigger=20
the drivers again. As this multicast IP address has not been registered=20
yet on the card multicast packets for this group
will be dropped  by the hardware. Similar applies to Ethernet .


diff -urN linux-2.6/drivers/s390/net/lcs.c=20
linux-2.6-s390/drivers/s390/net/lcs.c
--- linux-2.6/drivers/s390/net/lcs.c    Thu Aug 26 11:23:33 2004
+++ linux-2.6-s390/drivers/s390/net/lcs.c       Thu Aug 26 11:23:45 2004
@@ -11,7 +11,7 @@
  *                       Frank Pavlic (pavlic@de.ibm.com) and
  *                       Martin Schwidefsky <schwidefsky@de.ibm.com>
  *
- *    $Revision: 1.89 $         $Date: 2004/08/24 10:49:27 $
+ *    $Revision: 1.90 $         $Date: 2004/08/26 03:29:44 $
  *
  * This program is free software; you can redistribute it and/or modify
  * it under the terms of the GNU General Public License as published by
@@ -59,7 +59,7 @@
 /**
  * initialization string for output
  */
-#define VERSION_LCS_C  "$Revision: 1.89 $"
+#define VERSION_LCS_C  "$Revision: 1.90 $"

 static char version[] __initdata =3D "LCS driver ("VERSION_LCS_C "/"=20
VERSION_LCS_H ")";
 static char debug_buffer[255];
@@ -101,9 +101,9 @@
                return -ENOMEM;
        }
        debug_register_view(lcs_dbf_setup, &debug_hex_ascii_view);
-       debug_set_level(lcs_dbf_setup, 4);
+       debug_set_level(lcs_dbf_setup, 2);
        debug_register_view(lcs_dbf_trace, &debug_hex_ascii_view);
-       debug_set_level(lcs_dbf_trace, 4);
+       debug_set_level(lcs_dbf_trace, 2);
        return 0;
 }

@@ -1276,9 +1276,8 @@
         LCS_DBF_TEXT(4, trace, "setmulti");
         card =3D (struct lcs_card *) dev->priv;

-        if (!lcs_set_thread_start_bit(card, LCS_SET_MC_THREAD)) {
+        if (!lcs_set_thread_start_bit(card, LCS_SET_MC_THREAD))
                schedule_work(&card->kernel_thread_starter);
-       }
 }

 #endif /* CONFIG_IP_MULTICAST */
@@ -2181,8 +2180,10 @@
                goto out;
        memcpy(card->dev->dev_addr, card->mac, LCS_MAC_LENGTH);
 #ifdef CONFIG_IP_MULTICAST
-       if (!lcs_check_multicast_support(card))
+       if (!lcs_check_multicast_support(card)) {
                card->dev->set_multicast_list =3D lcs_set_multicast_list;
+               card->dev->features |=3D NETIF_F_MC_ALL;
+       }
 #endif
        netif_stop_queue(card->dev);
        lcs_set_allowed_threads(card,0xffffffff);
@@ -2294,7 +2295,6 @@
                PRINT_ERR("Initialization failed\n");
                return rc;
        }
-
        return 0;
 }

diff -urN linux-2.6/drivers/s390/net/qeth_main.c=20
linux-2.6-s390/drivers/s390/net/qeth_main.c
--- linux-2.6/drivers/s390/net/qeth_main.c      Thu Aug 26 11:23:42 2004
+++ linux-2.6-s390/drivers/s390/net/qeth_main.c Thu Aug 26 11:23:45 2004
@@ -1,6 +1,6 @@
 /*
  *
- * linux/drivers/s390/net/qeth_main.c ($Revision: 1.132 $)
+ * linux/drivers/s390/net/qeth_main.c ($Revision: 1.133 $)
@@ -1,6 +1,6 @@
 /*
  *
- * linux/drivers/s390/net/qeth_main.c ($Revision: 1.132 $)
+ * linux/drivers/s390/net/qeth_main.c ($Revision: 1.133 $)
  *
  * Linux on zSeries OSA Express and HiperSockets support
  *
@@ -12,7 +12,7 @@
  *                       Frank Pavlic (pavlic@de.ibm.com) and
  *                       Thomas Spatzier <tspat@de.ibm.com>
  *
- *    $Revision: 1.132 $        $Date: 2004/08/19 12:39:43 $
+ *    $Revision: 1.133 $        $Date: 2004/08/26 03:29:44 $
  *
  * This program is free software; you can redistribute it and/or modify
  * it under the terms of the GNU General Public License as published by
@@ -78,7 +78,7 @@
 #include "qeth_mpc.h"
 #include "qeth_fs.h"

-#define VERSION_QETH_C "$Revision: 1.132 $"
+#define VERSION_QETH_C "$Revision: 1.133 $"
 static const char *version =3D "qeth S/390 OSA-Express driver";

 /**
@@ -6263,6 +6263,7 @@
        } else {
                PRINT_INFO("Multicast enabled\n");
                card->dev->flags |=3D IFF_MULTICAST;
+               card->dev->features |=3D NETIF_F_MC_ALL;
        }
        return rc;
 }
diff -urN linux-2.6/include/linux/netdevice.h=20
linux-2.6-s390/include/linux/netdevice.h
--- linux-2.6/include/linux/netdevice.h Thu Aug 26 11:23:43 2004
+++ linux-2.6-s390/include/linux/netdevice.h    Thu Aug 26 11:23:45 2004
@@ -408,7 +408,10 @@
 #define NETIF_F_VLAN_CHALLENGED        1024    /* Device cannot handle=20
VLAN packets */
 #define NETIF_F_TSO            2048    /* Can offload TCP/IP segmentatio=
n=20
*/
 #define NETIF_F_LLTX           4096    /* LockLess TX */
-
+#define NETIF_F_MC_ALL         8192    /* trigger driver on every=20
multicast
+                                        * address been added/deleted
+                                        */
+
        /* Called after device is detached from network. */
        void                    (*uninit)(struct net_device *dev);
        /* Called after last user reference disappears. */
diff -urN linux-2.6/net/core/dev_mcast.c=20
linux-2.6-s390/net/core/dev_mcast.c
--- linux-2.6/net/core/dev_mcast.c      Sat Aug 14 12:55:10 2004
+++ linux-2.6-s390/net/core/dev_mcast.c Thu Aug 26 11:23:45 2004
@@ -145,6 +145,8 @@
        }
        err =3D -ENOENT;
 done:
+       if (dev->features & NETIF_F_MC_ALL)
+               __dev_mc_upload(dev);
        spin_unlock_bh(&dev->xmit_lock);
        return err;
 }
@@ -193,6 +195,9 @@
        return 0;

 done:
+       if (dev->features & NETIF_F_MC_ALL)
+               __dev_mc_upload(dev);
+
        spin_unlock_bh(&dev->xmit_lock);
        if (dmi1)
                kfree(dmi1);
diff -urN linux-2.6/net/ipv4/igmp.c linux-2.6-s390/net/ipv4/igmp.c
--- linux-2.6/net/ipv4/igmp.c   Thu Aug 26 11:23:21 2004
+++ linux-2.6-s390/net/ipv4/igmp.c      Thu Aug 26 11:23:45 2004
@@ -1202,7 +1202,6 @@

                                if (!in_dev->dead)
                                        ip_rt_multicast_event(in_dev);
-
                                ip_ma_put(i);
                                return;
                        }
diff -urN linux-2.6/net/ipv6/mcast.c linux-2.6-s390/net/ipv6/mcast.c
--- linux-2.6/net/ipv6/mcast.c  Sat Aug 14 12:56:01 2004
+++ linux-2.6-s390/net/ipv6/mcast.c     Thu Aug 26 11:23:45 2004
@@ -882,7 +882,6 @@
                                write_unlock_bh(&idev->lock);

                                igmp6_group_dropped(ma);
-
                                ma_put(ma);
                                return 0;
                        }


Mit  freundlichen Gr=FCssen / Best regards
Frank Pavlic
=20
Linux for eServer Development
Schoenaicher Str. 220, 71032 Boeblingen
Phone:  ext. +49-(0)7031/16-2463, int. *120-2463
mailto:   pavlic@de.ibm.com
