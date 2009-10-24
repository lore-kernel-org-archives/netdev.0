From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [PATCH] net: allow netdev_wait_allrefs() to run faster
Date: Fri, 23 Oct 2009 22:49:43 -0700
Message-ID: <20091024054943.GA6638@linux.vnet.ibm.com>
References: <20091017221857.GG1925@kvack.org> <4ADB55BC.5020107@gmail.com> <20091018182144.GC23395@kvack.org> <200910211539.01824.opurdila@ixiacom.com> <4ADF2B57.4030708@gmail.com> <20091023211338.GA6145@linux.vnet.ibm.com> <4AE28429.6040608@gmail.com>
Reply-To: paulmck@linux.vnet.ibm.com
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Octavian Purdila <opurdila@ixiacom.com>,
	Benjamin LaHaise <bcrl@lhnet.ca>, netdev@vger.kernel.org,
	Cosmin Ratiu <cratiu@ixiacom.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e7.ny.us.ibm.com ([32.97.182.137]:50044 "EHLO e7.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751670AbZJXFtm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 24 Oct 2009 01:49:42 -0400
Received: from d01relay07.pok.ibm.com (d01relay07.pok.ibm.com [9.56.227.147])
	by e7.ny.us.ibm.com (8.14.3/8.13.1) with ESMTP id n9O5kVGL016547
	for <netdev@vger.kernel.org>; Sat, 24 Oct 2009 01:46:31 -0400
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay07.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id n9O5niSB1302618
	for <netdev@vger.kernel.org>; Sat, 24 Oct 2009 01:49:46 -0400
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.14.3/8.13.1/NCO v10.0 AVout) with ESMTP id n9O5niMZ004632
	for <netdev@vger.kernel.org>; Sat, 24 Oct 2009 01:49:44 -0400
Content-Disposition: inline
In-Reply-To: <4AE28429.6040608@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Oct 24, 2009 at 06:35:53AM +0200, Eric Dumazet wrote:
> Paul E. McKenney a =E9crit :
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
>=20
> Thanks for the tip Paul
>=20
> I believe netdev_wait_allrefs() is not a perfect candidate, because=20
> synchronize_sched_expedited() seems really expensive.

It does indeed keep the CPUs quite busy for a bit.  ;-)

> Maybe we could call it once only, if we had to call 1 times
> the jiffie delay ?

This could be a very useful approach!

However, please keep in mind that although synchronize_rcu_expedited()
forces a grace period, it does nothing to speed the invocation of other
RCU callbacks.  In short, synchronize_rcu_expedited() is a faster versi=
on
of synchronize_rcu(), but doesn't necessarily help other synchronize_rc=
u()
or call_rcu() invocations.

The reason I point this out is that it looks to me that the code below =
is
waiting for some other task which is in turn waiting on a grace period.
But I don't know this code, so could easily be confused.

						Thanx, paul

> diff --git a/net/core/dev.c b/net/core/dev.c
> index fa88dcd..9b04b9a 100644
> --- a/net/core/dev.c
> +++ b/net/core/dev.c
> @@ -4970,6 +4970,7 @@ EXPORT_SYMBOL(register_netdev);
>  static void netdev_wait_allrefs(struct net_device *dev)
>  {
>  	unsigned long rebroadcast_time, warning_time;
> +	unsigned int count =3D 0;
>=20
>  	rebroadcast_time =3D warning_time =3D jiffies;
>  	while (atomic_read(&dev->refcnt) !=3D 0) {
> @@ -4995,7 +4996,10 @@ static void netdev_wait_allrefs(struct net_dev=
ice *dev)
>  			rebroadcast_time =3D jiffies;
>  		}
>=20
> -		msleep(250);
> +		if (count++ =3D=3D 1)
> +			synchronize_rcu_expedited();
> +		else
> +			schedule_timeout_uninterruptible(1);
>=20
>  		if (time_after(jiffies, warning_time + 10 * HZ)) {
>  			printk(KERN_EMERG "unregister_netdevice: "
>=20
