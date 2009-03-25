From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [PATCH] conntrack: use SLAB_DESTROY_BY_RCU for nf_conn structs
Date: Wed, 25 Mar 2009 19:15:38 +0100
Message-ID: <49CA74CA.1040603@cosmosbay.com>
References: <OF1FEA88FD.D6B88765-ONC1257582.003A487F-C1257582.003ACE3A@transmode.se>	 <49C77D71.8090709@trash.net>	 <OF8A05682D.BA831A09-ONC1257582.0043892E-C1257582.004440BD@transmode.se>	 <49C780AD.70704@trash.net>	 <OF20814141.D78C9170-ONC1257582.0060B64A-C1257582.00614FDC@transmode.se>	 <49C7CB9B.1040409@trash.net>	 <OFBD3D31D8.7AD81126-ONC1257583.002C5C2B-C1257583.002DFF13@transmode.se>	 <49C8A415.1090606@cosmosbay.com>	 <OF9168DCC3.5E31F8E4-ONC1257583.003B48CC-C1257583.003C0A5E@transmode.se>	 <49C8CCF4.5050104@cosmosbay.com> <1237907850.12351.80.camel@sakura.staff.proxad.net> <49C8FBCA.40402@cosmosbay.com> <49CA6F9A.9010806@cosmosbay.com> <49CA7255.20807@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: mbizon@freebox.fr, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	Joakim Tjernlund <Joakim.Tjernlund@transmode.se>,
	avorontsov@ru.mvista.com, netdev@vger.kernel.org,
	Netfilter Developers <netfilter-devel@vger.kernel.org>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:55372 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753507AbZCYSTS convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Mar 2009 14:19:18 -0400
In-Reply-To: <49CA7255.20807@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Patrick McHardy a =E9crit :
> Eric Dumazet wrote:
>> Hi Patrick
>>
>> Here is the patch I had the time to test this time...
>> No problem so far on my machine.
>> I did a UDP flood stress.
>=20
> Thanks Eric. Most parts looks good, just two questions below:
>=20
>> diff --git a/net/ipv4/netfilter/nf_conntrack_l3proto_ipv4_compat.c
>> b/net/ipv4/netfilter/nf_conntrack_l3proto_ipv4_compat.c
>> index 6ba5c55..fcbcf62 100644
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
>=20
> Don't we need to make sure the entry is not reused while dumping
> it?
>=20

Ah yes, I forgot that for UDP/TCP I had to change locking on this part.
Because messing with reference count was crazy...
But in UDP/TCP we have different spinlock for each chain, so hold time
was small enough.

So I guess that with central conntrack lock, we need to take references=
 on entries
while dumping them.

