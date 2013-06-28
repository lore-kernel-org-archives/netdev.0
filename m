From: Kamal Mostafa <kamal@canonical.com>
Subject: [PATCH 090/105] sctp: fully initialize sctp_outq in sctp_outq_init
Date: Fri, 28 Jun 2013 11:51:52 -0700
Message-ID: <1372445527-24414-91-git-send-email-kamal@canonical.com>
References: <1372445527-24414-1-git-send-email-kamal@canonical.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Vlad Yasevich <vyasevich@gmail.com>,
 Kamal Mostafa <kamal@canonical.com>, davem@davemloft.net,
 Neil Horman <nhorman@tuxdriver.com>
To: linux-kernel@vger.kernel.org, stable@vger.kernel.org,
 kernel-team@lists.ubuntu.com
Return-path: <kernel-team-bounces@lists.ubuntu.com>
In-Reply-To: <1372445527-24414-1-git-send-email-kamal@canonical.com>
List-Unsubscribe: <https://lists.ubuntu.com/mailman/options/kernel-team>,
 <mailto:kernel-team-request@lists.ubuntu.com?subject=unsubscribe>
List-Archive: <https://lists.ubuntu.com/archives/kernel-team>
List-Post: <mailto:kernel-team@lists.ubuntu.com>
List-Help: <mailto:kernel-team-request@lists.ubuntu.com?subject=help>
List-Subscribe: <https://lists.ubuntu.com/mailman/listinfo/kernel-team>,
 <mailto:kernel-team-request@lists.ubuntu.com?subject=subscribe>
Errors-To: kernel-team-bounces@lists.ubuntu.com
Sender: kernel-team-bounces@lists.ubuntu.com
List-Id: netdev.vger.kernel.org

3.8.13.4 -stable review patch.  If anyone has any objections, please let me know.

------------------

From: Neil Horman <nhorman@tuxdriver.com>

[ Upstream commit c5c7774d7eb4397891edca9ebdf750ba90977a69 ]

In commit 2f94aabd9f6c925d77aecb3ff020f1cc12ed8f86
(refactor sctp_outq_teardown to insure proper re-initalization)
we modified sctp_outq_teardown to use sctp_outq_init to fully re-initalize the
outq structure.  Steve West recently asked me why I removed the q->error = 0
initalization from sctp_outq_teardown.  I did so because I was operating under
the impression that sctp_outq_init would properly initalize that value for us,
but it doesn't.  sctp_outq_init operates under the assumption that the outq
struct is all 0's (as it is when called from sctp_association_init), but using
it in __sctp_outq_teardown violates that assumption. We should do a memset in
sctp_outq_init to ensure that the entire structure is in a known state there
instead.

Signed-off-by: Neil Horman <nhorman@tuxdriver.com>
Reported-by: "West, Steve (NSN - US/Fort Worth)" <steve.west@nsn.com>
CC: Vlad Yasevich <vyasevich@gmail.com>
CC: netdev@vger.kernel.org
CC: davem@davemloft.net
Acked-by: Vlad Yasevich <vyasevich@gmail.com>
Signed-off-by: David S. Miller <davem@davemloft.net>
Signed-off-by: Kamal Mostafa <kamal@canonical.com>
---
 net/sctp/outqueue.c | 8 ++------
 1 file changed, 2 insertions(+), 6 deletions(-)

diff --git a/net/sctp/outqueue.c b/net/sctp/outqueue.c
index 9bcdbd0..b531098 100644
--- a/net/sctp/outqueue.c
+++ b/net/sctp/outqueue.c
@@ -206,6 +206,8 @@ static inline int sctp_cacc_skip(struct sctp_transport *primary,
  */
 void sctp_outq_init(struct sctp_association *asoc, struct sctp_outq *q)
 {
+	memset(q, 0, sizeof(struct sctp_outq));
+
 	q->asoc = asoc;
 	INIT_LIST_HEAD(&q->out_chunk_list);
 	INIT_LIST_HEAD(&q->control_chunk_list);
@@ -213,13 +215,7 @@ void sctp_outq_init(struct sctp_association *asoc, struct sctp_outq *q)
 	INIT_LIST_HEAD(&q->sacked);
 	INIT_LIST_HEAD(&q->abandoned);
 
-	q->fast_rtx = 0;
-	q->outstanding_bytes = 0;
 	q->empty = 1;
-	q->cork  = 0;
-
-	q->malloced = 0;
-	q->out_qlen = 0;
 }
 
 /* Free the outqueue structure and any related pending chunks.
-- 
1.8.1.2
