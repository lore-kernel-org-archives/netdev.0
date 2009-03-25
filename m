From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [PATCH] conntrack: Reduce conntrack count in nf_conntrack_free()
Date: Wed, 25 Mar 2009 14:44:34 +0100
Message-ID: <49CA3542.5020601@cosmosbay.com>
References: <OF1FEA88FD.D6B88765-ONC1257582.003A487F-C1257582.003ACE3A@transmode.se> <49C77D71.8090709@trash.net> <OF8A05682D.BA831A09-ONC1257582.0043892E-C1257582.004440BD@transmode.se> <49C780AD.70704@trash.net> <OF20814141.D78C9170-ONC1257582.0060B64A-C1257582.00614FDC@transmode.se> <49C7CB9B.1040409@trash.net> <OFBD3D31D8.7AD81126-ONC1257583.002C5C2B-C1257583.002DFF13@transmode.se> <49C8A415.1090606@cosmosbay.com> <OF9168DCC3.5E31F8E4-ONC1257583.003B48CC-C1257583.003C0A5E@transmode.se> <49C8CCF4.5050104@cosmosbay.com> <49C8D13D.10307@cosmosbay.com> <49C8D58A.6060401@trash.net> <49C8E0D3.1010202@cosmosbay.com> <49C8E268.6090507@trash.net> <49C8E48D.2070501@cosmosbay.com> <49C8F871.9070600@cosmosbay.com> <49C8F8E0.9050502@trash.net> <49C9AAAC.30607@cosmosbay.com> <49CA3404.3090609@trash.
 net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Netfilter Developers <netfilter-devel@vger.kernel.org>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:45876 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759553AbZCYNoh convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Mar 2009 09:44:37 -0400
In-Reply-To: <49CA3404.3090609@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Patrick McHardy a =E9crit :
> Eric Dumazet wrote:
>> I have a litle problem on __nf_conntrack_find() being exported.
>>
>> Problem is that with SLAB_DESTROY_BY_RCU we must take a reference on
>> object
>> to recheck it. So ideally  only nf_conntrack_find_get() should be us=
ed,
>> or callers of __nf_conntrack_find() should lock nf_conntrack_lock
>> (as properly done for example in net/netfilter/nf_conntrack_netlink.=
c,
>> line 1292)
>>
>> Here is preliminary patch for review (not tested at all, its 4h50 am
>> here :) )
>>
>> Could you help me, by checking __nf_conntrack_find() use in
>> net/netfilter/xt_connlimit.c ?
>> and line 1246 of net/netfilter/nf_conntrack_netlink.c
>>
>> This part is a litle bit gray for me. :)
>=20
> In case of xt_connlimit, it seems fine to just take a reference.
> In case of ctnetlink, keeping the unreferenced lookup under the
> lock seems fine. We unfortunately have to export some internals
> like nf_conntrack lock for ctnetlink anyways, so I don't think
> it would be worth to change it to take references and unexport
> the lookup function.
>=20
>> +/*
>> + * Warning :
>> + * - Caller must take a reference on returned object
>> + *   and recheck nf_ct_tuple_equal(tuple, &h->tuple)
>> + * OR
>> + * - Caller must lock nf_conntrack_lock before calling this functio=
n
>> + */
>>  struct nf_conntrack_tuple_hash *
>>  __nf_conntrack_find(struct net *net, const struct nf_conntrack_tupl=
e
>> *tuple)
>>  {
>>      struct nf_conntrack_tuple_hash *h;
>> -    struct hlist_node *n;
>> +    struct hlist_nulls_node *n;
>>      unsigned int hash =3D hash_conntrack(tuple);
>> =20
>>      /* Disable BHs the entire time since we normally need to disabl=
e
>> them
>>       * at least once for the stats anyway.
>>       */
>>      local_bh_disable();
>> -    hlist_for_each_entry_rcu(h, n, &net->ct.hash[hash], hnode) {
>> +begin:
>> +    hlist_nulls_for_each_entry_rcu(h, n, &net->ct.hash[hash], hnnod=
e) {
>>          if (nf_ct_tuple_equal(tuple, &h->tuple)) {
>>              NF_CT_STAT_INC(net, found);
>>              local_bh_enable();
>> @@ -261,6 +270,13 @@ __nf_conntrack_find(struct net *net, const stru=
ct
>> nf_conntrack_tuple *tuple)
>>          }
>>          NF_CT_STAT_INC(net, searched);
>>      }
>> +    /*
>> +     * if the nulls value we got at the end of this lookup is
>> +     * not the expected one, we must restart lookup.
>> +     * We probably met an item that was moved to another chain.
>> +     */
>> +    if (get_nulls_value(n) !=3D hash)
>> +        goto begin;
>=20
> Are you sure this is enough? An entry might have been reused and adde=
d
> to the same chain I think, so I think we need to recheck the tuple.

Yes, done in caller

>=20
>>      local_bh_enable();
>> =20
>>      return NULL;
>> @@ -275,11 +291,18 @@ nf_conntrack_find_get(struct net *net, const
>> struct nf_conntrack_tuple *tuple)
>>      struct nf_conn *ct;
>> =20
>>      rcu_read_lock();
>> +begin:
>>      h =3D __nf_conntrack_find(net, tuple);
>>      if (h) {
>>          ct =3D nf_ct_tuplehash_to_ctrack(h);
>>          if (unlikely(!atomic_inc_not_zero(&ct->ct_general.use)))
>>              h =3D NULL;
>> +        else {
>> +            if (unlikely(!nf_ct_tuple_equal(tuple, &h->tuple))) {
>> +                nf_ct_put(ct);
>> +                goto begin;
>=20
> Ah I see, the hash comparison above is only an optimization?
>=20
>> +            }
>> +        }
>>      }
>>      rcu_read_unlock();
>> =20
>=20
>=20

check net/ipv4/udp.c for an example (__udp4_lib_lookup())

In case of UDP, key check is not returning true/false, but a score.
So UDP case is a litle bit more complex than conntrack case.


        rcu_read_lock();
begin:
        result =3D NULL;
        badness =3D -1;
        sk_nulls_for_each_rcu(sk, node, &hslot->head) {
                score =3D compute_score(sk, net, saddr, hnum, sport,
                                      daddr, dport, dif);
                if (score > badness) {
                        result =3D sk;
                        badness =3D score;
                }
        }
        /*
         * if the nulls value we got at the end of this lookup is
         * not the expected one, we must restart lookup.
         * We probably met an item that was moved to another chain.
         */
        if (get_nulls_value(node) !=3D hash)
                goto begin;

        if (result) {
                if (unlikely(!atomic_inc_not_zero(&result->sk_refcnt)))
                        result =3D NULL;
                else if (unlikely(compute_score(result, net, saddr, hnu=
m, sport,
                                  daddr, dport, dif) < badness)) {
                        sock_put(result);
                        goto begin;
                }
        }
        rcu_read_unlock();
        return result;


