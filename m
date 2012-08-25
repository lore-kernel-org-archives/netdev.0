From: Xi Wang <xi.wang@gmail.com>
Subject: [PATCH] af_unix: fix unix_nr_socks check in unix_create1()
Date: Sat, 25 Aug 2012 02:05:53 -0400
Message-ID: <1345874753-7214-1-git-send-email-xi.wang@gmail.com>
Cc: "David S. Miller" <davem@davemloft.net>,
	Xi Wang <xi.wang@gmail.com>, Eric Dumazet <edumazet@google.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vc0-f174.google.com ([209.85.220.174]:37291 "EHLO
	mail-vc0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750788Ab2HYGGQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 25 Aug 2012 02:06:16 -0400
Received: by vcbfk26 with SMTP id fk26so2929471vcb.19
        for <netdev@vger.kernel.org>; Fri, 24 Aug 2012 23:06:15 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch complements 518de9b3 ("fs: allow for more than 2^31 files").

get_max_files() returns files_stat.max_files, which can be set to any
value from user space via /proc/sys/fs/file-max.  A large file-max will
cause an integer overflow in the following check:

	if (atomic_long_read(&unix_nr_socks) > 2 * get_max_files())
		goto out;

The kernel will then fail to create a unix domain socket.

Rewrite the check using "/ 2" on the left-hand side.

Signed-off-by: Xi Wang <xi.wang@gmail.com>
Cc: Eric Dumazet <edumazet@google.com>
---
 net/unix/af_unix.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/unix/af_unix.c b/net/unix/af_unix.c
index c5ee4ff..99a8bc9 100644
--- a/net/unix/af_unix.c
+++ b/net/unix/af_unix.c
@@ -630,9 +630,9 @@ static struct sock *unix_create1(struct net *net, struct socket *sock)
 {
 	struct sock *sk = NULL;
 	struct unix_sock *u;
+	unsigned long nr_socks = atomic_long_inc_return(&unix_nr_socks);
 
-	atomic_long_inc(&unix_nr_socks);
-	if (atomic_long_read(&unix_nr_socks) > 2 * get_max_files())
+	if (nr_socks / 2 > get_max_files())
 		goto out;
 
 	sk = sk_alloc(net, PF_UNIX, GFP_KERNEL, &unix_proto);
-- 
1.7.9.5
