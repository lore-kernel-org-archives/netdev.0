From: Changli Gao <xiaosuo@gmail.com>
Subject: Re: DDoS attack causing bad effect on conntrack searches
Date: Tue, 1 Jun 2010 08:28:53 +0800
Message-ID: <AANLkTikw3uonDB4nPXg8FVFN_07F_wq0SA_ayyAHL6VM@mail.gmail.com>
References: <1271941082.14501.189.camel@jdb-workstation> <q2h412e6f7f1004220613m488c2ee4r6d24a8d1e65997d4@mail.gmail.com>
	<4BD04C74.9020402@trash.net> <1271946961.7895.5665.camel@edumazet-laptop>
	<1271948029.7895.5707.camel@edumazet-laptop> <20100422155123.GA2524@linux.vnet.ibm.com>
	<1271952128.7895.5851.camel@edumazet-laptop> <Pine.LNX.4.64.1004222213290.10919@ask.diku.dk>
	<1272056237.4599.7.camel@edumazet-laptop> <Pine.LNX.4.64.1004241219280.32071@ask.diku.dk>
	<1272139861.20714.525.camel@edumazet-laptop> <1272292568.13192.43.camel@jdb-workstation>
	<1275340896.2478.26.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: hawk@comx.dk, Jesper Dangaard Brouer <hawk@diku.dk>,
	paulmck@linux.vnet.ibm.com, Patrick McHardy <kaber@trash.net>,
	Linux Kernel Network Hackers <netdev@vger.kernel.org>,
	Netfilter Developers <netfilter-devel@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pz0-f185.google.com ([209.85.222.185]:45467 "EHLO
	mail-pz0-f185.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751049Ab0FAA3O convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 31 May 2010 20:29:14 -0400
In-Reply-To: <1275340896.2478.26.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jun 1, 2010 at 5:21 AM, Eric Dumazet <eric.dumazet@gmail.com> w=
rote:
>
> I had a look at current conntrack and found the 'unconfirmed' list wa=
s
> maybe a candidate for a potential blackhole.
>
> That is, if a reader happens to hit an entry that is moved from regul=
ar
> hash table slot 'hash' to unconfirmed list,

Sorry, but I can't find where we do this things. unconfirmed list is
used to track the unconfirmed cts, whose corresponding skbs are still
in path from the first to the last netfilter hooks. As soon as the
skbs end their travel in netfilter, the corresponding cts will be
confirmed(moving ct from unconfirmed list to regular hash table).

unconfirmed list should be small, as networking receiving is in BH.
How about implementing unconfirmed list as a per cpu variable?

> reader might scan whole
> unconfirmed list to find out he is not anymore on the wanted hash cha=
in.
>
> Problem is this unconfirmed list might be very very long in case of
> DDOS. It's really not designed to be scanned during a lookup.
>
> So I guess we should stop early if we find an unconfirmed entry ?
>
>
>
> diff --git a/include/net/netfilter/nf_conntrack.h b/include/net/netfi=
lter/nf_conntrack.h
> index bde095f..0573641 100644
> --- a/include/net/netfilter/nf_conntrack.h
> +++ b/include/net/netfilter/nf_conntrack.h
> @@ -298,8 +298,10 @@ extern int nf_conntrack_set_hashsize(const char =
*val, struct kernel_param *kp);
> =C2=A0extern unsigned int nf_conntrack_htable_size;
> =C2=A0extern unsigned int nf_conntrack_max;
>
> -#define NF_CT_STAT_INC(net, count) =C2=A0 =C2=A0 \
> +#define NF_CT_STAT_INC(net, count) =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 \
> =C2=A0 =C2=A0 =C2=A0 =C2=A0__this_cpu_inc((net)->ct.stat->count)
> +#define NF_CT_STAT_ADD(net, count, value) =C2=A0 =C2=A0 =C2=A0\
> + =C2=A0 =C2=A0 =C2=A0 __this_cpu_add((net)->ct.stat->count, value)
> =C2=A0#define NF_CT_STAT_INC_ATOMIC(net, count) =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0\
> =C2=A0do { =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 \
> =C2=A0 =C2=A0 =C2=A0 =C2=A0local_bh_disable(); =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 \
> diff --git a/net/netfilter/nf_conntrack_core.c b/net/netfilter/nf_con=
ntrack_core.c
> index eeeb8bc..e96d999 100644
> --- a/net/netfilter/nf_conntrack_core.c
> +++ b/net/netfilter/nf_conntrack_core.c
> @@ -299,6 +299,7 @@ __nf_conntrack_find(struct net *net, u16 zone,
> =C2=A0 =C2=A0 =C2=A0 =C2=A0struct nf_conntrack_tuple_hash *h;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0struct hlist_nulls_node *n;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0unsigned int hash =3D hash_conntrack(net, =
zone, tuple);
> + =C2=A0 =C2=A0 =C2=A0 unsigned int cnt =3D 0;
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0/* Disable BHs the entire time since we no=
rmally need to disable them
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 * at least once for the stats anyway.
> @@ -309,10 +310,19 @@ begin:
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0if (nf_ct_tupl=
e_equal(tuple, &h->tuple) &&
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
nf_ct_zone(nf_ct_tuplehash_to_ctrack(h)) =3D=3D zone) {
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0NF_CT_STAT_INC(net, found);
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 NF_CT_STAT_ADD(net, searched, cnt);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0local_bh_enable();
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0return h;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0}
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 NF_CT_STAT_INC(net=
, searched);
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 /*
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0* If we find=
 an unconfirmed entry, restart the lookup to
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0* avoid scan=
ning whole unconfirmed list
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0*/
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 if (unlikely(++cnt=
 > 8 &&
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0!nf_ct_is_confirmed(nf_ct_tuplehash_to_ctra=
ck(h)))) {
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 NF_CT_STAT_INC(net, search_restart);
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 goto begin;
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 }
> =C2=A0 =C2=A0 =C2=A0 =C2=A0}
> =C2=A0 =C2=A0 =C2=A0 =C2=A0/*
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 * if the nulls value we got at the end of=
 this lookup is
> @@ -323,6 +333,7 @@ begin:
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0NF_CT_STAT_INC=
(net, search_restart);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0goto begin;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0}
> + =C2=A0 =C2=A0 =C2=A0 NF_CT_STAT_ADD(net, searched, cnt);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0local_bh_enable();
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0return NULL;
>
>
>



--=20
Regards=EF=BC=8C
Changli Gao(xiaosuo@gmail.com)
