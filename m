From: Abhijit Pawar <abhi.c.pawar@gmail.com>
Subject: [PATCH 2/4] net: remove obsolete simple_strto<foo>
Date: Fri,  7 Dec 2012 17:19:58 +0530
Message-ID: <1354880998-23417-1-git-send-email-abhi.c.pawar@gmail.com>
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
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f46.google.com ([209.85.220.46]:49628 "EHLO
	mail-pa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932675Ab2LGLua (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Dec 2012 06:50:30 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch replace the obsolete simple_strto<foo> with kstrto<foo>

Signed-off-by: Abhijit Pawar <abhi.c.pawar@gmail.com>
---
 net/core/netpoll.c                 |    9 +++++++--
 net/ipv4/netfilter/ipt_CLUSTERIP.c |    9 +++++++--
 net/mac80211/debugfs_sta.c         |    4 +++-
 net/netfilter/nf_conntrack_core.c  |    6 ++++--
 4 files changed, 21 insertions(+), 7 deletions(-)

diff --git a/net/core/netpoll.c b/net/core/netpoll.c
index 77a0388..596b127 100644
--- a/net/core/netpoll.c
+++ b/net/core/netpoll.c
@@ -668,13 +668,16 @@ EXPORT_SYMBOL(netpoll_print_options);
 
 int netpoll_parse_options(struct netpoll *np, char *opt)
 {
+	int rc;
 	char *cur=opt, *delim;
 
 	if (*cur != '@') {
 		if ((delim = strchr(cur, '@')) == NULL)
 			goto parse_failed;
 		*delim = 0;
-		np->local_port = simple_strtol(cur, NULL, 10);
+		rc = kstrtol(cur, 10, &np->local_port);
+		if (rc)
+			goto parse_failed;
 		cur = delim;
 	}
 	cur++;
@@ -705,7 +708,9 @@ int netpoll_parse_options(struct netpoll *np, char *opt)
 		*delim = 0;
 		if (*cur == ' ' || *cur == '\t')
 			np_info(np, "warning: whitespace is not allowed\n");
-		np->remote_port = simple_strtol(cur, NULL, 10);
+		rc = kstrtol(cur, 10, &np->remote_port);
+		if (rc)
+			goto parse_failed;
 		cur = delim;
 	}
 	cur++;
diff --git a/net/ipv4/netfilter/ipt_CLUSTERIP.c b/net/ipv4/netfilter/ipt_CLUSTERIP.c
index fe5daea..55e7b73 100644
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
+			return -EINVAL;
 		if (clusterip_add_node(c, nodenum))
 			return -ENOMEM;
 	} else if (*buffer == '-') {
-		nodenum = simple_strtoul(buffer+1, NULL,10);
+		rc = kstrtoul(buffer+1, 10, &nodenum);
+		if (rc)
+			return -EINVAL;
 		if (clusterip_del_node(c, nodenum))
 			return -ENOENT;
 	} else
diff --git a/net/mac80211/debugfs_sta.c b/net/mac80211/debugfs_sta.c
index 89281d2..18754fd 100644
--- a/net/mac80211/debugfs_sta.c
+++ b/net/mac80211/debugfs_sta.c
@@ -219,7 +219,9 @@ static ssize_t sta_agg_status_write(struct file *file, const char __user *userbu
 	} else
 		return -EINVAL;
 
-	tid = simple_strtoul(buf, NULL, 0);
+	ret = kstrtoul(buf, 0, &tid);
+	if (ret)
+		return -EINVAL;
 
 	if (tid >= IEEE80211_NUM_TIDS)
 		return -EINVAL;
diff --git a/net/netfilter/nf_conntrack_core.c b/net/netfilter/nf_conntrack_core.c
index af17516..18ce24b 100644
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
+		return -EINVAL;
 	if (!hashsize)
 		return -EINVAL;
 
-- 
1.7.7.6
