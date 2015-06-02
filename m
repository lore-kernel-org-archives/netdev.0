From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH net v3 2/2] mpls: fix mpls route deletes to not check for route scope
Date: Tue, 02 Jun 2015 16:13:51 -0500
Message-ID: <87a8wholtc.fsf@x220.int.ebiederm.org>
References: <1433226567-23302-3-git-send-email-roopa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: stephen@networkplumber.org, davem@davemloft.net,
	rshearma@brocade.com, netdev@vger.kernel.org,
	vivek@cumulusnetworks.com
To: Roopa Prabhu <roopa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out03.mta.xmission.com ([166.70.13.233]:35322 "EHLO
	out03.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752082AbbFBVS4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Jun 2015 17:18:56 -0400
In-Reply-To: <1433226567-23302-3-git-send-email-roopa@cumulusnetworks.com>
	(Roopa Prabhu's message of "Mon, 1 Jun 2015 23:29:27 -0700")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Roopa Prabhu <roopa@cumulusnetworks.com> writes:

> From: Roopa Prabhu <roopa@cumulusnetworks.com>
>
> Ignore scope for route del messages

So I just stopped and looked at what is happening.  When you originally
reported this you said (or at least I understood) that rtm_scope was not
being set in iproute.  I assumed that meant it was not being touched
and it was taking a default value of zero (or else it was possibly
floating).  Having looked neither is true.  iproute sets rtm_scope
to RT_SCOPE_NOWHERE during delete deliberately to act as a wild card.

In the kernel in other protocols currently ipv4 treats RT_SCOPE_NOWHERE
as a wild card during delete, decnet treats RT_SCOPE_NOWHERE as a wild
card during delete, the remaining protocols (ipv6, phonet, and can) that
implement RTM_DELROUTE do not look at rtm_scope at all.  Further ipv6
and phonet set rtm_scope to RT_SCOPE_UNIVERSE when dumped.

Which says to me that we have semantics in the kernel that no one has
let userspace know about, and that scares me when there is a
misunderstanding between the kernel and userspace about what fields
mean.  That inevitabily leads to bugs.  The kind of bugs that I have
to create security fixes for recently.

So I really think we should fix this in userspace so that that someone
reading iproute will have a chance at knowing that this scopes do not
exist in ipv6 and mpls and that scope logic is just noise in those
cases.

Something like:

>From 837dddea49af874fe750ab0712b3ef8066a2f55a Mon Sep 17 00:00:00 2001
From: "Eric W. Biederman" <ebiederm@xmission.com>
Date: Tue, 2 Jun 2015 15:51:31 -0500
Subject: [PATCH] iproute: When deleting routes don't always set the scope to RT_SCOPE_NOWHERE

IPv6 and MPLS do not implement scopes on addresses and using
RT_SCOPE_NOWHERE is just confusing noise.  Use RT_SCOPE_UNIVERSE
instead so that it is clear what is actually happening in the code.

Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
---
 ip/iproute.c | 11 +++++++----
 1 file changed, 7 insertions(+), 4 deletions(-)

diff --git a/ip/iproute.c b/ip/iproute.c
index fba475f65314..e9b991fdf62f 100644
--- a/ip/iproute.c
+++ b/ip/iproute.c
@@ -1136,6 +1136,9 @@ static int iproute_modify(int cmd, unsigned flags, int argc, char **argv)
 	if (nhs_ok)
 		parse_nexthops(&req.n, &req.r, argc, argv);
 
+	if (req.r.rtm_family == AF_UNSPEC)
+		req.r.rtm_family = AF_INET;
+
 	if (!table_ok) {
 		if (req.r.rtm_type == RTN_LOCAL ||
 		    req.r.rtm_type == RTN_BROADCAST ||
@@ -1144,7 +1147,10 @@ static int iproute_modify(int cmd, unsigned flags, int argc, char **argv)
 			req.r.rtm_table = RT_TABLE_LOCAL;
 	}
 	if (!scope_ok) {
-		if (req.r.rtm_type == RTN_LOCAL ||
+		if (req.r.rtm_family == AF_INET6 ||
+		    req.r.rtm_family == AF_MPLS)
+			req.r.rtm_scope = RT_SCOPE_UNIVERSE;
+		else if (req.r.rtm_type == RTN_LOCAL ||
 		    req.r.rtm_type == RTN_NAT)
 			req.r.rtm_scope = RT_SCOPE_HOST;
 		else if (req.r.rtm_type == RTN_BROADCAST ||
@@ -1160,9 +1166,6 @@ static int iproute_modify(int cmd, unsigned flags, int argc, char **argv)
 		}
 	}
 
-	if (req.r.rtm_family == AF_UNSPEC)
-		req.r.rtm_family = AF_INET;
-
 	if (rtnl_talk(&rth, &req.n, NULL, 0) < 0)
 		return -2;
 
-- 
2.2.1
