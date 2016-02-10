From: Craig Gallek <kraigatgoog@gmail.com>
Subject: [PATCH net-next v3 5/7] soreuseport: Prep for fast reuseport TCP socket selection
Date: Tue,  9 Feb 2016 19:19:00 -0500
Message-ID: <1455063542-18227-6-git-send-email-kraigatgoog@gmail.com>
References: <1455063542-18227-1-git-send-email-kraigatgoog@gmail.com>
To: netdev@vger.kernel.org, David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f46.google.com ([209.85.192.46]:34716 "EHLO
	mail-qg0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754906AbcBJATQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Feb 2016 19:19:16 -0500
Received: by mail-qg0-f46.google.com with SMTP id b67so3017004qgb.1
        for <netdev@vger.kernel.org>; Tue, 09 Feb 2016 16:19:15 -0800 (PST)
In-Reply-To: <1455063542-18227-1-git-send-email-kraigatgoog@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Craig Gallek <kraig@google.com>

Both of the lines in this patch probably should have been included
in the initial implementation of this code for generic socket
support, but weren't technically necessary since only UDP sockets
were supported.

First, the sk_reuseport_cb points to a structure which assumes
each socket in the group has this pointer assigned at the same
time it's added to the array in the structure.  The sk_clone_lock
function breaks this assumption.  Since a child socket shouldn't
implicitly be in a reuseport group, the simple fix is to clear
the field in the clone.

Second, the SO_ATTACH_REUSEPORT_xBPF socket options require that
SO_REUSEPORT also be set first.  For UDP sockets, this is easily
enforced at bind-time since that process both puts the socket in
the appropriate receive hlist and updates the reuseport structures.
Since these operations can happen at two different times for TCP
sockets (bind and listen) it must be explicitly checked to enforce
the use of SO_REUSEPORT with SO_ATTACH_REUSEPORT_xBPF in the
setsockopt call.

Signed-off-by: Craig Gallek <kraig@google.com>
---
 net/core/filter.c | 2 +-
 net/core/sock.c   | 1 +
 2 files changed, 2 insertions(+), 1 deletion(-)

diff --git a/net/core/filter.c b/net/core/filter.c
index 94d26201080d..2a6e9562f1ab 100644
--- a/net/core/filter.c
+++ b/net/core/filter.c
@@ -1181,7 +1181,7 @@ static int __reuseport_attach_prog(struct bpf_prog *prog, struct sock *sk)
 	if (bpf_prog_size(prog->len) > sysctl_optmem_max)
 		return -ENOMEM;
 
-	if (sk_unhashed(sk)) {
+	if (sk_unhashed(sk) && sk->sk_reuseport) {
 		err = reuseport_alloc(sk);
 		if (err)
 			return err;
diff --git a/net/core/sock.c b/net/core/sock.c
index 6c1c8bc93412..46dc8ad7d050 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -1531,6 +1531,7 @@ struct sock *sk_clone_lock(const struct sock *sk, const gfp_t priority)
 			newsk = NULL;
 			goto out;
 		}
+		RCU_INIT_POINTER(newsk->sk_reuseport_cb, NULL);
 
 		newsk->sk_err	   = 0;
 		newsk->sk_priority = 0;
-- 
2.7.0.rc3.207.g0ac5344
