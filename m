From: Robert Olsson <Robert.Olsson@data.slu.se>
Subject: Re: ksoftirqd uses 99% CPU triggered by network traffic (maybe
 RLT-8139 related)
Date: Tue, 27 Jul 2004 00:38:12 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <16645.34772.760879.146784@robur.slu.se>
References: <16645.13126.52445.630789@robur.slu.se>
	<Pine.LNX.4.44.0407270028170.11416-100000@silmu.st.jyu.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: quoted-printable
Cc: Robert Olsson <Robert.Olsson@data.slu.se>,
        Francois Romieu <romieu@fr.zoreil.com>,
        H?ctor Mart?n <hector@marcansoft.com>,
        Linux-Kernel <linux-kernel@vger.kernel.org>, <akpm@osdl.org>,
        <netdev@oss.sgi.com>, <brad@brad-x.com>, <shemminger@osdl.org>
Return-path: <netdev-bounce@oss.sgi.com>
To: Pasi Sjoholm <ptsjohol@cc.jyu.fi>
In-Reply-To: <Pine.LNX.4.44.0407270028170.11416-100000@silmu.st.jyu.fi>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Pasi Sjoholm writes:

 > Hur =E4r l=E4get Robert?-)
   Tack bra!

 > >  In summary: High softirq loads can totally kill userland. The reaso=
n is that=20
 > >  do_softirq() is run from many places hard interrupts, local_bh_enab=
le etc=20
 > >  and bypasses the ksoftirqd protection. It just been discussed at OL=
S with
 > >  Andrea and Dipankar and others. Current RCU suffers from this probl=
em as well.
 >=20
 > Ok, this explanation makes sense and my point of view I think this is=20
 > quite critical problem if you can "crash" linux kernel just sending en=
ough=20
 > packets to network interface for an example.

 Well the packets also has to create hard softirq loads in practice this =
means route
 lookup or something else for normal traffic the RX_SOFIRQ is very well b=
ehaved
 and schedules itself to give other softirq's a chance to run also I'll g=
uess you=20
 have softirq's not only from the network. If you decrease your load a bi=
t you come
 to more nomal operation?
=20
 > I would be more than glad to help you in testing if you want to publis=
h=20
 > some patches.=20

 Well maybe we should start to verify that this problem. Alexey did a lit=
te program=20
 doing gettimeofday to run to see how long user mode could be starved. Al=
so note we=20
 add new source of softirq's.=20


#include <stdio.h>=20
#include <sys/time.h>
#include <asm/types.h>

main()
{
	struct timeval tv, prev_tv;
	__s64 diff;
	__u32 i;
	__s32 maxlat =3D 50;

	  gettimeofday(&prev_tv, NULL);

	  printf("time control loop starting\n");

	  for (i=3D0;;i++) {
	      gettimeofday(&tv, NULL);
	      diff =3D (tv.tv_sec - prev_tv.tv_sec)*1000000 +
	             (tv.tv_usec - prev_tv.tv_usec);
	      if (diff > 1000000)=20
		  printf("**%lld\n", diff);
	      prev_tv =3D tv;
	      if (diff > maxlat) {
		      maxlat =3D diff;
		      printf("new maxlat =3D %d\n", maxlat);
	      }
	      if(!(i % 1000000))
		      printf("timestamp diff =3D %lld, maxlat =3D %d\n", diff, maxlat);
	  }
}

Cheers.
							--ro
