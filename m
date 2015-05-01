From: Alexei Starovoitov <ast@plumgrid.com>
Subject: [PATCH v3 net-next] pktgen: introduce 'rx' mode
Date: Thu, 30 Apr 2015 22:12:10 -0700
Message-ID: <1430457130-16003-1-git-send-email-ast@plumgrid.com>
Cc: Eric Dumazet <edumazet@google.com>, netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f46.google.com ([209.85.220.46]:36420 "EHLO
	mail-pa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750786AbbEAFMU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 May 2015 01:12:20 -0400
Received: by pabsx10 with SMTP id sx10so81235518pab.3
        for <netdev@vger.kernel.org>; Thu, 30 Apr 2015 22:12:19 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Introduce 'RX' mode for pktgen which generates the packets
using familiar pktgen commands, but feeds them into
netif_receive_skb() instead of ndo_start_xmit().

It is designed to test netif_receive_skb and ingress qdisc
performace only. Make sure to understand how it works before
using it for other rx benchmarking.

Sample script 'pktgen.sh':
\#!/bin/bash
function pgset() {
  local result

  echo $1 > $PGDEV

  result=`cat $PGDEV | fgrep "Result: OK:"`
  if [ "$result" = "" ]; then
    cat $PGDEV | fgrep Result:
  fi
}

ETH=$1

PGDEV=/proc/net/pktgen/kpktgend_0
pgset "rem_device_all"
pgset "add_device $ETH"

PGDEV=/proc/net/pktgen/$ETH
pgset "rx"
pgset "pkt_size 60"
pgset "dst 99.1.1.2"
pgset "dst_mac 90:e2:ba:6e:a8:e5"
pgset "count 10000000"
pgset "burst 32"

PGDEV=/proc/net/pktgen/pgctrl
echo "Running... ctrl^C to stop"
pgset "start"
echo "Done"
cat /proc/net/pktgen/$ETH

Usage:
$ sudo ./pktgen.sh eth2
...
Result: OK: 232376(c232372+d3) usec, 10000000 (60byte,0frags)
  43033682pps 20656Mb/sec (20656167360bps) errors: 10000000

Raw netif_receive_skb speed should be ~43 million packet
per second on 3.7Ghz x86 and 'perf report' should look like:
  37.69%  kpktgend_0   [kernel.vmlinux]  [k] __netif_receive_skb_core
  25.81%  kpktgend_0   [kernel.vmlinux]  [k] kfree_skb
   7.22%  kpktgend_0   [kernel.vmlinux]  [k] ip_rcv
   5.68%  kpktgend_0   [pktgen]          [k] pktgen_thread_worker

if fib_table_lookup is seen on top, it means skb was processed
by the stack. To benchmark netif_receive_skb only make sure
that 'dst_mac' of your pktgen script is different from
receiving device mac and it will be dropped by ip_rcv

Signed-off-by: Alexei Starovoitov <ast@plumgrid.com>
---
v2->v3: addressed more Eric comments. Thanks!

v1->v2: as suggested by Eric:
- dropped 'clone_skb' flag, now it will return enotsupp
- fix rps/rfs bug by checking skb->users after every netif_receive_skb
- tested with RPS/RFS, taps, veth, physical devs, various tc cls/act

 net/core/pktgen.c |   49 +++++++++++++++++++++++++++++++++++++++++++++++--
 1 file changed, 47 insertions(+), 2 deletions(-)

diff --git a/net/core/pktgen.c b/net/core/pktgen.c
index 508155b283dd..34fd5ece2681 100644
--- a/net/core/pktgen.c
+++ b/net/core/pktgen.c
@@ -203,6 +203,7 @@
 #define F_NODE          (1<<15)	/* Node memory alloc*/
 #define F_UDPCSUM       (1<<16)	/* Include UDP checksum */
 #define F_NO_TIMESTAMP  (1<<17)	/* Don't timestamp packets (default TS) */
+#define F_DO_RX		(1<<18)	/* generate packets for RX */
 
 /* Thread control flag bits */
 #define T_STOP        (1<<0)	/* Stop run */
@@ -1081,7 +1082,8 @@ static ssize_t pktgen_if_write(struct file *file,
 		if (len < 0)
 			return len;
 		if ((value > 0) &&
-		    (!(pkt_dev->odev->priv_flags & IFF_TX_SKB_SHARING)))
+		    ((pkt_dev->flags & F_DO_RX) ||
+		     !(pkt_dev->odev->priv_flags & IFF_TX_SKB_SHARING)))
 			return -ENOTSUPP;
 		i += len;
 		pkt_dev->clone_skb = value;
@@ -1089,6 +1091,12 @@ static ssize_t pktgen_if_write(struct file *file,
 		sprintf(pg_result, "OK: clone_skb=%d", pkt_dev->clone_skb);
 		return count;
 	}
+	if (!strcmp(name, "rx")) {
+		pkt_dev->flags |= F_DO_RX;
+
+		sprintf(pg_result, "OK: RX is ON");
+		return count;
+	}
 	if (!strcmp(name, "count")) {
 		len = num_arg(&user_buffer[i], 10, &value);
 		if (len < 0)
@@ -1134,7 +1142,7 @@ static ssize_t pktgen_if_write(struct file *file,
 			return len;
 
 		i += len;
-		if ((value > 1) &&
+		if ((value > 1) && !(pkt_dev->flags & F_DO_RX) &&
 		    (!(pkt_dev->odev->priv_flags & IFF_TX_SKB_SHARING)))
 			return -ENOTSUPP;
 		pkt_dev->burst = value < 1 ? 1 : value;
@@ -3317,6 +3325,7 @@ static void pktgen_xmit(struct pktgen_dev *pkt_dev)
 	unsigned int burst = ACCESS_ONCE(pkt_dev->burst);
 	struct net_device *odev = pkt_dev->odev;
 	struct netdev_queue *txq;
+	struct sk_buff *skb;
 	int ret;
 
 	/* If device is offline, then don't send */
@@ -3349,11 +3358,46 @@ static void pktgen_xmit(struct pktgen_dev *pkt_dev)
 		pkt_dev->last_pkt_size = pkt_dev->skb->len;
 		pkt_dev->allocated_skbs++;
 		pkt_dev->clone_count = 0;	/* reset counter */
+		if (pkt_dev->flags & F_DO_RX)
+			pkt_dev->skb->protocol = eth_type_trans(pkt_dev->skb,
+								pkt_dev->skb->dev);
 	}
 
 	if (pkt_dev->delay && pkt_dev->last_ok)
 		spin(pkt_dev, pkt_dev->next_tx);
 
+	if (pkt_dev->flags & F_DO_RX) {
+		skb = pkt_dev->skb;
+		atomic_add(burst, &skb->users);
+		local_bh_disable();
+		do {
+			ret = netif_receive_skb(skb);
+			if (ret == NET_RX_DROP)
+				pkt_dev->errors++;
+			pkt_dev->sofar++;
+			pkt_dev->seq_num++;
+			if (atomic_read(&skb->users) != burst) {
+				/* skb was queued by rps/rfs or taps,
+				 * so cannot reuse this skb
+				 */
+				atomic_sub(burst - 1, &skb->users);
+				/* get out of the loop and wait
+				 * until skb is consumed
+				 */
+				pkt_dev->last_ok = 1;
+				pkt_dev->clone_skb = 0;
+				break;
+			}
+			/* skb was 'freed' by stack, so clean few
+			 * bits and reuse it
+			 */
+#ifdef CONFIG_NET_CLS_ACT
+			skb->tc_verd = 0; /* reset reclass/redir ttl */
+#endif
+		} while (--burst > 0);
+		goto out;
+	}
+
 	txq = skb_get_tx_queue(odev, pkt_dev->skb);
 
 	local_bh_disable();
@@ -3401,6 +3445,7 @@ xmit_more:
 unlock:
 	HARD_TX_UNLOCK(odev, txq);
 
+out:
 	local_bh_enable();
 
 	/* If pkt_dev->count is zero, then run forever */
-- 
1.7.9.5
