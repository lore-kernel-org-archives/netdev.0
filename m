From: akpm@osdl.org
Subject: [patch 2/2] bluetooth: use GFP_ATOMIC in *_sock_create's sk_alloc
Date: Sat, 30 Sep 2006 20:43:20 -0700
Message-ID: <200610010343.k913hKe9007189@shell0.pdx.osdl.net>
Cc: netdev@vger.kernel.org, akpm@osdl.org, deweerdt@free.fr,
	frederik.deweerdt@gmail.com, jet@gyve.org, marcel@holtmann.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:5096 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1751831AbWJADne (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 30 Sep 2006 23:43:34 -0400
To: arcel@holtmann.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Frederik Deweerdt <deweerdt@free.fr>

I think that the bluetooth-guard-bt_proto-with-rwlock.patch introduced the following
BUG:
[   43.232000] BUG: sleeping function called from invalid context at mm/slab.c:2903
[   43.232000] in_atomic():1, irqs_disabled():0
[   43.232000]  [<c0104114>] show_trace_log_lvl+0x197/0x1ba
[   43.232000]  [<c010415e>] show_trace+0x27/0x29
[   43.232000]  [<c010426e>] dump_stack+0x26/0x28
[   43.232000]  [<c011ad1c>] __might_sleep+0xa2/0xaa
[   43.232000]  [<c0173085>] __kmalloc+0x9c/0xb3
[   43.232000]  [<c02f9295>] sk_alloc+0x1bc/0x1de
[   43.232000]  [<c036d689>] hci_sock_create+0x42/0x8a
[   43.236000]  [<c0366f40>] bt_sock_create+0xb5/0x154
[   43.236000]  [<c02f69dc>] __sock_create+0x131/0x356
[   43.236000]  [<c02f6c2f>] sock_create+0x2e/0x30
[   43.236000]  [<c02f6c88>] sys_socket+0x27/0x53
[   43.240000]  [<c02f7db5>] sys_socketcall+0xa9/0x277
[   43.240000]  [<c0103131>] sysenter_past_esp+0x56/0x8d
[   43.240000]  [<b7f38410>] 0xb7f38410

This patch makes sk_alloc GFP_ATOMIC, because we are holding the bt_proto_rwlock, for
the following functions:
- bnep_sock_create
- cmtp_sock_create
- hci_sock_create
- hidp_sock_create
- l2cap_sock_create
- rfcomm_sock_create
- sco_sock_create

Signed-off-by: Frederik Deweerdt <frederik.deweerdt@gmail.com>
Cc: Masatake YAMATO <jet@gyve.org>
Cc: Marcel Holtmann <marcel@holtmann.org>
Signed-off-by: Andrew Morton <akpm@osdl.org>
---

 net/bluetooth/bnep/sock.c   |    2 +-
 net/bluetooth/cmtp/sock.c   |    2 +-
 net/bluetooth/hci_sock.c    |    2 +-
 net/bluetooth/hidp/sock.c   |    2 +-
 net/bluetooth/l2cap.c       |    2 +-
 net/bluetooth/rfcomm/sock.c |    2 +-
 net/bluetooth/sco.c         |    2 +-
 7 files changed, 7 insertions(+), 7 deletions(-)

diff -puN net/bluetooth/bnep/sock.c~bluetooth-use-gfp_atomic-in-_sock_creates-sk_alloc net/bluetooth/bnep/sock.c
--- a/net/bluetooth/bnep/sock.c~bluetooth-use-gfp_atomic-in-_sock_creates-sk_alloc
+++ a/net/bluetooth/bnep/sock.c
@@ -181,7 +181,7 @@ static int bnep_sock_create(struct socke
 	if (sock->type != SOCK_RAW)
 		return -ESOCKTNOSUPPORT;
 
-	sk = sk_alloc(PF_BLUETOOTH, GFP_KERNEL, &bnep_proto, 1);
+	sk = sk_alloc(PF_BLUETOOTH, GFP_ATOMIC, &bnep_proto, 1);
 	if (!sk)
 		return -ENOMEM;
 
diff -puN net/bluetooth/cmtp/sock.c~bluetooth-use-gfp_atomic-in-_sock_creates-sk_alloc net/bluetooth/cmtp/sock.c
--- a/net/bluetooth/cmtp/sock.c~bluetooth-use-gfp_atomic-in-_sock_creates-sk_alloc
+++ a/net/bluetooth/cmtp/sock.c
@@ -172,7 +172,7 @@ static int cmtp_sock_create(struct socke
 	if (sock->type != SOCK_RAW)
 		return -ESOCKTNOSUPPORT;
 
-	sk = sk_alloc(PF_BLUETOOTH, GFP_KERNEL, &cmtp_proto, 1);
+	sk = sk_alloc(PF_BLUETOOTH, GFP_ATOMIC, &cmtp_proto, 1);
 	if (!sk)
 		return -ENOMEM;
 
diff -puN net/bluetooth/hci_sock.c~bluetooth-use-gfp_atomic-in-_sock_creates-sk_alloc net/bluetooth/hci_sock.c
--- a/net/bluetooth/hci_sock.c~bluetooth-use-gfp_atomic-in-_sock_creates-sk_alloc
+++ a/net/bluetooth/hci_sock.c
@@ -618,7 +618,7 @@ static int hci_sock_create(struct socket
 
 	sock->ops = &hci_sock_ops;
 
-	sk = sk_alloc(PF_BLUETOOTH, GFP_KERNEL, &hci_sk_proto, 1);
+	sk = sk_alloc(PF_BLUETOOTH, GFP_ATOMIC, &hci_sk_proto, 1);
 	if (!sk)
 		return -ENOMEM;
 
diff -puN net/bluetooth/hidp/sock.c~bluetooth-use-gfp_atomic-in-_sock_creates-sk_alloc net/bluetooth/hidp/sock.c
--- a/net/bluetooth/hidp/sock.c~bluetooth-use-gfp_atomic-in-_sock_creates-sk_alloc
+++ a/net/bluetooth/hidp/sock.c
@@ -178,7 +178,7 @@ static int hidp_sock_create(struct socke
 	if (sock->type != SOCK_RAW)
 		return -ESOCKTNOSUPPORT;
 
-	sk = sk_alloc(PF_BLUETOOTH, GFP_KERNEL, &hidp_proto, 1);
+	sk = sk_alloc(PF_BLUETOOTH, GFP_ATOMIC, &hidp_proto, 1);
 	if (!sk)
 		return -ENOMEM;
 
diff -puN net/bluetooth/l2cap.c~bluetooth-use-gfp_atomic-in-_sock_creates-sk_alloc net/bluetooth/l2cap.c
--- a/net/bluetooth/l2cap.c~bluetooth-use-gfp_atomic-in-_sock_creates-sk_alloc
+++ a/net/bluetooth/l2cap.c
@@ -559,7 +559,7 @@ static int l2cap_sock_create(struct sock
 
 	sock->ops = &l2cap_sock_ops;
 
-	sk = l2cap_sock_alloc(sock, protocol, GFP_KERNEL);
+	sk = l2cap_sock_alloc(sock, protocol, GFP_ATOMIC);
 	if (!sk)
 		return -ENOMEM;
 
diff -puN net/bluetooth/rfcomm/sock.c~bluetooth-use-gfp_atomic-in-_sock_creates-sk_alloc net/bluetooth/rfcomm/sock.c
--- a/net/bluetooth/rfcomm/sock.c~bluetooth-use-gfp_atomic-in-_sock_creates-sk_alloc
+++ a/net/bluetooth/rfcomm/sock.c
@@ -336,7 +336,7 @@ static int rfcomm_sock_create(struct soc
 
 	sock->ops = &rfcomm_sock_ops;
 
-	if (!(sk = rfcomm_sock_alloc(sock, protocol, GFP_KERNEL)))
+	if (!(sk = rfcomm_sock_alloc(sock, protocol, GFP_ATOMIC)))
 		return -ENOMEM;
 
 	rfcomm_sock_init(sk, NULL);
diff -puN net/bluetooth/sco.c~bluetooth-use-gfp_atomic-in-_sock_creates-sk_alloc net/bluetooth/sco.c
--- a/net/bluetooth/sco.c~bluetooth-use-gfp_atomic-in-_sock_creates-sk_alloc
+++ a/net/bluetooth/sco.c
@@ -452,7 +452,7 @@ static int sco_sock_create(struct socket
 
 	sock->ops = &sco_sock_ops;
 
-	if (!(sk = sco_sock_alloc(sock, protocol, GFP_KERNEL)))
+	if (!(sk = sco_sock_alloc(sock, protocol, GFP_ATOMIC)))
 		return -ENOMEM;
 
 	sco_sock_init(sk, NULL);
_
