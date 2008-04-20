From: David Miller <davem@davemloft.net>
Subject: Re: [built bug] drivers/net/wireless/iwlwifi/iwl-debugfs.c
Date: Sat, 19 Apr 2008 18:08:31 -0700 (PDT)
Message-ID: <20080419.180831.72013410.davem@davemloft.net>
References: <20080419135602.GA2499@elte.hu>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linville@tuxdriver.com, tomas.winkler@intel.com,
	linux-kernel@vger.kernel.org, kaber@trash.net,
	torvalds@linux-foundation.org, akpm@linux-foundation.org,
	netdev@vger.kernel.org, netfilter-devel@vger.kernel.org
To: mingo@elte.hu
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20080419135602.GA2499@elte.hu>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Ingo Molnar <mingo@elte.hu>
Date: Sat, 19 Apr 2008 15:56:02 +0200

> drivers/net/wireless/iwlwifi/iwl-debugfs.c: In function 'iwl_dbgfs_stations_read':
> drivers/net/wireless/iwlwifi/iwl-debugfs.c:256: error: 'struct iwl4965_tid_data' has no member named 'agg'

This should fix it, thanks for the report.

Longer term, I seriously question the sanity of including iwl4964
specific dumping into a debug module that is linked into both
iwlwifi drivers :-/

iwlwifi: Fix unconditional access to station->tidp[].agg.

Reportred by Ingo Molnar:

drivers/net/wireless/iwlwifi/iwl-debugfs.c: In function 'iwl_dbgfs_stations_read':
drivers/net/wireless/iwlwifi/iwl-debugfs.c:256: error: 'struct iwl4965_tid_data' has no member named 'agg'

Needs CONFIG_IWL4965_HT protection.

Signed-off-by: David S. Miller <davem@davemloft.net>

diff --git a/drivers/net/wireless/iwlwifi/iwl-debugfs.c b/drivers/net/wireless/iwlwifi/iwl-debugfs.c
index 0f16f26..9a30e1d 100644
--- a/drivers/net/wireless/iwlwifi/iwl-debugfs.c
+++ b/drivers/net/wireless/iwlwifi/iwl-debugfs.c
@@ -239,28 +239,34 @@ static ssize_t iwl_dbgfs_stations_read(struct file *file, char __user *user_buf,
 					"ps_status: %u\n", station->ps_status);
 			pos += scnprintf(buf + pos, bufsz - pos, "tid data:\n");
 			pos += scnprintf(buf + pos, bufsz - pos,
-					"seq_num\t\ttxq_id\t");
+					"seq_num\t\ttxq_id");
+#ifdef CONFIG_IWL4965_HT
 			pos += scnprintf(buf + pos, bufsz - pos,
-					"frame_count\twait_for_ba\t");
+					"\tframe_count\twait_for_ba\t");
 			pos += scnprintf(buf + pos, bufsz - pos,
 					"start_idx\tbitmap0\t");
 			pos += scnprintf(buf + pos, bufsz - pos,
-					"bitmap1\trate_n_flags\n");
+					"bitmap1\trate_n_flags");
+#endif
+			pos += scnprintf(buf + pos, bufsz - pos, "\n");
 
 			for (j = 0; j < MAX_TID_COUNT; j++) {
 				pos += scnprintf(buf + pos, bufsz - pos,
-						"[%d]:\t\t%u\t", j,
+						"[%d]:\t\t%u", j,
 						station->tid[j].seq_number);
+#ifdef CONFIG_IWL4965_HT
 				pos += scnprintf(buf + pos, bufsz - pos,
-						"%u\t\t%u\t\t%u\t\t",
+						"\t%u\t\t%u\t\t%u\t\t",
 						station->tid[j].agg.txq_id,
 						station->tid[j].agg.frame_count,
 						station->tid[j].agg.wait_for_ba);
 				pos += scnprintf(buf + pos, bufsz - pos,
-						"%u\t%llu\t%u\n",
+						"%u\t%llu\t%u",
 						station->tid[j].agg.start_idx,
 						(unsigned long long)station->tid[j].agg.bitmap,
 						station->tid[j].agg.rate_n_flags);
+#endif
+				pos += scnprintf(buf + pos, bufsz - pos, "\n");
 			}
 			pos += scnprintf(buf + pos, bufsz - pos, "\n");
 		}
