From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] net: vxlan: fix crash when interface is created
 with no group
Date: Thu, 20 Mar 2014 16:02:29 -0400 (EDT)
Message-ID: <20140320.160229.857536522237793124.davem@davemloft.net>
References: <1395055050-20874-1-git-send-email-mike.rapoport@ravellosystems.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: mike.rapoport@ravellosystems.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:50967 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751271AbaCTUCb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Mar 2014 16:02:31 -0400
In-Reply-To: <1395055050-20874-1-git-send-email-mike.rapoport@ravellosystems.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mike Rapoport <mike.rapoport@ravellosystems.com>
Date: Mon, 17 Mar 2014 13:17:30 +0200

> If the vxlan interface is created without group definition, there is a
> panic on the first packet reception:
 ...
> The crash occurs because vxlan_rcv decides on protocol version of outer
> packed using vxlan->default_dst.remote_ip.sa.sa_family field which is
> not initialized if no multicast group was specified at interface
> creation time. This causes vxlan driver to always assume that outer
> packet is IPv6.
> 
> Using IP protocol version from skb instead of default destination
> address family fixes the problem.
> 
> Signed-off-by: Mike Rapoport <mike.rapoport@ravellosystems.com>

Thinking some more, I'd like to propose an alternate version of this fix.

Any objections to this?  I think it maintains the pre-ipv6-support
behavior.  I know there may be some concerns about supporting multiple
families on the same socket, but I'm not so sure the code is able to
support that right now anyways.

diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
index a7eb3f2..3a23623 100644
--- a/drivers/net/vxlan.c
+++ b/drivers/net/vxlan.c
@@ -1206,7 +1206,7 @@ static void vxlan_rcv(struct vxlan_sock *vs,
 		goto drop;
 
 	/* Re-examine inner Ethernet packet */
-	if (remote_ip->sa.sa_family == AF_INET) {
+	if (vs->family == AF_INET) {
 		oip = ip_hdr(skb);
 		saddr.sin.sin_addr.s_addr = oip->saddr;
 		saddr.sa.sa_family = AF_INET;
@@ -2409,10 +2409,13 @@ static struct vxlan_sock *vxlan_socket_create(struct net *net, __be16 port,
 
 	INIT_WORK(&vs->del_work, vxlan_del_work);
 
-	if (ipv6)
+	if (ipv6) {
+		vs->family = AF_INET6;
 		sock = create_v6_sock(net, port);
-	else
+	} else {
+		vs->family = AF_INET;
 		sock = create_v4_sock(net, port);
+	}
 	if (IS_ERR(sock)) {
 		kfree(vs);
 		return ERR_CAST(sock);
diff --git a/include/net/vxlan.h b/include/net/vxlan.h
index 5deef1a..6f00731 100644
--- a/include/net/vxlan.h
+++ b/include/net/vxlan.h
@@ -16,6 +16,7 @@ struct vxlan_sock {
 	struct hlist_node hlist;
 	vxlan_rcv_t	 *rcv;
 	void		 *data;
+	__u16		  family;
 	struct work_struct del_work;
 	struct socket	 *sock;
 	struct rcu_head	  rcu;
