From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: regression: unregister_netdev() unusably slow
Date: Mon, 25 May 2009 07:22:02 +0200
Message-ID: <4A1A2AFA.8020605@cosmosbay.com>
References: <20090524192150.GE24757@kvack.org> <200905250023.31056.denys@visp.net.lb> <20090524213744.GG24757@kvack.org> <4A19BF39.4000305@cosmosbay.com> <20090524214433.GH24757@kvack.org> <4A19C50B.9040304@cosmosbay.com> <20090524221240.GI24757@kvack.org> <4A19CE8B.3070302@cosmosbay.com> <20090525000050.GJ24757@kvack.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Denys Fedoryschenko <denys@visp.net.lb>, netdev@vger.kernel.org,
	linux kernel <linux-kernel@vger.kernel.org>,
	damien.wyart@free.fr
To: Benjamin LaHaise <bcrl@lhnet.ca>,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:39240 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750881AbZEYFWT convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 May 2009 01:22:19 -0400
In-Reply-To: <20090525000050.GJ24757@kvack.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Benjamin LaHaise a =E9crit :
> On Mon, May 25, 2009 at 12:47:39AM +0200, Eric Dumazet wrote:
>> There is a strong dependancy against HZ
>> BTW, I am using TREE_RCU
>=20
> I'm using CLASSIC_RCU.  The bisect just completed, and it points to R=
CU. =20
> It makes some degree of sense since I'm testing on an otherwise idle=20
> machine.  That said, where is fixing it going to make sense?  I'm not=
=20
> opposed to having device unregister take a few timer ticks, but there=
=20
> has to be some way of exposing parallelism to the system, and since t=
he=20
> synchronize_net() calls are done under rntl_lock(), none is possible =
at=20
> present.  Hrm.

Thanks Ben, this bisection indeed confirms how nasty synchronize_rcu() =
is :)

Time to include Paul and lkml in the discussion, and find a better solu=
tion than=20
one provided in February.

>=20
> 		-ben
>=20
> bf51935f3e988e0ed6f34b55593e5912f990750a is first bad commit
> commit bf51935f3e988e0ed6f34b55593e5912f990750a
> Author: Paul E. McKenney <paulmck@linux.vnet.ibm.com>
> Date:   Tue Feb 17 06:01:30 2009 -0800
>=20
>     x86, rcu: fix strange load average and ksoftirqd behavior
>    =20
>     Damien Wyart reported high ksoftirqd CPU usage (20%) on an
>     otherwise idle system.
>    =20
>     The function-graph trace Damien provided:
> ...
> diff --git a/arch/x86/kernel/process_32.c b/arch/x86/kernel/process_3=
2.c
>=20
> index a546f55..bd4da2a 100644
> --- a/arch/x86/kernel/process_32.c
> +++ b/arch/x86/kernel/process_32.c
> @@ -104,9 +104,6 @@ void cpu_idle(void)
>  			check_pgt_cache();
>  			rmb();
> =20
> -			if (rcu_pending(cpu))
> -				rcu_check_callbacks(cpu, 0);
> -
>  			if (cpu_is_offline(cpu))
>  				play_dead();
> =20
>=20
> --

Paul, this commit makes net device unregister very slow (more than 100 =
ms
 if CONFIG_NO_HZ is set), while it used to be pretty fast in previous k=
ernels.

Quoting Ben :=20
" I just ran a few L2TP tests against 2.6.30-rc7, and it looks like net=
work=20
  device deletion has become unusably slow.  At least in 2.6.27.10, del=
eting=20
  1000 network interfaces takes less than 2 seconds of real time.  The =
same=20
  test run under 2.6.30-rc7 is taking hundreds of seconds to delete 100=
0=20
  interfaces at a rate of about 5 per second.  The interfaces all share=
 the=20
  same local ip address, but each have a single route to a unique clien=
t=20
  ip address."

Device unregister is a synchronize_rcu() abuser (three calls to dismant=
le
a vlan...) so delaying rcu callbacks can be pretty expensive for it.

I wonder if the real root of the problem was not discovered in the mean=
time,
by commit 64ca5ab913f1594ef316556e65f5eae63ff50cee
rcu: increment quiescent state counter in ksoftirqd()

Maybe this commit solved Damien Wyart problem as well, and we can rever=
t
commit bf51935f3e988e0ed6f34b55593e5912f990750a ?

Thank you

