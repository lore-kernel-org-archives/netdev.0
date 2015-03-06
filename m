From: Robert Shearman <rshearma@brocade.com>
Subject: [PATCH net-next] mpls: Properly validate RTA_VIA payload length
Date: Fri, 6 Mar 2015 10:47:00 +0000
Message-ID: <1425638820-19990-1-git-send-email-rshearma@brocade.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, Robert Shearman <rshearma@brocade.com>,
	"Eric W. Biederman" <ebiederm@xmission.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-000f0801.pphosted.com ([67.231.144.122]:46546 "EHLO
	mx0a-000f0801.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932195AbbCFKsM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Mar 2015 05:48:12 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If the nla length is less than 2 then the nla data could be accessed
beyond the accessible bounds. So ensure that the nla is big enough to
at least read the via_family before doing so. Replace magic value of
2.

Fixes: 03c0566542f4 ("mpls: Basic support for adding and removing routes")
Cc: Eric W. Biederman <ebiederm@xmission.com>
Signed-off-by: Robert Shearman <rshearma@brocade.com>
---
 net/mpls/af_mpls.c | 5 ++++-
 1 file changed, 4 insertions(+), 1 deletion(-)

diff --git a/net/mpls/af_mpls.c b/net/mpls/af_mpls.c
index 23e51d1..4ce39f6 100644
--- a/net/mpls/af_mpls.c
+++ b/net/mpls/af_mpls.c
@@ -585,8 +585,11 @@ static int rtm_to_route_config(struct sk_buff *skb,  struct nlmsghdr *nlh,
 		case RTA_VIA:
 		{
 			struct rtvia *via = nla_data(nla);
+			if (nla_len(nla) < offsetof(struct rtvia, rtvia_addr))
+				goto errout;
 			cfg->rc_via_family = via->rtvia_family;
-			cfg->rc_via_alen   = nla_len(nla) - 2;
+			cfg->rc_via_alen   = nla_len(nla) -
+				offsetof(struct rtvia, rtvia_addr);
 			if (cfg->rc_via_alen > MAX_VIA_ALEN)
 				goto errout;
 
-- 
2.1.4
