From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: net-next/unix: BUG: using smp_processor_id() in preemptible
Date: Mon, 24 Nov 2008 09:01:49 +0100
Message-ID: <492A5F6D.3040708@cosmosbay.com>
References: <Pine.LNX.4.64.0811221634370.10534@wrl-59.cs.helsinki.fi>	<4928CECE.602@cosmosbay.com>	<20081123.172014.78676422.davem@davemloft.net> <20081123.173426.255648175.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------090906080605010506050700"
Cc: ilpo.jarvinen@helsinki.fi, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([86.65.150.130]:41362 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750722AbYKXIB6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Nov 2008 03:01:58 -0500
In-Reply-To: <20081123.173426.255648175.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------090906080605010506050700
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: quoted-printable

David Miller a =E9crit :
> From: David Miller <davem@davemloft.net>
> Date: Sun, 23 Nov 2008 17:20:14 -0800 (PST)
>=20
>> From: Eric Dumazet <dada1@cosmosbay.com>
>> Date: Sun, 23 Nov 2008 04:32:30 +0100
>>
>>> [PATCH] net: make sock_prot_inuse_add() preempt safe
>  ...
>> Eric, you added this bug by starting to use this interface in
>> situations where BH's were not disabled.
>>
>> Ever existing use adhered to that rule.
>>
>> If you therefore want to call this interface in new locations,
>> you have to make sure those locations follow the rule too.
>=20
> Here is what I commited to fix this bug.
>=20
> net: Make sure BHs are disabled in sock_prot_inuse_add()
>=20
> The rule of calling sock_prot_inuse_add() is that BHs must
> be disabled.  Some new calls were added where this was not
> true and this tiggers warnings as reported by Ilpo.
>=20
> Fix this by adding explicit BH disabling around those call sites.
>=20
> Signed-off-by: David S. Miller <davem@davemloft.net>
> ---
>  net/netlink/af_netlink.c |    3 +++
>  net/sctp/socket.c        |    4 ++++
>  net/unix/af_unix.c       |    2 ++
>  3 files changed, 9 insertions(+), 0 deletions(-)

I believe some bits are missing

Ilpo report was about unix_create1() being preemptable for example

Thanks

[PATCH] net: Make sure BHs are disabled in sock_prot_inuse_add()

The rule of calling sock_prot_inuse_add() is that BHs must
be disabled.  Some new calls were added where this was not
true and this tiggers warnings as reported by Ilpo.

Fix this by adding explicit BH disabling around those call sites,
or moving sock_prot_inuse_add() call inside an existing BH disabled
section.

Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>
---

 net/ipv4/inet_hashtables.c |    2 +-
 net/packet/af_packet.c     |    4 ++--
 net/unix/af_unix.c         |    6 ++++--
 3 files changed, 7 insertions(+), 5 deletions(-)

--------------090906080605010506050700
Content-Type: text/plain;
 name="prot_inuse.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="prot_inuse.patch"

diff --git a/net/ipv4/inet_hashtables.c b/net/ipv4/inet_hashtables.c
index 11fcb87..6a1045d 100644
--- a/net/ipv4/inet_hashtables.c
+++ b/net/ipv4/inet_hashtables.c
@@ -402,9 +402,9 @@ void inet_unhash(struct sock *sk)
 
 	spin_lock_bh(lock);
 	done =__sk_nulls_del_node_init_rcu(sk);
-	spin_unlock_bh(lock);
 	if (done)
 		sock_prot_inuse_add(sock_net(sk), sk->sk_prot, -1);
+	spin_unlock_bh(lock);
 }
 EXPORT_SYMBOL_GPL(inet_unhash);
 
diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
index b4870a3..5f94db2 100644
--- a/net/packet/af_packet.c
+++ b/net/packet/af_packet.c
@@ -872,6 +872,7 @@ static int packet_release(struct socket *sock)
 
 	write_lock_bh(&net->packet.sklist_lock);
 	sk_del_node_init(sk);
+	sock_prot_inuse_add(net, sk->sk_prot, -1);
 	write_unlock_bh(&net->packet.sklist_lock);
 
 	/*
@@ -910,7 +911,6 @@ static int packet_release(struct socket *sock)
 	skb_queue_purge(&sk->sk_receive_queue);
 	sk_refcnt_debug_release(sk);
 
-	sock_prot_inuse_add(net, sk->sk_prot, -1);
 	sock_put(sk);
 	return 0;
 }
@@ -1085,8 +1085,8 @@ static int packet_create(struct net *net, struct socket *sock, int protocol)
 
 	write_lock_bh(&net->packet.sklist_lock);
 	sk_add_node(sk, &net->packet.sklist);
-	write_unlock_bh(&net->packet.sklist_lock);
 	sock_prot_inuse_add(net, &packet_proto, 1);
+	write_unlock_bh(&net->packet.sklist_lock);
 	return(0);
 out:
 	return err;
diff --git a/net/unix/af_unix.c b/net/unix/af_unix.c
index a45a9f7..3a35a6e 100644
--- a/net/unix/af_unix.c
+++ b/net/unix/af_unix.c
@@ -615,9 +615,11 @@ static struct sock *unix_create1(struct net *net, struct socket *sock)
 out:
 	if (sk == NULL)
 		atomic_dec(&unix_nr_socks);
-	else
+	else {
+		local_bh_disable();
 		sock_prot_inuse_add(sock_net(sk), sk->sk_prot, 1);
-
+		local_bh_enable();
+	}
 	return sk;
 }
 

--------------090906080605010506050700--
