From: Cosmin Ratiu <cratiu@ixiacom.com>
Subject: SIOCSARP auto resolve
Date: Mon, 13 Apr 2009 20:41:45 +0300
Message-ID: <49E37959.7030502@ixiacom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ixro-out-rtc.ixiacom.com ([92.87.192.98]:3451 "EHLO
	ixro-ex1.ixiacom.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1750782AbZDMRlm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Apr 2009 13:41:42 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

Is there a way to make the kernel send an ARP request from a user space 
program?

If not, then I'd like to hear your opinions on the patch below, which 
extends SIOCSARP with a flag ATF_AUTORESOLVE that when set, will send 
out an ARP request instead of adding an entry to the cache.

Thanks,
Cosmin.


--- include/linux/if_arp.h
+++ include/linux/if_arp.h
@@ -124,6 +124,7 @@
 #define ATF_NETMASK     0x20            /* want to use a netmask (only
                                           for proxy entries) */
 #define ATF_DONTPUB    0x40            /* don't answer this addresses  */
+#define ATF_AUTORESOLVE        0x80            /* send ARP request 
instead     */
 
 /*
  *     This structure defines an ethernet arp header.
--- net/ipv4/arp.c
+++ net/ipv4/arp.c
@@ -1028,13 +1028,18 @@
        neigh = __neigh_lookup_errno(&arp_tbl, &ip, dev);
        err = PTR_ERR(neigh);
        if (!IS_ERR(neigh)) {
-               unsigned state = NUD_STALE;
-               if (r->arp_flags & ATF_PERM)
-                       state = NUD_PERMANENT;
-               err = neigh_update(neigh, (r->arp_flags&ATF_COM) ?
-                                  r->arp_ha.sa_data : NULL, state,
-                                  NEIGH_UPDATE_F_OVERRIDE|
-                                  NEIGH_UPDATE_F_ADMIN);
+               if (r->arp_flags & ATF_AUTORESOLVE) {
+                       neigh_event_send(neigh, NULL);
+                       err = 0;
+               } else {
+                       unsigned state = NUD_STALE;
+                       if (r->arp_flags & ATF_PERM)
+                               state = NUD_PERMANENT;
+                       err = neigh_update(neigh, (r->arp_flags&ATF_COM) ?
+                                          r->arp_ha.sa_data : NULL, state,
+                                          NEIGH_UPDATE_F_OVERRIDE|
+                                          NEIGH_UPDATE_F_ADMIN);
+               }
                neigh_release(neigh);
        }
        return err;

