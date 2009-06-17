From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH] atm: sk_wmem_alloc initial value is one
Date: Wed, 17 Jun 2009 13:31:30 +0200
Message-ID: <4A38D412.5000701@gmail.com>
References: <4A37A058.1030701@gmail.com>	<4A37AA0C.40507@gmail.com>	<alpine.LFD.2.01.0906161155400.3282@localhost.localdomain> <20090616.120829.182011393.davem@davemloft.net> <4A37F495.9030101@gmail.com> <4A37FC93.7070403@gmail.com> <4A389031.1060902@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:53132 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933126AbZFQLbg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Jun 2009 07:31:36 -0400
In-Reply-To: <4A389031.1060902@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet a =E9crit :
> David
>=20
> Please find the followup patch I promised yesterday.
>=20
> Some review still needed for net/atm, since this protocol
> sets sock_wmem_alloc initial value to 0

Here is last patch of this serie, for net/atm part.

Thank you

[PATCH] atm: sk_wmem_alloc initial value is one

commit 2b85a34e911bf483c27cfdd124aeb1605145dc80=20
(net: No more expensive sock_hold()/sock_put() on each tx)
changed initial sk_wmem_alloc value.

This broke net/atm since this protocol assumed a null
initial value. This patch makes necessary changes.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 net/atm/common.c |   12 ++++++------
 net/atm/ioctl.c  |    3 +--
 net/atm/proc.c   |    4 ++--
 net/atm/raw.c    |    2 +-
 4 files changed, 10 insertions(+), 11 deletions(-)
diff --git a/net/atm/common.c b/net/atm/common.c
index d34edbe..c1c9793 100644
--- a/net/atm/common.c
+++ b/net/atm/common.c
@@ -62,15 +62,15 @@ static struct sk_buff *alloc_tx(struct atm_vcc *vcc=
,unsigned int size)
 	struct sk_buff *skb;
 	struct sock *sk =3D sk_atm(vcc);
=20
-	if (atomic_read(&sk->sk_wmem_alloc) && !atm_may_send(vcc, size)) {
+	if (sk_wmem_alloc_get(sk) && !atm_may_send(vcc, size)) {
 		pr_debug("Sorry: wmem_alloc =3D %d, size =3D %d, sndbuf =3D %d\n",
-			atomic_read(&sk->sk_wmem_alloc), size,
+			sk_wmem_alloc_get(sk), size,
 			sk->sk_sndbuf);
 		return NULL;
 	}
-	while (!(skb =3D alloc_skb(size,GFP_KERNEL))) schedule();
-	pr_debug("AlTx %d +=3D %d\n", atomic_read(&sk->sk_wmem_alloc),
-		skb->truesize);
+	while (!(skb =3D alloc_skb(size, GFP_KERNEL)))
+		schedule();
+	pr_debug("AlTx %d +=3D %d\n", sk_wmem_alloc_get(sk), skb->truesize);
 	atomic_add(skb->truesize, &sk->sk_wmem_alloc);
 	return skb;
 }
@@ -145,7 +145,7 @@ int vcc_create(struct net *net, struct socket *sock=
, int protocol, int family)
 	memset(&vcc->local,0,sizeof(struct sockaddr_atmsvc));
 	memset(&vcc->remote,0,sizeof(struct sockaddr_atmsvc));
 	vcc->qos.txtp.max_sdu =3D 1 << 16; /* for meta VCs */
-	atomic_set(&sk->sk_wmem_alloc, 0);
+	atomic_set(&sk->sk_wmem_alloc, 1);
 	atomic_set(&sk->sk_rmem_alloc, 0);
 	vcc->push =3D NULL;
 	vcc->pop =3D NULL;
diff --git a/net/atm/ioctl.c b/net/atm/ioctl.c
index 76ed3c8..4da8892 100644
--- a/net/atm/ioctl.c
+++ b/net/atm/ioctl.c
@@ -63,8 +63,7 @@ static int do_vcc_ioctl(struct socket *sock, unsigned=
 int cmd, unsigned long arg
 				error =3D  -EINVAL;
 				goto done;
 			}
-			error =3D put_user(sk->sk_sndbuf -
-					 atomic_read(&sk->sk_wmem_alloc),
+			error =3D put_user(sk->sk_sndbuf - sk_wmem_alloc_get(sk),
 					 (int __user *) argp) ? -EFAULT : 0;
 			goto done;
 		case SIOCINQ:
diff --git a/net/atm/proc.c b/net/atm/proc.c
index e7b3b27..38de5ff 100644
--- a/net/atm/proc.c
+++ b/net/atm/proc.c
@@ -204,8 +204,8 @@ static void vcc_info(struct seq_file *seq, struct a=
tm_vcc *vcc)
 			seq_printf(seq, "%3d", sk->sk_family);
 	}
 	seq_printf(seq, " %04lx  %5d %7d/%7d %7d/%7d [%d]\n", vcc->flags, sk-=
>sk_err,
-		  atomic_read(&sk->sk_wmem_alloc), sk->sk_sndbuf,
-		  atomic_read(&sk->sk_rmem_alloc), sk->sk_rcvbuf,
+		  sk_wmem_alloc_get(sk), sk->sk_sndbuf,
+		  sk_rmem_alloc_get(sk), sk->sk_rcvbuf,
 		  atomic_read(&sk->sk_refcnt));
 }
=20
diff --git a/net/atm/raw.c b/net/atm/raw.c
index b0a2d8c..cbfcc71 100644
--- a/net/atm/raw.c
+++ b/net/atm/raw.c
@@ -33,7 +33,7 @@ static void atm_pop_raw(struct atm_vcc *vcc,struct sk=
_buff *skb)
 	struct sock *sk =3D sk_atm(vcc);
=20
 	pr_debug("APopR (%d) %d -=3D %d\n", vcc->vci,
-		atomic_read(&sk->sk_wmem_alloc), skb->truesize);
+		sk_wmem_alloc_get(sk), skb->truesize);
 	atomic_sub(skb->truesize, &sk->sk_wmem_alloc);
 	dev_kfree_skb_any(skb);
 	sk->sk_write_space(sk);
