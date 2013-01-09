From: Tom Parkin <tparkin@katalix.com>
Subject: [PATCH 2/4] l2tp: prevent tunnel creation on netns mismatch
Date: Wed,  9 Jan 2013 18:36:21 +0000
Message-ID: <1357756583-22535-3-git-send-email-tparkin@katalix.com>
References: <1357756583-22535-1-git-send-email-tparkin@katalix.com>
Cc: Tom Parkin <tparkin@katalix.com>,
	James Chapman <jchapman@katalix.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from katalix.com ([82.103.140.233]:55329 "EHLO mail.katalix.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932134Ab3AISgn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 9 Jan 2013 13:36:43 -0500
In-Reply-To: <1357756583-22535-1-git-send-email-tparkin@katalix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

l2tp_tunnel_create is passed a pointer to the network namespace for the
tunnel, along with an optional file descriptor for the tunnel which may
be passed in from userspace via. netlink.

In the case where the file descriptor is defined, ensure that the namespace
associated with that socket matches the namespace explicitly passed to
l2tp_tunnel_create.

Signed-off-by: Tom Parkin <tparkin@katalix.com>
Signed-off-by: James Chapman <jchapman@katalix.com>
---
 net/l2tp/l2tp_core.c |   11 +++++++++--
 1 file changed, 9 insertions(+), 2 deletions(-)

diff --git a/net/l2tp/l2tp_core.c b/net/l2tp/l2tp_core.c
index 1a9f372..75b347b 100644
--- a/net/l2tp/l2tp_core.c
+++ b/net/l2tp/l2tp_core.c
@@ -1521,11 +1521,18 @@ int l2tp_tunnel_create(struct net *net, int fd, int version, u32 tunnel_id, u32
 		if (err < 0)
 			goto err;
 	} else {
-		err = -EBADF;
 		sock = sockfd_lookup(fd, &err);
 		if (!sock) {
-			pr_err("tunl %hu: sockfd_lookup(fd=%d) returned %d\n",
+			pr_err("tunl %u: sockfd_lookup(fd=%d) returned %d\n",
 			       tunnel_id, fd, err);
+			err = -EBADF;
+			goto err;
+		}
+
+		/* Reject namespace mismatches */
+		if (!net_eq(sock_net(sock->sk), net)) {
+			pr_err("tunl %u: netns mismatch\n", tunnel_id);
+			err = -EINVAL;
 			goto err;
 		}
 	}
-- 
1.7.9.5
