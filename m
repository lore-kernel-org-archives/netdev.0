From: Abhijit Pawar <abhi.c.pawar@gmail.com>
Subject: [PATCH RESEND RESEND] net: remove obsolete simple_strto<foo>
Date: Tue, 11 Dec 2012 09:04:20 +0530
Message-ID: <1355196860-10708-1-git-send-email-abhi.c.pawar@gmail.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	netfilter-devel@vger.kernel.org, netfilter@vger.kernel.org,
	coreteam@netfilter.org, linux-wireless@vger.kernel.org,
	Abhijit Pawar <abhi.c.pawar@gmail.com>
To: "David S. Miller" <davem@davemloft.net>,
	Pablo Neira Ayuso <pablo@netfilter.org>,
	Patrick McHardy <kaber@trash.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	"John W. Linville" <linville@tuxdriver.com>,
	Johannes Berg <johannes@sipsolutions.net>,
	Cong Wang <amwang@redhat.com>,
	Eric Dumazet <edumazet@google.com>,
	Neil Horman <nhorman@tuxdriver.com>,
	Joe Perches <joe@perches.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch replace the obsolete simple_strto<foo> with kstrto<foo>

Signed-off-by: Abhijit Pawar <abhi.c.pawar@gmail.com>
---
 net/core/netpoll.c                 |    6 ++++--
 net/ipv4/netfilter/ipt_CLUSTERIP.c |    9 +++++++--
 net/mac80211/debugfs_sta.c         |    4 +++-
 net/netfilter/nf_conntrack_core.c  |    6 ++++--
 4 files changed, 18 insertions(+), 7 deletions(-)

diff --git a/net/core/netpoll.c b/net/core/netpoll.c
index 77a0388..3151acf 100644
--- a/net/core/netpoll.c
+++ b/net/core/netpoll.c
@@ -674,7 +674,8 @@ int netpoll_parse_options(struct netpoll *np, char *opt)
 		if ((delim = strchr(cur, '@')) == NULL)
 			goto parse_failed;
 		*delim = 0;
-		np->local_port = simple_strtol(cur, NULL, 10);
+		if (kstrtou16(cur, 10, &np->local_port))
+			goto parse_failed;
 		cur = delim;
 	}
 	cur++;
@@ -705,7 +706,8 @@ int netpoll_parse_options(struct netpoll *np, char *opt)
 		*delim = 0;
 		if (*cur == ' ' || *cur == '\t')
 			np_info(np, "warning: whitespace is not allowed\n");
-		np->remote_port = simple_strtol(cur, NULL, 10);
+		if (kstrtou16(cur, 10, &np->remote_port))
+			goto parse_failed;
 		cur = delim;
 	}
 	cur++;
diff --git a/net/ipv4/netfilter/ipt_CLUSTERIP.c b/net/ipv4/netfilter/ipt_CLUSTERIP.c
index fe5daea..75e33a7 100644
--- a/net/ipv4/netfilter/ipt_CLUSTERIP.c
+++ b/net/ipv4/netfilter/ipt_CLUSTERIP.c
@@ -661,6 +661,7 @@ static ssize_t clusterip_proc_write(struct file *file, const char __user *input,
 #define PROC_WRITELEN	10
 	char buffer[PROC_WRITELEN+1];
 	unsigned long nodenum;
+	int rc;
 
 	if (size > PROC_WRITELEN)
 		return -EIO;
@@ -669,11 +670,15 @@ static ssize_t clusterip_proc_write(struct file *file, const char __user *input,
 	buffer[size] = 0;
 
 	if (*buffer == '+') {
-		nodenum = simple_strtoul(buffer+1, NULL, 10);
+		rc = kstrtoul(buffer+1, 10, &nodenum);
+		if (rc)
+			return rc;
 		if (clusterip_add_node(c, nodenum))
 			return -ENOMEM;
 	} else if (*buffer == '-') {
-		nodenum = simple_strtoul(buffer+1, NULL,10);
+		rc = kstrtoul(buffer+1, 10, &nodenum);
+		if (rc)
+			return rc;
 		if (clusterip_del_node(c, nodenum))
 			return -ENOENT;
 	} else
diff --git a/net/mac80211/debugfs_sta.c b/net/mac80211/debugfs_sta.c
index 49a1c70..6fb1168 100644
--- a/net/mac80211/debugfs_sta.c
+++ b/net/mac80211/debugfs_sta.c
@@ -220,7 +220,9 @@ static ssize_t sta_agg_status_write(struct file *file, const char __user *userbu
 	} else
 		return -EINVAL;
 
-	tid = simple_strtoul(buf, NULL, 0);
+	ret = kstrtoul(buf, 0, &tid);
+	if (ret)
+		return ret;
 
 	if (tid >= IEEE80211_NUM_TIDS)
 		return -EINVAL;
diff --git a/net/netfilter/nf_conntrack_core.c b/net/netfilter/nf_conntrack_core.c
index af17516..08cdc71 100644
--- a/net/netfilter/nf_conntrack_core.c
+++ b/net/netfilter/nf_conntrack_core.c
@@ -1409,7 +1409,7 @@ EXPORT_SYMBOL_GPL(nf_ct_alloc_hashtable);
 
 int nf_conntrack_set_hashsize(const char *val, struct kernel_param *kp)
 {
-	int i, bucket;
+	int i, bucket, rc;
 	unsigned int hashsize, old_size;
 	struct hlist_nulls_head *hash, *old_hash;
 	struct nf_conntrack_tuple_hash *h;
@@ -1422,7 +1422,9 @@ int nf_conntrack_set_hashsize(const char *val, struct kernel_param *kp)
 	if (!nf_conntrack_htable_size)
 		return param_set_uint(val, kp);
 
-	hashsize = simple_strtoul(val, NULL, 0);
+	rc = kstrtouint(val, 0, &hashsize);
+	if (rc)
+		return rc;
 	if (!hashsize)
 		return -EINVAL;
 
-- 
1.7.7.6
