From: Patrick McHardy <kaber@trash.net>
Subject: Re: [bug] __nf_ct_refresh_acct(): WARNING: at lib/list_debug.c:30
 __list_add+0x7d/0xad()
Date: Wed, 17 Jun 2009 14:00:04 +0200
Message-ID: <4A38DAC4.2050902@trash.net>
References: <20090615.050449.144947903.davem@davemloft.net> <20090616091538.GA4184@elte.hu> <20090616.034752.226811527.davem@davemloft.net> <20090616105304.GA3579@elte.hu> <20090616122415.GA16630@elte.hu> <20090617092152.GA17449@elte.hu> <4A38C2F3.3000009@gmail.com> <4A38D5BD.2040502@trash.net> <4A38D9BE.3020403@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Ingo Molnar <mingo@elte.hu>, David Miller <davem@davemloft.net>,
	Thomas Gleixner <tglx@linutronix.de>,
	torvalds@linux-foundation.org, akpm@linux-foundation.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1765489AbZFQMAY@vger.kernel.org>
In-Reply-To: <4A38D9BE.3020403@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Eric Dumazet wrote:
> Patrick McHardy a =E9crit :
>> Before the conntrack is confirmed, it is exclusively handled by a
>> single CPU. I agree that we need to make sure the IPS_CONFIRMED_BIT
>> is visible before we add the conntrack to the hash table since the
>> lookup is lockless, but simply moving the set_bit before the hash
>> insertion should be fine I think.
>>
>=20
> Hmm...  now we could have the reverse case :
>=20
> __nf_conntrack_confirm() could be "interrupted" by __nf_ct_refresh_ac=
ct()
>=20
> index 5f72b94..22755fa 100644
> --- a/net/netfilter/nf_conntrack_core.c
> +++ b/net/netfilter/nf_conntrack_core.c
> @@ -425,6 +425,7 @@ __nf_conntrack_confirm(struct sk_buff *skb)
>  	/* Remove from unconfirmed list */
>  	hlist_nulls_del_rcu(&ct->tuplehash[IP_CT_DIR_ORIGINAL].hnnode);
> =20
> +	set_bit(IPS_CONFIRMED_BIT, &ct->status);
>  	__nf_conntrack_hash_insert(ct, hash, repl_hash);
>  	/* Timer relative to confirmation time, not original
>  	   setting time, otherwise we'd get timer wrap in
> @@ -432,7 +433,6 @@ __nf_conntrack_confirm(struct sk_buff *skb)
>  	ct->timeout.expires +=3D jiffies;
>=20
> << What happens if another packet is handled by __nf_ct_refresh_acct =
here >>
> (seeing or not the IPS_CONFIRMED_BIT) >>
>=20
>  	add_timer(&ct->timeout);
>=20
> << or here ? >>
>=20
>=20
>  	atomic_inc(&ct->ct_general.use);
> -	set_bit(IPS_CONFIRMED_BIT, &ct->status);
>  	NF_CT_STAT_INC(net, insert);
>  	spin_unlock_bh(&nf_conntrack_lock);
>  	help =3D nfct_help(ct);
>=20
> Problem is timeout.expires is either a relative or absolute timeout, =
and changes happen
> in __nf_conntrack_confirm() or __nf_ct_refresh_acct().
>=20
> We must have a synchronization (an barriers), a single bit wont be en=
ough.

Please have a look at the second patch I just sent. It relies
on the RCU barriers to make sure all stores are visible before
other CPUs can find the conntrack.
