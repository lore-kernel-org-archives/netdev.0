From: Patrick McHardy <kaber@trash.net>
Subject: Re: 2.6.25-rc2-mm1 - several bugs and a crash
Date: Thu, 21 Feb 2008 12:28:50 +0100
Message-ID: <47BD6072.4000407@trash.net>
References: <20080216002522.9c4bd0fb.akpm@linux-foundation.org> <47BC982C.7050402@imap.cc>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------020401060508010500060202"
Cc: Andrew Morton <akpm@linux-foundation.org>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org
To: Tilman Schmidt <tilman@imap.cc>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <47BC982C.7050402@imap.cc>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------020401060508010500060202
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit

Tilman Schmidt wrote:
> Still, X came up fine, I could log in (Gnome feeling subjectively
> a bit sluggish), call up a web page from the Internet in Firefox,
> and start perusing the logs, when the whole system froze: neither
> mouse nor keyboard would react anymore, and only the Wind^Wreset
> button would put me back in control. After rebooting into the
> previous, non-mm kernel I found this in the syslog:
> 
> Feb 20 17:22:40 xenon kernel: [   48.180297] BUG: using smp_processor_id() in preemptible [00000000] code: ntpdate/3562
> Feb 20 17:22:40 xenon kernel: [   48.180297] caller is __nf_conntrack_find+0x9b/0xeb [nf_conntrack]
> Feb 20 17:22:40 xenon kernel: [   48.180297] Pid: 3562, comm: ntpdate Not tainted 2.6.25-rc2-mm1-testing #1
> Feb 20 17:22:40 xenon kernel: [   48.180297]  [<c02015b9>] debug_smp_processor_id+0x99/0xb0


Could you test whether this patch fixes the netfilter
warnings please?


--------------020401060508010500060202
Content-Type: text/plain;
 name="x"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="x"

commit 736b33102292be0d75be1e950ca9bcd5361db7dd
Author: Patrick McHardy <kaber@trash.net>
Date:   Thu Feb 21 12:26:01 2008 +0100

    [NETFILTER]: nf_conntrack: fix smp_processor_id() in preemptible code warning
    
    Since we're using RCU for the conntrack hash now, we need to avoid
    getting preempted or interrupted by BHs while changing the stats.
    
    Fixes warning reported by Tilman Schmidt <tilman@imap.cc> when using
    preemptible RCU:
    
    [   48.180297] BUG: using smp_processor_id() in preemptible [00000000] code: ntpdate/3562
    [   48.180297] caller is __nf_conntrack_find+0x9b/0xeb [nf_conntrack]
    [   48.180297] Pid: 3562, comm: ntpdate Not tainted 2.6.25-rc2-mm1-testing #1
    [   48.180297]  [<c02015b9>] debug_smp_processor_id+0x99/0xb0
    [   48.180297]  [<fac643a7>] __nf_conntrack_find+0x9b/0xeb [nf_conntrack]
    
    Signed-off-by: Patrick McHardy <kaber@trash.net>

diff --git a/net/netfilter/nf_conntrack_core.c b/net/netfilter/nf_conntrack_core.c
index 327e847..b77eb56 100644
--- a/net/netfilter/nf_conntrack_core.c
+++ b/net/netfilter/nf_conntrack_core.c
@@ -256,13 +256,19 @@ __nf_conntrack_find(const struct nf_conntrack_tuple *tuple)
 	struct hlist_node *n;
 	unsigned int hash = hash_conntrack(tuple);
 
+	/* Disable BHs the entire time since we normally need to disable them
+	 * at least once for the stats anyway.
+	 */
+	local_bh_disable();
 	hlist_for_each_entry_rcu(h, n, &nf_conntrack_hash[hash], hnode) {
 		if (nf_ct_tuple_equal(tuple, &h->tuple)) {
 			NF_CT_STAT_INC(found);
+			local_bh_enable();
 			return h;
 		}
 		NF_CT_STAT_INC(searched);
 	}
+	local_bh_enable();
 
 	return NULL;
 }
@@ -400,17 +406,20 @@ nf_conntrack_tuple_taken(const struct nf_conntrack_tuple *tuple,
 	struct hlist_node *n;
 	unsigned int hash = hash_conntrack(tuple);
 
-	rcu_read_lock();
+	/* Disable BHs the entire time since we need to disable them at
+	 * least once for the stats anyway.
+	 */
+	rcu_read_lock_bh();
 	hlist_for_each_entry_rcu(h, n, &nf_conntrack_hash[hash], hnode) {
 		if (nf_ct_tuplehash_to_ctrack(h) != ignored_conntrack &&
 		    nf_ct_tuple_equal(tuple, &h->tuple)) {
 			NF_CT_STAT_INC(found);
-			rcu_read_unlock();
+			rcu_read_unlock_bh();
 			return 1;
 		}
 		NF_CT_STAT_INC(searched);
 	}
-	rcu_read_unlock();
+	rcu_read_unlock_bh();
 
 	return 0;
 }

--------------020401060508010500060202--
