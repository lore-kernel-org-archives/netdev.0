From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [PATCH] conntrack: Reduce conntrack count in nf_conntrack_free()
Date: Tue, 24 Mar 2009 14:32:03 +0100
Message-ID: <49C8E0D3.1010202@cosmosbay.com>
References: <OF1FEA88FD.D6B88765-ONC1257582.003A487F-C1257582.003ACE3A@transmode.se> <49C77D71.8090709@trash.net> <OF8A05682D.BA831A09-ONC1257582.0043892E-C1257582.004440BD@transmode.se> <49C780AD.70704@trash.net> <OF20814141.D78C9170-ONC1257582.0060B64A-C1257582.00614FDC@transmode.se> <49C7CB9B.1040409@trash.net> <OFBD3D31D8.7AD81126-ONC1257583.002C5C2B-C1257583.002DFF13@transmode.se> <49C8A415.1090606@cosmosbay.com> <OF9168DCC3.5E31F8E4-ONC1257583.003B48CC-C1257583.003C0A5E@transmode.se> <49C8CCF4.5050104@cosmosbay.com> <49C8D13D.10307@cosmosbay.com> <49C8D58A.6060401@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Joakim Tjernlund <Joakim.Tjernlund@transmode.se>,
	avorontsov@ru.mvista.com, netdev@vger.kernel.org,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:58888 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753666AbZCXNew convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Mar 2009 09:34:52 -0400
In-Reply-To: <49C8D58A.6060401@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Patrick McHardy a =E9crit :
> Eric Dumazet wrote:
>>> In a stress situation, you feed more deleted conntracks to call_rcu=
()
>>> than
>>> the blimit (10 real freeing per RCU softirq invocation).
>>> So with default qhimark being 10000, this means about 10000 conntra=
cks
>>> can sit in RCU (per CPU) before being really freed.
>>>
>>> Only when hitting 10000, RCU enters a special mode to free all queu=
ed
>>> items, instead
>>> of a small batch of 10
>>>
>>> To solve your problem we can :
>>>
>>> 1) reduce qhimark from 10000 to 1000 (for example)
>>>    Probably should be done to reduce some spikes in RCU code when
>>> freeing
>>>    whole 10000 elements...
>>> OR
>>> 2) change conntrack tunable (max conntrack entries on your machine)
>>> OR
>>> 3) change net/netfilter/nf_conntrack_core.c to decrement net->ct.co=
unt
>>>   in nf_conntrack_free() instead of callback.
>>>
>>> [PATCH] conntrack: Reduce conntrack count in nf_conntrack_free()
>>>
>>> We use RCU to defer freeing of conntrack structures. In DOS
>>> situation, RCU might
>>> accumulate about 10.000 elements per CPU in its internal queues. To
>>> get accurate
>>> conntrack counts (at the expense of slightly more RAM used), we mig=
ht
>>> consider
>>> conntrack counter not taking into account "about to be freed
>>> elements, waiting
>>> in RCU queues". We thus decrement it in nf_conntrack_free(), not in
>>> the RCU
>>> callback.
>>>
>>> Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>
>>>
>>>
>>> diff --git a/net/netfilter/nf_conntrack_core.c
>>> b/net/netfilter/nf_conntrack_core.c
>>> index f4935e3..6478dc7 100644
>>> --- a/net/netfilter/nf_conntrack_core.c
>>> +++ b/net/netfilter/nf_conntrack_core.c
>>> @@ -516,16 +516,17 @@ EXPORT_SYMBOL_GPL(nf_conntrack_alloc);
>>>  static void nf_conntrack_free_rcu(struct rcu_head *head)
>>>  {
>>>      struct nf_conn *ct =3D container_of(head, struct nf_conn, rcu)=
;
>>> -    struct net *net =3D nf_ct_net(ct);
>>> =20
>>>      nf_ct_ext_free(ct);
>>>      kmem_cache_free(nf_conntrack_cachep, ct);
>>> -    atomic_dec(&net->ct.count);
>>>  }
>>> =20
>>>  void nf_conntrack_free(struct nf_conn *ct)
>>>  {
>>> +    struct net *net =3D nf_ct_net(ct);
>>> +
>>>      nf_ct_ext_destroy(ct);
>>> +    atomic_dec(&net->ct.count);
>>>      call_rcu(&ct->rcu, nf_conntrack_free_rcu);
>>>  }
>>>  EXPORT_SYMBOL_GPL(nf_conntrack_free);
>>
>> I forgot to say this is what we do for 'struct file' freeing as well=
=2E We
>> decrement nr_files in file_free(), not in file_free_rcu()
>=20
>=20
> While temporarily exceeding the limit by up to 10000 entries is
> quite a lot, I guess the important thing is that it can't grow
> unbounded, so I think this patch is fine.
>=20
>=20

Maybe we could use SLAB_DESTROY_BY_RCU thing and no more call_rcu() que=
ueing
problem. That would better use CPU caches as well...

