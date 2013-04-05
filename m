From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net 1/2] net: ipv4: reset check_lifetime_work after changing lifetime
Date: Fri,  5 Apr 2013 11:39:38 +0200
Message-ID: <1365154779-4204-2-git-send-email-jiri@resnulli.us>
References: <1365154779-4204-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, kuznet@ms2.inr.ac.ru, jmorris@namei.org,
	yoshfuji@linux-ipv6.org, kaber@trash.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f178.google.com ([209.85.212.178]:50181 "EHLO
	mail-wi0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751763Ab3DEJjs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Apr 2013 05:39:48 -0400
Received: by mail-wi0-f178.google.com with SMTP id ez12so381660wid.11
        for <netdev@vger.kernel.org>; Fri, 05 Apr 2013 02:39:46 -0700 (PDT)
In-Reply-To: <1365154779-4204-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This will result in calling check_lifetime in nearest opportunity and
that function will adjust next time to call check_lifetime correctly.
Without this, check_lifetime is called in time computed by previous run,
not affecting modified lifetime.

Introduced by: commit 5c766d642bcaf "ipv4: introduce address lifetime"

Signed-off-by: Jiri Pirko <jiri@resnulli.us>
---
 net/ipv4/devinet.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/net/ipv4/devinet.c b/net/ipv4/devinet.c
index 96083b7..00386e0 100644
--- a/net/ipv4/devinet.c
+++ b/net/ipv4/devinet.c
@@ -804,6 +804,8 @@ static int inet_rtm_newaddr(struct sk_buff *skb, struct nlmsghdr *nlh, void *arg
 			return -EEXIST;
 		ifa = ifa_existing;
 		set_ifa_lifetime(ifa, valid_lft, prefered_lft);
+		cancel_delayed_work(&check_lifetime_work);
+		schedule_delayed_work(&check_lifetime_work, 0);
 		rtmsg_ifa(RTM_NEWADDR, ifa, nlh, NETLINK_CB(skb).portid);
 		blocking_notifier_call_chain(&inetaddr_chain, NETDEV_UP, ifa);
 	}
-- 
1.8.1.2
