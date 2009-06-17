From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [bug] __nf_ct_refresh_acct(): WARNING: at lib/list_debug.c:30
 __list_add+0x7d/0xad()
Date: Wed, 17 Jun 2009 13:55:42 +0200
Message-ID: <4A38D9BE.3020403@gmail.com>
References: <20090615.050449.144947903.davem@davemloft.net> <20090616091538.GA4184@elte.hu> <20090616.034752.226811527.davem@davemloft.net> <20090616105304.GA3579@elte.hu> <20090616122415.GA16630@elte.hu> <20090617092152.GA17449@elte.hu> <4A38C2F3.3000009@gmail.com> <4A38D5BD.2040502@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Ingo Molnar <mingo@elte.hu>, David Miller <davem@davemloft.net>,
	Thomas Gleixner <tglx@linutronix.de>,
	torvalds@linux-foundation.org, akpm@linux-foundation.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:39105 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1763385AbZFQL42 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Jun 2009 07:56:28 -0400
In-Reply-To: <4A38D5BD.2040502@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Patrick McHardy a =E9crit :
> Eric Dumazet wrote:
>> IPS_CONFIRMED_BIT is set under nf_conntrack_lock (in
>> __nf_conntrack_confirm()),
>> we probably want to add a synchronisation under ct->lock as well,
>> or __nf_ct_refresh_acct() could set ct->timeout.expires to extra_jif=
fies,
>> while a different cpu could confirm the conntrack.
>=20
> Before the conntrack is confirmed, it is exclusively handled by a
> single CPU. I agree that we need to make sure the IPS_CONFIRMED_BIT
> is visible before we add the conntrack to the hash table since the
> lookup is lockless, but simply moving the set_bit before the hash
> insertion should be fine I think.
>=20

Hmm...  now we could have the reverse case :

__nf_conntrack_confirm() could be "interrupted" by __nf_ct_refresh_acct=
()

index 5f72b94..22755fa 100644
--- a/net/netfilter/nf_conntrack_core.c
+++ b/net/netfilter/nf_conntrack_core.c
@@ -425,6 +425,7 @@ __nf_conntrack_confirm(struct sk_buff *skb)
 	/* Remove from unconfirmed list */
 	hlist_nulls_del_rcu(&ct->tuplehash[IP_CT_DIR_ORIGINAL].hnnode);
=20
+	set_bit(IPS_CONFIRMED_BIT, &ct->status);
 	__nf_conntrack_hash_insert(ct, hash, repl_hash);
 	/* Timer relative to confirmation time, not original
 	   setting time, otherwise we'd get timer wrap in
@@ -432,7 +433,6 @@ __nf_conntrack_confirm(struct sk_buff *skb)
 	ct->timeout.expires +=3D jiffies;

<< What happens if another packet is handled by __nf_ct_refresh_acct he=
re >>
(seeing or not the IPS_CONFIRMED_BIT) >>

 	add_timer(&ct->timeout);

<< or here ? >>


 	atomic_inc(&ct->ct_general.use);
-	set_bit(IPS_CONFIRMED_BIT, &ct->status);
 	NF_CT_STAT_INC(net, insert);
 	spin_unlock_bh(&nf_conntrack_lock);
 	help =3D nfct_help(ct);



Problem is timeout.expires is either a relative or absolute timeout, an=
d changes happen
in __nf_conntrack_confirm() or __nf_ct_refresh_acct().

We must have a synchronization (an barriers), a single bit wont be enou=
gh.

