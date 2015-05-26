From: Roopa Prabhu <roopa@cumulusnetworks.com>
Subject: [PATCH net] mpls: fix mpls route deletes to not check for route scope and type
Date: Tue, 26 May 2015 14:14:27 -0700
Message-ID: <1432674867-63142-1-git-send-email-roopa@cumulusnetworks.com>
Cc: davem@davemloft.net, rshearma@brocade.com, netdev@vger.kernel.org,
	vivek@cumulusnetworks.com
To: ebiederm@xmission.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f182.google.com ([209.85.192.182]:33794 "EHLO
	mail-pd0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750961AbbEZVOc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 May 2015 17:14:32 -0400
Received: by pdbki1 with SMTP id ki1so57749789pdb.1
        for <netdev@vger.kernel.org>; Tue, 26 May 2015 14:14:32 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Roopa Prabhu <roopa@cumulusnetworks.com>

This patch fixes incorrect -EINVAL error due to invalid
scope and type for mpls route deletes.

iproute2 route modify code does not set protocol/scope/type
for RTM_DELROUTE msgs. mpls code can skip checking for
these too.

$ip -f mpls route add 100 as 200 via inet 10.1.1.2 dev swp1

$ip -f mpls route show
100 as to 200 via inet 10.1.1.2 dev swp1

$ip -f mpls route del 100 as 200 via inet 10.1.1.2 dev swp1
RTNETLINK answers: Invalid argument

$ip -f mpls route del 100
RTNETLINK answers: Invalid argument

After patch:

$ip -f mpls route show
100 as to 200 via inet 10.1.1.2 dev swp1

$ip -f mpls route del 100 as 200 via inet 10.1.1.2 dev swp1

$ip -f mpls route show

Reported-by: Vivek Venkataraman <vivek@cumulusnetworks.com>
Suggested-by: Vivek Venkataraman <vivek@cumulusnetworks.com>
Signed-off-by: Vivek Venkataraman <vivek@cumulusnetworks.com>
Signed-off-by: Roopa Prabhu <roopa@cumulusnetworks.com>
---
 net/mpls/af_mpls.c |   11 +++++++----
 1 file changed, 7 insertions(+), 4 deletions(-)

diff --git a/net/mpls/af_mpls.c b/net/mpls/af_mpls.c
index 7b3f732..18ab7bf 100644
--- a/net/mpls/af_mpls.c
+++ b/net/mpls/af_mpls.c
@@ -693,10 +693,13 @@ static int rtm_to_route_config(struct sk_buff *skb,  struct nlmsghdr *nlh,
 	 * (or source specific address in the case of multicast)
 	 * all addresses have universal scope.
 	 */
-	if (rtm->rtm_scope != RT_SCOPE_UNIVERSE)
-		goto errout;
-	if (rtm->rtm_type != RTN_UNICAST)
-		goto errout;
+	if (nlh->nlmsg_type != RTM_DELROUTE) {
+		if (rtm->rtm_scope != RT_SCOPE_UNIVERSE)
+			goto errout;
+		if (rtm->rtm_type != RTN_UNICAST)
+			goto errout;
+	}
+
 	if (rtm->rtm_flags != 0)
 		goto errout;
 
-- 
1.7.10.4
