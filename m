From: Chen Gang <gang.chen@asianux.com>
Subject: [PATCH v2] ipv4: netfilter: always let NUL terminated string ended
 by '\0'
Date: Thu, 23 May 2013 19:50:46 +0800
Message-ID: <519E0296.6010601@asianux.com>
References: <5195ECB3.5000006@asianux.com> <20130523110832.GB22553@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: kaber@trash.net, kuznet@ms2.inr.ac.ru, jmorris@namei.org,
	yoshfuji@linux-ipv6.org, David Miller <davem@davemloft.net>,
	netfilter-devel@vger.kernel.org, netfilter@vger.kernel.org,
	coreteam@netfilter.org, netdev <netdev@vger.kernel.org>
To: Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from intranet.asianux.com ([58.214.24.6]:61024 "EHLO
	intranet.asianux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758006Ab3EWLvi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 May 2013 07:51:38 -0400
In-Reply-To: <20130523110832.GB22553@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


For NUL terminated string, need always be sure of ended by '\0'.

'prefix' max length is 128 (NF_LOG_PREFIXLEN), and 'pm->prefix' max
length is 32 (ULOG_PREFIX_LEN), so really need notice it.

'pm' is 'struct ulog_packet_msg_t' which may be copied to user mode
(defined in "include/uapi/..."), so can not use strlcpy() instead of.


Signed-off-by: Chen Gang <gang.chen@asianux.com>
---
 net/ipv4/netfilter/ipt_ULOG.c |    6 ++++--
 1 files changed, 4 insertions(+), 2 deletions(-)

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
1.7.7.6
