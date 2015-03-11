From: David Miller <davem@davemloft.net>
Subject: Re: rtnl_newlink() cleanup on namespace change
Date: Tue, 10 Mar 2015 22:00:11 -0400 (EDT)
Message-ID: <20150310.220011.1982964437618102167.davem@davemloft.net>
References: <20150310.184347.1581730121744725414.davem@davemloft.net>
	<CAM_iQpXNp4+1D454yrwJyER50gKC3N1CtDffEExDYiGCENTiFQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: xiyou.wangcong@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:36137 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751811AbbCKCAN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Mar 2015 22:00:13 -0400
In-Reply-To: <CAM_iQpXNp4+1D454yrwJyER50gKC3N1CtDffEExDYiGCENTiFQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <xiyou.wangcong@gmail.com>
Date: Tue, 10 Mar 2015 16:44:06 -0700

> On Tue, Mar 10, 2015 at 3:43 PM, David Miller <davem@davemloft.net> wrote:
>>
>> Cong, I was reviewing commit 7afb8886a05be68e376655539a064ec672de8a8e
>> ("rtnetlink: call ->dellink on failure when ->newlink exists") during
>> a stable backport and I noticed that the function, after the change
>> you made, subsequently goes:
>>
>>                 if (link_net) {
>>                         err = dev_change_net_namespace(dev, dest_net, ifname);
>>                         if (err < 0)
>>                                 unregister_netdevice(dev);
>>                 }
>>
>> Isn't the potential ->dellink() unwinding necessary in this path too?
>>
> 
> Right, I wasn't aware of the link_net change.
> Do you want me to send a fix?

I took care of it, as follows:

====================
[PATCH] net: Handle unregister properly when netdev namespace change fails.

If rtnl_newlink() fails on it's call to dev_change_net_namespace(), we
have to make use of the ->dellink() method, if present, just like we
do when rtnl_configure_link() fails.

Fixes: 317f4810e45e ("rtnl: allow to create device with IFLA_LINK_NETNSID set")
Signed-off-by: David S. Miller <davem@davemloft.net>
---
 net/core/rtnetlink.c | 26 +++++++++++++-------------
 1 file changed, 13 insertions(+), 13 deletions(-)

diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index 25b4b5d..ee0608b 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -2166,28 +2166,28 @@ replay:
 			}
 		}
 		err = rtnl_configure_link(dev, ifm);
-		if (err < 0) {
-			if (ops->newlink) {
-				LIST_HEAD(list_kill);
-
-				ops->dellink(dev, &list_kill);
-				unregister_netdevice_many(&list_kill);
-			} else {
-				unregister_netdevice(dev);
-			}
-			goto out;
-		}
-
+		if (err < 0)
+			goto out_unregister;
 		if (link_net) {
 			err = dev_change_net_namespace(dev, dest_net, ifname);
 			if (err < 0)
-				unregister_netdevice(dev);
+				goto out_unregister;
 		}
 out:
 		if (link_net)
 			put_net(link_net);
 		put_net(dest_net);
 		return err;
+out_unregister:
+		if (ops->newlink) {
+			LIST_HEAD(list_kill);
+
+			ops->dellink(dev, &list_kill);
+			unregister_netdevice_many(&list_kill);
+		} else {
+			unregister_netdevice(dev);
+		}
+		goto out;
 	}
 }
 
-- 
2.1.0
