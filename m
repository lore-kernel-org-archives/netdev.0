From: fanhui <fanhui00@gmail.com>
Subject: [PATCH 1/1] ipv4: fix NULL pointer dereference in __inet_put_port()
Date: Tue, 29 Mar 2016 14:45:53 +0800
Message-ID: <1459233953-4745-1-git-send-email-fanhui00@gmail.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	fanhui <fanhui00@gmail.com>
To: "David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

There may be race condition when accessing inet_csk(sk)->icsk_bind_hash,
which leads to a crash like this:

Unable to handle kernel NULL pointer dereference at virtual
address 00000010
......
[<ffffffc000929140>] inet_put_port+0x80/0xb8
[<ffffffc00092c4bc>] tcp_set_state+0xc4/0x110
[<ffffffc00092ce68>] tcp_done+0x60/0xb8
[<ffffffc000930718>] tcp_nuke_addr+0x22c/0x2a0
[<ffffffc000950558>] devinet_ioctl+0x294/0x680
[<ffffffc000951e68>] inet_ioctl+0xd4/0x100
[<ffffffc00089fd04>] sock_do_ioctl+0x40/0x70
[<ffffffc0008a0238>] sock_ioctl+0x288/0x2a8
[<ffffffc000193358>] do_vfs_ioctl+0x4b4/0x588
[<ffffffc000193494>] SyS_ioctl+0x68/0x94
......

Signed-off-by: fanhui <fanhui00@gmail.com>
---
 net/ipv4/inet_hashtables.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/net/ipv4/inet_hashtables.c b/net/ipv4/inet_hashtables.c
index bc68ece..742c618 100644
--- a/net/ipv4/inet_hashtables.c
+++ b/net/ipv4/inet_hashtables.c
@@ -112,11 +112,14 @@ static void __inet_put_port(struct sock *sk)
 
 	spin_lock(&head->lock);
 	tb = inet_csk(sk)->icsk_bind_hash;
+	if (!tb)
+		goto out;
 	__sk_del_bind_node(sk);
 	tb->num_owners--;
 	inet_csk(sk)->icsk_bind_hash = NULL;
 	inet_sk(sk)->inet_num = 0;
 	inet_bind_bucket_destroy(hashinfo->bind_bucket_cachep, tb);
+out:
 	spin_unlock(&head->lock);
 }
 
-- 
1.9.1
