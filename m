From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: [patch] packet: missing dev_put() in packet_do_bind()
Date: Tue, 28 Jul 2015 01:32:21 +0300
Message-ID: <20150727223220.GA10072@mwanda>
References: <55B62C77.3070300@newtec.eu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Willem de Bruijn <willemb@google.com>,
	Eric Dumazet <edumazet@google.com>,
	Daniel Borkmann <dborkman@redhat.com>,
	Alexander Drozdov <al.drozdov@gmail.com>,
	Eyal Birger <eyal.birger@gmail.com>,
	"Michael S. Tsirkin" <mst@redhat.com>, netdev@vger.kernel.org,
	Lars Westerhoff <lars.westerhoff@newtec.eu>,
	Boris Nikolaus <boris.nikolaus@newtec.eu>,
	krystian.garbaciak@newtec.eu,
	Michael Eyrich <michael.eyrich@newtec.eu>, security@kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:47658 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754305AbbG0WdI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Jul 2015 18:33:08 -0400
Content-Disposition: inline
In-Reply-To: <55B62C77.3070300@newtec.eu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Lars Westerhoff <lars.westerhoff@newtec.eu>

When binding a PF_PACKET socket, the use count of the bound interface is
always increased with dev_hold in dev_get_by_{index,name}.  However,
when rebound with the same protocol and device as in the previous bind
the use count of the interface was not decreased.  Ultimately, this
caused the deletion of the interface to fail with the following message:

unregister_netdevice: waiting for dummy0 to become free. Usage count = 1

This patch moves the dev_put out of the conditional part that was only
executed when either the protocol or device changed on a bind.

Fixes: 902fefb82ef7 ('packet: improve socket create/bind latency in some cases')
Signed-off-by: Lars Westerhoff <lars.westerhoff@newtec.eu>
Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>
Reviewed-by: Daniel Borkmann <dborkman@redhat.com>

diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
index c9e8741..c7c42eb 100644
--- a/net/packet/af_packet.c
+++ b/net/packet/af_packet.c
@@ -2784,7 +2784,7 @@ static int packet_release(struct socket *sock)
 static int packet_do_bind(struct sock *sk, struct net_device *dev, __be16 proto)
 {
 	struct packet_sock *po = pkt_sk(sk);
-	const struct net_device *dev_curr;
+	struct net_device *dev_curr;
 	__be16 proto_curr;
 	bool need_rehook;
 
@@ -2808,15 +2808,13 @@ static int packet_do_bind(struct sock *sk, struct net_device *dev, __be16 proto)
 
 		po->num = proto;
 		po->prot_hook.type = proto;
-
-		if (po->prot_hook.dev)
-			dev_put(po->prot_hook.dev);
-
 		po->prot_hook.dev = dev;
 
 		po->ifindex = dev ? dev->ifindex : 0;
 		packet_cached_dev_assign(po, dev);
 	}
+	if (dev_curr)
+		dev_put(dev_curr);
 
 	if (proto == 0 || !need_rehook)
 		goto out_unlock;
