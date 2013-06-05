From: Daniel Borkmann <dborkman@redhat.com>
Subject: [PATCH net] net: sctp: fix NULL pointer dereference in endpoint destruction
Date: Wed,  5 Jun 2013 11:58:23 +0200
Message-ID: <1370426303-2069-1-git-send-email-dborkman@redhat.com>
Cc: netdev@vger.kernel.org, linux-sctp@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:50223 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752530Ab3FEJ60 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 5 Jun 2013 05:58:26 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

While stress testing sctp sockets, I hit the following panic:

BUG: unable to handle kernel NULL pointer dereference at 0000000000000020
IP: [<ffffffffa0490c4e>] sctp_endpoint_free+0xe/0x40 [sctp]
PGD 7cead067 PUD 7ce76067 PMD 0 
Oops: 0000 [#1] SMP 
Modules linked in: sctp(F) libcrc32c(F) [...]
CPU: 7 PID: 2950 Comm: acc Tainted: GF            3.10.0-rc2+ #1
Hardware name: Dell Inc. PowerEdge T410/0H19HD, BIOS 1.6.3 02/01/2011
task: ffff88007ce0e0c0 ti: ffff88007b568000 task.ti: ffff88007b568000
RIP: 0010:[<ffffffffa0490c4e>]  [<ffffffffa0490c4e>] sctp_endpoint_free+0xe/0x40 [sctp]
RSP: 0018:ffff88007b569e08  EFLAGS: 00010292
RAX: 0000000000000000 RBX: ffff88007db78a00 RCX: dead000000200200
RDX: ffffffffa049fdb0 RSI: ffff8800379baf38 RDI: 0000000000000000
RBP: ffff88007b569e18 R08: ffff88007c230da0 R09: 0000000000000001
R10: 0000000000000000 R11: 0000000000000000 R12: 0000000000000000
R13: ffff880077990d00 R14: 0000000000000084 R15: ffff88007db78a00
FS:  00007fc18ab61700(0000) GS:ffff88007fc60000(0000) knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
CR2: 0000000000000020 CR3: 000000007cf9d000 CR4: 00000000000007e0
DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
Stack:
 ffff88007b569e38 ffff88007db78a00 ffff88007b569e38 ffffffffa049fded
 ffffffff81abf0c0 ffff88007db78a00 ffff88007b569e58 ffffffff8145b60e
 0000000000000000 0000000000000000 ffff88007b569eb8 ffffffff814df36e
Call Trace:
 [<ffffffffa049fded>] sctp_destroy_sock+0x3d/0x80 [sctp]
 [<ffffffff8145b60e>] sk_common_release+0x1e/0xf0
 [<ffffffff814df36e>] inet_create+0x2ae/0x350
 [<ffffffff81455a6f>] __sock_create+0x11f/0x240
 [<ffffffff81455bf0>] sock_create+0x30/0x40
 [<ffffffff8145696c>] SyS_socket+0x4c/0xc0
 [<ffffffff815403be>] ? do_page_fault+0xe/0x10
 [<ffffffff8153cb32>] ? page_fault+0x22/0x30
 [<ffffffff81544e02>] system_call_fastpath+0x16/0x1b
Code: 0c c9 c3 66 2e 0f 1f 84 00 00 00 00 00 e8 fb fe ff ff c9 c3 66 0f
      1f 84 00 00 00 00 00 55 48 89 e5 53 48 83 ec 08 66 66 66 66 90 <48>
      8b 47 20 48 89 fb c6 47 1c 01 c6 40 12 07 e8 9e 68 01 00 48
RIP  [<ffffffffa0490c4e>] sctp_endpoint_free+0xe/0x40 [sctp]
 RSP <ffff88007b569e08>
CR2: 0000000000000020
---[ end trace e0d71ec1108c1dd9 ]---

I did not hit this with the lksctp-tools functional tests, but with a
small, multi-threaded test program, that heavily allocates, binds,
listens and waits in accept on sctp sockets, and then randomly kills
some of them (no need for an actual client in this case to hit this).
Then, again, allocating, binding, etc, and then fragging the child
processes.

This patch fixes the NULL pointer dereference that can easily be hit
by this. My assumption is that while the endpoint's destruction is
deferred, the socket has already been destroyed at that time, when we
actually want to clean up endpoint garbage. Yet, during endpoint clean
up, we access through the base member parts of the original sctp socket,
i.e. hmac and others. Thus, we hit this bug when we try to access this.

Fix it by releasing socket related data during sctp_destroy_sock()
after we called sctp_endpoint_free(), but still before we leave the
socket destruction callback. This seems valid to do so, because the
socket's hmac and bind_hash are only used in socket.c and actually
not in endpointola.c.

Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
---
 net/sctp/endpointola.c |    7 -------
 net/sctp/socket.c      |    9 +++++++++
 2 files changed, 9 insertions(+), 7 deletions(-)

diff --git a/net/sctp/endpointola.c b/net/sctp/endpointola.c
index 5fbd7bc..ecfba70 100644
--- a/net/sctp/endpointola.c
+++ b/net/sctp/endpointola.c
@@ -248,9 +248,6 @@ static void sctp_endpoint_destroy(struct sctp_endpoint *ep)
 {
 	SCTP_ASSERT(ep->base.dead, "Endpoint is not dead", return);
 
-	/* Free up the HMAC transform. */
-	crypto_free_hash(sctp_sk(ep->base.sk)->hmac);
-
 	/* Free the digest buffer */
 	kfree(ep->digest);
 
@@ -270,10 +267,6 @@ static void sctp_endpoint_destroy(struct sctp_endpoint *ep)
 
 	memset(ep->secret_key, 0, sizeof(ep->secret_key));
 
-	/* Remove and free the port */
-	if (sctp_sk(ep->base.sk)->bind_hash)
-		sctp_put_port(ep->base.sk);
-
 	/* Give up our hold on the sock. */
 	if (ep->base.sk)
 		sock_put(ep->base.sk);
diff --git a/net/sctp/socket.c b/net/sctp/socket.c
index f631c5f..3267534 100644
--- a/net/sctp/socket.c
+++ b/net/sctp/socket.c
@@ -4007,7 +4007,16 @@ SCTP_STATIC void sctp_destroy_sock(struct sock *sk)
 		sp->do_auto_asconf = 0;
 		list_del(&sp->auto_asconf_list);
 	}
+
 	sctp_endpoint_free(sp->ep);
+
+	/* Free up the HMAC transform. */
+	crypto_free_hash(sp->hmac);
+
+	/* Remove and free the port */
+	if (sp->bind_hash)
+		sctp_put_port(sk);
+
 	local_bh_disable();
 	percpu_counter_dec(&sctp_sockets_allocated);
 	sock_prot_inuse_add(sock_net(sk), sk->sk_prot, -1);
-- 
1.7.1
