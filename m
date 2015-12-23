From: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
Subject: [PATCH net] sctp: use GFP_USER for user-controlled kmalloc
Date: Wed, 23 Dec 2015 16:28:40 -0200
Message-ID: <e03c1ba5fef1bc2572475d7796290ca8acb95794.1450895185.git.marcelo.leitner@gmail.com>
References: <CACT4Y+Ztb5cw2SGqxHiOBq9FgDs3J12Wk9iG0NaNvdunM_ex-w@mail.gmail.com>
Cc: linux-sctp@vger.kernel.org, Vlad Yasevich <vyasevich@gmail.com>,
	Neil Horman <nhorman@tuxdriver.com>,
	Dmitry Vyukov <dvyukov@google.com>,
	linux-kernel@vger.kernel.org, syzkaller@googlegroups.com,
	kcc@google.com, glider@google.com, sasha.levin@oracle.com,
	edumazet@google.com
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CACT4Y+Ztb5cw2SGqxHiOBq9FgDs3J12Wk9iG0NaNvdunM_ex-w@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Commit cacc06215271 ("sctp: use GFP_USER for user-controlled kmalloc")
missed two other spots.

For connectx, as it's more likely to be used by kernel users of the API,
it detects if GFP_USER should be used or not.

Fixes: cacc06215271 ("sctp: use GFP_USER for user-controlled kmalloc")
Reported-by: Dmitry Vyukov <dvyukov@google.com>
Signed-off-by: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
---
 net/sctp/socket.c | 9 ++++++---
 1 file changed, 6 insertions(+), 3 deletions(-)

diff --git a/net/sctp/socket.c b/net/sctp/socket.c
index 2a1e8ba2808cab3bb29d670f155bcef243f85922..400a14d744834c7a503b338bc68f5f8b5b5dae8e 100644
--- a/net/sctp/socket.c
+++ b/net/sctp/socket.c
@@ -1301,8 +1301,9 @@ static int __sctp_setsockopt_connectx(struct sock *sk,
 				      int addrs_size,
 				      sctp_assoc_t *assoc_id)
 {
-	int err = 0;
 	struct sockaddr *kaddrs;
+	gfp_t gfp = GFP_KERNEL;
+	int err = 0;
 
 	pr_debug("%s: sk:%p addrs:%p addrs_size:%d\n",
 		 __func__, sk, addrs, addrs_size);
@@ -1315,7 +1316,9 @@ static int __sctp_setsockopt_connectx(struct sock *sk,
 		return -EFAULT;
 
 	/* Alloc space for the address array in kernel memory.  */
-	kaddrs = kmalloc(addrs_size, GFP_KERNEL);
+	if (sk->sk_socket->file)
+		gfp = GFP_USER | __GFP_NOWARN;
+	kaddrs = kmalloc(addrs_size, gfp);
 	if (unlikely(!kaddrs))
 		return -ENOMEM;
 
@@ -5773,7 +5776,7 @@ static int sctp_getsockopt_assoc_ids(struct sock *sk, int len,
 
 	len = sizeof(struct sctp_assoc_ids) + sizeof(sctp_assoc_t) * num;
 
-	ids = kmalloc(len, GFP_KERNEL);
+	ids = kmalloc(len, GFP_USER | __GFP_NOWARN);
 	if (unlikely(!ids))
 		return -ENOMEM;
 
-- 
2.5.0
