From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [PATCH] conntrack: use SLAB_DESTROY_BY_RCU for nf_conn structs
Date: Wed, 25 Mar 2009 20:17:36 +0100
Message-ID: <49CA8350.5040407@cosmosbay.com>
References: <OF1FEA88FD.D6B88765-ONC1257582.003A487F-C1257582.003ACE3A@transmode.se>	 <49C77D71.8090709@trash.net>	 <OF8A05682D.BA831A09-ONC1257582.0043892E-C1257582.004440BD@transmode.se>	 <49C780AD.70704@trash.net>	 <OF20814141.D78C9170-ONC1257582.0060B64A-C1257582.00614FDC@transmode.se>	 <49C7CB9B.1040409@trash.net>	 <OFBD3D31D8.7AD81126-ONC1257583.002C5C2B-C1257583.002DFF13@transmode.se>	 <49C8A415.1090606@cosmosbay.com>	 <OF9168DCC3.5E31F8E4-ONC1257583.003B48CC-C1257583.003C0A5E@transmode.se>	 <49C8CCF4.5050104@cosmosbay.com> <1237907850.12351.80.camel@sakura.staff.proxad.net> <49C8FBCA.40402@cosmosbay.com> <49CA6F9A.9010806@cosmosbay.com> <49CA7255.20807@trash.net> <49CA74CA.1040603@cosmosbay.com> <49CA76C4.2090409@trash.net> <49CA7DAF.9070207@cosmosbay.com> <49CA7F45.5020800@trash.n
 et>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: mbizon@freebox.fr, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	Joakim Tjernlund <Joakim.Tjernlund@transmode.se>,
	avorontsov@ru.mvista.com, netdev@vger.kernel.org,
	Netfilter Developers <netfilter-devel@vger.kernel.org>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:58886 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752594AbZCYTSG convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Mar 2009 15:18:06 -0400
In-Reply-To: <49CA7F45.5020800@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Patrick McHardy a =E9crit :
> Eric Dumazet wrote:
>> Here is take 2 of the patch with proper ref counting on dumping.
>=20
> Thanks, one final question about the seq-file handling:
>=20
>> diff --git a/net/ipv4/netfilter/nf_conntrack_l3proto_ipv4_compat.c
>> b/net/ipv4/netfilter/nf_conntrack_l3proto_ipv4_compat.c
>> index 6ba5c55..0b870b9 100644
>> --- a/net/ipv4/netfilter/nf_conntrack_l3proto_ipv4_compat.c
>> +++ b/net/ipv4/netfilter/nf_conntrack_l3proto_ipv4_compat.c
>> @@ -25,30 +25,30 @@ struct ct_iter_state {
>>      unsigned int bucket;
>>  };
>> =20
>> -static struct hlist_node *ct_get_first(struct seq_file *seq)
>> +static struct hlist_nulls_node *ct_get_first(struct seq_file *seq)
>>  {
>>      struct net *net =3D seq_file_net(seq);
>>      struct ct_iter_state *st =3D seq->private;
>> -    struct hlist_node *n;
>> +    struct hlist_nulls_node *n;
>> =20
>>      for (st->bucket =3D 0;
>>           st->bucket < nf_conntrack_htable_size;
>>           st->bucket++) {
>>          n =3D rcu_dereference(net->ct.hash[st->bucket].first);
>> -        if (n)
>> +        if (!is_a_nulls(n))
>>              return n;
>>      }
>>      return NULL;
>>  }
>> =20
>> -static struct hlist_node *ct_get_next(struct seq_file *seq,
>> -                      struct hlist_node *head)
>> +static struct hlist_nulls_node *ct_get_next(struct seq_file *seq,
>> +                      struct hlist_nulls_node *head)
>>  {
>>      struct net *net =3D seq_file_net(seq);
>>      struct ct_iter_state *st =3D seq->private;
>> =20
>>      head =3D rcu_dereference(head->next);
>> -    while (head =3D=3D NULL) {
>> +    while (is_a_nulls(head)) {
>>          if (++st->bucket >=3D nf_conntrack_htable_size)
>>              return NULL;
>>          head =3D rcu_dereference(net->ct.hash[st->bucket].first);
>> @@ -56,9 +56,9 @@ static struct hlist_node *ct_get_next(struct
>> seq_file *seq,
>>      return head;
>>  }
>> =20
>> -static struct hlist_node *ct_get_idx(struct seq_file *seq, loff_t p=
os)
>> +static struct hlist_nulls_node *ct_get_idx(struct seq_file *seq,
>> loff_t pos)
>>  {
>> -    struct hlist_node *head =3D ct_get_first(seq);
>> +    struct hlist_nulls_node *head =3D ct_get_first(seq);
>> =20
>>      if (head)
>>          while (pos && (head =3D ct_get_next(seq, head)))
>> @@ -87,69 +87,76 @@ static void ct_seq_stop(struct seq_file *s, void=
 *v)
>> =20
>>  static int ct_seq_show(struct seq_file *s, void *v)
>>  {
>> -    const struct nf_conntrack_tuple_hash *hash =3D v;
>> -    const struct nf_conn *ct =3D nf_ct_tuplehash_to_ctrack(hash);
>> +    struct nf_conntrack_tuple_hash *hash =3D v;
>> +    struct nf_conn *ct =3D nf_ct_tuplehash_to_ctrack(hash);
>>      const struct nf_conntrack_l3proto *l3proto;
>>      const struct nf_conntrack_l4proto *l4proto;
>> +    int ret =3D 0;
>> =20
>>      NF_CT_ASSERT(ct);
>> +    if (unlikely(!atomic_inc_not_zero(&ct->ct_general.use)))
>> +        return 0;
>=20
> Can we assume the next pointer still points to the next entry
> in the same chain after the refcount dropped to zero?
>=20
>=20
>=20

We are looking chain N.
If we cannot atomic_inc() refcount, we got some deleted entry.
If we could atomic_inc, we can meet an entry that just moved to another=
 chain X

When hitting its end, we continue the search to the N+1 chain so we onl=
y=20
skip the end of previous chain (N). We can 'forget' some entries, we ca=
n print
several time one given entry.


We could solve this by :

1) Checking hash value : if not one expected ->=20
   Going back to head of chain N, (potentially re-printing already hand=
led entries)
   So it is not a *perfect* solution.

2) Use a locking to forbid writers (as done in UDP/TCP), but it is expe=
nsive and
wont solve other problem :

We wont avoid emitting same entry several time anyway (this is a flaw o=
f=20
current seq_file handling, since we 'count' entries to be skiped, and t=
his is
wrong if some entries were deleted or inserted meanwhile)

We have same problem on /proc/net/udp & /proc/net/tcp, I am not sure we=
 should care...

Also, current resizing code can give to a /proc/net/ip_conntrack reader=
 a problem, since
hash table can switch while its doing its dumping : many entries might =
be lost or regiven...


