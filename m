From: Daniel Wagner <wagi@monom.org>
Subject: [PATCH 1/2] carl9170: Fix wrong completion usage
Date: Thu, 18 Aug 2016 15:12:05 +0200
Message-ID: <1471525926-20384-2-git-send-email-wagi@monom.org>
References: <1471525926-20384-1-git-send-email-wagi@monom.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-wireless@vger.kernel.org,
 linux-kernel@vger.kernel.org, ath10k@lists.infradead.org,
 Daniel Wagner <daniel.wagner@bmw-carit.de>,
 "Luis R . Rodriguez" <mcgrof@kernel.org>,
 Christian Lamparter <chunkeey@googlemail.com>
To: Kalle Valo <kvalo@codeaurora.org>
Return-path: <ath10k-bounces+gldad-ath10k=m.gmane.org@lists.infradead.org>
In-Reply-To: <1471525926-20384-1-git-send-email-wagi@monom.org>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/ath10k>,
 <mailto:ath10k-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/ath10k/>
List-Post: <mailto:ath10k@lists.infradead.org>
List-Help: <mailto:ath10k-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/ath10k>,
 <mailto:ath10k-request@lists.infradead.org?subject=subscribe>
Sender: "ath10k" <ath10k-bounces@lists.infradead.org>
Errors-To: ath10k-bounces+gldad-ath10k=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

From: Daniel Wagner <daniel.wagner@bmw-carit.de>

carl9170_usb_stop() is used from several places to flush and cleanup any
pending work. The normal pattern is to send a request and wait for the
irq handler to call complete(). The completion is not reinitialized
during normal operation and as the old comment indicates it is important
to keep calls to wait_for_completion_timeout() and complete() balanced.

Calling complete_all() brings this equilibirum out of balance and needs
to be fixed by a reinit_completion(). But that opens a small race
window. It is possible that the sequence of complete_all(),
reinit_completion() is faster than the wait_for_completion_timeout() can
do its work. The wake up is not lost but the done counter test is after
reinit_completion() has been executed. The only reason we don't see
carl9170_exec_cmd() hang forever is we use the timeout version of
wait_for_copletion().

Let's fix this by reinitializing the completion (that is just setting
done counter to 0) just before we send out an request. Now,
carl9170_usb_stop() can be sure a complete() call is enough to make
progess since there is only one waiter at max. This is a common pattern
also seen in various drivers which use completion.

Signed-off-by: Daniel Wagner <daniel.wagner@bmw-carit.de>
---
 drivers/net/wireless/ath/carl9170/usb.c | 6 ++----
 1 file changed, 2 insertions(+), 4 deletions(-)

diff --git a/drivers/net/wireless/ath/carl9170/usb.c b/drivers/net/wireless/ath/carl9170/usb.c
index 76842e6..99ab203 100644
--- a/drivers/net/wireless/ath/carl9170/usb.c
+++ b/drivers/net/wireless/ath/carl9170/usb.c
@@ -670,6 +670,7 @@ int carl9170_exec_cmd(struct ar9170 *ar, const enum carl9170_cmd_oids cmd,
 	ar->readlen = outlen;
 	spin_unlock_bh(&ar->cmd_lock);
 
+	reinit_completion(&ar->cmd_wait);
 	err = __carl9170_exec_cmd(ar, &ar->cmd, false);
 
 	if (!(cmd & CARL9170_CMD_ASYNC_FLAG)) {
@@ -778,10 +779,7 @@ void carl9170_usb_stop(struct ar9170 *ar)
 	spin_lock_bh(&ar->cmd_lock);
 	ar->readlen = 0;
 	spin_unlock_bh(&ar->cmd_lock);
-	complete_all(&ar->cmd_wait);
-
-	/* This is required to prevent an early completion on _start */
-	reinit_completion(&ar->cmd_wait);
+	complete(&ar->cmd_wait);
 
 	/*
 	 * Note:
-- 
2.7.4
