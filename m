From: Ricardo C Gonzalez <ricardoz@us.ibm.com>
Subject: Re: [e1000 2.6 10/11] TxDescriptors -> 1024 default
Date: Tue, 18 May 2004 09:34:40 -0500
Sender: netdev-bounce@oss.sgi.com
Message-ID: <OF817307D7.5FC78280-ON85256E98.004FDB43-86256E98.00500AA1@us.ibm.com>
References: <Pine.LNX.4.58.0405141430340.4622@fcat>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Cc: "David S. Miller" <davem@redhat.com>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
In-Reply-To: <Pine.LNX.4.58.0405141430340.4622@fcat>
To: Marc Herbert <marc.herbert@free.fr>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Marc,

      Are you considering the case of small packets?  Many applications u=
se
lots of small packets.  Example is the volano benchmark.
You needs to look at throughput rates for small packets. A 1GB  ethernet
can send something like 1.4 Million 64 byte packets per second.

Let me know what you think.



regards,


---------------------------------------------------------
Rick Gonzalez
LTC pSeries Performance
Building: 908    Office: 1D004
Phone: (512) 838-0623


                                                                         =
 =20
             Marc Herbert                                                =
 =20
             <marc.herbert@fre                                           =
 =20
             e.fr>                                                      T=
o=20
                                       Ricardo C Gonzalez/Austin/IBM@ibmu=
s=20
             05/14/2004 09:16                                           c=
c=20
             AM                        "David S. Miller"                 =
 =20
                                       <davem@redhat.com>,               =
 =20
                                       netdev@oss.sgi.com                =
 =20
                                                                   Subjec=
t=20
                                       Re: [e1000 2.6 10/11] TxDescriptor=
s=20
                                       -> 1024 default                   =
 =20
                                                                         =
 =20
                                                                         =
 =20
                                                                         =
 =20
                                                                         =
 =20
                                                                         =
 =20
                                                                         =
 =20




On Sun, 14 Sep 2003, Ricardo C Gonzalez wrote:

> David Miller wrote:
>
> >Back to the main topic, maybe we should set dev->tx_queue_len to
> >1000 by default for all ethernet devices.
>
>
> I definately agree with setting the dev->tx_queue_len to 1000 as a
default
> for all ethernet adapters. All adapters will benefit from this change.
>

Sorry to exhume this discussion but I only recently discovered this
change, the hard way.

I carefully read this old thread and did not grasp every detail, but
there is one thing that I am sure of: 1000 packets @ 1=A0Gb/s looks
good, but on the other hand, 1000 full size packets @ 10=A0Mb/s are
about 1.2=A0seconds long!

Too little buffering means not enough dampering effect, which is very
important for performance in asynchronous systems. Granted. However,
_too much_ buffering means too big and too variable latencies. When
discussing buffers, duration is very often more important than size.
Applications, TCP's dynamic (and kernel dynamics too?) do not care
much about buffer sizes, they more often care about latencies (and
throughput, of course). Buffers sizes is often "just a small matter of
implementation" :-) People designing routers for instance talk about
buffers in _milliseconds_ much more often than in _bytes_ (despite the
fact that their memories cost more than in hosts, considering the
throughputs involved).

100 packets @ 100=A0Mb/s was 12 ms. 1000 packets @ 1=A0Gb/s is still
12=A0ms. 12=A0ms is great. It's a "good" latency because it is the
order of magnitude of real-world constants like:  comfortable
interactive applications, operating system sheduler granularity or
propagation time in 2000=A0km of cable.

But 1000=A0packets @ 100=A0Mb/s is 120=A0ms and is neither very good nor
useful anymore. 1000=A0packets @ 10=A0Mb/s is 1.2=A0s, which is ridiculou=
s.
It does mean that, when joe user is uploading some big file through
his cheap Ethernet card, and that there are no other bottleneck/drops
further in the network, every concurrent application will have to wait
1.2 s before accessing the network. Imagine now that some packet is
lost for whatever reason on some _other_ TCP connection going through
this terrible 1.2=A0s queue. Then you need one SACK/RTX extra round trip
time to recover from it: so it's now 2.4=A0s to deliver the data just
after the drop.  Assuming of course TCP does not become confused by
this huge latency and probably huge jitter.

And I don't think you want to make fiddling with "tc" mandatory for
joe user.

I am unfortunately not familiar with this part of the linux kernel,
but I really think that, if possible, txqueuelen should be initialized
at "12=A0ms" and not at "1000 packets". I=A0can imagine there are some
corner cases, like for instance when some GEth NIC is hot-plugged into
a 100=A0Mb/s, but hey, those are corner cases. I think even a simple
constant-per-model txqueuelen initialization would be already great.

Cheers,

Marc.


PS: one workaround for joe user against this 1.2s latency would be to
keep his SND_BUF and number of sockets small. But this is poor.


--
"Je n'ai fait cette lettre-ci plus longue que parce que je n'ai pas eu
le loisir de la faire plus courte." -- Blaise Pascal
