From: Chen Gang <gang.chen@asianux.com>
Subject: [PATCH] ipv4: netfilter: always let NUL terminated string ended by
 '\0'
Date: Fri, 17 May 2013 16:39:15 +0800
Message-ID: <5195ECB3.5000006@asianux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	netfilter-devel@vger.kernel.org, netfilter@vger.kernel.org,
	coreteam@netfilter.org, netdev <netdev@vger.kernel.org>
To: pablo@netfilter.org, kaber@trash.net, kuznet@ms2.inr.ac.ru,
	jmorris@namei.org, yoshfuji@linux-ipv6.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


For NUL terminated string, better always be sure of ended by '\0'.

'pm' is 'struct ulog_packet_msg_t' which may be copied to user mode
(defined in "include/uapi/..."), so can not use strlcpy() instead of.


Signed-off-by: Chen Gang <gang.chen@asianux.com>
---
 net/ipv4/netfilter/ipt_ULOG.c |   27 ++++++++++++++++-----------
 1 files changed, 16 insertions(+), 11 deletions(-)

diff --git a/net/ipv4/netfilter/ipt_ULOG.c b/net/ipv4/netfilter/ipt_ULOG.c
index f8a222cb..4a93382 100644
--- a/net/ipv4/netfilter/ipt_ULOG.c
+++ b/net/ipv4/netfilter/ipt_ULOG.c
@@ -231,11 +231,13 @@ static void ipt_ulog_packet(unsigned int hooknum,
 	put_unaligned(tv.tv_usec, &pm->timestamp_usec);
 	put_unaligned(skb->mark, &pm->mark);
 	pm->hook = hooknum;
-	if (prefix != NULL)
-		strncpy(pm->prefix, prefix, sizeof(pm->prefix));
-	else if (loginfo->prefix[0] != '\0')
-		strncpy(pm->prefix, loginfo->prefix, sizeof(pm->prefix));
-	else
+	if (prefix != NULL) {
+		strncpy(pm->prefix, prefix, sizeof(pm->prefix) - 1);
+		pm->prefix[sizeof(pm->prefix) - 1] = '\0';
+	} else if (loginfo->prefix[0] != '\0') {
+		strncpy(pm->prefix, loginfo->prefix, sizeof(pm->prefix) - 1);
+		pm->prefix[sizeof(pm->prefix) - 1] = '\0';
+	} else
 		*(pm->prefix) = '\0';
 
 	if (in && in->hard_header_len > 0 &&
@@ -246,14 +248,17 @@ static void ipt_ulog_packet(unsigned int hooknum,
 	} else
 		pm->mac_len = 0;
 
-	if (in)
-		strncpy(pm->indev_name, in->name, sizeof(pm->indev_name));
-	else
+	if (in) {
+		strncpy(pm->indev_name, in->name, sizeof(pm->indev_name) - 1);
+		pm->indev_name[sizeof(pm->indev_name) - 1] = '\0';
+	} else
 		pm->indev_name[0] = '\0';
 
-	if (out)
-		strncpy(pm->outdev_name, out->name, sizeof(pm->outdev_name));
-	else
+	if (out) {
+		strncpy(pm->outdev_name, out->name,
+			sizeof(pm->outdev_name) - 1);
+		pm->outdev_name[sizeof(pm->outdev_name) - 1] = '\0';
+	} else
 		pm->outdev_name[0] = '\0';
 
 	/* copy_len <= skb->len, so can't fail. */
-- 
1.7.7.6
