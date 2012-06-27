From: Paul Bolle <pebolle@tiscali.nl>
Subject: [PATCH] iwlegacy: print how long queue was actually stuck
Date: Wed, 27 Jun 2012 10:36:27 +0200
Message-ID: <1340786187.1911.24.camel@x61.thuisdomein>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Stanislaw Gruszka <sgruszka@redhat.com>,
	"John W. Linville" <linville@tuxdriver.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Every now and then, after resuming from suspend, the iwlegacy driver
prints
    iwl4965 0000:03:00.0: Queue 2 stuck for 2000 ms.
    iwl4965 0000:03:00.0: On demand firmware reload

I have no idea what causes these errors. But the code currently uses
wd_timeout in the first error. wd_timeout will generally be set at
IL_DEF_WD_TIMEOUT (ie, 2000). Perhaps printing for how long the queue
was actually stuck can clarify the cause of these errors.

Signed-off-by: Paul Bolle <pebolle@tiscali.nl>
---
0) Compile tested on v3.5-rc4. Tested on Fedora 's current v3.4.2 based
kernel (ie, on F16). That required an edit to this commit because of
trivial context changes.

1) Please note that testing here involved waiting until I again
triggered this error (which now of course printed how long the queue was
actually stuck).

 drivers/net/wireless/iwlegacy/common.c |    7 ++++---
 1 files changed, 4 insertions(+), 3 deletions(-)

diff --git a/drivers/net/wireless/iwlegacy/common.c b/drivers/net/wireless/iwlegacy/common.c
index cbf2dc1..763c752 100644
--- a/drivers/net/wireless/iwlegacy/common.c
+++ b/drivers/net/wireless/iwlegacy/common.c
@@ -4717,10 +4717,11 @@ il_check_stuck_queue(struct il_priv *il, int cnt)
 	struct il_tx_queue *txq = &il->txq[cnt];
 	struct il_queue *q = &txq->q;
 	unsigned long timeout;
+	unsigned long now = jiffies;
 	int ret;
 
 	if (q->read_ptr == q->write_ptr) {
-		txq->time_stamp = jiffies;
+		txq->time_stamp = now;
 		return 0;
 	}
 
@@ -4728,9 +4729,9 @@ il_check_stuck_queue(struct il_priv *il, int cnt)
 	    txq->time_stamp +
 	    msecs_to_jiffies(il->cfg->wd_timeout);
 
-	if (time_after(jiffies, timeout)) {
+	if (time_after(now, timeout)) {
 		IL_ERR("Queue %d stuck for %u ms.\n", q->id,
-		       il->cfg->wd_timeout);
+		       jiffies_to_msecs(now - txq->time_stamp));
 		ret = il_force_reset(il, false);
 		return (ret == -EAGAIN) ? 0 : 1;
 	}
-- 
1.7.7.6
