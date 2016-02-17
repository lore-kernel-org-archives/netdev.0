From: Mathieu Desnoyers <mathieu.desnoyers@efficios.com>
Subject: [PATCH] Revert "net: sched: drop all special handling of tx_queue_len == 0"
Date: Tue, 16 Feb 2016 19:56:23 -0500
Message-ID: <1455670592-5649-1-git-send-email-mathieu.desnoyers@efficios.com>
Cc: linux-kernel@vger.kernel.org,
	Mathieu Desnoyers <mathieu.desnoyers@efficios.com>,
	Phil Sutter <phil@nwl.cc>, Jamal Hadi Salim <jhs@mojatatu.com>,
	netdev@vger.kernel.org, stable@vger.kernel.org
To: "David S . Miller" <davem@davemloft.net>
Return-path: <stable-owner@vger.kernel.org>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This reverts commit 348e3435cbefa815bd56a5205c1412b5afe7b92e.
It breaks HTB classful qdiscs on the loopback interface.

It has been broken since kernel v4.2. The offending commit has
been identified by bissection of the issue with the following
test-case. It appears that the loopback interface does indeed
still have tx_queue_len == 0.

Reverting the commit on a v4.4.1 kernel fixes the issue.

When the problem occurs, no network traffic (at all), not
even an ICMP ping, can go through the loopback interface.

The following bash script reproduces the issue:

SESSIOND_CTRL_PORT=5342
SESSIOND_DATA_PORT=5343
DEFAULT_IF="lo"

function set_bw_limit
{
        limit=$1
        ctrlportlimit=$(($limit/10))
        [ $ctrlportlimit = 0 ] && ctrlportlimit=1
        dataportlimit=$((9*${ctrlportlimit}))

        tc qdisc add dev $DEFAULT_IF root handle 1: htb default 15

        tc class add dev $DEFAULT_IF parent 1: classid 1:1 htb rate ${limit}kbit ceil ${limit}kbit
        tc class add dev $DEFAULT_IF parent 1:1 classid 1:10 htb rate ${ctrlportlimit}kbit ceil ${limit}kbit prio 1
        tc class add dev $DEFAULT_IF parent 1:1 classid 1:11 htb rate ${dataportlimit}kbit ceil ${limit}kbit prio 2

        tc filter add dev $DEFAULT_IF parent 1: protocol ip u32 match ip dport $SESSIOND_CTRL_PORT 0xffff flowid 1:10
        tc filter add dev $DEFAULT_IF parent 1: protocol ip u32 match ip dport $SESSIOND_DATA_PORT 0xffff flowid 1:11

        echo "Set bandwidth limits to ${limit}kbits, ${ctrlportlimit} for control and ${dataportlimit} for data"
}

function reset_bw_limit
{
        tc qdisc del dev $DEFAULT_IF root
        echo "Reset bandwith limits"
}

trap reset_bw_limit SIGINT SIGTERM

set_bw_limit 3200
sleep 1
ping localhost

Signed-off-by: Mathieu Desnoyers <mathieu.desnoyers@efficios.com>
Reported-by: Jonathan Rajotte-Julien <joraj@efficios.com>
CC: Phil Sutter <phil@nwl.cc>
CC: Jamal Hadi Salim <jhs@mojatatu.com>
CC: David S. Miller <davem@davemloft.net>
CC: netdev@vger.kernel.org
CC: stable@vger.kernel.org # 4.2+
---
 net/sched/sch_fifo.c | 2 +-
 net/sched/sch_gred.c | 8 +++++---
 net/sched/sch_htb.c  | 6 ++++--
 net/sched/sch_plug.c | 8 ++++++--
 net/sched/sch_sfb.c  | 2 +-
 5 files changed, 17 insertions(+), 9 deletions(-)

diff --git a/net/sched/sch_fifo.c b/net/sched/sch_fifo.c
index 2177eac..2e2398c 100644
--- a/net/sched/sch_fifo.c
+++ b/net/sched/sch_fifo.c
@@ -54,7 +54,7 @@ static int fifo_init(struct Qdisc *sch, struct nlattr *opt)
 	bool is_bfifo = sch->ops == &bfifo_qdisc_ops;
 
 	if (opt == NULL) {
-		u32 limit = qdisc_dev(sch)->tx_queue_len;
+		u32 limit = qdisc_dev(sch)->tx_queue_len ? : 1;
 
 		if (is_bfifo)
 			limit *= psched_mtu(qdisc_dev(sch));
diff --git a/net/sched/sch_gred.c b/net/sched/sch_gred.c
index 8010510..abb9f2f 100644
--- a/net/sched/sch_gred.c
+++ b/net/sched/sch_gred.c
@@ -512,9 +512,11 @@ static int gred_init(struct Qdisc *sch, struct nlattr *opt)
 
 	if (tb[TCA_GRED_LIMIT])
 		sch->limit = nla_get_u32(tb[TCA_GRED_LIMIT]);
-	else
-		sch->limit = qdisc_dev(sch)->tx_queue_len
-		             * psched_mtu(qdisc_dev(sch));
+	else {
+		u32 qlen = qdisc_dev(sch)->tx_queue_len ? : 1;
+
+		sch->limit = qlen * psched_mtu(qdisc_dev(sch));
+	}
 
 	return gred_change_table_def(sch, tb[TCA_GRED_DPS]);
 }
diff --git a/net/sched/sch_htb.c b/net/sched/sch_htb.c
index 15ccd7f..366ba83 100644
--- a/net/sched/sch_htb.c
+++ b/net/sched/sch_htb.c
@@ -1048,9 +1048,11 @@ static int htb_init(struct Qdisc *sch, struct nlattr *opt)
 
 	if (tb[TCA_HTB_DIRECT_QLEN])
 		q->direct_qlen = nla_get_u32(tb[TCA_HTB_DIRECT_QLEN]);
-	else
+	else {
 		q->direct_qlen = qdisc_dev(sch)->tx_queue_len;
-
+		if (q->direct_qlen < 2)	/* some devices have zero tx_queue_len */
+			q->direct_qlen = 2;
+	}
 	if ((q->rate2quantum = gopt->rate2quantum) < 1)
 		q->rate2quantum = 1;
 	q->defcls = gopt->defcls;
diff --git a/net/sched/sch_plug.c b/net/sched/sch_plug.c
index 5abfe44..ade9445 100644
--- a/net/sched/sch_plug.c
+++ b/net/sched/sch_plug.c
@@ -130,8 +130,12 @@ static int plug_init(struct Qdisc *sch, struct nlattr *opt)
 	q->unplug_indefinite = false;
 
 	if (opt == NULL) {
-		q->limit = qdisc_dev(sch)->tx_queue_len
-		           * psched_mtu(qdisc_dev(sch));
+		/* We will set a default limit of 100 pkts (~150kB)
+		 * in case tx_queue_len is not available. The
+		 * default value is completely arbitrary.
+		 */
+		u32 pkt_limit = qdisc_dev(sch)->tx_queue_len ? : 100;
+		q->limit = pkt_limit * psched_mtu(qdisc_dev(sch));
 	} else {
 		struct tc_plug_qopt *ctl = nla_data(opt);
 
diff --git a/net/sched/sch_sfb.c b/net/sched/sch_sfb.c
index 5bbb633..d5c1c1d 100644
--- a/net/sched/sch_sfb.c
+++ b/net/sched/sch_sfb.c
@@ -502,7 +502,7 @@ static int sfb_change(struct Qdisc *sch, struct nlattr *opt)
 
 	limit = ctl->limit;
 	if (limit == 0)
-		limit = qdisc_dev(sch)->tx_queue_len;
+		limit = max_t(u32, qdisc_dev(sch)->tx_queue_len, 1);
 
 	child = fifo_create_dflt(sch, &pfifo_qdisc_ops, limit);
 	if (IS_ERR(child))
-- 
1.9.1
