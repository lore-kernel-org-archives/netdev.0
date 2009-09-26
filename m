From: Yakov Lerner <iler.ml@gmail.com>
Subject: [PATCH] /proc/net/tcp, overhead removed
Date: Sun, 27 Sep 2009 00:31:15 +0300
Message-ID: <1254000675-8327-1-git-send-email-iler.ml@gmail.com>
Cc: Yakov Lerner <iler.ml@gmail.com>
To: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	davem@davemloft.net, kuznet@ms2.inr.ac.ru, pekkas@netcore.fi,
	jmorris@namei.org, yoshfuji@linux-ipv6.org, kaber@trash.net,
	torval
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f211.google.com ([209.85.219.211]:47317 "EHLO
	mail-ew0-f211.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752712AbZIZVbP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 26 Sep 2009 17:31:15 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

/proc/net/tcp does 20,000 sockets in 60-80 milliseconds, with this patch.

The overhead was in tcp_seq_start(). See analysis (3) below.
The patch is against Linus git tree (1). The patch is small.

------------  -----------   ------------------------------------
Before patch  After patch   20,000 sockets (10,000 tw + 10,000 estab)(2)
------------  -----------   ------------------------------------
6 sec          0.06 sec     dd bs=1k if=/proc/net/tcp >/dev/null 
1.5 sec        0.06 sec     dd bs=4k if=/proc/net/tcp >/dev/null

1.9 sec        0.16 sec     netstat -4ant >/dev/null
------------  -----------   ------------------------------------

This is ~ x25 improvement.
The new time is not dependent on read blockize.
Speed of netstat, naturally, improves, too; both -4 and -6.
/proc/net/tcp6 does 20,000 sockets in 100 millisec.

(1) against git://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux-2.6.git

(2) Used 'manysock' utility to stress system with large number of sockets:
  "manysock 10000 10000"    - 10,000 tw + 10,000 estab ip4 sockets.
  "manysock -6 10000 10000" - 10,000 tw + 10,000 estab ip6 sockets.
Found at http://ilerner.3b1.org/manysock/manysock.c

(3) Algorithmic analysis. 
    Old algorithm.

During 'cat </proc/net/tcp', tcp_seq_start() is called O(numsockets) times (4).
On average, every call to tcp_seq_start() scans half the whole hashtable. Ouch.
This is O(numsockets * hashsize). 95-99% of 'cat </proc/net/tcp' is spent in
tcp_seq_start()->tcp_get_idx. This overhead is eliminated by new algorithm,
which is O(numsockets + hashsize).

    New algorithm.

New algorithms is O(numsockets + hashsize). We jump to the right
hash bucket in tcp_seq_start(), without scanning half the hash.
To jump right to the hash bucket corresponding to *pos in tcp_seq_start(),
we reuse three pieces of state (st->num, st->bucket, st->sbucket)
as follows:
 - we check that requested pos >= last seen pos (st->num), the typical case. 
 - if so, we jump to bucket st->bucket
 - to arrive to the right item after beginning of st->bucket, we
keep in st->sbucket the position corresponding to the beginning of
bucket.

(4) Explanation of O( numsockets * hashsize) of old algorithm.

tcp_seq_start() is called once for every ~7 lines of netstat output 
if readsize is 1kb, or once for every ~28 lines if readsize >= 4kb.
Since record length of /proc/net/tcp records is 150 bytes, formula for
number of calls to tcp_seq_start() is
            (numsockets * 150 / min(4096,readsize)).
Netstat uses 4kb readsize (newer versions), or 1kb (older versions).
Note that speed of old algorithm does not improve above 4kb blocksize.

Speed of the new algorithm does not depend on blocksize.

Speed of the new algorithm does not perceptibly depend on hashsize (which
depends on ramsize). Speed of old algorithm drops with bigger hashsize.

(5) Reporting order.

Reporting order is exactly same as before if hash does not change underfoot.
When hash elements come and go during report, reporting order will be
same as that of tcpdiag.

Signed-off-by: Yakov Lerner <iler.ml@gmail.com>
---
 net/ipv4/tcp_ipv4.c |   26 ++++++++++++++++++++++++--
 1 files changed, 24 insertions(+), 2 deletions(-)

diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index 7cda24b..7d9421a 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -1994,13 +1994,14 @@ static inline int empty_bucket(struct tcp_iter_state *st)
 		hlist_nulls_empty(&tcp_hashinfo.ehash[st->bucket].twchain);
 }
 
-static void *established_get_first(struct seq_file *seq)
+static void *established_get_first_after(struct seq_file *seq, int bucket)
 {
 	struct tcp_iter_state *st = seq->private;
 	struct net *net = seq_file_net(seq);
 	void *rc = NULL;
 
-	for (st->bucket = 0; st->bucket < tcp_hashinfo.ehash_size; ++st->bucket) {
+	for (st->bucket = bucket; st->bucket < tcp_hashinfo.ehash_size;
+	     ++st->bucket) {
 		struct sock *sk;
 		struct hlist_nulls_node *node;
 		struct inet_timewait_sock *tw;
@@ -2036,6 +2037,11 @@ out:
 	return rc;
 }
 
+static void *established_get_first(struct seq_file *seq)
+{
+	return established_get_first_after(seq, 0);
+}
+
 static void *established_get_next(struct seq_file *seq, void *cur)
 {
 	struct sock *sk = cur;
@@ -2045,6 +2051,7 @@ static void *established_get_next(struct seq_file *seq, void *cur)
 	struct net *net = seq_file_net(seq);
 
 	++st->num;
+	st->sbucket = st->num;
 
 	if (st->state == TCP_SEQ_STATE_TIME_WAIT) {
 		tw = cur;
@@ -2116,6 +2123,21 @@ static void *tcp_get_idx(struct seq_file *seq, loff_t pos)
 static void *tcp_seq_start(struct seq_file *seq, loff_t *pos)
 {
 	struct tcp_iter_state *st = seq->private;
+
+	if (*pos && *pos >= st->sbucket &&
+	    (st->state == TCP_SEQ_STATE_ESTABLISHED ||
+	     st->state == TCP_SEQ_STATE_TIME_WAIT)) {
+		int nskip;
+		void *cur;
+
+		st->num = st->sbucket;
+		st->state = TCP_SEQ_STATE_ESTABLISHED;
+		cur = established_get_first_after(seq, st->bucket);
+		for (nskip = *pos - st->sbucket; nskip > 0 && cur; --nskip)
+			cur = established_get_next(seq, cur);
+		return cur;
+	}
+
 	st->state = TCP_SEQ_STATE_LISTENING;
 	st->num = 0;
 	return *pos ? tcp_get_idx(seq, *pos - 1) : SEQ_START_TOKEN;
-- 
1.6.5.rc2

