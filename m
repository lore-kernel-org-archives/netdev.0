From: Ding Tianhong <dingtianhong@huawei.com>
Subject: [PATCH net v2] igmp: fix the problem when mc leave group
Date: Wed, 2 Jul 2014 13:50:48 +0800
Message-ID: <53B39DB8.2060306@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
To: "David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>,
	Netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga01-in.huawei.com ([119.145.14.64]:40474 "EHLO
	szxga01-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751797AbaGBFvF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Jul 2014 01:51:05 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The problem was triggered by these steps:

1) create socket, bind and then setsockopt for add mc group.
   mreq.imr_multiaddr.s_addr = inet_addr("255.0.0.37");
   mreq.imr_interface.s_addr = inet_addr("192.168.1.2");
   setsockopt(sockfd, IPPROTO_IP, IP_ADD_MEMBERSHIP, &mreq, sizeof(mreq));

2) drop the mc group for this socket.
   mreq.imr_multiaddr.s_addr = inet_addr("255.0.0.37");
   mreq.imr_interface.s_addr = inet_addr("0.0.0.0");
   setsockopt(sockfd, IPPROTO_IP, IP_DROP_MEMBERSHIP, &mreq, sizeof(mreq));

3) and then drop the socket, I found the mc group was still used by the dev:

   netstat -g

   Interface       RefCnt Group
   --------------- ------ ---------------------
   eth2		   1	  255.0.0.37

Normally even though the IP_DROP_MEMBERSHIP return error, the mc group still need
to be released for the netdev when drop the socket, but this process was broken when
route default is NULL, the reason is that:

The ip_mc_leave_group() will choose the in_dev by the imr_interface.s_addr, if input addr
is NULL, the default route dev will be chosen, then the ifindex is got from the dev,
then polling the inet->mc_list and return -ENODEV, but if the default route dev is NULL,
the in_dev and ifIndex is both NULL, when polling the inet->mc_list, the mc group will be
released from the mc_list, but the dev didn't dec the refcnt for this mc group, so
when dropping the socket, the mc_list is NULL and the dev still keep this group.

v1->v2: According Hideaki's suggestion, we should align with IPv6 (RFC3493) and BSDs,
	so I add the checking for the in_dev before polling the mc_list, make sure when
	we remove the mc group, dec the refcnt to the real dev which was using the mc address.
	The problem would never happened again.

Signed-off-by: Ding Tianhong <dingtianhong@huawei.com>
---
 net/ipv4/igmp.c | 10 ++++++----
 1 file changed, 6 insertions(+), 4 deletions(-)

diff --git a/net/ipv4/igmp.c b/net/ipv4/igmp.c
index 17d34e3..7fb6565 100644
--- a/net/ipv4/igmp.c
+++ b/net/ipv4/igmp.c
@@ -1944,6 +1944,10 @@ int ip_mc_leave_group(struct sock *sk, struct ip_mreqn *imr)
 
 	rtnl_lock();
 	in_dev = ip_mc_find_dev(net, imr);
+	if (!in_dev) {
+		ret = -ENODEV;
+		goto out;
+	}
 	ifindex = imr->imr_ifindex;
 	for (imlp = &inet->mc_list;
 	     (iml = rtnl_dereference(*imlp)) != NULL;
@@ -1961,16 +1965,14 @@ int ip_mc_leave_group(struct sock *sk, struct ip_mreqn *imr)
 
 		*imlp = iml->next_rcu;
 
-		if (in_dev)
-			ip_mc_dec_group(in_dev, group);
+		ip_mc_dec_group(in_dev, group);
 		rtnl_unlock();
 		/* decrease mem now to avoid the memleak warning */
 		atomic_sub(sizeof(*iml), &sk->sk_omem_alloc);
 		kfree_rcu(iml, rcu);
 		return 0;
 	}
-	if (!in_dev)
-		ret = -ENODEV;
+out:
 	rtnl_unlock();
 	return ret;
 }
-- 
1.7.12
