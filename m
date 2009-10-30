From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: WARNING: at net/ipv4/af_inet.c:154 inet_sock_destruct
Date: Fri, 30 Oct 2009 16:03:53 +0100
Message-ID: <4AEB0059.1050400@gmail.com>
References: <38b2ab8a0909290109m3f82c161j4fb0f1266152877e@mail.gmail.com>	 <4AC1D0F5.4050709@gmail.com> <38b2ab8a0910300144i7a3c190fi9aa3d079c9cdb754@mail.gmail.com> <4AEACD88.8080108@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Linux Netdev List <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>
To: Francis Moreau <francis.moro@gmail.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S932348AbZJ3PDy@vger.kernel.org>
In-Reply-To: <4AEACD88.8080108@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Eric Dumazet a =E9crit :
> Francis Moreau a =E9crit :
>> Hello Eric,
>>
>> It seems I still have a related bug, please have a look to the follo=
wing oops.
>>
>> This happened on a 2.6.32-rc5 where your patch is included.
>>
>> [107304.558821] nfsd: last server has exited, flushing export cache
>> [107304.558848] ------------[ cut here ]------------
>> [107304.558858] WARNING: at net/ipv4/af_inet.c:153
>> inet_sock_destruct+0x161/0x17c()
>> [107304.558862] Hardware name: P5K-VM
>> [107304.558865] Modules linked in: kvm_intel kvm jfs loop nfsd lockd
>> nfs_acl auth_rpcgss exportfs sunrpc [last unloaded: microcode]
>> [107304.558889] Pid: 8198, comm: nfsd Tainted: G   M       2.6.32-rc=
5 #25
>> [107304.558892] Call Trace:
>> [107304.558899]  [<ffffffff81429f19>] ? inet_sock_destruct+0x161/0x1=
7c
>> [107304.558907]  [<ffffffff810487e9>] warn_slowpath_common+0x7c/0xa9
>> [107304.558914]  [<ffffffff8104882a>] warn_slowpath_null+0x14/0x16
>> [107304.558920]  [<ffffffff81429f19>] inet_sock_destruct+0x161/0x17c
>> [107304.558927]  [<ffffffff813c8741>] __sk_free+0x23/0xe7
>> [107304.558933]  [<ffffffff813c8881>] sk_free+0x1f/0x21
>> [107304.558939]  [<ffffffff813c894b>] sk_common_release+0xc8/0xcd
>> [107304.558944]  [<ffffffff81420b59>] udp_lib_close+0xe/0x10
>> [107304.558951]  [<ffffffff814299bf>] inet_release+0x55/0x5c
>> [107304.558957]  [<ffffffff813c5aa9>] sock_release+0x1f/0x71
>> [107304.558962]  [<ffffffff813c5b22>] sock_close+0x27/0x2b
>> [107304.558968]  [<ffffffff810eb60f>] __fput+0xfb/0x1c0
>> [107304.558973]  [<ffffffff810eb6f1>] fput+0x1d/0x1f
>> [107304.558995]  [<ffffffffa0013e23>] svc_sock_free+0x40/0x56 [sunrp=
c]
>> [107304.559018]  [<ffffffffa001f392>] svc_xprt_free+0x43/0x53 [sunrp=
c]
>> [107304.559038]  [<ffffffffa001f34f>] ? svc_xprt_free+0x0/0x53 [sunr=
pc]
>> [107304.559048]  [<ffffffff811d9275>] kref_put+0x43/0x4f
>> [107304.559069]  [<ffffffffa001e67a>] svc_close_xprt+0x55/0x5e [sunr=
pc]
>> [107304.559088]  [<ffffffffa001e6d3>] svc_close_all+0x50/0x69 [sunrp=
c]
>> [107304.559107]  [<ffffffffa0012a2b>] svc_destroy+0x9e/0x142 [sunrpc=
]
>> [107304.559126]  [<ffffffffa0012b88>] svc_exit_thread+0xb9/0xc2 [sun=
rpc]
>> [107304.559138]  [<ffffffffa008981b>] ? nfsd+0x0/0x13f [nfsd]
>> [107304.559149]  [<ffffffffa0089940>] nfsd+0x125/0x13f [nfsd]
>> [107304.559157]  [<ffffffff810685e3>] kthread+0x82/0x8a
>> [107304.559164]  [<ffffffff8100c13a>] child_rip+0xa/0x20
>> [107304.559172]  [<ffffffff8100baad>] ? restore_args+0x0/0x30
>> [107304.559179]  [<ffffffff81068561>] ? kthread+0x0/0x8a
>> [107304.559185]  [<ffffffff8100c130>] ? child_rip+0x0/0x20
>> [107304.559191] ---[ end trace c107131f4762168c ]---
>> [107304.927931] NFSD: Using /var/lib/nfs/v4recovery as the NFSv4 sta=
te
>> recovery directory
>> [107304.932765] NFSD: starting 90-second grace period
>>
>=20
> This oops occurring again and again with SUNRPC finally gave me the r=
ight pointer.
>=20
> David, we added two years ago memory accounting to UDP, and this chan=
ged
> requirements about calling skb_free_datagram() in the right context.
>=20
> I wish we had an ASSERT_SOCK_LOCKED() debugging facility :(
>=20
> Francis, would you please test following patch ?

Here is the updated patch (against linux-2.6) , in case other people ar=
e interested to test it.

[PATCH take2] net: fix sk_forward_alloc corruption

On UDP sockets, we must call skb_free_datagram() with socket locked,
or risk sk_forward_alloc corruption. This requirement is not respected
in SUNRPC.

Add a convenient helper, skb_free_datagram_locked() and use it in SUNRP=
C

Reported-by: Francis Moreau <francis.moro@gmail.com>
Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 include/linux/skbuff.h |    2 ++
 net/core/datagram.c    |   10 +++++++++-
 net/ipv4/udp.c         |    4 +---
 net/ipv6/udp.c         |    4 +---
 net/sunrpc/svcsock.c   |   10 +++++-----
 5 files changed, 18 insertions(+), 12 deletions(-)

diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index df7b23a..266878f 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -1757,6 +1757,8 @@ extern int	       skb_copy_datagram_const_iovec(c=
onst struct sk_buff *from,
 						     int to_offset,
 						     int size);
 extern void	       skb_free_datagram(struct sock *sk, struct sk_buff *=
skb);
+extern void	       skb_free_datagram_locked(struct sock *sk,
+						struct sk_buff *skb);
 extern int	       skb_kill_datagram(struct sock *sk, struct sk_buff *s=
kb,
 					 unsigned int flags);
 extern __wsum	       skb_checksum(const struct sk_buff *skb, int offse=
t,
diff --git a/net/core/datagram.c b/net/core/datagram.c
index 1c6cf3a..4ade301 100644
--- a/net/core/datagram.c
+++ b/net/core/datagram.c
@@ -224,6 +224,15 @@ void skb_free_datagram(struct sock *sk, struct sk_=
buff *skb)
 	consume_skb(skb);
 	sk_mem_reclaim_partial(sk);
 }
+EXPORT_SYMBOL(skb_free_datagram);
+
+void skb_free_datagram_locked(struct sock *sk, struct sk_buff *skb)
+{
+	lock_sock(sk);
+	skb_free_datagram(sk, skb);
+	release_sock(sk);
+}
+EXPORT_SYMBOL(skb_free_datagram_locked);
=20
 /**
  *	skb_kill_datagram - Free a datagram skbuff forcibly
@@ -752,5 +761,4 @@ unsigned int datagram_poll(struct file *file, struc=
t socket *sock,
 EXPORT_SYMBOL(datagram_poll);
 EXPORT_SYMBOL(skb_copy_and_csum_datagram_iovec);
 EXPORT_SYMBOL(skb_copy_datagram_iovec);
-EXPORT_SYMBOL(skb_free_datagram);
 EXPORT_SYMBOL(skb_recv_datagram);
diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index d0d436d..0fa9f70 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -999,9 +999,7 @@ try_again:
 		err =3D ulen;
=20
 out_free:
-	lock_sock(sk);
-	skb_free_datagram(sk, skb);
-	release_sock(sk);
+	skb_free_datagram_locked(sk, skb);
 out:
 	return err;
=20
diff --git a/net/ipv6/udp.c b/net/ipv6/udp.c
index 3a60f12..cf538ed 100644
--- a/net/ipv6/udp.c
+++ b/net/ipv6/udp.c
@@ -288,9 +288,7 @@ try_again:
 		err =3D ulen;
=20
 out_free:
-	lock_sock(sk);
-	skb_free_datagram(sk, skb);
-	release_sock(sk);
+	skb_free_datagram_locked(sk, skb);
 out:
 	return err;
=20
diff --git a/net/sunrpc/svcsock.c b/net/sunrpc/svcsock.c
index ccc5e83..1c246a4 100644
--- a/net/sunrpc/svcsock.c
+++ b/net/sunrpc/svcsock.c
@@ -111,7 +111,7 @@ static void svc_release_skb(struct svc_rqst *rqstp)
 		rqstp->rq_xprt_ctxt =3D NULL;
=20
 		dprintk("svc: service %p, releasing skb %p\n", rqstp, skb);
-		skb_free_datagram(svsk->sk_sk, skb);
+		skb_free_datagram_locked(svsk->sk_sk, skb);
 	}
 }
=20
@@ -578,7 +578,7 @@ static int svc_udp_recvfrom(struct svc_rqst *rqstp)
 				"svc: received unknown control message %d/%d; "
 				"dropping RPC reply datagram\n",
 					cmh->cmsg_level, cmh->cmsg_type);
-		skb_free_datagram(svsk->sk_sk, skb);
+		skb_free_datagram_locked(svsk->sk_sk, skb);
 		return 0;
 	}
=20
@@ -588,18 +588,18 @@ static int svc_udp_recvfrom(struct svc_rqst *rqst=
p)
 		if (csum_partial_copy_to_xdr(&rqstp->rq_arg, skb)) {
 			local_bh_enable();
 			/* checksum error */
-			skb_free_datagram(svsk->sk_sk, skb);
+			skb_free_datagram_locked(svsk->sk_sk, skb);
 			return 0;
 		}
 		local_bh_enable();
-		skb_free_datagram(svsk->sk_sk, skb);
+		skb_free_datagram_locked(svsk->sk_sk, skb);
 	} else {
 		/* we can use it in-place */
 		rqstp->rq_arg.head[0].iov_base =3D skb->data +
 			sizeof(struct udphdr);
 		rqstp->rq_arg.head[0].iov_len =3D len;
 		if (skb_checksum_complete(skb)) {
-			skb_free_datagram(svsk->sk_sk, skb);
+			skb_free_datagram_locked(svsk->sk_sk, skb);
 			return 0;
 		}
 		rqstp->rq_xprt_ctxt =3D skb;
