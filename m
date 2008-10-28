From: Yavor Goulishev <yavor@simplifymedia.com>
Subject: [Patch] Establishing more than 64K outgoing TCP connections
Date: Tue, 28 Oct 2008 17:06:33 -0400
Message-ID: <241CE5A1B2AFFA4987A663380D74C0BB3FD69B08A7@MBX73.ad2.softcom.biz>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: David Miller <davem@davemloft.net>
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xsmtp03.mail2web.com ([168.144.250.223]:40323 "EHLO
	xsmtp03.mail2web.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753459AbYJ1VJN convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Oct 2008 17:09:13 -0400
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi guys,
I'm sending you a tiny patch for the kernel.
The change allowed me to establish more than 64K outgoing TCP connections from a single Linux box.
Being able to use multihomed client box to load test a server reduced dramatically the number of physical boxes I needed.
The other way to go was virtual machines, but you can't beat the simplicity of the single multihomed client.
Also the patch fixes an important symmetry.
Using the multihome setup is a simple technique to overcome the 64K limit on the server side.
The patch makes it possible on the client side too.

The fix is only for TCP but probably the same issue exists for UDP.
I didn't had the time to investigate.

The patch is against the latest code base 2.6.28-rc2.

--Yavor

diff --git a/net/ipv4/inet_connection_sock.c b/net/ipv4/inet_connection_sock.c
index bd1278a..d72fba6 100644
--- a/net/ipv4/inet_connection_sock.c
+++ b/net/ipv4/inet_connection_sock.c
@@ -109,7 +109,9 @@ int inet_csk_get_port(struct sock *sk, unsigned short snum)
                                        hashinfo->bhash_size)];
                        spin_lock(&head->lock);
                        inet_bind_bucket_for_each(tb, node, &head->chain)
-                               if (tb->ib_net == net && tb->port == rover)
+                               if (tb->ib_net == net &&
+                                   tb->port == rover &&
+                                   inet_csk(sk)->icsk_af_ops->bind_conflict(sk, tb))
                                        goto next;
                        break;
                next:
