From: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
Subject: [PATCH] sctp: use GFP_USER for user-controlled kmalloc
Date: Mon, 30 Nov 2015 14:32:54 -0200
Message-ID: <db23659cdf84bc80aff45e906cbfb67581e7a125.1448901154.git.marcelo.leitner@gmail.com>
References: <CACT4Y+a_V5WQZNEnYkuA3Xc5qCWmLV3oScNeNiATZm-wW5eg3Q@mail.gmail.comc>
Cc: linux-sctp@vger.kernel.org, Vlad Yasevich <vyasevich@gmail.com>,
	Neil Horman <nhorman@tuxdriver.com>, daniel@iogearbox.net,
	linux-kernel@vger.kernel.org, davem@davemloft.net,
	syzkaller@googlegroups.com, dvyukov@google.com, kcc@google.com,
	glider@google.com, sasha.levin@oracle.com, edumazet@google.com
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CACT4Y+a_V5WQZNEnYkuA3Xc5qCWmLV3oScNeNiATZm-wW5eg3Q@mail.gmail.comc>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Dmitry Vyukov reported that the user could trigger a kernel warning by
using a large len value for getsockopt SCTP_GET_LOCAL_ADDRS, as that
value directly affects the value used as a kmalloc() parameter.

This patch thus switches the allocation flags from all user-controllable
kmalloc size to GFP_USER to put some more restrictions on it and also
disables the warn, as they are not necessary.

Signed-off-by: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
Acked-by: Daniel Borkmann <daniel@iogearbox.net>
---
 net/sctp/socket.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/sctp/socket.c b/net/sctp/socket.c
index 897c01c029cab3d5805cc56b0964c70e06f4143a..676b3bb092e16848fd1c822e1c999af4a2ef198d 100644
--- a/net/sctp/socket.c
+++ b/net/sctp/socket.c
@@ -972,7 +972,7 @@ static int sctp_setsockopt_bindx(struct sock *sk,
 		return -EFAULT;
 
 	/* Alloc space for the address array in kernel memory.  */
-	kaddrs = kmalloc(addrs_size, GFP_KERNEL);
+	kaddrs = kmalloc(addrs_size, GFP_USER | __GFP_NOWARN);
 	if (unlikely(!kaddrs))
 		return -ENOMEM;
 
@@ -4928,7 +4928,7 @@ static int sctp_getsockopt_local_addrs(struct sock *sk, int len,
 	to = optval + offsetof(struct sctp_getaddrs, addrs);
 	space_left = len - offsetof(struct sctp_getaddrs, addrs);
 
-	addrs = kmalloc(space_left, GFP_KERNEL);
+	addrs = kmalloc(space_left, GFP_USER | __GFP_NOWARN);
 	if (!addrs)
 		return -ENOMEM;
 
-- 
2.5.0
