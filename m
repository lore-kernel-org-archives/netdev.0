From: Claudiu Manoil <claudiu.manoil@freescale.com>
Subject: [PATCH net-next 0/4 v2] gianfar: Add Rx S/G
Date: Mon, 13 Jul 2015 16:22:02 +0300
Message-ID: <1436793726-13310-1-git-send-email-claudiu.manoil@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: "David S. Miller" <davem@davemloft.net>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-by2on0135.outbound.protection.outlook.com ([207.46.100.135]:52512
	"EHLO na01-by2-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752464AbbGMNYK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 13 Jul 2015 09:24:10 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David,
This patch-set introduces scatter/gather support
on the Rx side, addressing Rx path performance
issues in the driver.
Thanks.

As an example, two boards connected back-to-back
were used to measure the throughput, running the
same kernel 4.1, before and after applying these
patches.
The netperf UDP_STREAM results below show that the
bottleneck lies on the Rx side BEFORE applying the
patches, and that the Rx throughput is even lower
with a larger MTU.  AFTER applying the patches the
Rx bottleneck is gone (Rx throughput matches the
Tx one) and the RX throughput is not influenced by
MTU size any longer (as expected).


BEFORE:

1) MTU 1500 (default)

root@p1010rdb-pb:~# netperf -l 150 -cC -H 192.85.1.1 -p 12867 -t UDP_STREAM -- -m 512
MIGRATED UDP STREAM TEST from 0.0.0.0 () port 0 AF_INET to 192.85.1.1 () port 0 AF_INET
Socket  Message  Elapsed      Messages                   CPU      Service
Size    Size     Time         Okay Errors   Throughput   Util     Demand
bytes   bytes    secs            #      #   10^6bits/sec % SS     us/KB

163840     512   150.00    20119124      0      549.4     100.00   14.911
163840           150.00    14057349             383.9     100.00   14.911

root@p1010rdb-pb:~# netperf -l 150 -cC -H 192.85.1.1 -p 12867 -t UDP_STREAM -- -m 64
MIGRATED UDP STREAM TEST from 0.0.0.0 () port 0 AF_INET to 192.85.1.1 () port 0 AF_INET
Socket  Message  Elapsed      Messages                   CPU      Service
Size    Size     Time         Okay Errors   Throughput   Util     Demand
bytes   bytes    secs            #      #   10^6bits/sec % SS     us/KB

163840      64   150.00    23654013      0       80.7     100.00   101.463
163840           150.00    15875288              54.2     100.00   101.463

2) MTU 8000

root@p1010rdb-pb:~# netperf -l 150 -cC -H 192.85.1.1 -p 12867 -t UDP_STREAM -- -m 512
MIGRATED UDP STREAM TEST from 0.0.0.0 () port 0 AF_INET to 192.85.1.1 () port 0 AF_INET
Socket  Message  Elapsed      Messages                   CPU      Service
Size    Size     Time         Okay Errors   Throughput   Util     Demand
bytes   bytes    secs            #      #   10^6bits/sec % SS     us/KB

163840     512   150.00    20067232      0      548.0     100.00   14.950
163840           150.00    6113498             166.9     99.95    14.942

root@p1010rdb-pb:~# netperf -l 150 -cC -H 192.85.1.1 -p 12867 -t UDP_STREAM -- -m 64
MIGRATED UDP STREAM TEST from 0.0.0.0 () port 0 AF_INET to 192.85.1.1 () port 0 AF_INET
Socket  Message  Elapsed      Messages                   CPU      Service
Size    Size     Time         Okay Errors   Throughput   Util     Demand
bytes   bytes    secs            #      #   10^6bits/sec % SS     us/KB

163840      64   150.00    23621279      0       80.6     100.00   101.604
163840           150.00    5868602              20.0     99.96    101.563


AFTER:
(both MTU 1500 and MTU 8000)

root@p1010rdb-pb:~# netperf -l 150 -cC -H 192.85.1.1 -p 12867 -t UDP_STREAM -- -m 512
MIGRATED UDP STREAM TEST from 0.0.0.0 () port 0 AF_INET to 192.85.1.1 () port 0 AF_INET
Socket  Message  Elapsed      Messages                   CPU      Service
Size    Size     Time         Okay Errors   Throughput   Util     Demand
bytes   bytes    secs            #      #   10^6bits/sec % SS     us/KB

163840     512   150.00    19914969      0      543.8     100.00   15.064
163840           150.00    19914969             543.8     99.35    14.966

root@p1010rdb-pb:~# netperf -l 150 -cC -H 192.85.1.1 -p 12867 -t UDP_STREAM -- -m 64
MIGRATED UDP STREAM TEST from 0.0.0.0 () port 0 AF_INET to 192.85.1.1 () port 0 AF_INET
Socket  Message  Elapsed      Messages                   CPU      Service
Size    Size     Time         Okay Errors   Throughput   Util     Demand
bytes   bytes    secs            #      #   10^6bits/sec % SS     us/KB

163840      64   150.00    23433989      0       80.0     100.00   102.416
163840           150.00    23433989              80.0     99.62    102.023




Claudiu Manoil (4):
  gianfar: Bundle Rx allocation, cleanup
  gianfar: Fix and cleanup rxbd status handling
  gianfar: Use ndev, more Rx path cleanup
  gianfar: Add paged allocation and Rx S/G

 drivers/net/ethernet/freescale/gianfar.c         | 496 +++++++++++++----------
 drivers/net/ethernet/freescale/gianfar.h         |  72 ++--
 drivers/net/ethernet/freescale/gianfar_ethtool.c |   4 +-
 3 files changed, 331 insertions(+), 241 deletions(-)

-- 
1.7.11.7
