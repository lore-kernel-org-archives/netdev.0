From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] net: Fix sock_wfree() race
Date: Wed, 09 Sep 2009 11:18:01 +0200
Message-ID: <4AA772C9.9010001@gmail.com>
References: <alpine.DEB.2.00.0909072323350.3940@parag-desktop>	 <df9815e70909072151l2686231en76773418aaf9deeb@mail.gmail.com>	 <4AA609E8.3060408@gmail.com>	 <df9815e70909080109r3d61ee76v3dcba41dbd87b998@mail.gmail.com>	 <4AA64A11.7090804@gmail.com> <4AA6DF7B.7060105@gmail.com> <df9815e70909090014w27828827j860ecee4f1c3a9e2@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org, David Miller <davem@davemloft.net>,
	Parag Warudkar <parag.lkml@gmail.com>
To: Jike Song <albcamus@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:42448 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752541AbZIIJSC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Sep 2009 05:18:02 -0400
In-Reply-To: <df9815e70909090014w27828827j860ecee4f1c3a9e2@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jike Song a =C3=A9crit :
> On Wed, Sep 9, 2009 at 6:49 AM, Eric Dumazet<eric.dumazet@gmail.com> =
wrote:
>> Eric Dumazet a =C3=A9crit :
>>> Jike Song a =C3=A9crit :
>>>> On Tue, Sep 8, 2009 at 3:38 PM, Eric Dumazet<eric.dumazet@gmail.co=
m> wrote:
>>>>> We decrement a refcnt while object already freed.
>>>>>
>>>>> (SLUB DEBUG poisons the zone with 0x6B pattern)
>>>>>
>>>>> You might add this patch to trigger a WARN_ON when refcnt >=3D 0x=
60000000U
>>>>> in sk_free() : We'll see the path trying to delete an already fre=
ed sock
>>>>>
>>>>> diff --git a/net/core/sock.c b/net/core/sock.c
>>>>> index 7633422..1cb85ff 100644
>>>>> --- a/net/core/sock.c
>>>>> +++ b/net/core/sock.c
>>>>> @@ -1058,6 +1058,7 @@ static void __sk_free(struct sock *sk)
>>>>>
>>>>>  void sk_free(struct sock *sk)
>>>>>  {
>>>>> +       WARN_ON(atomic_read(&sk->sk_wmem_alloc) >=3D 0x60000000U)=
;
>>>>>        /*
>>>>>         * We substract one from sk_wmem_alloc and can know if
>>>>>        * some packets are still in some tx queue.
>>>>>
>>>>>
>>>> The output of dmesg with this patch appllied is attached.
>>>>
>>>>
>>> Unfortunatly this WARN_ON was not triggered,
>>> maybe freeing comes from sock_wfree()
>>>
>>> Could you try this patch instead ?
>>>
>>> Thanks
>>>
>>> diff --git a/net/core/sock.c b/net/core/sock.c
>>> index 7633422..30469dc 100644
>>> --- a/net/core/sock.c
>>> +++ b/net/core/sock.c
>>> @@ -1058,6 +1058,7 @@ static void __sk_free(struct sock *sk)
>>>
>>>  void sk_free(struct sock *sk)
>>>  {
>>> +     WARN_ON(atomic_read(&sk->sk_wmem_alloc) >=3D 0x60000000U);
>>>       /*
>>>        * We substract one from sk_wmem_alloc and can know if
>>>       * some packets are still in some tx queue.
>>> @@ -1220,6 +1221,7 @@ void sock_wfree(struct sk_buff *skb)
>>>       struct sock *sk =3D skb->sk;
>>>       int res;
>>>
>>> +     WARN_ON(atomic_read(&sk->sk_wmem_alloc) >=3D 0x60000000U);
>>>       /* In case it might be waiting for more memory. */
>>>       res =3D atomic_sub_return(skb->truesize, &sk->sk_wmem_alloc);
>>>       if (!sock_flag(sk, SOCK_USE_WRITE_QUEUE))
>>>
>>
>> David, I believe problem could come from a race in sock_wfree()
>>
>> It used to have two atomic ops.
>>
>> One doing the atomic_sub(skb->truesize, &sk->sk_wmem_alloc);
>> then one sock_put() doing the atomic_dec_and_test(&sk->sk_refcnt)
>>
>> Now, if two cpus are both :
>>
>> CPU 1 calling sock_wfree()
>> CPU 2 calling the 'final' sock_put(),
>> CPU 1 doing sock_wfree() might call sk->sk_write_space(sk)
>> while CPU 2 is already freeing the socket.
>>
>>
>> Please note I did not test this patch, its very late here and I shou=
ld get some sleep now...
>>
>> Thanks
>>
>> [PATCH] net: Fix sock_wfree() race
>>
>> Commit 2b85a34e911bf483c27cfdd124aeb1605145dc80
>> (net: No more expensive sock_hold()/sock_put() on each tx)
>> opens a window in sock_wfree() where another cpu
>> might free the socket we are working on.
>>
>> Fix is to call sk->sk_write_space(sk) only
>> while still holding a reference on sk.
>>
>> Since doing this call is done before the
>> atomic_sub(truesize, &sk->sk_wmem_alloc), we should pass truesize as
>> a bias for possible sk_wmem_alloc evaluations.
>>
>> Reported-by: Jike Song <albcamus@gmail.com>
>> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
>=20
> Eric, I'm unable to apply this patch neatly.  I applied it by hand,
> and did some change necessary. This patch for test is attached.
>=20
> With this patch applied, when run vncviewer, the kerneloops service
> still reports kernel failure. But I can't see any in dmesg output.
>=20
>=20

Sorry this was a patch against net-next-2.6

We probably can do something less intrusive for linux-2.6.31

[PATCH] net: Fix sock_wfree() race

Commit 2b85a34e911bf483c27cfdd124aeb1605145dc80
(net: No more expensive sock_hold()/sock_put() on each tx)
opens a window in sock_wfree() where another cpu
might free the socket we are working on.

A possible fix is to call sk->sk_write_space(sk) only
while still holding a reference on sk.


Reported-by: Jike Song <albcamus@gmail.com>
Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---

diff --git a/net/core/sock.c b/net/core/sock.c
index 7633422..aba5cd0 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -1220,10 +1220,12 @@ void sock_wfree(struct sk_buff *skb)
 	struct sock *sk =3D skb->sk;
 	int res;

-	/* In case it might be waiting for more memory. */
-	res =3D atomic_sub_return(skb->truesize, &sk->sk_wmem_alloc);
-	if (!sock_flag(sk, SOCK_USE_WRITE_QUEUE))
+	if (!sock_flag(sk, SOCK_USE_WRITE_QUEUE)) {
+		atomic_sub(skb->truesize - 1, &sk->sk_wmem_alloc);
 		sk->sk_write_space(sk);
+		res =3D atomic_sub_return(1, &sk->sk_wmem_alloc);
+	} else
+		res =3D atomic_sub_return(skb->truesize, &sk->sk_wmem_alloc);
 	/*
 	 * if sk_wmem_alloc reached 0, we are last user and should
 	 * free this sock, as sk_free() call could not do it.
