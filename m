From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [PATCH] net: allow netdev_wait_allrefs() to run faster
Date: Fri, 23 Oct 2009 14:13:38 -0700
Message-ID: <20091023211338.GA6145@linux.vnet.ibm.com>
References: <20091017221857.GG1925@kvack.org> <4ADB55BC.5020107@gmail.com> <20091018182144.GC23395@kvack.org> <200910211539.01824.opurdila@ixiacom.com> <4ADF2B57.4030708@gmail.com>
Reply-To: paulmck@linux.vnet.ibm.com
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Octavian Purdila <opurdila@ixiacom.com>,
	Benjamin LaHaise <bcrl@lhnet.ca>, netdev@vger.kernel.org,
	Cosmin Ratiu <cratiu@ixiacom.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e9.ny.us.ibm.com ([32.97.182.139]:51268 "EHLO e9.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751982AbZJWXkX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 23 Oct 2009 19:40:23 -0400
Received: from d01relay06.pok.ibm.com (d01relay06.pok.ibm.com [9.56.227.116])
	by e9.ny.us.ibm.com (8.14.3/8.13.1) with ESMTP id n9NNaJqE029223
	for <netdev@vger.kernel.org>; Fri, 23 Oct 2009 19:36:19 -0400
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay06.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id n9NNeRFx1056888
	for <netdev@vger.kernel.org>; Fri, 23 Oct 2009 19:40:27 -0400
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.14.3/8.13.1/NCO v10.0 AVout) with ESMTP id n9NNeQGl001427
	for <netdev@vger.kernel.org>; Fri, 23 Oct 2009 19:40:27 -0400
Content-Disposition: inline
In-Reply-To: <4ADF2B57.4030708@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Oct 21, 2009 at 05:40:07PM +0200, Eric Dumazet wrote:
> Octavian Purdila a =E9crit :
> > On Sunday 18 October 2009 21:21:44 you wrote:
> >>> The msleep(250) should be tuned first. Then if this is really nec=
essary
> >>> to dismantle 100.000 netdevices per second, we might have to thin=
k a bit
> >>> more.=20
> >>> Just try msleep(1 or 2), it should work quite well.
> >> My goal is tearing down 100,000 interfaces in a few seconds, which=
 really
> >>  is  necessary.  Right now we're running about 40,000 interfaces o=
n a not
> >>  yet saturated 10Gbps link.  Going to dual 10Gbps links means push=
ing more
> >>  than 100,000 subscriber interfaces, and it looks like a modern du=
al socket
> >>  system can handle that.
> >>
> >=20
> > I would also like to see this patch in, we are running into scalabi=
lity issues=20
> > with creating/deleting lots of interfaces as well.
>=20
> Ben patch only address interface deletion, and one part of the proble=
m,
> maybe the more visible one for the current kernel.
>=20
> Adding lots of interfaces only needs several threads to run concurent=
ly.
>=20
> Before applying/examining his patch I suggest identifying all dev_put=
() spots than
> can be deleted and replaced by something more scalable. I began this =
job
> but others can help me.
>=20
> RTNL and rcu grace periods are going to hurt anyway, so you probably =
need
> to use many tasks to be able to delete lots of interfaces in parallel=
=2E
>=20
> netdev_run_todo() should also use a better algorithm to allow paralle=
lism.
>=20
> Following patch doesnt slow down dev_put() users and real scalability
> problems will surface and might be addressed.
>=20
> [PATCH] net: allow netdev_wait_allrefs() to run faster
>=20
> netdev_wait_allrefs() waits that all references to a device vanishes.
>=20
> It currently uses a _very_ pessimistic 250 ms delay between each prob=
e.
> Some users report that no more than 4 devices can be dismantled per s=
econd,
> this is a pretty serious problem for extreme setups.
>=20
> Most likely, references only wait for a rcu grace period that should =
come
> fast, so use a schedule_timeout_uninterruptible(1) to allow faster re=
covery.

Is this a place where synchronize_rcu_expedited() is appropriate?
(It went in to 2.6.32-rc1.)

							Thanx, Paul

> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
> ---
>  net/core/dev.c |    2 +-
>  1 files changed, 1 insertion(+), 1 deletion(-)
>=20
> diff --git a/net/core/dev.c b/net/core/dev.c
> index 28b0b9e..fca2e4a 100644
> --- a/net/core/dev.c
> +++ b/net/core/dev.c
> @@ -4983,7 +4983,7 @@ static void netdev_wait_allrefs(struct net_devi=
ce *dev)
>  			rebroadcast_time =3D jiffies;
>  		}
>=20
> -		msleep(250);
> +		schedule_timeout_uninterruptible(1);
>=20
>  		if (time_after(jiffies, warning_time + 10 * HZ)) {
>  			printk(KERN_EMERG "unregister_netdevice: "
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
