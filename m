From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 2/5] netfilter: ipt_ULOG: fix non-null terminated string in the nf_log path
Date: Wed, 29 May 2013 18:03:10 +0200
Message-ID: <1369843394-24251-3-git-send-email-pablo@netfilter.org>
References: <1369843394-24251-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1369843394-24251-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Chen Gang <gang.chen@asianux.com>

If nf_log uses ipt_ULOG as logging output, we can deliver non-null
terminated strings to user-space since the maximum length of the
prefix that is passed by nf_log is NF_LOG_PREFIXLEN but pm->prefix
is 32 bytes long (ULOG_PREFIX_LEN).

This is actually happening already from nf_conntrack_tcp if ipt_ULOG
is used, since it is passing strings longer than 32 bytes.

Signed-off-by: Chen Gang <gang.chen@asianux.com>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/ipv4/netfilter/ipt_ULOG.c |    6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff --git a/net/ipv4/netfilter/ipt_ULOG.c b/net/ipv4/netfilter/ipt_ULOG.c
index cf08218..ff4b781 100644
--- a/net/ipv4/netfilter/ipt_ULOG.c
+++ b/net/ipv4/netfilter/ipt_ULOG.c
@@ -231,8 +231,10 @@ static void ipt_ulog_packet(struct net *net,
 	put_unaligned(tv.tv_usec, &pm->timestamp_usec);
 	put_unaligned(skb->mark, &pm->mark);
 	pm->hook = hooknum;
-	if (prefix != NULL)
-		strncpy(pm->prefix, prefix, sizeof(pm->prefix));
+	if (prefix != NULL) {
+		strncpy(pm->prefix, prefix, sizeof(pm->prefix) - 1);
+		pm->prefix[sizeof(pm->prefix) - 1] = '\0';
+	}
 	else if (loginfo->prefix[0] != '\0')
 		strncpy(pm->prefix, loginfo->prefix, sizeof(pm->prefix));
 	else
-- 
1.7.10.4

