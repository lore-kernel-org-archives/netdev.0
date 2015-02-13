From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: [Patch] rtnetlink: call ->dellink on failure when ->newlink exists
Date: Fri, 13 Feb 2015 13:56:53 -0800
Message-ID: <1423864613-29637-1-git-send-email-xiyou.wangcong@gmail.com>
Cc: davem@davemloft.net, ignacy.gawedzki@green-communications.fr,
	Cong Wang <xiyou.wangcong@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f175.google.com ([209.85.192.175]:39485 "EHLO
	mail-pd0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753785AbbBMV5C (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Feb 2015 16:57:02 -0500
Received: by pdjy10 with SMTP id y10so21962886pdj.6
        for <netdev@vger.kernel.org>; Fri, 13 Feb 2015 13:57:01 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ignacy reported that when eth0 is down and add a vlan device
on top of it like:

  ip link add link eth0 name eth0.1 up type vlan id 1

We will get a refcount leak:

  unregister_netdevice: waiting for eth0.1 to become free. Usage count = 2

The problem is when rtnl_configure_link() fails in rtnl_newlink(),
we simply call unregister_device(), but for stacked device like vlan,
we almost do nothing when we unregister the upper device, more work
is done when we unregister the lower device, so call its ->dellink().

Reported-by: Ignacy Gawedzki <ignacy.gawedzki@green-communications.fr>
Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
---
 net/core/rtnetlink.c | 9 ++++++++-
 1 file changed, 8 insertions(+), 1 deletion(-)

diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index 5be499b..ab293a3 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -2162,7 +2162,14 @@ static int rtnl_newlink(struct sk_buff *skb, struct nlmsghdr *nlh)
 		}
 		err = rtnl_configure_link(dev, ifm);
 		if (err < 0) {
-			unregister_netdevice(dev);
+			if (ops->newlink) {
+				LIST_HEAD(list_kill);
+
+				ops->dellink(dev, &list_kill);
+				unregister_netdevice_many(&list_kill);
+			} else {
+				unregister_netdevice(dev);
+			}
 			goto out;
 		}
 
-- 
1.8.3.1
