From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH v2 net] dccp/tcp: do not inherit mc_list from parent
Date: Tue, 09 May 2017 06:29:19 -0700
Message-ID: <1494336559.7796.78.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1494332235.7796.70.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, Pray3r <pray3r.z@gmail.com>,
        Andrey Konovalov <andreyknvl@google.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f196.google.com ([209.85.192.196]:33967 "EHLO
        mail-pf0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752541AbdEIN3X (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 9 May 2017 09:29:23 -0400
Received: by mail-pf0-f196.google.com with SMTP id w69so47594pfk.1
        for <netdev@vger.kernel.org>; Tue, 09 May 2017 06:29:22 -0700 (PDT)
In-Reply-To: <1494332235.7796.70.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

syzkaller found a way to trigger double frees from ip_mc_drop_socket()

It turns out that leave a copy of parent mc_list at accept() time,
which is very bad.

Very similar to commit 8b485ce69876 ("tcp: do not inherit
fastopen_req from parent")

Initial report from Pray3r, completed by Andrey one.
Thanks a lot to them !

Signed-off-by: Eric Dumazet <edumazet@google.com>
Reported-by: Pray3r <pray3r.z@gmail.com>
Reported-by: Andrey Konovalov <andreyknvl@google.com>
Tested-by: Andrey Konovalov <andreyknvl@google.com>
---
v2: fix moved into inet_csk_clone_lock() to fix both DCCP and TCP

 net/ipv4/inet_connection_sock.c |    2 ++
 1 file changed, 2 insertions(+)

diff --git a/net/ipv4/inet_connection_sock.c b/net/ipv4/inet_connection_sock.c
index 5e313c1ac94fc88eca5fe3a0e9e46e551e955ff0..1054d330bf9df3189a21dbb08e27c0e6ad136775 100644
--- a/net/ipv4/inet_connection_sock.c
+++ b/net/ipv4/inet_connection_sock.c
@@ -794,6 +794,8 @@ struct sock *inet_csk_clone_lock(const struct sock *sk,
 		/* listeners have SOCK_RCU_FREE, not the children */
 		sock_reset_flag(newsk, SOCK_RCU_FREE);
 
+		inet_sk(newsk)->mc_list = NULL;
+
 		newsk->sk_mark = inet_rsk(req)->ir_mark;
 		atomic64_set(&newsk->sk_cookie,
 			     atomic64_read(&inet_rsk(req)->ir_cookie));
