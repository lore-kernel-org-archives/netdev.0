From: Huajun Li <huajun.li.lee@gmail.com>
Subject: Re: [PATCH 2/2] net: Fix potential memory leak
Date: Mon, 26 Sep 2011 16:43:09 +0800
Message-ID: <CA+v9cxbK-oyJXQ+VpMf8DtD267Yc_Yy0+N_rK6ikxKvApRwYxw@mail.gmail.com>
References: <CA+v9cxYuFArVUh9gc-be-Lmy4TOTxp72VaCC4QeCEE3p1j2Ykg@mail.gmail.com>
	<1317017353.2853.13.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Huajun Li <huajun.li.lee@gmail.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:40608 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751499Ab1IZInK convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Sep 2011 04:43:10 -0400
Received: by mail-fx0-f46.google.com with SMTP id 4so5864576fxe.19
        for <netdev@vger.kernel.org>; Mon, 26 Sep 2011 01:43:09 -0700 (PDT)
In-Reply-To: <1317017353.2853.13.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric, thanks for your comment.

2011/9/26 Eric Dumazet <eric.dumazet@gmail.com>:
> Le samedi 24 septembre 2011 =E0 23:57 +0800, Huajun Li a =E9crit :
>> While preparing flow caches, once fail may cause potential memory le=
ak , fix it.
>>
>> Signed-off-by: Huajun Li <huajun.li.lee@gmail.com>
>> ---
>> =A0net/core/flow.c | =A0 19 ++++++++++++++++++-
>> =A01 files changed, 18 insertions(+), 1 deletions(-)
>>
>> diff --git a/net/core/flow.c b/net/core/flow.c
>> index ba3e617..2dcaa03 100644
>> --- a/net/core/flow.c
>> +++ b/net/core/flow.c
>> @@ -420,7 +420,7 @@ static int __init flow_cache_init(struct flow_ca=
che *fc)
>>
>> =A0 =A0 =A0 for_each_online_cpu(i) {
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (flow_cache_cpu_prepare(fc, i))
>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 return -ENOMEM;
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto err;
>> =A0 =A0 =A0 }
>> =A0 =A0 =A0 fc->hotcpu_notifier =3D (struct notifier_block){
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 .notifier_call =3D flow_cache_cpu,
>> @@ -433,6 +433,23 @@ static int __init flow_cache_init(struct flow_c=
ache *fc)
>> =A0 =A0 =A0 add_timer(&fc->rnd_timer);
>>
>> =A0 =A0 =A0 return 0;
>> +err:
>> + =A0 =A0 if (fc->percpu) {
>> + =A0 =A0 =A0 =A0 =A0 =A0 free_percpu(fc->percpu);
>> + =A0 =A0 =A0 =A0 =A0 =A0 fc->percpu =3D NULL;
>> + =A0 =A0 }
>> +
>> + =A0 =A0 /*
>> + =A0 =A0 =A0* Check each possible CPUs rather than online ones beca=
use they may be
>> + =A0 =A0 =A0* offline before the notifier is registered.
>> + =A0 =A0 =A0*/
>
> Please remove this comment.
>

Sure.

>
>> + =A0 =A0 for_each_possible_cpu(i) {
>> + =A0 =A0 =A0 =A0 =A0 =A0 struct flow_cache_percpu *fcp =3D per_cpu_=
ptr(fc->percpu, i);
>> + =A0 =A0 =A0 =A0 =A0 =A0 kfree(fcp->hash_table);
>> + =A0 =A0 =A0 =A0 =A0 =A0 fcp->hash_table =3D NULL;
>> + =A0 =A0 }
>
> You access fc->percpu after freeing it...
>

Yes, need change the order to free memory.

>> +
>> + =A0 =A0 return -ENOMEM;
>> =A0}
>>
>> =A0static int __init flow_cache_init_global(void)
>
> Previous to 2.6.37 (commit 83b6b1f5d134), a memory allocation at this
> stage was panicing the box, so no worry about mem leak :)
>
> Now I wonder if a proper patch would not print a nice message in
> flow_cache_init_global() if flow_cache_init() returns an error, inste=
ad
> of silently panicing or something worse...
>

There prints err msg in flow_cache_cpu_prepare(L369) if fails to
allocate memory. Do you mean it should give more detail error info,
right ?

> Before submitting a new patch, could you test this case (injecting a
> memalloc error in flow_cache_cpu_prepare() for example.
>

Will test it further if new patch comes.  ;)
