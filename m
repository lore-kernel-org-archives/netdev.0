From: Cyrill Gorcunov <gorcunov@gmail.com>
Subject: [PATCH] net: ip, diag -- Adjust raw_abort to use unlocked
 __udp_disconnect
Date: Tue, 1 Nov 2016 23:05:00 +0300
Message-ID: <20161101200500.GA1852@uranus.lan>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, dsa@cumulusnetworks.com,
        jhs@mojatatu.com, linux-kernel@vger.kernel.org,
        kuznet@ms2.inr.ac.ru, jmorris@namei.org, yoshfuji@linux-ipv6.org,
        kaber@trash.net, avagin@openvz.org, stephen@networkplumber.org
To: netdev@vger.kernel.org, eric.dumazet@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

While being preparing patches for killing raw sockets via
diag netlink interface I noticed that my runs are stuck:

 | [root@pcs7 ~]# cat /proc/`pidof ss`/stack
 | [<ffffffff816d1a76>] __lock_sock+0x80/0xc4
 | [<ffffffff816d206a>] lock_sock_nested+0x47/0x95
 | [<ffffffff8179ded6>] udp_disconnect+0x19/0x33
 | [<ffffffff8179b517>] raw_abort+0x33/0x42
 | [<ffffffff81702322>] sock_diag_destroy+0x4d/0x52

which has not been the case before. I narrowed it down to the commit

 | commit 286c72deabaa240b7eebbd99496ed3324d69f3c0
 | Author: Eric Dumazet <edumazet@google.com>
 | Date:   Thu Oct 20 09:39:40 2016 -0700
 | 
 |     udp: must lock the socket in udp_disconnect()

where we start locking the socket for different reason.

So the raw_abort escaped the renaming and we have to
fix this typo using __udp_disconnect instead.

CC: David S. Miller <davem@davemloft.net>
CC: Eric Dumazet <eric.dumazet@gmail.com>
CC: David Ahern <dsa@cumulusnetworks.com>
CC: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
CC: James Morris <jmorris@namei.org>
CC: Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>
CC: Patrick McHardy <kaber@trash.net>
CC: Andrey Vagin <avagin@openvz.org>
CC: Stephen Hemminger <stephen@networkplumber.org>
Signed-off-by: Cyrill Gorcunov <gorcunov@openvz.org>
---

On top of net-next tree 22ca904ad70afc831d8503e80be1b6558a978759

 net/ipv4/raw.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

Index: linux-ml.git/net/ipv4/raw.c
===================================================================
--- linux-ml.git.orig/net/ipv4/raw.c
+++ linux-ml.git/net/ipv4/raw.c
@@ -920,7 +920,7 @@ int raw_abort(struct sock *sk, int err)
 
 	sk->sk_err = err;
 	sk->sk_error_report(sk);
-	udp_disconnect(sk, 0);
+	__udp_disconnect(sk, 0);
 
 	release_sock(sk);
 
