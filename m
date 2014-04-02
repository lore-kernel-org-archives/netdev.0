From: David Decotigny <decot@googlers.com>
Subject: [PATCH iproute2 v1] iproute2: show counter of carrier on<->off transitions
Date: Wed,  2 Apr 2014 09:19:00 -0700
Message-ID: <6c78808eaf4b31f98c9de9bef6f29397c67cf09e.1396455409.git.decot@googlers.com>
References: <cover.1396455409.git.decot@googlers.com>
Cc: David Decotigny <decot@googlers.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f201.google.com ([209.85.192.201]:43500 "EHLO
	mail-pd0-f201.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932348AbaDBQ0h (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Apr 2014 12:26:37 -0400
Received: by mail-pd0-f201.google.com with SMTP id x10so69404pdj.0
        for <netdev@vger.kernel.org>; Wed, 02 Apr 2014 09:26:36 -0700 (PDT)
In-Reply-To: <cover.1396455409.git.decot@googlers.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch allows to display the current counter of carrier on<->off
transitions (IFLA_CARRIER_CHANGES, see kernel commit "expose number of
carrier on/off changes"):

  ip -s -s link show dev eth0
  ...
  2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 etc.
    link/ether ............ brd ff:ff:ff:ff:ff:ff
    RX: bytes  packets  errors  dropped overrun mcast
    134705     758      0       0       0       0
    RX errors: length  crc     frame   fifo    missed
               0        0       0       0       0
    TX: bytes  packets  errors  dropped carrier collsns
    77374      731      0       0       0       0
    TX errors: aborted fifo    window  heartbeat
               0        0       0       0
    link: carrier_changes 4

Tested:
  - kernel with patch "net-sysfs: expose number of carrier on/off
    changes": see above
  - kernel wthout the patch: line "link:" not displayed (as expected)

Signed-off-by: David Decotigny <decot@googlers.com>
---
 include/linux/if_link.h | 1 +
 ip/ipaddress.c          | 5 +++++
 2 files changed, 6 insertions(+)

diff --git a/include/linux/if_link.h b/include/linux/if_link.h
index f08505c..84fca1e 100644
--- a/include/linux/if_link.h
+++ b/include/linux/if_link.h
@@ -144,6 +144,7 @@ enum {
 	IFLA_NUM_RX_QUEUES,
 	IFLA_CARRIER,
 	IFLA_PHYS_PORT_ID,
+	IFLA_CARRIER_CHANGES,
 	__IFLA_MAX
 };
 
diff --git a/ip/ipaddress.c b/ip/ipaddress.c
index 14d1720..78b80ee 100644
--- a/ip/ipaddress.c
+++ b/ip/ipaddress.c
@@ -527,6 +527,11 @@ int print_linkinfo(const struct sockaddr_nl *who,
 			print_link_stats(fp, RTA_DATA(tb[IFLA_STATS]));
 	}
 
+	if (do_link && (show_stats > 1) && tb[IFLA_CARRIER_CHANGES]) {
+		fprintf(fp, "%s    link: carrier_changes %u", _SL_,
+			*(int*)RTA_DATA(tb[IFLA_CARRIER_CHANGES]));
+	}
+
 	if (do_link && tb[IFLA_VFINFO_LIST] && tb[IFLA_NUM_VF]) {
 		struct rtattr *i, *vflist = tb[IFLA_VFINFO_LIST];
 		int rem = RTA_PAYLOAD(vflist);
-- 
1.9.1.423.g4596e3a
