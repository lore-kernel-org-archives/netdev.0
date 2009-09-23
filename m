From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] net: Fix sock_wfree() race
Date: Wed, 23 Sep 2009 15:44:15 +0200
Message-ID: <4ABA262F.9040407@gmail.com>
References: <4AA64A11.7090804@gmail.com>	<4AA6DF7B.7060105@gmail.com>	<20090911.114337.150207703.davem@davemloft.net> <20090911.125242.244008840.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: albcamus@gmail.com, parag.lkml@gmail.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:42689 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751311AbZIWNoP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Sep 2009 09:44:15 -0400
In-Reply-To: <20090911.125242.244008840.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller a =E9crit :
> From: David Miller <davem@davemloft.net>
> Date: Fri, 11 Sep 2009 11:43:37 -0700 (PDT)
>=20
>> From: Eric Dumazet <eric.dumazet@gmail.com>
>> Date: Wed, 09 Sep 2009 00:49:31 +0200
>>
>>> [PATCH] net: Fix sock_wfree() race
>>>
>>> Commit 2b85a34e911bf483c27cfdd124aeb1605145dc80
>>> (net: No more expensive sock_hold()/sock_put() on each tx)
>>> opens a window in sock_wfree() where another cpu
>>> might free the socket we are working on.
>>>
>>> Fix is to call sk->sk_write_space(sk) only
>>> while still holding a reference on sk.
>>>
>>> Since doing this call is done before the=20
>>> atomic_sub(truesize, &sk->sk_wmem_alloc), we should pass truesize a=
s=20
>>> a bias for possible sk_wmem_alloc evaluations.
>>>
>>> Reported-by: Jike Song <albcamus@gmail.com>
>>> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
>> Applied to net-next-2.6, thanks.  I'll queue up your simpler
>> version for -stable.
>=20
> Eric, I have to revert, as you didn't update the callbacks
> of several protocols such as SCTP and RDS in this change.
>=20
> Let me know when you have a fixed version of this patch :-)

Sorry for the delay David. But this is complex. I am not
sure we can do a clean and safe thing, not counting
the added bloat.

If we do :

void sock_wfree(struct sk_buff *skb)
{
        struct sock *sk =3D skb->sk;
        int res;

        if (!sock_flag(sk, SOCK_USE_WRITE_QUEUE))
                sk->sk_write_space(sk, skb->truesize);

        res =3D atomic_sub_return(skb->truesize, &sk->sk_wmem_alloc);
        /*
         * if sk_wmem_alloc reached 0, we are last user and should
         * free this sock, as sk_free() call could not do it.
         */
        if (res =3D=3D 0)
                __sk_free(sk);
}


There is still a possibility multiple cpus call sock_wfree()
for the same socket, and that they all call sk_write_space()
with their bias, yet the protocol still has a possible too
big estimation of sk_wmem_alloc

We could miss to wakeup a blocked writer in case low sk->sk_sndbuf
values are setup. (One could argue that with small sk_sndbuf
values we should not have many packets in flight : Keep in mind
sk_sndbuf can be lowered by the user)


With second patch we instead have :

void sock_wfree(struct sk_buff *skb)
{
	struct sock *sk =3D skb->sk;
	unsigned int len =3D skb->truesize;

	if (!sock_flag(sk, SOCK_USE_WRITE_QUEUE)) {
		/*
		 * Keep a reference on sk_wmem_alloc, this will be released
		 * after sk_write_space() call
		 */
		atomic_sub(len - 1, &sk->sk_wmem_alloc);
		sk->sk_write_space(sk);
		len =3D 1;
	}
	/*
	 * if sk_wmem_alloc reaches 0, we must finish what sk_free()
	 * could not do because of in-flight packets
	 */
	if (atomic_sub_return(len, &sk->sk_wmem_alloc) =3D=3D 0)
		__sk_free(sk);
}

The accumulated transient error on sk_wmem_alloc is then < num_online_c=
pus(),
that should be OK even for very small sk_sndbuf values.

Of course TCP doesnt have to pay the price of sk_write_space() and the =
second
atomic operation re-added by this fix.

Here is the patch for reference :

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
+	if (atomic_sub_return(len, &sk->sk_wmem_alloc) =3D=3D 0)
 		__sk_free(sk);
 }
 EXPORT_SYMBOL(sock_wfree);

