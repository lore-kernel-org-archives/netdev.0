From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH] net: allow netdev_wait_allrefs() to run faster
Date: Sat, 24 Oct 2009 13:22:38 -0700
Message-ID: <20091024132238.35069740@nehalam>
References: <20091017221857.GG1925@kvack.org>
	<4ADB55BC.5020107@gmail.com>
	<20091018182144.GC23395@kvack.org>
	<200910211539.01824.opurdila@ixiacom.com>
	<4ADF2B57.4030708@gmail.com>
	<20091023211338.GA6145@linux.vnet.ibm.com>
	<4AE28429.6040608@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: paulmck@linux.vnet.ibm.com,
	Octavian Purdila <opurdila@ixiacom.com>,
	Benjamin LaHaise <bcrl@lhnet.ca>, netdev@vger.kernel.org,
	Cosmin Ratiu <cratiu@ixiacom.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:55492 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751864AbZJXUWj convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 24 Oct 2009 16:22:39 -0400
In-Reply-To: <4AE28429.6040608@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 24 Oct 2009 06:35:53 +0200
Eric Dumazet <eric.dumazet@gmail.com> wrote:

> Paul E. McKenney a =C3=A9crit :
> > On Wed, Oct 21, 2009 at 05:40:07PM +0200, Eric Dumazet wrote:
> >> [PATCH] net: allow netdev_wait_allrefs() to run faster
> >>
> >> netdev_wait_allrefs() waits that all references to a device vanish=
es.
> >>
> >> It currently uses a _very_ pessimistic 250 ms delay between each p=
robe.
> >> Some users report that no more than 4 devices can be dismantled pe=
r second,
> >> this is a pretty serious problem for extreme setups.
> >>
> >> Most likely, references only wait for a rcu grace period that shou=
ld come
> >> fast, so use a schedule_timeout_uninterruptible(1) to allow faster=
 recovery.
> >=20
> > Is this a place where synchronize_rcu_expedited() is appropriate?
> > (It went in to 2.6.32-rc1.)
> >=20
>=20
> Thanks for the tip Paul
>=20
> I believe netdev_wait_allrefs() is not a perfect candidate, because=20
> synchronize_sched_expedited() seems really expensive.
>=20
> Maybe we could call it once only, if we had to call 1 times
> the jiffie delay ?
>=20
> diff --git a/net/core/dev.c b/net/core/dev.c
> index fa88dcd..9b04b9a 100644
> --- a/net/core/dev.c
> +++ b/net/core/dev.c
> @@ -4970,6 +4970,7 @@ EXPORT_SYMBOL(register_netdev);
>  static void netdev_wait_allrefs(struct net_device *dev)
>  {
>  	unsigned long rebroadcast_time, warning_time;
> +	unsigned int count =3D 0;
> =20
>  	rebroadcast_time =3D warning_time =3D jiffies;
>  	while (atomic_read(&dev->refcnt) !=3D 0) {
> @@ -4995,7 +4996,10 @@ static void netdev_wait_allrefs(struct net_dev=
ice *dev)
>  			rebroadcast_time =3D jiffies;
>  		}
> =20
> -		msleep(250);
> +		if (count++ =3D=3D 1)
> +			synchronize_rcu_expedited();
> +		else
> +			schedule_timeout_uninterruptible(1);
> =20
>  		if (time_after(jiffies, warning_time + 10 * HZ)) {
>  			printk(KERN_EMERG "unregister_netdevice: "

Actually, anything that requires more than one pass through the loop is
broken. Devices and protocols should be cleaning up on the first notifi=
er.
The worst offender seems to be the dst cache gc code.


--=20
