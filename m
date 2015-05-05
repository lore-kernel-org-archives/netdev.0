From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: [PATCH 2/2] pktgen: introduce xmit_mode 'rx_inject'
Date: Tue, 05 May 2015 22:30:38 +0200
Message-ID: <20150505202959.8715.51882.stgit@ivy>
References: <20150505202730.8715.48527.stgit@ivy>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Alexei Starovoitov <ast@plumgrid.com>
To: Jesper Dangaard Brouer <brouer@redhat.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:57256 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751158AbbEEUhQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 5 May 2015 16:37:16 -0400
In-Reply-To: <20150505202730.8715.48527.stgit@ivy>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexei Starovoitov <ast@plumgrid.com>

Introduce xmit_mode 'rx_inject' for pktgen which generates the packets
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
pgset "xmit_mode rx_inject"
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

If fib_table_lookup is seen on top, it means skb was processed
by the stack. To benchmark netif_receive_skb only make sure
that 'dst_mac' of your pktgen script is different from
receiving device mac and it will be dropped by ip_rcv

Signed-off-by: Alexei Starovoitov <ast@plumgrid.com>
Signed-off-by: Jesper Dangaard Brouer <brouer@redhat.com>

---
v3->v4: Jesper address his own concerns
- User interface intro xmit_mode
- Mention xmit_mode in doc
- Make sure skb_clone cannot be used together with this mode

v2->v3: addressed more Eric comments. Thanks!

v1->v2: as suggested by Eric:
- dropped 'clone_skb' flag, now it will return enotsupp
- fix rps/rfs bug by checking skb->users after every netif_receive_skb
- tested with RPS/RFS, taps, veth, physical devs, various tc cls/act
---

 Documentation/networking/pktgen.txt |    7 +++
 net/core/pktgen.c                   |   84 +++++++++++++++++++++++++++++++++--
 2 files changed, 86 insertions(+), 5 deletions(-)

diff --git a/Documentation/networking/pktgen.txt b/Documentation/networking/pktgen.txt
index 6199ee6..bfb5f2c 100644
--- a/Documentation/networking/pktgen.txt
+++ b/Documentation/networking/pktgen.txt
@@ -193,6 +193,10 @@ Examples:
  pgset "rate 300M"        set rate to 300 Mb/s
  pgset "ratep 1000000"    set rate to 1Mpps
 
+ pgset "xmit_mode rx_inject"	RX inject packets into stack netif_receive_skb()
+				Works with "burst" but not with "clone_skb".
+				Default xmit_mode is "tx".
+
 Sample scripts
 ==============
 
@@ -310,6 +314,9 @@ flowlen
 rate
 ratep
 
+xmit_mode
+
+
 References:
 ftp://robur.slu.se/pub/Linux/net-development/pktgen-testing/
 ftp://robur.slu.se/pub/Linux/net-development/pktgen-testing/examples/
diff --git a/net/core/pktgen.c b/net/core/pktgen.c
index 43bb215..85195b2 100644
--- a/net/core/pktgen.c
+++ b/net/core/pktgen.c
@@ -210,6 +210,10 @@
 #define T_REMDEVALL   (1<<2)	/* Remove all devs */
 #define T_REMDEV      (1<<3)	/* Remove one dev */
 
+/* Xmit modes */
+#define M_TX		0	/* Default normal TX */
+#define M_RX_INJECT	1	/* RX inject packet into stack */
+
 /* If lock -- protects updating of if_list */
 #define   if_lock(t)           spin_lock(&(t->if_lock));
 #define   if_unlock(t)           spin_unlock(&(t->if_lock));
@@ -251,13 +255,14 @@ struct pktgen_dev {
 	 * we will do a random selection from within the range.
 	 */
 	__u32 flags;
-	int removal_mark;	/* non-zero => the device is marked for
-				 * removal by worker thread */
-
+	int xmit_mode;
 	int min_pkt_size;
 	int max_pkt_size;
 	int pkt_overhead;	/* overhead for MPLS, VLANs, IPSEC etc */
 	int nfrags;
+	int removal_mark;	/* non-zero => the device is marked for
+				 * removal by worker thread */
+
 	struct page *page;
 	u64 delay;		/* nano-seconds */
 
@@ -620,6 +625,9 @@ static int pktgen_if_show(struct seq_file *seq, void *v)
 	if (pkt_dev->node >= 0)
 		seq_printf(seq, "     node: %d\n", pkt_dev->node);
 
+	if (pkt_dev->xmit_mode == M_RX_INJECT)
+		seq_puts(seq, "     xmit_mode: rx_inject\n");
+
 	seq_puts(seq, "     Flags: ");
 
 	if (pkt_dev->flags & F_IPV6)
@@ -1081,7 +1089,8 @@ static ssize_t pktgen_if_write(struct file *file,
 		if (len < 0)
 			return len;
 		if ((value > 0) &&
-		    (!(pkt_dev->odev->priv_flags & IFF_TX_SKB_SHARING)))
+		    ((pkt_dev->xmit_mode == M_RX_INJECT) ||
+		     !(pkt_dev->odev->priv_flags & IFF_TX_SKB_SHARING)))
 			return -ENOTSUPP;
 		i += len;
 		pkt_dev->clone_skb = value;
@@ -1134,7 +1143,7 @@ static ssize_t pktgen_if_write(struct file *file,
 			return len;
 
 		i += len;
-		if ((value > 1) &&
+		if ((value > 1) && (pkt_dev->xmit_mode == M_TX) &&
 		    (!(pkt_dev->odev->priv_flags & IFF_TX_SKB_SHARING)))
 			return -ENOTSUPP;
 		pkt_dev->burst = value < 1 ? 1 : value;
@@ -1160,6 +1169,35 @@ static ssize_t pktgen_if_write(struct file *file,
 			sprintf(pg_result, "ERROR: node not possible");
 		return count;
 	}
+	if (!strcmp(name, "xmit_mode")) {
+		char f[32];
+
+		memset(f, 0, 32);
+		len = strn_len(&user_buffer[i], sizeof(f) - 1);
+		if (len < 0)
+			return len;
+
+		if (copy_from_user(f, &user_buffer[i], len))
+			return -EFAULT;
+		i += len;
+
+		if (strcmp(f, "tx") == 0) {
+			pkt_dev->xmit_mode = M_TX;
+		} else if (strcmp(f, "rx_inject") == 0) {
+			/* clone_skb set earlier, not supported in this mode */
+			if (pkt_dev->clone_skb > 0)
+				return -ENOTSUPP;
+
+			pkt_dev->xmit_mode = M_RX_INJECT;
+		} else {
+			sprintf(pg_result,
+				"xmit_mode -:%s:- unknown\nAvailable modes: %s",
+				f, "tx, rx_inject\n");
+			return count;
+		}
+		sprintf(pg_result, "OK: xmit_mode=%s", f);
+		return count;
+	}
 	if (!strcmp(name, "flag")) {
 		char f[32];
 		memset(f, 0, 32);
@@ -3320,6 +3358,7 @@ static void pktgen_xmit(struct pktgen_dev *pkt_dev)
 	unsigned int burst = ACCESS_ONCE(pkt_dev->burst);
 	struct net_device *odev = pkt_dev->odev;
 	struct netdev_queue *txq;
+	struct sk_buff *skb;
 	int ret;
 
 	/* If device is offline, then don't send */
@@ -3352,11 +3391,45 @@ static void pktgen_xmit(struct pktgen_dev *pkt_dev)
 		pkt_dev->last_pkt_size = pkt_dev->skb->len;
 		pkt_dev->allocated_skbs++;
 		pkt_dev->clone_count = 0;	/* reset counter */
+		if (pkt_dev->xmit_mode == M_RX_INJECT)
+			pkt_dev->skb->protocol = eth_type_trans(pkt_dev->skb,
+								pkt_dev->skb->dev);
 	}
 
 	if (pkt_dev->delay && pkt_dev->last_ok)
 		spin(pkt_dev, pkt_dev->next_tx);
 
+	if (pkt_dev->xmit_mode == M_RX_INJECT) {
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
+				break;
+			}
+			/* skb was 'freed' by stack, so clean few
+			 * bits and reuse it
+			 */
+#ifdef CONFIG_NET_CLS_ACT
+			skb->tc_verd = 0; /* reset reclass/redir ttl */
+#endif
+		} while (--burst > 0);
+		goto out; /* Skips xmit_mode M_TX */
+	}
+
 	txq = skb_get_tx_queue(odev, pkt_dev->skb);
 
 	local_bh_disable();
@@ -3404,6 +3477,7 @@ xmit_more:
 unlock:
 	HARD_TX_UNLOCK(odev, txq);
 
+out:
 	local_bh_enable();
 
 	/* If pkt_dev->count is zero, then run forever */
