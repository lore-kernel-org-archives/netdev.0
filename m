From: Sridhar Samudrala <sri@us.ibm.com>
Subject: [PATCH] Add CAP_NET_RAW checks to bind() and sendmsg() on a
 AF_PACKET socket
Date: Tue, 12 Jan 2010 15:54:00 -0800
Message-ID: <1263340440.6844.110.camel@w-sridhar.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e31.co.us.ibm.com ([32.97.110.149]:36605 "EHLO
	e31.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751038Ab0ALXyI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Jan 2010 18:54:08 -0500
Received: from d03relay03.boulder.ibm.com (d03relay03.boulder.ibm.com [9.17.195.228])
	by e31.co.us.ibm.com (8.14.3/8.13.1) with ESMTP id o0CNk43E003716
	for <netdev@vger.kernel.org>; Tue, 12 Jan 2010 16:46:04 -0700
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay03.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o0CNs1t4050916
	for <netdev@vger.kernel.org>; Tue, 12 Jan 2010 16:54:01 -0700
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.14.3/8.13.1/NCO v10.0 AVout) with ESMTP id o0CNs1B3018926
	for <netdev@vger.kernel.org>; Tue, 12 Jan 2010 16:54:01 -0700
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

CAP_NET_RAW capability check is currently done only when creating
a PF_PACKET socket. But there are so such checks when doing a bind()
to a specific interface or sending a message to a specific interface
via sendmsg() with msg->msg_name.

So when a packet socket fd is passed to an un-privileged process, it
can do a re-bind or send a message to any interface.
We ran into this case when considering using raw socket backend for
KVM guests with libvirt opening the packet socket and passing the fd to
an un-priviliged qemu process.

The following patch adds CAP_NET_RAW checks to bind() and sendmsg()
with msg_name calls.

Signed-off-by: Sridhar Samudrala <sri@us.ibm.com>

diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
--- a/net/packet/af_packet.c
+++ b/net/packet/af_packet.c
@@ -958,6 +958,9 @@ static int tpacket_snd(struct packet_sock *po, struct msghdr *msg)
 		proto	= po->num;
 		addr	= NULL;
 	} else {
+		if (!capable(CAP_NET_RAW))
+			return -EACCES;
+
 		err = -EINVAL;
 		if (msg->msg_namelen < sizeof(struct sockaddr_ll))
 			goto out;
@@ -1075,6 +1078,9 @@ static int packet_snd(struct socket *sock,
 		proto	= po->num;
 		addr	= NULL;
 	} else {
+		if (!capable(CAP_NET_RAW))
+			return -EACCES;
+
 		err = -EINVAL;
 		if (msg->msg_namelen < sizeof(struct sockaddr_ll))
 			goto out;
@@ -1284,6 +1290,8 @@ static int packet_bind_spkt(struct socket *sock, struct sockaddr *uaddr,
 	struct net_device *dev;
 	int err = -ENODEV;
 
+	if (!capable(CAP_NET_RAW))
+		return -EACCES;
 	/*
 	 *	Check legality
 	 */
@@ -1307,6 +1315,8 @@ static int packet_bind(struct socket *sock, struct sockaddr *uaddr, int addr_len
 	struct net_device *dev = NULL;
 	int err;
 
+	if (!capable(CAP_NET_RAW))
+		return -EACCES;
 
 	/*
 	 *	Check legality


