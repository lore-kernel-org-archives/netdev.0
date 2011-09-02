From: Serge Hallyn <serge@hallyn.com>
Subject: [PATCH 08/15] af_netlink.c: make netlink_capable userns-aware
Date: Fri,  2 Sep 2011 19:56:33 +0000
Message-ID: <1314993400-6910-11-git-send-email-serge@hallyn.com>
References: <1314993400-6910-1-git-send-email-serge@hallyn.com>
Cc: "Serge E. Hallyn" <serge.hallyn@canonical.com>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: akpm@osdl.org, segooon@gmail.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, containers@lists.linux-foundation.org,
	dhowells@redhat.com, ebiederm@xmission.com, rdunlap@xenotime.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 50-56-35-84.static.cloud-ips.com ([50.56.35.84]:39520 "EHLO
	mail" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1755247Ab1IBTz7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 2 Sep 2011 15:55:59 -0400
In-Reply-To: <1314993400-6910-1-git-send-email-serge@hallyn.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Serge E. Hallyn" <serge.hallyn@canonical.com>

netlink_capable should check for permissions against the user
namespace owning the socket in question.

Changelog:
  Per Eric Dumazet advice, use sock_net(sk) instead of #ifdef.

Signed-off-by: Serge E. Hallyn <serge.hallyn@canonical.com>
Cc: Eric W. Biederman <ebiederm@xmission.com>
Cc: Eric Dumazet <eric.dumazet@gmail.com>
---
 net/netlink/af_netlink.c |    5 +++--
 1 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/net/netlink/af_netlink.c b/net/netlink/af_netlink.c
index 0a4db02..3cc0bbe 100644
--- a/net/netlink/af_netlink.c
+++ b/net/netlink/af_netlink.c
@@ -580,8 +580,9 @@ retry:
 
 static inline int netlink_capable(struct socket *sock, unsigned int flag)
 {
-	return (nl_table[sock->sk->sk_protocol].nl_nonroot & flag) ||
-	       capable(CAP_NET_ADMIN);
+	if (nl_table[sock->sk->sk_protocol].nl_nonroot & flag)
+		return 1;
+	return ns_capable(sock_net(sock->sk)->user_ns, CAP_NET_ADMIN);
 }
 
 static void
-- 
1.7.5.4
