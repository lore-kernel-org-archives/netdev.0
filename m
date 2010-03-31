From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [net-2.6 PATCH] bonding: fix broken multicast with round-robin
 mode
Date: Wed, 31 Mar 2010 11:08:37 +0200
Message-ID: <1270026517.2103.9.camel@edumazet-laptop>
References: <20100325214033.GA28741@gospo.rdu.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, lhh@redhat.com, fubar@us.ibm.com,
	bonding-devel@lists.sourceforge.net
To: Andy Gospodarek <andy@greyhouse.net>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f209.google.com ([209.85.218.209]:52724 "EHLO
	mail-bw0-f209.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932919Ab0CaJIk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 31 Mar 2010 05:08:40 -0400
Received: by bwz1 with SMTP id 1so5018642bwz.21
        for <netdev@vger.kernel.org>; Wed, 31 Mar 2010 02:08:39 -0700 (PDT)
In-Reply-To: <20100325214033.GA28741@gospo.rdu.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le jeudi 25 mars 2010 =C3=A0 17:40 -0400, Andy Gospodarek a =C3=A9crit =
:
> Round-robin (mode 0) does nothing to ensure that any multicast traffi=
c
> originally destined for the host will continue to arrive at the host =
when
> the link that sent the IGMP join or membership report goes down.  One=
 of
> the benefits of absolute round-robin transmit.
>=20
> Keeping track of subscribed multicast groups for each slave did not s=
eem
> like a good use of resources, so I decided to simply send on the
> curr_active slave of the bond (typically the first enslaved device th=
at
> is up).  This makes failover management simple as IGMP membership
> reports only need to be sent when the curr_active_slave changes.  I
> tested this patch and it appears to work as expected.
>=20
> Originally reported by Lon Hohberger <lhh@redhat.com>.
>=20
> Signed-off-by: Andy Gospodarek <andy@greyhouse.net>
> CC: Lon Hohberger <lhh@redhat.com>
> CC: Jay Vosburgh <fubar@us.ibm.com>
>=20
> ---
>  drivers/net/bonding/bond_main.c |   34 ++++++++++++++++++++++++++---=
-----
>  1 files changed, 26 insertions(+), 8 deletions(-)
>=20
> diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bo=
nd_main.c
> index 430c022..0b38455 100644
> --- a/drivers/net/bonding/bond_main.c
> +++ b/drivers/net/bonding/bond_main.c
> @@ -1235,6 +1235,11 @@ void bond_change_active_slave(struct bonding *=
bond, struct slave *new_active)
>  			write_lock_bh(&bond->curr_slave_lock);
>  		}
>  	}
> +
> +	/* resend IGMP joins since all were sent on curr_active_slave */
> +	if (bond->params.mode =3D=3D BOND_MODE_ROUNDROBIN) {
> +		bond_resend_igmp_join_requests(bond);
> +	}
>  }
> =20
>  /**
> @@ -4138,22 +4143,35 @@ static int bond_xmit_roundrobin(struct sk_buf=
f *skb, struct net_device *bond_dev
>  	struct bonding *bond =3D netdev_priv(bond_dev);
>  	struct slave *slave, *start_at;
>  	int i, slave_no, res =3D 1;
> +	struct iphdr *iph =3D ip_hdr(skb);
> =20
>  	read_lock(&bond->lock);
> =20
>  	if (!BOND_IS_OK(bond))
>  		goto out;
> -
>  	/*
> -	 * Concurrent TX may collide on rr_tx_counter; we accept that
> -	 * as being rare enough not to justify using an atomic op here
> +	 * Start with the curr_active_slave that joined the bond as the
> +	 * default for sending IGMP traffic.  For failover purposes one
> +	 * needs to maintain some consistency for the interface that will
> +	 * send the join/membership reports.  The curr_active_slave found
> +	 * will send all of this type of traffic.
>  	 */
> -	slave_no =3D bond->rr_tx_counter++ % bond->slave_cnt;
> +	if ((skb->protocol =3D=3D htons(ETH_P_IP)) &&
> +	    (iph->protocol =3D=3D htons(IPPROTO_IGMP))) {

Hmm...

iph->protocol is a u8, how can htons(IPPROTO_IGMP) be equal to
iph->protocol ?

[PATCH] bonding: bond_xmit_roundrobin() fix

Commit a2fd940f (bonding: fix broken multicast with round-robin mode)
added a problem on litle endian machines.

drivers/net/bonding/bond_main.c:4159: warning: comparison is always
false due to limited range of data type

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond=
_main.c
index 5b92fbf..5972a52 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -4156,7 +4156,7 @@ static int bond_xmit_roundrobin(struct sk_buff *s=
kb, struct net_device *bond_dev
 	 * send the join/membership reports.  The curr_active_slave found
 	 * will send all of this type of traffic.
 	 */
-	if ((iph->protocol =3D=3D htons(IPPROTO_IGMP)) &&
+	if ((iph->protocol =3D=3D IPPROTO_IGMP) &&
 	    (skb->protocol =3D=3D htons(ETH_P_IP))) {
=20
 		read_lock(&bond->curr_slave_lock);



