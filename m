From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net] net: ipv4: notify when address lifetime changes
Date: Thu,  4 Apr 2013 20:33:00 +0200
Message-ID: <1365100380-6796-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, kuznet@ms2.inr.ac.ru, jmorris@namei.org,
	yoshfuji@linux-ipv6.org, kaber@trash.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f47.google.com ([74.125.82.47]:48685 "EHLO
	mail-wg0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1761306Ab3DDSdH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Apr 2013 14:33:07 -0400
Received: by mail-wg0-f47.google.com with SMTP id y10so3101339wgg.14
        for <netdev@vger.kernel.org>; Thu, 04 Apr 2013 11:33:05 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

if userspace changes lifetime of address, send netlink notification and
call notifier.

Signed-off-by: Jiri Pirko <jiri@resnulli.us>
---
 net/ipv4/devinet.c | 6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff --git a/net/ipv4/devinet.c b/net/ipv4/devinet.c
index f678507..96083b7 100644
--- a/net/ipv4/devinet.c
+++ b/net/ipv4/devinet.c
@@ -802,8 +802,10 @@ static int inet_rtm_newaddr(struct sk_buff *skb, struct nlmsghdr *nlh, void *arg
 		if (nlh->nlmsg_flags & NLM_F_EXCL ||
 		    !(nlh->nlmsg_flags & NLM_F_REPLACE))
 			return -EEXIST;
-
-		set_ifa_lifetime(ifa_existing, valid_lft, prefered_lft);
+		ifa = ifa_existing;
+		set_ifa_lifetime(ifa, valid_lft, prefered_lft);
+		rtmsg_ifa(RTM_NEWADDR, ifa, nlh, NETLINK_CB(skb).portid);
+		blocking_notifier_call_chain(&inetaddr_chain, NETDEV_UP, ifa);
 	}
 	return 0;
 }
-- 
1.8.1.2
