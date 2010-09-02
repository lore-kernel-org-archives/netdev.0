From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] bonding: Fix jiffies overflow problems (again)
Date: Thu, 02 Sep 2010 16:36:26 +0200
Message-ID: <1283438186.2454.856.camel@edumazet-laptop>
References: <201009021619.46206.jdelvare@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jay Vosburgh <fubar@us.ibm.com>,
	bonding-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	Jiri Bohac <jbohac@suse.cz>
To: Jean Delvare <jdelvare@suse.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f46.google.com ([209.85.215.46]:42576 "EHLO
	mail-ew0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753913Ab0IBOgc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Sep 2010 10:36:32 -0400
Received: by ewy23 with SMTP id 23so291259ewy.19
        for <netdev@vger.kernel.org>; Thu, 02 Sep 2010 07:36:30 -0700 (PDT)
In-Reply-To: <201009021619.46206.jdelvare@suse.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le jeudi 02 septembre 2010 =C3=A0 16:19 +0200, Jean Delvare a =C3=A9cri=
t :
> From: Jiri Bohac <jbohac@suse.cz>
>=20
> The time_before_eq()/time_after_eq() functions operate on unsigned
> long and only work if the difference between the two compared values
> is smaller than half the range of unsigned long (31 bits on i386).
>=20
> Some of the variables (slave->jiffies, dev->trans_start, dev->last_rx=
)
> used by bonding store a copy of jiffies and may not be updated for a
> long time. With HZ=3D1000, time_before_eq()/time_after_eq() will star=
t
> giving bad results after ~25 days.
>=20
> jiffies will never be before slave->jiffies, dev->trans_start,
> dev->last_rx by more than possibly a couple ticks caused by preemptio=
n
> of this code. This allows us to detect/prevent these overflows by
> replacing time_before_eq()/time_after_eq() with time_in_range().
>=20
> Signed-off-by: Jiri Bohac <jbohac@suse.cz>
> Signed-off-by: Jean Delvare <jdelvare@suse.de>
> ---
>  drivers/net/bonding/bond_main.c |   48 +++++++++++++++++++++++++++--=
-----------
>  1 file changed, 33 insertions(+), 15 deletions(-)
>=20
> --- a/drivers/net/bonding/bond_main.c
> +++ b/drivers/net/bonding/bond_main.c
> @@ -2798,8 +2798,12 @@ void bond_loadbalance_arp_mon(struct wor
>  	 */
>  	bond_for_each_slave(bond, slave, i) {
>  		if (slave->link !=3D BOND_LINK_UP) {
> -			if (time_before_eq(jiffies, dev_trans_start(slave->dev) + delta_i=
n_ticks) &&
> -			    time_before_eq(jiffies, slave->dev->last_rx + delta_in_ticks)=
) {
> +			if (time_in_range(jiffies,
> +				dev_trans_start(slave->dev) - delta_in_ticks,
> +				dev_trans_start(slave->dev) + delta_in_ticks) &&

since dev_trans_start() might be expensive, you probably should cache
its result.


> +			    time_in_range(jiffies,
> +				slave->dev->last_rx - delta_in_ticks,
> +				slave->dev->last_rx + delta_in_ticks)) {
> =20
>  				slave->link  =3D BOND_LINK_UP;
>  				slave->state =3D BOND_STATE_ACTIVE;
> @@ -2827,8 +2831,12 @@ void bond_loadbalance_arp_mon(struct wor
>  			 * when the source ip is 0, so don't take the link down
>  			 * if we don't know our ip yet
>  			 */
> -			if (time_after_eq(jiffies, dev_trans_start(slave->dev) + 2*delta_=
in_ticks) ||
> -			    (time_after_eq(jiffies, slave->dev->last_rx + 2*delta_in_tick=
s))) {
> +			if (!time_in_range(jiffies,
> +				dev_trans_start(slave->dev) - delta_in_ticks,
> +				dev_trans_start(slave->dev) + 2*delta_in_ticks) ||
> +			    (!time_in_range(jiffies,
> +				slave->dev->last_rx - delta_in_ticks,
> +				slave->dev->last_rx + 2*delta_in_ticks))) {
> =20
>  				slave->link  =3D BOND_LINK_DOWN;
>  				slave->state =3D BOND_STATE_BACKUP;
> @@ -2888,8 +2896,10 @@ static int bond_ab_arp_inspect(struct bo
>  		slave->new_link =3D BOND_LINK_NOCHANGE;
> =20
>  		if (slave->link !=3D BOND_LINK_UP) {
> -			if (time_before_eq(jiffies, slave_last_rx(bond, slave) +
> -					   delta_in_ticks)) {
> +			if (time_in_range(jiffies,
> +				slave_last_rx(bond, slave) - delta_in_ticks,
> +				slave_last_rx(bond, slave) + delta_in_ticks)) {
> +
>  				slave->new_link =3D BOND_LINK_UP;
>  				commit++;
>  			}
> @@ -2902,8 +2912,9 @@ static int bond_ab_arp_inspect(struct bo
>  		 * active.  This avoids bouncing, as the last receive
>  		 * times need a full ARP monitor cycle to be updated.
>  		 */
> -		if (!time_after_eq(jiffies, slave->jiffies +
> -				   2 * delta_in_ticks))
> +		if (time_in_range(jiffies,
> +				  slave->jiffies - delta_in_ticks,
> +				  slave->jiffies + 2 * delta_in_ticks))
>  			continue;
> =20
>  		/*
> @@ -2921,8 +2932,10 @@ static int bond_ab_arp_inspect(struct bo
>  		 */
>  		if (slave->state =3D=3D BOND_STATE_BACKUP &&
>  		    !bond->current_arp_slave &&
> -		    time_after(jiffies, slave_last_rx(bond, slave) +
> -			       3 * delta_in_ticks)) {
> +		    !time_in_range(jiffies,
> +			slave_last_rx(bond, slave) - delta_in_ticks,
> +			slave_last_rx(bond, slave) + 3 * delta_in_ticks)) {
> +
>  			slave->new_link =3D BOND_LINK_DOWN;
>  			commit++;
>  		}
> @@ -2934,10 +2947,13 @@ static int bond_ab_arp_inspect(struct bo
>  		 *    the bond has an IP address)
>  		 */
>  		if ((slave->state =3D=3D BOND_STATE_ACTIVE) &&
> -		    (time_after_eq(jiffies, dev_trans_start(slave->dev) +
> -				    2 * delta_in_ticks) ||
> -		      (time_after_eq(jiffies, slave_last_rx(bond, slave)
> -				     + 2 * delta_in_ticks)))) {
> +		    (!time_in_range(jiffies,
> +			dev_trans_start(slave->dev) - delta_in_ticks,
> +			dev_trans_start(slave->dev) + 2 * delta_in_ticks) ||
> +		     (!time_in_range(jiffies,
> +			slave_last_rx(bond, slave) - delta_in_ticks,
> +			slave_last_rx(bond, slave) + 2 * delta_in_ticks)))) {
> +
>  			slave->new_link =3D BOND_LINK_DOWN;
>  			commit++;
>  		}
> @@ -2964,7 +2980,9 @@ static void bond_ab_arp_commit(struct bo
> =20
>  		case BOND_LINK_UP:
>  			if ((!bond->curr_active_slave &&
> -			     time_before_eq(jiffies,
> +			     time_in_range(jiffies,
> +					    dev_trans_start(slave->dev) -
> +					    delta_in_ticks,
>  					    dev_trans_start(slave->dev) +
>  					    delta_in_ticks)) ||
>  			    bond->curr_active_slave !=3D slave) {
>=20


