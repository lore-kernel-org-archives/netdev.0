From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: Flow Control and Port Mirroring Revisited
Date: Mon, 17 Jan 2011 12:26:55 +0200
Message-ID: <20110117102655.GH23479@redhat.com>
References: <AANLkTinJK-nbkP5_ee2cuS8RA7jTB4-bcWmAf4bjSouP@mail.gmail.com>
 <20110107012356.GA1257@verge.net.au>
 <20110110093155.GB13420@verge.net.au>
 <20110113064718.GA17905@verge.net.au>
 <AANLkTimO=5HmTJO1kmHGAWa-HTac+3d0TbrmJX5W4hVu@mail.gmail.com>
 <20110113234135.GC8426@verge.net.au>
 <20110114045818.GA29738@redhat.com>
 <20110114063528.GB10957@verge.net.au>
 <20110114065415.GA30300@redhat.com>
 <20110116223728.GA6279@verge.net.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jesse Gross <jesse@nicira.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Rusty Russell <rusty@rustcorp.com.au>,
	virtualization@lists.linux-foundation.org, dev@openvswitch.org,
	virtualization@lists.osdl.org, netdev@vger.kernel.org,
	kvm@vger.kernel.org
To: Simon Horman <horms@verge.net.au>
Return-path: <kvm-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20110116223728.GA6279@verge.net.au>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Jan 17, 2011 at 07:37:30AM +0900, Simon Horman wrote:
> On Fri, Jan 14, 2011 at 08:54:15AM +0200, Michael S. Tsirkin wrote:
> > On Fri, Jan 14, 2011 at 03:35:28PM +0900, Simon Horman wrote:
> > > On Fri, Jan 14, 2011 at 06:58:18AM +0200, Michael S. Tsirkin wrot=
e:
> > > > On Fri, Jan 14, 2011 at 08:41:36AM +0900, Simon Horman wrote:
> > > > > On Thu, Jan 13, 2011 at 10:45:38AM -0500, Jesse Gross wrote:
> > > > > > On Thu, Jan 13, 2011 at 1:47 AM, Simon Horman <horms@verge.=
net.au> wrote:
> > > > > > > On Mon, Jan 10, 2011 at 06:31:55PM +0900, Simon Horman wr=
ote:
> > > > > > >> On Fri, Jan 07, 2011 at 10:23:58AM +0900, Simon Horman w=
rote:
> > > > > > >> > On Thu, Jan 06, 2011 at 05:38:01PM -0500, Jesse Gross =
wrote:
> > > > > > >> >
> > > > > > >> > [ snip ]
> > > > > > >> > >
> > > > > > >> > > I know that everyone likes a nice netperf result but=
 I agree with
> > > > > > >> > > Michael that this probably isn't the right question =
to be asking. =A0I
> > > > > > >> > > don't think that socket buffers are a real solution =
to the flow
> > > > > > >> > > control problem: they happen to provide that functio=
nality but it's
> > > > > > >> > > more of a side effect than anything. =A0It's just th=
at the amount of
> > > > > > >> > > memory consumed by packets in the queue(s) doesn't r=
eally have any
> > > > > > >> > > implicit meaning for flow control (think multiple ph=
ysical adapters,
> > > > > > >> > > all with the same speed instead of a virtual device =
and a physical
> > > > > > >> > > device with wildly different speeds). =A0The analog =
in the physical
> > > > > > >> > > world that you're looking for would be Ethernet flow=
 control.
> > > > > > >> > > Obviously, if the question is limiting CPU or memory=
 consumption then
> > > > > > >> > > that's a different story.
> > > > > > >> >
> > > > > > >> > Point taken. I will see if I can control CPU (and thus=
 memory) consumption
> > > > > > >> > using cgroups and/or tc.
> > > > > > >>
> > > > > > >> I have found that I can successfully control the through=
put using
> > > > > > >> the following techniques
> > > > > > >>
> > > > > > >> 1) Place a tc egress filter on dummy0
> > > > > > >>
> > > > > > >> 2) Use ovs-ofctl to add a flow that sends skbs to dummy0=
 and then eth1,
> > > > > > >> =A0 =A0this is effectively the same as one of my hacks t=
o the datapath
> > > > > > >> =A0 =A0that I mentioned in an earlier mail. The result i=
s that eth1
> > > > > > >> =A0 =A0"paces" the connection.
> > > >=20
> > > > This is actually a bug. This means that one slow connection wil=
l affect
> > > > fast ones. I intend to change the default for qemu to sndbuf=3D=
0 : this
> > > > will fix it but break your "pacing". So pls do not count on thi=
s
> > > > behaviour.
> > >=20
> > > Do you have a patch I could test?
> >=20
> > You can (and users already can) just run qemu with sndbuf=3D0. But =
if you
> > like, below.
>=20
> Thanks
>=20
> > > > > > > Further to this, I wonder if there is any interest in pro=
viding
> > > > > > > a method to switch the action order - using ovs-ofctl is =
a hack imho -
> > > > > > > and/or switching the default action order for mirroring.
> > > > > >=20
> > > > > > I'm not sure that there is a way to do this that is correct=
 in the
> > > > > > generic case.  It's possible that the destination could be =
a VM while
> > > > > > packets are being mirrored to a physical device or we could=
 be
> > > > > > multicasting or some other arbitrarily complex scenario.  J=
ust think
> > > > > > of what a physical switch would do if it has ports with two=
 different
> > > > > > speeds.
> > > > >=20
> > > > > Yes, I have considered that case. And I agree that perhaps th=
ere
> > > > > is no sensible default. But perhaps we could make it configur=
able somehow?
> > > >=20
> > > > The fix is at the application level. Run netperf with -b and -w=
 flags to
> > > > limit the speed to a sensible value.
> > >=20
> > > Perhaps I should have stated my goals more clearly.
> > > I'm interested in situations where I don't control the applicatio=
n.
> >=20
> > Well an application that streams UDP without any throttling
> > at the application level will break on a physical network, right?
> > So I am not sure why should one try to make it work on the virtual =
one.
> >=20
> > But let's assume that you do want to throttle the guest
> > for reasons such as QOS. The proper approach seems
> > to be to throttle the sender, not have a dummy throttled
> > receiver "pacing" it. Place the qemu process in the
> > correct net_cls cgroup, set the class id and apply a rate limit?
>=20
> I would like to be able to use a class to rate limit egress packets.
> That much works fine for me.
>=20
> What I would also like is for there to be back-pressure such that the=
 guest
> doesn't consume lots of CPU, spinning, sending packets as fast as it =
can,
> almost of all of which are dropped. That does seem like a lot of wast=
ed
> CPU to me.
>=20
> Unfortunately there are several problems with this and I am fast conc=
luding
> that I will need to use a CPU cgroup. Which does make some sense, as =
what I
> am really trying to limit here is CPU usage not network packet rates =
- even
> if the test using the CPU is netperf.  So long as the CPU usage can
> (mostly) be attributed to the guest using a cgroup should work fine. =
 And
> indeed seems to in my limited testing.
>=20
> One scenario in which I don't think it is possible for there to be
> back-pressure in a meaningful sense is if root in the guest sets
> /proc/sys/net/core/wmem_default to a large value, say 2000000.
>=20
>=20
> I do think that to some extent there is back-pressure provided by soc=
kbuf
> in the case where process on the host is sending directly to a physic=
al
> interface.  And to my mind it would be "nice" if the same kind of
> back-pressure was present in guests.  But through our discussions of =
the
> past week or so I get the feeling that is not your view of things.

It might be nice. Unfortunately this is not what we have implemented:
the sockbuf backpressure blocks the socket, what we have blocks all
transmit from the guest. Another issue is that the strategy we have
seems to be broken if the target is a guest on another machine.

So it won't be all that simple to implement well, and before we try,
I'd like to know whether there are applications that are helped
by it. For example, we could try to measure latency at various
pps and see whether the backpressure helps. netperf has -b, -w
flags which might help these measurements.

> Perhaps I could characterise the guest situation by saying:
> 	Egress packet rates can be controlled using tc on the host;
> 	Guest CPU usage can be controlled using CPU cgroups on the host;
> 	Sockbuf controls memory usage on the host;

Not really, the memory usage on the host is controlled by the
various queue lengths in the host. E.g. if you send packets to
the physical device, they will get queued there.

> 	Back-pressure is irrelevant.

Or at least, broken :)

--=20
MST
