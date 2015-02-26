From: ebiederm@xmission.com (Eric W. Biederman)
Subject: [PATCH net 1/2] net: Verify permission to dest_net in newlink
Date: Thu, 26 Feb 2015 16:19:00 -0600
Message-ID: <87egpcmi3v.fsf_-_@x220.int.ebiederm.org>
References: <CAOYZPENnpPP-N-ST3xYE7vcCFhbNd-FMKj9OvBebYSMu42OdaQ@mail.gmail.com>
	<54EDF7BB.2060809@6wind.com> <871tldstju.fsf_-_@x220.int.ebiederm.org>
	<54EEDF9C.20302@6wind.com> <87wq34okb9.fsf@x220.int.ebiederm.org>
	<54EF3338.8000409@6wind.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Eugene Yakubovich <eugene.yakubovich@coreos.com>,
	netdev@vger.kernel.org, nicolas.dichtel@6wind.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out02.mta.xmission.com ([166.70.13.232]:34274 "EHLO
	out02.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754549AbbBZWWa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Feb 2015 17:22:30 -0500
In-Reply-To: <54EF3338.8000409@6wind.com> (Nicolas Dichtel's message of "Thu,
	26 Feb 2015 15:52:40 +0100")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


When applicable verify that the caller has permision to create a
network device in another network namespace.  This check is already
present when moving a network device between network namespaces in
setlink so all that is needed is to duplicate that check in newlink.

This change almost backports cleanly, but there are context conflicts
as the code that follows was added in v4.0-rc1

Fixes: b51642f6d77b131dc85d1d71029c3cbb5b07c262 net: Enable a userns root rtnl calls that are safe for unprivilged users
Cc: stable@vger.kernel.org
Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
---
 net/core/rtnetlink.c | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index ab293a3066b3..155e675f656c 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -2122,6 +2122,10 @@ replay:
 		if (IS_ERR(dest_net))
 			return PTR_ERR(dest_net);
 
+		err = -EPERM;
+		if (!netlink_ns_capable(skb, dest_net->user_ns, CAP_NET_ADMIN))
+			goto out;
+
 		if (tb[IFLA_LINK_NETNSID]) {
 			int id = nla_get_s32(tb[IFLA_LINK_NETNSID]);
 
-- 
2.2.1
