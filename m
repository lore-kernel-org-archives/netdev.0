From: Jesper Juhl <jj@chaosbits.net>
Subject: [PATCH] ath6kl: fix memory leak in ath6kl_fwlog_block_read()
Date: Wed, 11 Apr 2012 22:41:36 +0200 (CEST)
Message-ID: <alpine.LNX.2.00.1204112239070.2137@swampdragon.chaosbits.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Robert Love <rlove@google.com>,
	"John W. Linville" <linville@tuxdriver.com>,
	Kalle Valo <kvalo@qca.qualcomm.com>
To: linux-wireless@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

If, in
drivers/net/wireless/ath/ath6kl/debug.c::ath6kl_fwlog_block_read(),
the call to wait_for_completion_interruptible() returns -ERESTARTSYS
then we'll return without freeing the (as yet unused) memory we
allocated for 'buf' - thus leaking it.

Signed-off-by: Jesper Juhl <jj@chaosbits.net>
---
 drivers/net/wireless/ath/ath6kl/debug.c |    4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/drivers/net/wireless/ath/ath6kl/debug.c b/drivers/net/wireless/ath/ath6kl/debug.c
index d01403a..34eb927 100644
--- a/drivers/net/wireless/ath/ath6kl/debug.c
+++ b/drivers/net/wireless/ath/ath6kl/debug.c
@@ -401,8 +401,10 @@ static ssize_t ath6kl_fwlog_block_read(struct file *file,
 
 		ret = wait_for_completion_interruptible(
 			&ar->debug.fwlog_completion);
-		if (ret == -ERESTARTSYS)
+		if (ret == -ERESTARTSYS) {
+			vfree(buf);
 			return ret;
+		}
 
 		spin_lock(&ar->debug.fwlog_queue.lock);
 	}
-- 
1.7.10


PS. Please CC me on replies.

-- 
Jesper Juhl <jj@chaosbits.net>       http://www.chaosbits.net/
Don't top-post http://www.catb.org/jargon/html/T/top-post.html
Plain text mails only, please.
