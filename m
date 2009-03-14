From: Eric Dumazet <dada1@cosmosbay.com>
Subject: [PATCH] net: reorder fields of struct socket
Date: Sat, 14 Mar 2009 10:03:54 +0100
Message-ID: <49BB72FA.1080401@cosmosbay.com>
References: <49B4B909.7050002@cosmosbay.com>	<20090313.145152.121603300.davem@davemloft.net>	<49BADE87.40407@cosmosbay.com> <20090313.153851.11725991.davem@davemloft.net> <49BAE1F3.5020105@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: kchang@athenacr.com, netdev@vger.kernel.org, bmb@athenacr.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:49758 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751198AbZCNJEG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 14 Mar 2009 05:04:06 -0400
In-Reply-To: <49BAE1F3.5020105@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On x86_64, its rather unfortunate that "wait_queue_head_t wait"
field of "struct socket" spans two cache lines (assuming a 64
bytes cache line in current cpus)

offsetof(struct socket, wait)=0x30
sizeof(wait_queue_head_t)=0x18

This might explain why Kenny Chang noticed that his multicast workload
was performing bad with 64 bit kernels, since more cache lines ping pongs
were involved.

This litle patch moves "wait" field next "fasync_list" so that both
fields share a single cache line, to speedup sock_def_readable()

Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>

diff --git a/include/linux/net.h b/include/linux/net.h
index 4515efa..4fc2ffd 100644
--- a/include/linux/net.h
+++ b/include/linux/net.h
@@ -129,11 +129,15 @@ struct socket {
 	socket_state		state;
 	short			type;
 	unsigned long		flags;
-	const struct proto_ops	*ops;
+	/*
+	 * Please keep fasync_list & wait fields in the same cache line
+	 */
 	struct fasync_struct	*fasync_list;
+	wait_queue_head_t	wait;
+
 	struct file		*file;
 	struct sock		*sk;
-	wait_queue_head_t	wait;
+	const struct proto_ops	*ops;
 };
 
 struct vm_area_struct;

