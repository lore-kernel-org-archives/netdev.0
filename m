From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: BUG UNIX: Poison overwritten with 2.6.31-rc6-00223-g6c30c53
Date: Tue, 08 Sep 2009 14:12:01 +0200
Message-ID: <4AA64A11.7090804@gmail.com>
References: <alpine.DEB.2.00.0909072323350.3940@parag-desktop>	 <df9815e70909072151l2686231en76773418aaf9deeb@mail.gmail.com>	 <4AA609E8.3060408@gmail.com> <df9815e70909080109r3d61ee76v3dcba41dbd87b998@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Parag Warudkar <parag.lkml@gmail.com>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Jike Song <albcamus@gmail.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1754487AbZIHMMF@vger.kernel.org>
In-Reply-To: <df9815e70909080109r3d61ee76v3dcba41dbd87b998@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jike Song a =C3=A9crit :
> On Tue, Sep 8, 2009 at 3:38 PM, Eric Dumazet<eric.dumazet@gmail.com> =
wrote:
>> We decrement a refcnt while object already freed.
>>
>> (SLUB DEBUG poisons the zone with 0x6B pattern)
>>
>> You might add this patch to trigger a WARN_ON when refcnt >=3D 0x600=
00000U
>> in sk_free() : We'll see the path trying to delete an already freed =
sock
>>
>> diff --git a/net/core/sock.c b/net/core/sock.c
>> index 7633422..1cb85ff 100644
>> --- a/net/core/sock.c
>> +++ b/net/core/sock.c
>> @@ -1058,6 +1058,7 @@ static void __sk_free(struct sock *sk)
>>
>>  void sk_free(struct sock *sk)
>>  {
>> +       WARN_ON(atomic_read(&sk->sk_wmem_alloc) >=3D 0x60000000U);
>>        /*
>>         * We substract one from sk_wmem_alloc and can know if
>>        * some packets are still in some tx queue.
>>
>>
>=20
> The output of dmesg with this patch appllied is attached.
>=20
>=20

Unfortunatly this WARN_ON was not triggered,
maybe freeing comes from sock_wfree()

Could you try this patch instead ?

Thanks

diff --git a/net/core/sock.c b/net/core/sock.c
index 7633422..30469dc 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -1058,6 +1058,7 @@ static void __sk_free(struct sock *sk)

 void sk_free(struct sock *sk)
 {
+	WARN_ON(atomic_read(&sk->sk_wmem_alloc) >=3D 0x60000000U);
 	/*
 	 * We substract one from sk_wmem_alloc and can know if
 	* some packets are still in some tx queue.
@@ -1220,6 +1221,7 @@ void sock_wfree(struct sk_buff *skb)
 	struct sock *sk =3D skb->sk;
 	int res;

+	WARN_ON(atomic_read(&sk->sk_wmem_alloc) >=3D 0x60000000U);
 	/* In case it might be waiting for more memory. */
 	res =3D atomic_sub_return(skb->truesize, &sk->sk_wmem_alloc);
 	if (!sock_flag(sk, SOCK_USE_WRITE_QUEUE))
