From: Bill Fink <billfink@mindspring.com>
Subject: Re: can TCP socket send buffer be over used?
Date: Wed, 4 Aug 2010 05:07:50 -0400
Message-ID: <20100804050750.f737fb3a.billfink@mindspring.com>
References: <AANLkTi=Ma2yMVbgRnUUB6T1j=rHLb60oAXqCSbM35KgT@mail.gmail.com>
	<20100804032018.19fd9a36.billfink@mindspring.com>
	<AANLkTimhswtowB-TZ5Hj4KQXcf3gzjpxEJ8qO+PuWaPV@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Jack Zhang <jack.zhang2011@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from elasmtp-scoter.atl.sa.earthlink.net ([209.86.89.67]:33487 "EHLO
	elasmtp-scoter.atl.sa.earthlink.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756253Ab0HDJHv convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 4 Aug 2010 05:07:51 -0400
In-Reply-To: <AANLkTimhswtowB-TZ5Hj4KQXcf3gzjpxEJ8qO+PuWaPV@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 4 Aug 2010, Jack Zhang wrote:

> Hi Bill,
>=20
> Thanks a lot for your help.
>=20
> It does make sense!
>=20
> As I'm writing this part into my master thesis, do you happen to know
> which part in the source code I can maybe use as a proof in the thesi=
s
> that Linux uses 1/4 of the doubled buffer size for metadata?

Don't know about the source code, but from
Documentation/networking/ip-sysctl.txt:

tcp_adv_win_scale - INTEGER
	Count buffering overhead as bytes/2^tcp_adv_win_scale
	(if tcp_adv_win_scale > 0) or bytes-bytes/2^(-tcp_adv_win_scale),
	if it is <=3D 0.
	Default: 2

wizin% cat /proc/sys/net/ipv4/tcp_adv_win_scale=20
2

=46or the oddity involving the 128 KB window case, it seems to have
something to do with the TCP receiver autotuning.  On a real
cross-country link (~80 ms RTT), the best to be expected is:

wizin% bc
scale=3D10
128*1024*8/0.080/10^6*3/2
19.6608000000

And an actual 60-second nuttcp test (which by default sets both
the sender and receiver socket buffer sizes):

netem1% nuttcp -T60 -i5 -w128 192.168.1.18
    8.8125 MB /   5.00 sec =3D   14.7849 Mbps     0 retrans
    9.2500 MB /   5.00 sec =3D   15.5189 Mbps     0 retrans
    9.1875 MB /   5.00 sec =3D   15.4141 Mbps     0 retrans
    9.5000 MB /   5.00 sec =3D   15.9384 Mbps     0 retrans
    9.1250 MB /   5.00 sec =3D   15.3092 Mbps     0 retrans
    9.1875 MB /   5.00 sec =3D   15.4141 Mbps     0 retrans
    9.4375 MB /   5.00 sec =3D   15.8335 Mbps     0 retrans
    9.3125 MB /   5.00 sec =3D   15.6238 Mbps     0 retrans
    9.3125 MB /   5.00 sec =3D   15.6238 Mbps     0 retrans
    9.1250 MB /   5.00 sec =3D   15.3092 Mbps     0 retrans
    9.1875 MB /   5.00 sec =3D   15.4141 Mbps     0 retrans
    9.4375 MB /   5.00 sec =3D   15.8335 Mbps     0 retrans

  111.0100 MB /  60.13 sec =3D   15.4867 Mbps 0 %TX 0 %RX 0 retrans 80.=
59 msRTT

But if I allow the receiver to do autotuning by specifying
a server window size of 0:

netem1% nuttcp -T60 -i5 -w128 -ws0 192.168.1.18
   14.3125 MB /   5.00 sec =3D   24.0123 Mbps     0 retrans
   15.5000 MB /   5.00 sec =3D   26.0047 Mbps     0 retrans
   15.5000 MB /   5.00 sec =3D   26.0047 Mbps     0 retrans
   15.5000 MB /   5.00 sec =3D   26.0047 Mbps     0 retrans
   15.3750 MB /   5.00 sec =3D   25.7950 Mbps     0 retrans
   15.3750 MB /   5.00 sec =3D   25.7950 Mbps     0 retrans
   15.5000 MB /   5.00 sec =3D   26.0047 Mbps     0 retrans
   15.5000 MB /   5.00 sec =3D   26.0047 Mbps     0 retrans
   15.5000 MB /   5.00 sec =3D   26.0047 Mbps     0 retrans
   15.3750 MB /   5.00 sec =3D   25.7950 Mbps     0 retrans
   15.5000 MB /   5.00 sec =3D   26.0047 Mbps     0 retrans
   15.3750 MB /   5.00 sec =3D   25.7950 Mbps     0 retrans

  184.3643 MB /  60.04 sec =3D   25.7609 Mbps 0 %TX 0 %RX 0 retrans 80.=
58 msRTT

This kind of makes sense since with autotuning, the receiver
is allowed to increase the socket buffer size beyond 128 KB.
One would have to tcpdump the packet flow to see what the
receiver's advertised TCP window was.  Rate throttling by
specifying the socket buffer size only seems to be truly
effective when done by the receiver, not when it's only
done on the sender side.

					-Bill

P.S.  BTW I've also seen cases (on some older kernels), where
      the window scale used was 1 more than it should have been,
      resulting in the receiver's advertised TCP window being
      twice what one would have expected.  tcpdump can also be
      used to verify proper functioning of the window scaling.



> Thanks,
> Jack
>=20
> On 4 August 2010 01:20, Bill Fink <billfink@mindspring.com> wrote:
> > On Tue, 3 Aug 2010, Jack Zhang wrote:
> >
> >> Hi there,
> >>
> >> I'm doing experiments with (modified*) software iSCSI over a link =
with
> >> an emulated Round-Trip Time (RTT) of 100 ms by netem.
> >>
> >> For example, when I set the send buffer size to 128 KB, i could ge=
t a
> >> throughput up to 43 Mbps, which seems to be impossible as the (buf=
fer
> >> size) / RTT is only 10 Mbps.
> >
> > I'm not sure what's going on with this first case.
> >
> >> And When I set the send buffer size to 512 KB, i can get a through=
put
> >> up to 60 Mbps, which also seems to be impossible as the (buffer si=
ze)
> >> / RTT is only 40 Mbps.
> >
> > But this case seems just about right. =A0Linux doubles the requeste=
d
> > buffer size, then uses one quarter of that for overhead (not half),
> > so you effectively get 50% more than requested (2X * 3/4 =3D 1.5X).
> > Plugging your case into bc:
> >
> > wizin% bc
> > scale=3D10
> > 512*1024*8/0.100/10^6*3/2
> > 62.9145600000
> >
> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0 =A0-Bill
> >
> >
> >
> >> I understand that when the buffer size is set to 128 KB, I actuall=
y
> >> got a buffer of 256 KB as the kernel doubles the buffer size. I al=
so
> >> understand that half the doubled buffer size is used for meta data
> >> instead of the actual data to be transferred. So basically the
> >> effective buffer sizes for the two examples =A0are just 128 KB and=
 512
> >> KB respectively.
> >>
> >> So I was confused because, theoretically, send buffers of 128 KB a=
nd
> >> 512 KB should achieve no more than 10 Mbps and 40 Mbps respectivel=
y
> >> but I was able to get way much more than the theoretical limit. So
> >> I was wondering is there any chance the send buffer can be "overus=
ed"?
> >> or there is some other mechanism inside TCP is doing some
> >> optimization?
> >>
> >> * the modification is to disable "TCP_NODELAY" , enable
> >> "use_clustering" for SCSI, and set different send buffer sizes for=
 the
> >> TCP socket buffer.
> >>
> >> Any idea will be highly appreciated.
> >>
> >> Thanks a lot!
