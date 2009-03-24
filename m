From: Eric Dumazet <dada1@cosmosbay.com>
Subject: [PATCH] conntrack: Reduce conntrack count in nf_conntrack_free()
Date: Tue, 24 Mar 2009 13:07:16 +0100
Message-ID: <49C8CCF4.5050104@cosmosbay.com>
References: <OF1FEA88FD.D6B88765-ONC1257582.003A487F-C1257582.003ACE3A@transmode.se> <49C77D71.8090709@trash.net> <OF8A05682D.BA831A09-ONC1257582.0043892E-C1257582.004440BD@transmode.se> <49C780AD.70704@trash.net> <OF20814141.D78C9170-ONC1257582.0060B64A-C1257582.00614FDC@transmode.se> <49C7CB9B.1040409@trash.net> <OFBD3D31D8.7AD81126-ONC1257583.002C5C2B-C1257583.002DFF13@transmode.se> <49C8A415.1090606@cosmosbay.com> <OF9168DCC3.5E31F8E4-ONC1257583.003B48CC-C1257583.003C0A5E@transmode.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: avorontsov@ru.mvista.com, Patrick McHardy <kaber@trash.net>,
	netdev@vger.kernel.org,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
To: Joakim Tjernlund <Joakim.Tjernlund@transmode.se>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:46511 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752179AbZCXMIO convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Mar 2009 08:08:14 -0400
In-Reply-To: <OF9168DCC3.5E31F8E4-ONC1257583.003B48CC-C1257583.003C0A5E@transmode.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Joakim Tjernlund a =E9crit :
> Eric Dumazet <dada1@cosmosbay.com> wrote on 24/03/2009 10:12:53:
>> Joakim Tjernlund a =E9crit :
>>> Patrick McHardy <kaber@trash.net> wrote on 23/03/2009 18:49:15:
>>>> Joakim Tjernlund wrote:
>>>>> Patrick McHardy <kaber@trash.net> wrote on 23/03/2009 13:29:33:
>>>>>
>>>>>
>>>>>>> There is no /proc/net/netfilter/nf_conntrack. There is a
>>>>>>> /proc/net/nf_conntrack though and it is empty. If I telnet
>>>>>>> to the board I see:
>>>>>>>
>>>>>> That means that something is leaking conntrack references, most=20
>>> likely
>>>>>> by leaking skbs. Since I haven't seen any other reports, my gues=
s=20
>>> would
>>>>>> be the ucc_geth driver.
>>>>>>
>>>>> Mucking around with the ucc_geth driver I found that if I:
>>>>>  - Move TX from IRQ to NAPI context
>>>>>  - double the weight.
>>>>>  - after booting up, wait a few mins until the JFFS2 GC kernel=20
> thread=20
>>> has=20
>>>>> stopped
>>>>>    scanning the FS=20
>>>>>
>>>>> Then the "nf_conntrack: table full, dropping packet." msgs stops.
>>>>> Does this seem right to you guys?
>>>> No. As I said, something seems to be leaking packets. You should b=
e
>>>> able to confirm that by checking the sk_buff slabs in /proc/slabin=
fo.
>>>> If that *doesn't* show any signs of a leak, please run "conntrack =
-E"
>>>> to capture the conntrack events before the "table full" message
>>>> appears and post the output.
>>> skbuff does not differ much, but others do
>>>
>>> Before ping:
>>>   skbuff_fclone_cache    0      0    352   11    1 : tunables   54 =
27=20
> 0=20
>>> : slabdata      0      0      0
>>>   skbuff_head_cache     20     20    192   20    1 : tunables  120 =
60=20
> 0=20
>>> : slabdata      1      1      0
>>>   size-64              731    767     64   59    1 : tunables  120 =
60=20
> 0=20
>>> : slabdata     13     13      0
>>>   nf_conntrack          10     19    208   19    1 : tunables  120 =
60=20
> 0=20
>>> : slabdata      1      1      0
>>>
>>> During ping:=20
>>>   skbuff_fclone_cache    0      0    352   11    1 : tunables   54 =
27=20
> 0=20
>>> : slabdata      0      0      0
>>>   skbuff_head_cache     40     40    192   20    1 : tunables  120 =
60=20
> 0=20
>>> : slabdata      2      2      0
>>>   size-64             8909   8909     64   59    1 : tunables  120 =
60=20
> 0=20
>>> : slabdata    151    151      0
>>>   nf_conntrack        5111   5111    208   19    1 : tunables  120 =
60=20
> 0=20
>>> : slabdata    269    269      0
>>>
>>> This feels more like the freeing of conntrack objects are delayed a=
nd=20
>>> builds up when ping flooding.
>>>
>>> Don't have "conntrack -E" for my embedded board so that will have t=
o=20
> wait=20
>>> a bit longer.
>> I dont understand how your ping can use so many conntrack entries...
>>
>> Then, as I said yesterday, I believe you have a RCU delay, because o=
f
>> a misbehaving driver or something...
>>
>> grep RCU .config
> grep RCU .config
> # RCU Subsystem
> CONFIG_CLASSIC_RCU=3Dy
> # CONFIG_TREE_RCU is not set
> # CONFIG_PREEMPT_RCU is not set
> # CONFIG_TREE_RCU_TRACE is not set
> # CONFIG_PREEMPT_RCU_TRACE is not set
> # CONFIG_RCU_TORTURE_TEST is not set
> # CONFIG_RCU_CPU_STALL_DETECTOR is not set
>=20
>> grep CONFIG_SMP .config
> grep CONFIG_SMP .config
> # CONFIG_SMP is not set
>=20
>> You could change qhimark from 10000 to 1000 in kernel/rcuclassic.c (=
line=20
> 80)
>> as a workaround. It should force a quiescent state after 1000 freed=20
> conntracks.
>=20
> right, doing this almost killed all conntrack messages, had to stress=
 it=20
> pretty
> hard before I saw handful "nf_conntrack: table full, dropping packet"
>=20
> RCU is not my cup of tea, do you have any ideas were to look?

In a stress situation, you feed more deleted conntracks to call_rcu() t=
han
the blimit (10 real freeing per RCU softirq invocation).=20

So with default qhimark being 10000, this means about 10000 conntracks
can sit in RCU (per CPU) before being really freed.

Only when hitting 10000, RCU enters a special mode to free all queued i=
tems, instead
of a small batch of 10

To solve your problem we can :

1) reduce qhimark from 10000 to 1000 (for example)
   Probably should be done to reduce some spikes in RCU code when freei=
ng
   whole 10000 elements...
OR
2) change conntrack tunable (max conntrack entries on your machine)
OR
3) change net/netfilter/nf_conntrack_core.c to decrement net->ct.count
  in nf_conntrack_free() instead of callback.

[PATCH] conntrack: Reduce conntrack count in nf_conntrack_free()

We use RCU to defer freeing of conntrack structures. In DOS situation, =
RCU might
accumulate about 10.000 elements per CPU in its internal queues. To get=
 accurate
conntrack counts (at the expense of slightly more RAM used), we might c=
onsider
conntrack counter not taking into account "about to be freed elements, =
waiting
in RCU queues". We thus decrement it in nf_conntrack_free(), not in the=
 RCU
callback.

Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>


diff --git a/net/netfilter/nf_conntrack_core.c b/net/netfilter/nf_connt=
rack_core.c
index f4935e3..6478dc7 100644
--- a/net/netfilter/nf_conntrack_core.c
+++ b/net/netfilter/nf_conntrack_core.c
@@ -516,16 +516,17 @@ EXPORT_SYMBOL_GPL(nf_conntrack_alloc);
 static void nf_conntrack_free_rcu(struct rcu_head *head)
 {
 	struct nf_conn *ct =3D container_of(head, struct nf_conn, rcu);
-	struct net *net =3D nf_ct_net(ct);
=20
 	nf_ct_ext_free(ct);
 	kmem_cache_free(nf_conntrack_cachep, ct);
-	atomic_dec(&net->ct.count);
 }
=20
 void nf_conntrack_free(struct nf_conn *ct)
 {
+	struct net *net =3D nf_ct_net(ct);
+
 	nf_ct_ext_destroy(ct);
+	atomic_dec(&net->ct.count);
 	call_rcu(&ct->rcu, nf_conntrack_free_rcu);
 }
 EXPORT_SYMBOL_GPL(nf_conntrack_free);



