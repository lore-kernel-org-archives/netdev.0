From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net] ipv4: fix memory leaks in ip_cmsg_send() callers
Date: Thu, 04 Feb 2016 06:23:28 -0800
Message-ID: <1454595808.7627.296.camel@edumazet-glaptop2.roam.corp.google.com>
References: <CACT4Y+YMUc8j4_-oJfi0XmQebhaTZa2NTipSFY_ra38V-TAyXQ@mail.gmail.com>
	 <1454594653.7627.290.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: Dmitry Vyukov <dvyukov@google.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f180.google.com ([209.85.192.180]:36361 "EHLO
	mail-pf0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756746AbcBDOXa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Feb 2016 09:23:30 -0500
Received: by mail-pf0-f180.google.com with SMTP id n128so46259941pfn.3
        for <netdev@vger.kernel.org>; Thu, 04 Feb 2016 06:23:29 -0800 (PST)
In-Reply-To: <1454594653.7627.290.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

Dmitry reported memory leaks of IP options allocated in
ip_cmsg_send() when/if this function returns an error.

Callers are responsible for the freeing.

Many thanks to Dmitry for the report and diagnostic.

Reported-by: Dmitry Vyukov <dvyukov@google.com>
Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 net/ipv4/ip_sockglue.c |    2 ++
 net/ipv4/ping.c        |    4 +++-
 net/ipv4/raw.c         |    4 +++-
 net/ipv4/udp.c         |    4 +++-
 4 files changed, 11 insertions(+), 3 deletions(-)

diff --git a/net/ipv4/ip_sockglue.c b/net/ipv4/ip_sockglue.c
index 5f73a7c03e27..a50124260f5a 100644
--- a/net/ipv4/ip_sockglue.c
+++ b/net/ipv4/ip_sockglue.c
@@ -249,6 +249,8 @@ int ip_cmsg_send(struct net *net, struct msghdr *msg, struct ipcm_cookie *ipc,
 		switch (cmsg->cmsg_type) {
 		case IP_RETOPTS:
 			err = cmsg->cmsg_len - CMSG_ALIGN(sizeof(struct cmsghdr));
+
+			/* Our caller is responsible for freeing ipc->opt */
 			err = ip_options_get(net, &ipc->opt, CMSG_DATA(cmsg),
 					     err < 40 ? err : 40);
 			if (err)
diff --git a/net/ipv4/ping.c b/net/ipv4/ping.c
index c117b21b937d..ec74b1a34315 100644
--- a/net/ipv4/ping.c
+++ b/net/ipv4/ping.c
@@ -746,8 +746,10 @@ static int ping_v4_sendmsg(struct sock *sk, struct msghdr *msg, size_t len)
 
 	if (msg->msg_controllen) {
 		err = ip_cmsg_send(sock_net(sk), msg, &ipc, false);
-		if (err)
+		if (unlikely(err)) {
+			kfree(ipc.opt);
 			return err;
+		}
 		if (ipc.opt)
 			free = 1;
 	}
diff --git a/net/ipv4/raw.c b/net/ipv4/raw.c
index bc35f1842512..bba4f6f379a9 100644
--- a/net/ipv4/raw.c
+++ b/net/ipv4/raw.c
@@ -547,8 +547,10 @@ static int raw_sendmsg(struct sock *sk, struct msghdr *msg, size_t len)
 
 	if (msg->msg_controllen) {
 		err = ip_cmsg_send(net, msg, &ipc, false);
-		if (err)
+		if (unlikely(err)) {
+			kfree(ipc.opt);
 			goto out;
+		}
 		if (ipc.opt)
 			free = 1;
 	}
diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index be0b21852b13..8182363bff5e 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -1048,8 +1048,10 @@ int udp_sendmsg(struct sock *sk, struct msghdr *msg, size_t len)
 	if (msg->msg_controllen) {
 		err = ip_cmsg_send(sock_net(sk), msg, &ipc,
 				   sk->sk_family == AF_INET6);
-		if (err)
+		if (unlikely(err)) {
+			kfree(ipc.opt);
 			return err;
+		}
 		if (ipc.opt)
 			free = 1;
 		connected = 0;
