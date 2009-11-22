From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Subject: [2.6.32-rc8] set_all_monitor_traces() sleeping bug.
Date: Sun, 22 Nov 2009 22:49:14 +0900
Message-ID: <200911222249.EEG95313.OSLJQVFFOHFtOM@I-love.SAKURA.ne.jp>
References: <200911022100.EAC21893.OMFFJVOSOQHLtF@I-love.SAKURA.ne.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: nhorman@tuxdriver.com, davem@davemloft.net
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1755036AbZKVNtL@vger.kernel.org>
In-Reply-To: <200911022100.EAC21893.OMFFJVOSOQHLtF@I-love.SAKURA.ne.jp>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Commit: 4ea7e38696c7e798c47ebbecadfd392f23f814f9

set_all_monitor_traces() calls tracepoint_synchronize_unregister()
with a spinlock held, but tracepoint_synchronize_unregister() may sleep.

static int set_all_monitor_traces(int state)
{
	int rc = 0;
	struct dm_hw_stat_delta *new_stat = NULL;
	struct dm_hw_stat_delta *temp;

	spin_lock(&trace_state_lock);

	switch (state) {
	case TRACE_ON:
		rc |= register_trace_kfree_skb(trace_kfree_skb_hit);
		rc |= register_trace_napi_poll(trace_napi_poll_hit);
		break;
	case TRACE_OFF:
		rc |= unregister_trace_kfree_skb(trace_kfree_skb_hit);
		rc |= unregister_trace_napi_poll(trace_napi_poll_hit);

		tracepoint_synchronize_unregister();

		/*
		 * Clean the device list
		 */
		list_for_each_entry_safe(new_stat, temp, &hw_stats_list, list) {
			if (new_stat->dev == NULL) {
				list_del_rcu(&new_stat->list);
				call_rcu(&new_stat->rcu, free_dm_hw_stat);
			}
		}
		break;
	default:
		rc = 1;
		break;
	}

	if (!rc)
		trace_state = state;

	spin_unlock(&trace_state_lock);

	if (rc)
		return -EINPROGRESS;
	return rc;
}
