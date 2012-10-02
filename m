From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCHv2 net-next] vxlan: put UDP socket in correct namespace
Date: Mon, 1 Oct 2012 21:49:21 -0700
Message-ID: <20121001214921.78d9ed72@nehalam.linuxnetplumber.net>
References: <20121001141609.14639bc0@nehalam.linuxnetplumber.net>
	<20121001145838.5eafef4c@nehalam.linuxnetplumber.net>
	<87fw5xeryf.fsf@xmission.com>
	<20121001155702.5b5e2188@nehalam.linuxnetplumber.net>
	<87y5jpdbzo.fsf@xmission.com>
	<20121001163226.3873ca58@nehalam.linuxnetplumber.net>
	<871uhhd82p.fsf@xmission.com>
	<20121001175107.0ec2931c@nehalam.linuxnetplumber.net>
	<87626tbsgq.fsf@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: ebiederm@xmission.com (Eric W. Biederman)
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:38598 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750753Ab2JBEt4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 2 Oct 2012 00:49:56 -0400
In-Reply-To: <87626tbsgq.fsf@xmission.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Move vxlan UDP socket to correct network namespace

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
---
v2 need to change sock_release to sk_release_kernel

--- a/drivers/net/vxlan.c	2012-10-01 17:18:30.776513263 -0700
+++ b/drivers/net/vxlan.c	2012-10-01 21:47:40.435979178 -0700
@@ -1136,6 +1136,9 @@ static __net_init int vxlan_init_net(str
 		pr_debug("UDP socket create failed\n");
 		return rc;
 	}
+	/* Put in proper namespace */
+	sk = vn->sock->sk;
+	sk_change_net(sk, net);
 
 	vxlan_addr.sin_port = htons(vxlan_port);
 
@@ -1144,13 +1147,12 @@ static __net_init int vxlan_init_net(str
 	if (rc < 0) {
 		pr_debug("bind for UDP socket %pI4:%u (%d)\n",
 			 &vxlan_addr.sin_addr, ntohs(vxlan_addr.sin_port), rc);
-		sock_release(vn->sock);
+		sk_release_kernel(sk);
 		vn->sock = NULL;
 		return rc;
 	}
 
 	/* Disable multicast loopback */
-	sk = vn->sock->sk;
 	inet_sk(sk)->mc_loop = 0;
 
 	/* Mark socket as an encapsulation socket. */
@@ -1169,7 +1171,7 @@ static __net_exit void vxlan_exit_net(st
 	struct vxlan_net *vn = net_generic(net, vxlan_net_id);
 
 	if (vn->sock) {
-		sock_release(vn->sock);
+		sk_release_kernel(vn->sock->sk);
 		vn->sock = NULL;
 	}
 }
