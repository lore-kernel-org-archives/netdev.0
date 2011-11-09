From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [REPOST patch net-next V6] net: introduce ethernet teaming
 device
Date: Thu, 10 Nov 2011 00:53:09 +0100
Message-ID: <1320882789.5825.10.camel@edumazet-laptop>
References: <1320876793-1158-1-git-send-email-jpirko@redhat.com>
	 <1320880355.5825.1.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	bhutchings@solarflare.com, shemminger@vyatta.com, fubar@us.ibm.com,
	andy@greyhouse.net, tgraf@infradead.org, ebiederm@xmission.com,
	mirqus@gmail.com, kaber@trash.net, greearb@candelatech.com,
	jesse@nicira.com, fbl@redhat.com, benjamin.poirier@gmail.com,
	jzupka@redhat.com, ivecera@redhat.com
To: Jiri Pirko <jpirko@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:44810 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753979Ab1KIXxW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Nov 2011 18:53:22 -0500
Received: by wyh15 with SMTP id 15so2167662wyh.19
        for <netdev@vger.kernel.org>; Wed, 09 Nov 2011 15:53:21 -0800 (PST)
In-Reply-To: <1320880355.5825.1.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le jeudi 10 novembre 2011 =C3=A0 00:12 +0100, Eric Dumazet a =C3=A9crit=
 :
> Le mercredi 09 novembre 2011 =C3=A0 23:13 +0100, Jiri Pirko a =C3=A9c=
rit :
> > This patch introduces new network device called team. It supposes t=
o be
> > very fast, simple, userspace-driven alternative to existing bonding
> > driver.
>=20
> ...
>=20
> > +/*
> > + * note: already called with rcu_read_lock
> > + */
> > +static netdev_tx_t team_xmit(struct sk_buff *skb, struct net_devic=
e *dev)
> > +{
> > +	struct team *team =3D netdev_priv(dev);
> > +	bool tx_success =3D false;
> > +	unsigned int len =3D skb->len;
> > +
> > +	/*
> > +	 * Ensure transmit function is called only in case there is at le=
ast
> > +	 * one port present.
> > +	 */
> > +	if (likely(!list_empty(&team->port_list) && team->mode_ops.transm=
it))
> > +		tx_success =3D team->mode_ops.transmit(team, skb);

Not clear why its so complex here.

When you manipulate team->port_list and make it empty, why dont you set
team->mode_ops.transmit to a helper function, freeing the skb and
returning false.

Also, instead of setting .transmit to NULL, you also could set it to
same helper function.

This way you could just do in fast path :

	tx_succcess =3D team->mode_ops.transmit(team, skb);

Avoiding two tests

> > +	if (tx_success) {
> > +		struct team_pcpu_stats *pcpu_stats;
> > +
> > +		pcpu_stats =3D this_cpu_ptr(team->pcpu_stats);
> > +		u64_stats_update_begin(&pcpu_stats->syncp);
> > +		pcpu_stats->tx_packets++;
> > +		pcpu_stats->tx_bytes +=3D len;
> > +		u64_stats_update_end(&pcpu_stats->syncp);
> > +	} else {
> > +		this_cpu_inc(team->pcpu_stats->tx_dropped);
> > +	}
> > +
> > +	return NETDEV_TX_OK;
> > +}
> > +
>=20
