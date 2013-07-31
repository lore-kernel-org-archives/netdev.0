From: Cong Wang <amwang@redhat.com>
Subject: [Patch net-next] tcp_metrics: rearrange fields to avoid holes
Date: Wed, 31 Jul 2013 10:48:25 +0800
Message-ID: <1375238905-6423-1-git-send-email-amwang@redhat.com>
Cc: "David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	Yuchung Cheng <ycheng@google.com>,
	Neal Cardwell <ncardwell@google.com>,
	Cong Wang <amwang@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:37532 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751494Ab3GaCsg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 30 Jul 2013 22:48:36 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <amwang@redhat.com>

On x86_64, before this patch:

struct tcp_fastopen_metrics {
	u16                        mss;                  /*     0     2 */
	u16                        syn_loss:10;          /*     2: 6  2 */

	/* XXX 6 bits hole, try to pack */
	/* XXX 4 bytes hole, try to pack */

	long unsigned int          last_syn_loss;        /*     8     8 */
	struct tcp_fastopen_cookie cookie;               /*    16    17 */

	/* size: 40, cachelines: 1, members: 4 */
	/* sum members: 29, holes: 1, sum holes: 4 */
	/* bit holes: 1, sum bit holes: 6 bits */
	/* padding: 7 */
	/* last cacheline: 40 bytes */
};

after this patch:

struct tcp_fastopen_metrics {
	u16                        mss;                  /*     0     2 */
	u16                        syn_loss:10;          /*     2: 6  2 */

	/* XXX 6 bits hole, try to pack */

	struct tcp_fastopen_cookie cookie;               /*     4    17 */

	/* XXX 3 bytes hole, try to pack */

	long unsigned int          last_syn_loss;        /*    24     8 */

	/* size: 32, cachelines: 1, members: 4 */
	/* sum members: 29, holes: 1, sum holes: 3 */
	/* bit holes: 1, sum bit holes: 6 bits */
	/* last cacheline: 32 bytes */
};

On 32bit, the 4-byte hole should not exist, so this patch probably
doesn't change anything.

Cc: Eric Dumazet <edumazet@google.com>
Cc: Yuchung Cheng <ycheng@google.com>
Cc: Neal Cardwell <ncardwell@google.com>
Cc: David S. Miller <davem@davemloft.net>
Signed-off-by: Cong Wang <amwang@redhat.com>

---
diff --git a/net/ipv4/tcp_metrics.c b/net/ipv4/tcp_metrics.c
index 10b3796..438393f 100644
--- a/net/ipv4/tcp_metrics.c
+++ b/net/ipv4/tcp_metrics.c
@@ -25,8 +25,8 @@ int sysctl_tcp_nometrics_save __read_mostly;
 struct tcp_fastopen_metrics {
 	u16	mss;
 	u16	syn_loss:10;		/* Recurring Fast Open SYN losses */
-	unsigned long	last_syn_loss;	/* Last Fast Open SYN loss */
 	struct	tcp_fastopen_cookie	cookie;
+	unsigned long	last_syn_loss;	/* Last Fast Open SYN loss */
 };
 
 struct tcp_metrics_block {
