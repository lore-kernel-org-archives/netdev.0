From: Simon Horman <horms@verge.net.au>
Subject: Re: Flow Control and Port Mirroring Revisited
Date: Mon, 17 Jan 2011 07:37:30 +0900
Message-ID: <20110116223728.GA6279@verge.net.au>
References: <20110106124439.GA17004@verge.net.au>
 <AANLkTinJK-nbkP5_ee2cuS8RA7jTB4-bcWmAf4bjSouP@mail.gmail.com>
 <20110107012356.GA1257@verge.net.au>
 <20110110093155.GB13420@verge.net.au>
 <20110113064718.GA17905@verge.net.au>
 <AANLkTimO=5HmTJO1kmHGAWa-HTac+3d0TbrmJX5W4hVu@mail.gmail.com>
 <20110113234135.GC8426@verge.net.au>
 <20110114045818.GA29738@redhat.com>
 <20110114063528.GB10957@verge.net.au>
 <20110114065415.GA30300@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jesse Gross <jesse@nicira.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Rusty Russell <rusty@rustcorp.com.au>,
	virtualization@lists.linux-foundation.org, dev@openvswitch.org,
	virtualization@lists.osdl.org, netdev@vger.kernel.org,
	kvm@vger.kernel.org
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kirsty.vergenet.net ([202.4.237.240]:52012 "EHLO
	kirsty.vergenet.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751387Ab1APWhg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 16 Jan 2011 17:37:36 -0500
Content-Disposition: inline
In-Reply-To: <20110114065415.GA30300@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jan 14, 2011 at 08:54:15AM +0200, Michael S. Tsirkin wrote:
> On Fri, Jan 14, 2011 at 03:35:28PM +0900, Simon Horman wrote:
> > On Fri, Jan 14, 2011 at 06:58:18AM +0200, Michael S. Tsirkin wrote:
> > > On Fri, Jan 14, 2011 at 08:41:36AM +0900, Simon Horman wrote:
> > > > On Thu, Jan 13, 2011 at 10:45:38AM -0500, Jesse Gross wrote:
> > > > > On Thu, Jan 13, 2011 at 1:47 AM, Simon Horman <horms@verge.ne=
t.au> wrote:
> > > > > > On Mon, Jan 10, 2011 at 06:31:55PM +0900, Simon Horman wrot=
e:
> > > > > >> On Fri, Jan 07, 2011 at 10:23:58AM +0900, Simon Horman wro=
te:
> > > > > >> > On Thu, Jan 06, 2011 at 05:38:01PM -0500, Jesse Gross wr=
ote:
> > > > > >> >
> > > > > >> > [ snip ]
> > > > > >> > >
> > > > > >> > > I know that everyone likes a nice netperf result but I=
 agree with
> > > > > >> > > Michael that this probably isn't the right question to=
 be asking. =C2=A0I
> > > > > >> > > don't think that socket buffers are a real solution to=
 the flow
> > > > > >> > > control problem: they happen to provide that functiona=
lity but it's
> > > > > >> > > more of a side effect than anything. =C2=A0It's just t=
hat the amount of
> > > > > >> > > memory consumed by packets in the queue(s) doesn't rea=
lly have any
> > > > > >> > > implicit meaning for flow control (think multiple phys=
ical adapters,
> > > > > >> > > all with the same speed instead of a virtual device an=
d a physical
> > > > > >> > > device with wildly different speeds). =C2=A0The analog=
 in the physical
> > > > > >> > > world that you're looking for would be Ethernet flow c=
ontrol.
> > > > > >> > > Obviously, if the question is limiting CPU or memory c=
onsumption then
> > > > > >> > > that's a different story.
> > > > > >> >
> > > > > >> > Point taken. I will see if I can control CPU (and thus m=
emory) consumption
> > > > > >> > using cgroups and/or tc.
> > > > > >>
> > > > > >> I have found that I can successfully control the throughpu=
t using
> > > > > >> the following techniques
> > > > > >>
> > > > > >> 1) Place a tc egress filter on dummy0
> > > > > >>
> > > > > >> 2) Use ovs-ofctl to add a flow that sends skbs to dummy0 a=
nd then eth1,
> > > > > >> =C2=A0 =C2=A0this is effectively the same as one of my hac=
ks to the datapath
> > > > > >> =C2=A0 =C2=A0that I mentioned in an earlier mail. The resu=
lt is that eth1
> > > > > >> =C2=A0 =C2=A0"paces" the connection.
> > >=20
> > > This is actually a bug. This means that one slow connection will =
affect
> > > fast ones. I intend to change the default for qemu to sndbuf=3D0 =
: this
> > > will fix it but break your "pacing". So pls do not count on this
> > > behaviour.
> >=20
> > Do you have a patch I could test?
>=20
> You can (and users already can) just run qemu with sndbuf=3D0. But if=
 you
> like, below.

Thanks

> > > > > > Further to this, I wonder if there is any interest in provi=
ding
> > > > > > a method to switch the action order - using ovs-ofctl is a =
hack imho -
> > > > > > and/or switching the default action order for mirroring.
> > > > >=20
> > > > > I'm not sure that there is a way to do this that is correct i=
n the
> > > > > generic case.  It's possible that the destination could be a =
VM while
> > > > > packets are being mirrored to a physical device or we could b=
e
> > > > > multicasting or some other arbitrarily complex scenario.  Jus=
t think
> > > > > of what a physical switch would do if it has ports with two d=
ifferent
> > > > > speeds.
> > > >=20
> > > > Yes, I have considered that case. And I agree that perhaps ther=
e
> > > > is no sensible default. But perhaps we could make it configurab=
le somehow?
> > >=20
> > > The fix is at the application level. Run netperf with -b and -w f=
lags to
> > > limit the speed to a sensible value.
> >=20
> > Perhaps I should have stated my goals more clearly.
> > I'm interested in situations where I don't control the application.
>=20
> Well an application that streams UDP without any throttling
> at the application level will break on a physical network, right?
> So I am not sure why should one try to make it work on the virtual on=
e.
>=20
> But let's assume that you do want to throttle the guest
> for reasons such as QOS. The proper approach seems
> to be to throttle the sender, not have a dummy throttled
> receiver "pacing" it. Place the qemu process in the
> correct net_cls cgroup, set the class id and apply a rate limit?

I would like to be able to use a class to rate limit egress packets.
That much works fine for me.

What I would also like is for there to be back-pressure such that the g=
uest
doesn't consume lots of CPU, spinning, sending packets as fast as it ca=
n,
almost of all of which are dropped. That does seem like a lot of wasted
CPU to me.

Unfortunately there are several problems with this and I am fast conclu=
ding
that I will need to use a CPU cgroup. Which does make some sense, as wh=
at I
am really trying to limit here is CPU usage not network packet rates - =
even
if the test using the CPU is netperf.  So long as the CPU usage can
(mostly) be attributed to the guest using a cgroup should work fine.  A=
nd
indeed seems to in my limited testing.

One scenario in which I don't think it is possible for there to be
back-pressure in a meaningful sense is if root in the guest sets
/proc/sys/net/core/wmem_default to a large value, say 2000000.


I do think that to some extent there is back-pressure provided by sockb=
uf
in the case where process on the host is sending directly to a physical
interface.  And to my mind it would be "nice" if the same kind of
back-pressure was present in guests.  But through our discussions of th=
e
past week or so I get the feeling that is not your view of things.

Perhaps I could characterise the guest situation by saying:
	Egress packet rates can be controlled using tc on the host;
	Guest CPU usage can be controlled using CPU cgroups on the host;
	Sockbuf controls memory usage on the host;
	Back-pressure is irrelevant.

