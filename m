From: Serge Hallyn <serge@hallyn.com>
Subject: [PATCH 08/14] af_netlink.c: make netlink_capable userns-aware
Date: Tue, 26 Jul 2011 18:58:31 +0000
Message-ID: <1311706717-7398-9-git-send-email-serge@hallyn.com>
References: <1311706717-7398-1-git-send-email-serge@hallyn.com>
Cc: dhowells@redhat.com, ebiederm@xmission.com,
	containers@lists.linux-foundation.org, netdev@vger.kernel.org,
	akpm@osdl.org, "Serge E. Hallyn" <serge.hallyn@canonical.com>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1311706717-7398-1-git-send-email-serge@hallyn.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Serge E. Hallyn <serge.hallyn@canonical.com>

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
1.7.4.1
