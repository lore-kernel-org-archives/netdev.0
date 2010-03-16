From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] netlink: convert DIY reader/writer to mutex and RCU
 (v2)
Date: Tue, 16 Mar 2010 16:00:35 +0100
Message-ID: <1268751635.3094.43.camel@edumazet-laptop>
References: <20100308133211.4f157e2d@nehalam>
	 <20100308140021.234a120a@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f211.google.com ([209.85.218.211]:52367 "EHLO
	mail-bw0-f211.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S966328Ab0CPPAl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Mar 2010 11:00:41 -0400
Received: by bwz3 with SMTP id 3so30257bwz.29
        for <netdev@vger.kernel.org>; Tue, 16 Mar 2010 08:00:40 -0700 (PDT)
In-Reply-To: <20100308140021.234a120a@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 08 mars 2010 =C3=A0 14:00 -0800, Stephen Hemminger a =C3=A9cri=
t :
> The netlink table locking was open coded version of reader/writer
> sleeping lock.  Change to using mutex and RCU which makes
> code clearer, shorter, and simpler.
>=20
> Could use sk_list nulls but then would have to have kmem_cache
> for netlink handles and that seems like unnecessary bloat.
>=20
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
>=20
> ---
> v1 -> v2 do RCU correctly...
>   * use spinlock not mutex (not safe to sleep in normal RCU)
>   * use _rcu variants of add/delete


>  	kfree(nlk->groups);
>  	nlk->groups =3D NULL;
> @@ -533,6 +477,8 @@ static int netlink_release(struct socket
>  	local_bh_disable();
>  	sock_prot_inuse_add(sock_net(sk), &netlink_proto, -1);
>  	local_bh_enable();
> +
> +	synchronize_rcu();
>  	sock_put(sk);
>  	return 0;

I am a bit scared by synchronize_rcu() proliferation. This can slow dow=
n
some workloads (some scripts invoking netlink commands, not using batch
mode)

We could change sk_prot_free() behavior and optionaly call a callback t=
o
free a socket (and the module_put()) after rcu grace period. As the
rcu_head is not inside struct sock, I could not find a generic way to
code this.

=46or TCP/UDP sockets this was considered not a viable alternative, but
for other sockets its certainly better than synchronize_rcu() ?

diff --git a/include/net/sock.h b/include/net/sock.h
index 092b055..3a2d598 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -693,6 +693,8 @@ struct proto {
 	int			(*backlog_rcv) (struct sock *sk,=20
 						struct sk_buff *skb);
=20
+	void			(*free_socket)(struct sock *sk);
+
 	/* Keeping track of sk's, looking them up, and port selection methods=
=2E */
 	void			(*hash)(struct sock *sk);
 	void			(*unhash)(struct sock *sk);
diff --git a/net/core/sock.c b/net/core/sock.c
index c5812bb..3060c9b 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -1027,18 +1027,20 @@ out_free:
=20
 static void sk_prot_free(struct proto *prot, struct sock *sk)
 {
-	struct kmem_cache *slab;
-	struct module *owner;
+	security_sk_free(sk);
+	if (prot->free_socket)
+		prot->free_socket(sk);
+	else {
+		struct kmem_cache *slab;
=20
-	owner =3D prot->owner;
-	slab =3D prot->slab;
+		slab =3D prot->slab;
=20
-	security_sk_free(sk);
-	if (slab !=3D NULL)
-		kmem_cache_free(slab, sk);
-	else
-		kfree(sk);
-	module_put(owner);
+		if (slab !=3D NULL)
+			kmem_cache_free(slab, sk);
+		else
+			kfree(sk);
+		module_put(prot->owner);
+	}
 }
=20
 /**
diff --git a/net/netlink/af_netlink.c b/net/netlink/af_netlink.c
index 320d042..fae2344 100644
--- a/net/netlink/af_netlink.c
+++ b/net/netlink/af_netlink.c
@@ -81,6 +81,7 @@ struct netlink_sock {
 	struct mutex		cb_def_mutex;
 	void			(*netlink_rcv)(struct sk_buff *skb);
 	struct module		*module;
+	struct rcu_head		rcu;
 };
=20
 struct listeners_rcu_head {
@@ -394,10 +395,22 @@ static void netlink_remove(struct sock *sk)
 	netlink_table_ungrab();
 }
=20
+static void rcu_free_socket(struct rcu_head *rcu)
+{
+	kfree(container_of(rcu, struct netlink_sock, rcu));
+	module_put(THIS_MODULE);
+}
+
+static void free_socket(struct sock *sk)
+{
+	call_rcu(&nlk_sk(sk)->rcu, rcu_free_socket);
+}
+
 static struct proto netlink_proto =3D {
 	.name	  =3D "NETLINK",
 	.owner	  =3D THIS_MODULE,
 	.obj_size =3D sizeof(struct netlink_sock),
+	.free_socket =3D free_socket,
 };
=20
 static int __netlink_create(struct net *net, struct socket *sock,


