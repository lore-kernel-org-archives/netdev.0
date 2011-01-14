From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: Flow Control and Port Mirroring Revisited
Date: Fri, 14 Jan 2011 08:54:15 +0200
Message-ID: <20110114065415.GA30300@redhat.com>
References: <1294309362.3074.11.camel@edumazet-laptop>
 <20110106124439.GA17004@verge.net.au>
 <AANLkTinJK-nbkP5_ee2cuS8RA7jTB4-bcWmAf4bjSouP@mail.gmail.com>
 <20110107012356.GA1257@verge.net.au>
 <20110110093155.GB13420@verge.net.au>
 <20110113064718.GA17905@verge.net.au>
 <AANLkTimO=5HmTJO1kmHGAWa-HTac+3d0TbrmJX5W4hVu@mail.gmail.com>
 <20110113234135.GC8426@verge.net.au>
 <20110114045818.GA29738@redhat.com>
 <20110114063528.GB10957@verge.net.au>
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
In-Reply-To: <20110114063528.GB10957@verge.net.au>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Jan 14, 2011 at 03:35:28PM +0900, Simon Horman wrote:
> On Fri, Jan 14, 2011 at 06:58:18AM +0200, Michael S. Tsirkin wrote:
> > On Fri, Jan 14, 2011 at 08:41:36AM +0900, Simon Horman wrote:
> > > On Thu, Jan 13, 2011 at 10:45:38AM -0500, Jesse Gross wrote:
> > > > On Thu, Jan 13, 2011 at 1:47 AM, Simon Horman <horms@verge.net.=
au> wrote:
> > > > > On Mon, Jan 10, 2011 at 06:31:55PM +0900, Simon Horman wrote:
> > > > >> On Fri, Jan 07, 2011 at 10:23:58AM +0900, Simon Horman wrote=
:
> > > > >> > On Thu, Jan 06, 2011 at 05:38:01PM -0500, Jesse Gross wrot=
e:
> > > > >> >
> > > > >> > [ snip ]
> > > > >> > >
> > > > >> > > I know that everyone likes a nice netperf result but I a=
gree with
> > > > >> > > Michael that this probably isn't the right question to b=
e asking. =A0I
> > > > >> > > don't think that socket buffers are a real solution to t=
he flow
> > > > >> > > control problem: they happen to provide that functionali=
ty but it's
> > > > >> > > more of a side effect than anything. =A0It's just that t=
he amount of
> > > > >> > > memory consumed by packets in the queue(s) doesn't reall=
y have any
> > > > >> > > implicit meaning for flow control (think multiple physic=
al adapters,
> > > > >> > > all with the same speed instead of a virtual device and =
a physical
> > > > >> > > device with wildly different speeds). =A0The analog in t=
he physical
> > > > >> > > world that you're looking for would be Ethernet flow con=
trol.
> > > > >> > > Obviously, if the question is limiting CPU or memory con=
sumption then
> > > > >> > > that's a different story.
> > > > >> >
> > > > >> > Point taken. I will see if I can control CPU (and thus mem=
ory) consumption
> > > > >> > using cgroups and/or tc.
> > > > >>
> > > > >> I have found that I can successfully control the throughput =
using
> > > > >> the following techniques
> > > > >>
> > > > >> 1) Place a tc egress filter on dummy0
> > > > >>
> > > > >> 2) Use ovs-ofctl to add a flow that sends skbs to dummy0 and=
 then eth1,
> > > > >> =A0 =A0this is effectively the same as one of my hacks to th=
e datapath
> > > > >> =A0 =A0that I mentioned in an earlier mail. The result is th=
at eth1
> > > > >> =A0 =A0"paces" the connection.
> >=20
> > This is actually a bug. This means that one slow connection will af=
fect
> > fast ones. I intend to change the default for qemu to sndbuf=3D0 : =
this
> > will fix it but break your "pacing". So pls do not count on this
> > behaviour.
>=20
> Do you have a patch I could test?

You can (and users already can) just run qemu with sndbuf=3D0. But if y=
ou
like, below.

> > > > > Further to this, I wonder if there is any interest in providi=
ng
> > > > > a method to switch the action order - using ovs-ofctl is a ha=
ck imho -
> > > > > and/or switching the default action order for mirroring.
> > > >=20
> > > > I'm not sure that there is a way to do this that is correct in =
the
> > > > generic case.  It's possible that the destination could be a VM=
 while
> > > > packets are being mirrored to a physical device or we could be
> > > > multicasting or some other arbitrarily complex scenario.  Just =
think
> > > > of what a physical switch would do if it has ports with two dif=
ferent
> > > > speeds.
> > >=20
> > > Yes, I have considered that case. And I agree that perhaps there
> > > is no sensible default. But perhaps we could make it configurable=
 somehow?
> >=20
> > The fix is at the application level. Run netperf with -b and -w fla=
gs to
> > limit the speed to a sensible value.
>=20
> Perhaps I should have stated my goals more clearly.
> I'm interested in situations where I don't control the application.

Well an application that streams UDP without any throttling
at the application level will break on a physical network, right?
So I am not sure why should one try to make it work on the virtual one.

But let's assume that you do want to throttle the guest
for reasons such as QOS. The proper approach seems
to be to throttle the sender, not have a dummy throttled
receiver "pacing" it. Place the qemu process in the
correct net_cls cgroup, set the class id and apply a rate limit?


---

diff --git a/net/tap-linux.c b/net/tap-linux.c
index f7aa904..0dbcdd4 100644
--- a/net/tap-linux.c
+++ b/net/tap-linux.c
@@ -87,7 +87,7 @@ int tap_open(char *ifname, int ifname_size, int *vnet=
_hdr, int vnet_hdr_required
  * Ethernet NICs generally have txqueuelen=3D1000, so 1Mb is
  * a good default, given a 1500 byte MTU.
  */
-#define TAP_DEFAULT_SNDBUF 1024*1024
+#define TAP_DEFAULT_SNDBUF 0
=20
 int tap_set_sndbuf(int fd, QemuOpts *opts)
 {
