From: Marc Herbert <marc.herbert@free.fr>
Subject: TxDescriptors -> 1024 default. Please not for every NIC!
Date: Sat, 15 May 2004 14:14:26 +0200 (CEST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.58.0405151354220.9894@fcat>
References: <OF72607111.CD0234C8-ON85256DA1.0068861B-86256DA1.0068FF60@us.ibm.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=iso-8859-1
Content-Transfer-Encoding: quoted-printable
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
In-Reply-To: <OF72607111.CD0234C8-ON85256DA1.0068861B-86256DA1.0068FF60@us.ibm.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sun, 14 Sep 2003, Ricardo C Gonzalez wrote:

> David Miller wrote:
>
> >Back to the main topic, maybe we should set dev->tx_queue_len to
> >1000 by default for all ethernet devices.
>
>
> I definately agree with setting the dev->tx_queue_len to 1000 as a defa=
ult
> for all ethernet adapters. All adapters will benefit from this change.
>

<http://oss.sgi.com/projects/netdev/archive/2003-09/threads.html#00247>

Sorry to exhume this discussion but I only recently discovered this
change, the hard way.

I carefully read this old thread and did not grasp _every_ detail, but
there is one thing that I am sure of: 1000 packets @ 1=A0Gb/s looks
good, but on the other hand, 1000 full-size Ethernet packets @ 10=A0Mb/s
are about 1.2=A0seconds long!

Too little buffering means not enough dampering effect, which is very
important for performance in asynchronous systems, granted. However,
_too much_ buffering means too big and too variable latencies. When
discussing buffers, duration is very often more important than size.
Applications, TCP's dynamic (and kernel dynamics too?) do not care
much about buffer sizes, they more often care about latencies (and
throughput, of course). Buffers sizes is often "just a small matter of
implementation" :-) For instance people designing routers talk about
buffers in _milliseconds_ much more often than in _bytes_ (despite the
fact that their memories cost more than in hosts, considering the
throughputs involved).

100 packets @ 100=A0Mb/s was 12 ms. 1000 packets @ 1=A0Gb/s is still
12=A0ms. 12=A0ms is great. It's a "good" latency because it is the
order of magnitude of real-world constants like:  comfortable
interactive applications, operating system sheduler granularity or
propagation time in 2000=A0km of cable.

But 1000=A0packets @ 100=A0Mb/s is 120=A0ms and is neither very good nor
very useful anymore. 1000=A0packets @ 10=A0Mb/s is 1.2=A0s, which is
ridiculous. It does mean that, when joe user is uploading some big
file through his cheap Ethernet card, and that there are no other
bottleneck/drops further in the network, every concurrent application
will have to wait 1.2 s before accessing the network!
 It this hard to believe for you, just make the test yourself, it's
very easy: force one of you NICs to 10Mb/s full duplex, txqueuelen
1000 and send a continuous flow to a nearby machine. Then try to ping
anything.
 Imagine now that some packet is lost for whatever reason on some
_other_ TCP connection going through this terrible 1.2=A0s queue. Then
you need one SACK/RTX extra round trip time to recover from it: so
it's now _2.4=A0s_ to deliver the data sent just after the dropped
packet...  Assuming of course TCP timers do not become confused by
this huge latency and probably huge jitter.

And I don't think you want to make fiddling with "tc" mandatory for
joe user. Or tell him: "oh, please just 'ifconfig txqueuelen 10', or
buy a new Ethernet card".

I am unfortunately not familiar with this part of the linux kernel,
but I really think that, if possible, txqueuelen should be initialized
at some "constant 12=A0ms" and not at the "1000 packets" highly variable
latency setting. I=A0can imagine there are some corner cases, like for
instance when some GEth NIC is hot-plugged into a 100=A0Mb/s, or jumbo
frames, but hey, those are corner cases : as a first step, even a
simple constant-per-model txqueuelen initialization would be already
great.

Cheers,

Marc.


PS: one workaround for joe user against this 1.2s latency would be to
keep his SND_BUF and number of sockets small. But this is poor.


--=20
"Je n'ai fait cette lettre-ci plus longue que parce que je n'ai pas eu
le loisir de la faire plus courte." -- Blaise Pascal
