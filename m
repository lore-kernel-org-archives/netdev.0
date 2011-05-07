From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Scalability of interface creation and deletion
Date: Sat, 07 May 2011 20:32:54 +0200
Message-ID: <1304793174.3207.22.camel@edumazet-laptop>
References: <891B02256A0667292521A4BF@Ximines.local>
	 <1304770926.2821.1157.camel@edumazet-laptop>
	 <0F4A638C2A523577CDBC295E@Ximines.local>
	 <1304785589.3207.5.camel@edumazet-laptop>
	 <178E8895FB84C07251538EF7@Ximines.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Alex Bligh <alex@alex.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:49547 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755933Ab1EGSc7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 7 May 2011 14:32:59 -0400
Received: by wwa36 with SMTP id 36so4514184wwa.1
        for <netdev@vger.kernel.org>; Sat, 07 May 2011 11:32:58 -0700 (PDT)
In-Reply-To: <178E8895FB84C07251538EF7@Ximines.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le samedi 07 mai 2011 =C3=A0 19:24 +0100, Alex Bligh a =C3=A9crit :
> Eric,
>=20
> --On 7 May 2011 18:26:29 +0200 Eric Dumazet <eric.dumazet@gmail.com> =
wrote:
>=20
> > Here, on 2.6.38 kernel (Ubuntu 11.04 provided, on my 2 core laptop)
> ># time rmmod dummy
> > real	0m0.111s
> ...
> > On another machine with a very recent kernel :
> > $ modprobe dummy numdummies=3D1
> > $ ifconfig dummy0 192.168.46.46 up
> > $ time rmmod dummy
> >
> > real	0m0.032s
>=20
> I know it's different machines, but that's a pretty significant
> difference. So I compiled from 2.6.39-rc6 head (i.e. a kernel
> less than an hour old), with only your suggested change in,
> so that (a) I could eliminate old kernels, and (b) I could
> instrument it.
>=20
> > synchronize_rcu() calls are not consuming cpu, they just _wait_
> > rcu grace period.
> >
> > I suggest you read Documentation/RCU files if you really want to :)
>=20
> I understand the basic point: it needs to wait for all readers
> to drop their references. It's sort of hard to understand why
> on a machine with an idle network there would be reader(s) holding
> references for 250ms. And indeed the analysis below shows that
> isn't the case (it's more like 44 ms).
>=20
> > If you want to check how expensive it is, its quite easy:
> > add a trace in synchronize_net()
>=20
> At least for veth devices, I see the same on 2.6.39-rc6 - if anything
> it's worse:
>=20
> # ./ifseq -n 100
> Sat May 7 17:50:53 UTC 2011 creating 100 interfaces
> Sat May 7 17:50:54 UTC 2011 done
>=20
> real	0m1.549s
> user	0m0.060s
> sys	0m0.990s
> Sat May 7 17:50:54 UTC 2011 deleting 100 interfaces
> Sat May 7 17:51:22 UTC 2011 done
>=20
> real	0m27.917s
> user	0m0.420s
> sys	0m0.060s
>=20
> Performing that operation produced exactly 200 calls to synchronize n=
et.
> The timestamps indicate that's 2 per veth pair deletion, and zero
> per veth pair creation.
>=20
> Analysing the resultant logs shows only 31% of the problem is
> time spent within synchronize_net() (perl script below).
>=20
> $ ./analyse.pl < syncnet | tail -2
> Total 18.98515 Usage 199 Average 0.09540 elsewhere
> Total 8.77581 Usage 200 Average 0.04388 synchronizing
>=20
> So *something* is spending more than twice as much time as
> synchronize_net().
>=20
> I've attached the log below as well.
>=20
> --=20
> Alex Bligh
>=20
>=20
> $ cat analyse.pl
> #!/usr/bin/perl
>=20
> use strict;
> use warnings;
>=20
> my $lastuptime;
> my $uptime;
> my $diff;
> my $area;
> my %time;
> my %usage;
>=20
> while (<>)
> {
>     chomp;
>     if (m/\[\s*([0-9.]+)\].*synchronize_net/)
>     {
> 	$uptime =3D $1;
> 	if (defined($lastuptime))
> 	{
> 	    $area =3D (m/end/)?"synchronizing":"elsewhere";
> 	    $diff =3D $uptime - $lastuptime;
> 	    printf "%5.5f $area\n", $diff;
> 	    $time{$area}+=3D$diff;
> 	    $usage{$area}++;
> 	}
> 	$lastuptime =3D $uptime;
>     }
> }
>=20
> print "\n";
>=20
> my $k;
> foreach $k (sort keys %time)
> {
>     printf "Total %5.5f Usage %d Average %5.5f %s\n", $time{$k},=20
> $usage{$k}, $time{$k}/$usage{$k}, $k;
> }
>=20
>=20
>=20
> May  7 17:50:55 nattytest kernel: [  127.490142] begin synchronize_ne=
t()
> May  7 17:50:55 nattytest kernel: [  127.560084] end synchronize_net(=
)
> May  7 17:50:55 nattytest kernel: [  127.610350] begin synchronize_ne=
t()
> May  7 17:50:55 nattytest kernel: [  127.610932] end synchronize_net(=
)
> May  7 17:50:55 nattytest kernel: [  127.740078] begin synchronize_ne=
t()
> May  7 17:50:55 nattytest kernel: [  127.820071] end synchronize_net(=
)

Well, there is also one rcu_barrier() call that is expensive.
(It was changed from one synchronize_rcu() to one rcu_barrier() lately
in commit ef885afb , in 2.6.36 kernel)

net/core/dev.c line 5167


http://git2.kernel.org/?p=3Dlinux/kernel/git/torvalds/linux-2.6.git;a=3D=
commitdiff;h=3Def885afbf8a37689afc1d9d545e2f3e7a8276c17

netdev_wait_allrefs() waits that all references to a device vanishes.

It currently uses a _very_ pessimistic 250 ms delay between each probe.
Some users reported that no more than 4 devices can be dismantled per
second, this is a pretty serious problem for some setups.

Most of the time, a refcount is about to be released by an RCU callback=
,
that is still in flight because rollback_registered_many() uses a
synchronize_rcu() call instead of rcu_barrier(). Problem is visible if
number of online cpus is one, because synchronize_rcu() is then a no op=
=2E

time to remove 50 ipip tunnels on a UP machine :

before patch : real 11.910s
after patch : real 1.250s

Reported-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Reported-by: Octavian Purdila <opurdila@ixiacom.com>
Reported-by: Benjamin LaHaise <bcrl@kvack.org>
Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
Signed-off-by: David S. Miller <davem@davemloft.net>



