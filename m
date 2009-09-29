From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: WARNING: at net/ipv4/af_inet.c:154 inet_sock_destruct
Date: Tue, 29 Sep 2009 11:18:45 +0200
Message-ID: <4AC1D0F5.4050709@gmail.com>
References: <38b2ab8a0909290109m3f82c161j4fb0f1266152877e@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Linux Netdev List <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>
To: Francis Moreau <francis.moro@gmail.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1753720AbZI2JSq@vger.kernel.org>
In-Reply-To: <38b2ab8a0909290109m3f82c161j4fb0f1266152877e@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=46rancis Moreau a =E9crit :
> Hello,
>=20
> I got this kernel warning when stopping nfsd:
>=20
> [260104.553720] WARNING: at net/ipv4/af_inet.c:154
> inet_sock_destruct+0x164/0x182()
> [260104.553722] Hardware name: P5K-VM
> [260104.553724] Modules linked in: jfs loop nfsd lockd nfs_acl
> auth_rpcgss exportfs sunrpc [last unloaded: microcode]
> [260104.553736] Pid: 858, comm: nfsd Tainted: G   M       2.6.31 #13
> [260104.553738] Call Trace:
> [260104.553743]  [<ffffffff813ed53a>] ? inet_sock_destruct+0x164/0x18=
2
> [260104.553748]  [<ffffffff81044471>] warn_slowpath_common+0x7c/0xa9
> [260104.553751]  [<ffffffff810444b2>] warn_slowpath_null+0x14/0x16
> [260104.553754]  [<ffffffff813ed53a>] inet_sock_destruct+0x164/0x182
> [260104.553759]  [<ffffffff8138e1c0>] __sk_free+0x23/0xe7
> [260104.553762]  [<ffffffff8138e2fd>] sk_free+0x1f/0x21
> [260104.553765]  [<ffffffff8138e3c7>] sk_common_release+0xc8/0xcd
> [260104.553769]  [<ffffffff813e4459>] udp_lib_close+0xe/0x10
> [260104.553772]  [<ffffffff813ecfe2>] inet_release+0x55/0x5c
> [260104.553775]  [<ffffffff8138b746>] sock_release+0x1f/0x71
> [260104.553778]  [<ffffffff8138b7bf>] sock_close+0x27/0x2b
> [260104.553782]  [<ffffffff810d0641>] __fput+0xfb/0x1c0
> [260104.553787]  [<ffffffff8104a197>] ? local_bh_disable+0x12/0x14
> [260104.553790]  [<ffffffff810d0723>] fput+0x1d/0x1f
> [260104.553810]  [<ffffffffa0014035>] svc_sock_free+0x40/0x56 [sunrpc=
]
> [260104.553827]  [<ffffffffa001dea0>] svc_xprt_free+0x43/0x53 [sunrpc=
]
> [260104.553843]  [<ffffffffa001de5d>] ? svc_xprt_free+0x0/0x53 [sunrp=
c]
> [260104.553847]  [<ffffffff811b4641>] kref_put+0x43/0x4f
> [260104.553863]  [<ffffffffa001d224>] svc_close_xprt+0x55/0x5e [sunrp=
c]
> [260104.553879]  [<ffffffffa001d27d>] svc_close_all+0x50/0x69 [sunrpc=
]
> [260104.553894]  [<ffffffffa0012922>] svc_destroy+0x9e/0x142 [sunrpc]
> [260104.553910]  [<ffffffffa0012a7f>] svc_exit_thread+0xb9/0xc2 [sunr=
pc]
> [260104.553922]  [<ffffffffa00707b1>] ? nfsd+0x0/0x151 [nfsd]
> [260104.553932]  [<ffffffffa00708e8>] nfsd+0x137/0x151 [nfsd]
> [260104.553936]  [<ffffffff8105ad28>] kthread+0x94/0x9c
> [260104.553941]  [<ffffffff8100c1fa>] child_rip+0xa/0x20
> [260104.553944]  [<ffffffff81047b00>] ? do_exit+0x5d7/0x691
> [260104.553948]  [<ffffffff81039cf8>] ? finish_task_switch+0x6a/0xc7
> [260104.553953]  [<ffffffff8100bb6d>] ? restore_args+0x0/0x30
> [260104.553956]  [<ffffffff8105ac94>] ? kthread+0x0/0x9c
> [260104.553959]  [<ffffffff8100c1f0>] ? child_rip+0x0/0x20
>=20
> It happens on 2.6.31 and older kernels as well though I don't remembe=
r
> when it really started.

Could you please try following patch ?

Thanks

[PATCH] net: Fix sock_wfree() race

Commit 2b85a34e911bf483c27cfdd124aeb1605145dc80
(net: No more expensive sock_hold()/sock_put() on each tx)
opens a window in sock_wfree() where another cpu
might free the socket we are working on.

A fix is to call sk->sk_write_space(sk) while still
holding a reference on sk.


Reported-by: Jike Song <albcamus@gmail.com>
Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 net/core/sock.c |   19 ++++++++++++-------
 1 files changed, 12 insertions(+), 7 deletions(-)

diff --git a/net/core/sock.c b/net/core/sock.c
index 30d5446..e1f034e 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -1228,17 +1228,22 @@ void __init sk_init(void)
 void sock_wfree(struct sk_buff *skb)
 {
 	struct sock *sk =3D skb->sk;
-	int res;
+	unsigned int len =3D skb->truesize;
=20
-	/* In case it might be waiting for more memory. */
-	res =3D atomic_sub_return(skb->truesize, &sk->sk_wmem_alloc);
-	if (!sock_flag(sk, SOCK_USE_WRITE_QUEUE))
+	if (!sock_flag(sk, SOCK_USE_WRITE_QUEUE)) {
+		/*
+		 * Keep a reference on sk_wmem_alloc, this will be released
+		 * after sk_write_space() call
+		 */
+		atomic_sub(len - 1, &sk->sk_wmem_alloc);
 		sk->sk_write_space(sk);
+		len =3D 1;
+	}
 	/*
-	 * if sk_wmem_alloc reached 0, we are last user and should
-	 * free this sock, as sk_free() call could not do it.
+	 * if sk_wmem_alloc reaches 0, we must finish what sk_free()
+	 * could not do because of in-flight packets
 	 */
-	if (res =3D=3D 0)
+	if (atomic_sub_and_test(len, &sk->sk_wmem_alloc))
 		__sk_free(sk);
 }
 EXPORT_SYMBOL(sock_wfree);
