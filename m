From: Alexei Starovoitov <ast@plumgrid.com>
Subject: [PATCH RFC net-next] pktgen: introduce 'rx' mode
Date: Tue, 28 Apr 2015 19:11:28 -0700
Message-ID: <1430273488-8403-2-git-send-email-ast@plumgrid.com>
References: <1430273488-8403-1-git-send-email-ast@plumgrid.com>
Cc: Eric Dumazet <edumazet@google.com>,
	Daniel Borkmann <daniel@iogearbox.net>,
	Thomas Graf <tgraf@suug.ch>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	John Fastabend <john.r.fastabend@intel.com>,
	netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f50.google.com ([209.85.220.50]:35530 "EHLO
	mail-pa0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1031401AbbD2CLn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Apr 2015 22:11:43 -0400
Received: by pabtp1 with SMTP id tp1so13300723pab.2
        for <netdev@vger.kernel.org>; Tue, 28 Apr 2015 19:11:42 -0700 (PDT)
In-Reply-To: <1430273488-8403-1-git-send-email-ast@plumgrid.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Introduce 'RX' mode for pktgen which generates the packets
using familiar pktgen commands, but feeds them into netif_receive_skb()
instead of ndo_start_xmit().
It can be used to benchmark different kernel RX paths.

Sample script 'pktgen.sh':
!/bin/bash
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
pgset "clone_skb 1000"
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

Signed-off-by: Alexei Starovoitov <ast@plumgrid.com>
---
 net/core/pktgen.c |   30 ++++++++++++++++++++++++++++--
 1 file changed, 28 insertions(+), 2 deletions(-)

diff --git a/net/core/pktgen.c b/net/core/pktgen.c
index 508155b283dd..4f6c56bca550 100644
--- a/net/core/pktgen.c
+++ b/net/core/pktgen.c
@@ -203,6 +203,7 @@
 #define F_NODE          (1<<15)	/* Node memory alloc*/
 #define F_UDPCSUM       (1<<16)	/* Include UDP checksum */
 #define F_NO_TIMESTAMP  (1<<17)	/* Don't timestamp packets (default TS) */
+#define F_DO_RX		(1<<18) /* generate packets for RX */
 
 /* Thread control flag bits */
 #define T_STOP        (1<<0)	/* Stop run */
@@ -1080,7 +1081,7 @@ static ssize_t pktgen_if_write(struct file *file,
 		len = num_arg(&user_buffer[i], 10, &value);
 		if (len < 0)
 			return len;
-		if ((value > 0) &&
+		if ((value > 0) && !(pkt_dev->flags & F_DO_RX) &&
 		    (!(pkt_dev->odev->priv_flags & IFF_TX_SKB_SHARING)))
 			return -ENOTSUPP;
 		i += len;
@@ -1089,6 +1090,12 @@ static ssize_t pktgen_if_write(struct file *file,
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
@@ -1134,7 +1141,7 @@ static ssize_t pktgen_if_write(struct file *file,
 			return len;
 
 		i += len;
-		if ((value > 1) &&
+		if ((value > 1) && !(pkt_dev->flags & F_DO_RX) &&
 		    (!(pkt_dev->odev->priv_flags & IFF_TX_SKB_SHARING)))
 			return -ENOTSUPP;
 		pkt_dev->burst = value < 1 ? 1 : value;
@@ -3349,11 +3356,29 @@ static void pktgen_xmit(struct pktgen_dev *pkt_dev)
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
+		local_bh_disable();
+		atomic_add(burst, &pkt_dev->skb->users);
+		do {
+			ret = netif_receive_skb(pkt_dev->skb);
+			if (ret == NET_RX_DROP)
+				pkt_dev->errors++;
+			pkt_dev->last_ok = 1;
+			pkt_dev->sofar++;
+			pkt_dev->seq_num++;
+		} while (--burst > 0);
+		local_bh_enable();
+		goto out;
+	}
+
 	txq = skb_get_tx_queue(odev, pkt_dev->skb);
 
 	local_bh_disable();
@@ -3403,6 +3428,7 @@ unlock:
 
 	local_bh_enable();
 
+out:
 	/* If pkt_dev->count is zero, then run forever */
 	if ((pkt_dev->count != 0) && (pkt_dev->sofar >= pkt_dev->count)) {
 		pktgen_wait_for_skb(pkt_dev);
-- 
1.7.9.5
