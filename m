From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [RFT 3/4] Use mod_timer_noact to remove nf_conntrack_lock
Date: Wed, 18 Feb 2009 15:01:19 +0100
Message-ID: <499C14AF.60704@cosmosbay.com>
References: <20090218051906.174295181@vyatta.com> <20090218052747.555811553@vyatta.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	Patrick McHardy <kaber@trash.net>,
	Rick Jones <rick.jones2@hp.com>, netdev@vger.kernel.org,
	tglx@linutronix.de, netfilter-devel@vger.kernel.org,
	Martin Josefsson <gandalf@wlug.westbo.se>
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:36266 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751793AbZBROBd convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Feb 2009 09:01:33 -0500
In-Reply-To: <20090218052747.555811553@vyatta.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Stephen Hemminger a =E9crit :
> Now that we are using mod_timer_noact() for timer updates there's no =
need to
> hold the global lock during the timer update since the actual timeout=
 update
> is now protected by the timer locking.
>=20
> Signed-off-by: Martin Josefsson <gandalf@wlug.westbo.se>
>=20
> ---
>  net/netfilter/nf_conntrack_core.c |    9 ++++-----
>  1 file changed, 4 insertions(+), 5 deletions(-)
>=20
> --- a/net/netfilter/nf_conntrack_core.c	2009-02-17 10:55:33.370882059=
 -0800
> +++ b/net/netfilter/nf_conntrack_core.c	2009-02-17 13:48:25.080060712=
 -0800
> @@ -793,13 +793,12 @@ void __nf_ct_refresh_acct(struct nf_conn
>  	NF_CT_ASSERT(ct->timeout.data =3D=3D (unsigned long)ct);
>  	NF_CT_ASSERT(skb);
> =20
> -	spin_lock_bh(&nf_conntrack_lock);
> -
>  	/* Only update if this is not a fixed timeout */
>  	if (test_bit(IPS_FIXED_TIMEOUT_BIT, &ct->status))
>  		goto acct;
> =20
> -	/* If not in hash table, timer will not be active yet */
> +	/* If not in hash table, timer will not be active yet,
> +	   we are the only one able to see it. */
>  	if (!nf_ct_is_confirmed(ct)) {
>  		ct->timeout.expires =3D extra_jiffies;
>  		event =3D IPCT_REFRESH;
> @@ -821,16 +820,16 @@ acct:
>  	if (do_acct) {
>  		struct nf_conn_counter *acct;
> =20
> +		spin_lock_bh(&nf_conntrack_lock);
>  		acct =3D nf_conn_acct_find(ct);
>  		if (acct) {
>  			acct[CTINFO2DIR(ctinfo)].packets++;
>  			acct[CTINFO2DIR(ctinfo)].bytes +=3D
>  				skb->len - skb_network_offset(skb);
>  		}
> +		spin_unlock_bh(&nf_conntrack_lock);
>  	}
> =20
> -	spin_unlock_bh(&nf_conntrack_lock);
> -
>  	/* must be unlocked when calling event cache */
>  	if (event)
>  		nf_conntrack_event_cache(event, ct);
>=20

Unfortunatly, this patch changes nothing, as most of the time, do_acct =
is true.

We also need to fine lock the accounting part as well.

	spin_lock_bh(&ct->some_lock);
	acct =3D nf_conn_acct_find(ct);
	if (acct) {
		acct[CTINFO2DIR(ctinfo)].packets++;
		acct[CTINFO2DIR(ctinfo)].bytes +=3D
			skb->len - skb_network_offset(skb);
	}
	spin_unlock_bh(&ct->some_lock);

