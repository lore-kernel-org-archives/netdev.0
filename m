From: Wang Chen <wangchen@cn.fujitsu.com>
Subject: [PATCH] af_packet: po->mclist needs locker in reader side(WAS: [PATCH
 1/9] af_packet: Check return of dev_set_promiscuity/allmulti)
Date: Tue, 15 Jul 2008 15:52:31 +0800
Message-ID: <487C573F.3020803@cn.fujitsu.com>
References: <487C0ABA.1070506@cn.fujitsu.com>	<487C127D.9010908@cn.fujitsu.com> <20080714.205110.266962405.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: kaber@trash.net, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:62290 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1753763AbYGOH5l (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 15 Jul 2008 03:57:41 -0400
In-Reply-To: <20080714.205110.266962405.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller said the following on 2008-7-15 11:51:
> From: Wang Chen <wangchen@cn.fujitsu.com>
> Date: Tue, 15 Jul 2008 10:59:09 +0800
> 
>> dev_set_promiscuity/allmulti might overflow.
>> Commit: "netdevice: Fix promiscuity and allmulti overflow" in net-next makes
>> dev_set_promiscuity/allmulti return error number if overflow happened.
>>
>> In af_packet, we check all positive increment for promiscuity and allmulti
>> to get error return.
>>
>> Signed-off-by: Wang Chen <wangchen@cn.fujitsu.com>
>> Acked-by: Patrick McHardy <kaber@trash.net> 
> 
> Applied, thanks.
> 
> What are the exact locking rules for po->mclist btw?  Obviously
> changes to the list are RTNL protected, but what about readers?
> 
> If readers lock differently, this error recovery where we unlink 'i'
> could cause an OOPS.  It is ok to add new elements while allowing
> readers to traverse independantly but removal needs to interlock with
> such readers.

As my understanding, packet_dev_mclist() is the only reader who doesn't
use same lock as writers(actually it doesn't use any lock).
My proposal is that use RTNL to prevent synchronous access to po->mclist.
Because packet_dev_mclist() is only called when device be unregistered,
the lock will not affect speed too much. 

Signed-off-by: Wang Chen <wangchen@cn.fujitsu.com>
---
diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
index 2cee87d..9eb39f7 100644
--- a/net/packet/af_packet.c
+++ b/net/packet/af_packet.c
@@ -1196,10 +1196,12 @@ static void packet_dev_mc(struct net_device *dev, struct packet_mclist *i, int w
 
 static void packet_dev_mclist(struct net_device *dev, struct packet_mclist *i, int what)
 {
+	rtnl_lock();
 	for ( ; i; i=i->next) {
 		if (i->ifindex == dev->ifindex)
 			packet_dev_mc(dev, i, what);
 	}
+	rtnl_unlock();
 }
 
 static int packet_mc_add(struct sock *sk, struct packet_mreq_max *mreq)

