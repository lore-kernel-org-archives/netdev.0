From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net] arp: filter NOARP neighbours for SIOCGARP
Date: Mon, 27 Jul 2015 11:33:50 +0200
Message-ID: <1437989630.20182.35.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	Vytautas Valancius <valas@google.com>,
	Willem de Bruijn <willemb@google.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f173.google.com ([209.85.212.173]:34948 "EHLO
	mail-wi0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754402AbbG0Jdz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Jul 2015 05:33:55 -0400
Received: by wibxm9 with SMTP id xm9so103732762wib.0
        for <netdev@vger.kernel.org>; Mon, 27 Jul 2015 02:33:54 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

When arp is off on a device, and ioctl(SIOCGARP) is queried,
a buggy answer is given with MAC address of the device, instead
of the mac address of the destination/gateway.

We filter out NUD_NOARP neighbours for /proc/net/arp,
we must do the same for SIOCGARP ioctl.

Tested:

lpaa23:~# ./arp 10.246.7.190
MAC=00:01:e8:22:cb:1d      // correct answer

lpaa23:~# ip link set dev eth0 arp off
lpaa23:~# cat /proc/net/arp   # check arp table is now 'empty'
IP address       HW type     Flags       HW address    Mask     Device
lpaa23:~# ./arp 10.246.7.190
MAC=00:1a:11:c3:0d:7f   // buggy answer before patch (this is eth0 mac)

After patch :

lpaa23:~# ip link set dev eth0 arp off
lpaa23:~# ./arp 10.246.7.190
ioctl(SIOCGARP) failed: No such device or address

Signed-off-by: Eric Dumazet <edumazet@google.com>
Reported-by: Vytautas Valancius <valas@google.com>
Cc: Willem de Bruijn <willemb@google.com>
---
 net/ipv4/arp.c |   16 +++++++++-------
 1 file changed, 9 insertions(+), 7 deletions(-)

diff --git a/net/ipv4/arp.c b/net/ipv4/arp.c
index 933a92820d26..6c8b1fbafce8 100644
--- a/net/ipv4/arp.c
+++ b/net/ipv4/arp.c
@@ -1017,14 +1017,16 @@ static int arp_req_get(struct arpreq *r, struct net_device *dev)
 
 	neigh = neigh_lookup(&arp_tbl, &ip, dev);
 	if (neigh) {
-		read_lock_bh(&neigh->lock);
-		memcpy(r->arp_ha.sa_data, neigh->ha, dev->addr_len);
-		r->arp_flags = arp_state_to_flags(neigh);
-		read_unlock_bh(&neigh->lock);
-		r->arp_ha.sa_family = dev->type;
-		strlcpy(r->arp_dev, dev->name, sizeof(r->arp_dev));
+		if (!(neigh->nud_state & NUD_NOARP)) {
+			read_lock_bh(&neigh->lock);
+			memcpy(r->arp_ha.sa_data, neigh->ha, dev->addr_len);
+			r->arp_flags = arp_state_to_flags(neigh);
+			read_unlock_bh(&neigh->lock);
+			r->arp_ha.sa_family = dev->type;
+			strlcpy(r->arp_dev, dev->name, sizeof(r->arp_dev));
+			err = 0;
+		}
 		neigh_release(neigh);
-		err = 0;
 	}
 	return err;
 }
