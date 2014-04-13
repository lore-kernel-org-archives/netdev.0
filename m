From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH] tuntap: add flow control to support back pressure
Date: Sun, 13 Apr 2014 17:14:18 +0300
Message-ID: <20140413141418.GA17839@redhat.com>
References: <5345FFBC.7020502@adjacentlink.com>
 <20140410102931.GA12077@redhat.com>
 <5347487B.4040608@adjacentlink.com>
 <34F30F7A-5AEF-4E7B-9513-7A008CEE8820@nrl.navy.mil>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Steven Galgano <sgalgano@adjacentlink.com>, davem@davemloft.net,
	jasowang@redhat.com, xemul@parallels.com, wuzhy@linux.vnet.ibm.com,
	therbert@google.com, yamato@redhat.com, richardcochran@gmail.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Joseph Giovatto <jgiovatto@adjacentlink.com>
To: Brian Adamson <Brian.Adamson@nrl.navy.mil>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <34F30F7A-5AEF-4E7B-9513-7A008CEE8820@nrl.navy.mil>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Steven, Brian,

thanks for reporting this issue.
Please see my comments below.

On Fri, Apr 11, 2014 at 12:41:42PM -0400, Brian Adamson wrote:
> To weigh in on the desire to have support (at least as an optional be=
havior) for the legacy flow control behavior, there are many existing u=
ses of it.  Many these are related to experimental purposes where the t=
untap driver can be used (with a little user space code) as a surrogate=
 for a network interface type that may not even yet exist.  And in some=
 cases these experimental purposes have had utility for actual deployme=
nt (e.g. disaster relief wireless networks where  the TAP device has pr=
ovided some intermediate assistance for routing or other protocols, eve=
n an underwater acoustic sensor network proposed for reef monitoring, e=
tc where a TAP device provides a network interface and the sound card i=
s used as a modem on an embedded system).  Some of these networks have =
low data rates or packet loss and delays that make TCP (which provides =
flow control as part of its usual reliable transport for more typical n=
etworking purpose) not an ideal protocol to use and so UDP or other alt=
ernatives or used.  To keep this short, I'll list a few use cases here =
I know (and was involved with the implementation of some) with some lin=
ks (where I know them):
>=20
> 1) CORE network emulation tool  (http://code.google.com/p/coreemu/)
>=20
> 2) EMANE network emulation tool (https://github.com/adjacentlink/eman=
e)
>=20
> (likely other network emulation tools exist that have used tuntap as =
surrogates for real physical interfaces and expect the same backpressur=
e to sockets and queues that physical interfaces provide)
>=20
> 3) I don't have a link to it but I implemented an experimental IP int=
erface/ MAC protocol called SLIDE (serial-link internet daemon) that im=
plemented a user-space CSMA MAC protocol where an underwater acoustic m=
odem was connected to the serial port and TAP was used to present a vir=
tual network interface to the IP stack.  Because of the low data rates =
involved, the back pressure flow control to application sockets (and pr=
otocol daemons and qdiscs applied)  was important.
>=20
> 4)  User space implementation of Simplified Multicast Forwarding (SMF=
) of RFC 6621 has a "device" option that establishes TAP interfaces to =
perform distributed "backpressure" based flow control (and potentially =
routing) for MANET wireless networks.  (http://www.nrl.navy.mil/itd/ncs=
/products/smf)
>=20
> There are probably some more, among the more esoteric wireless and ot=
her special networking communities, where host (or routing/gateway/prox=
y non-host), e.g. special embedded system devices based on Linux such a=
s sensors, etc) have a first hop network attachment that is _not_ the t=
ypical Ethernet or something and may be using tuntap along with a sort =
of user-space "driver" to present an IP interface to the network stack.=
 some of this stuff, especially embedded systems, tend to lag behind wi=
th respect to kernel versions and this behavior change in Linux may be =
yet undiscovered so far even though the change was put in a couple year=
s ago.
>=20
> Several of these are implemented across multiple platforms, and, for =
example, BSD-based systems tuntap provides the same flow control behavi=
or.  Even if it was never formally documented, I think this behavior wa=
s fairly well known (at least for these sorts of experimental purposes)=
 and used.  I understand the concern that a single bad behaving flow ca=
n possibly block the flow of others unless traffic control queuing disc=
iplines (as done for other network interfaces).  For the purposes of wh=
ich I'm aware, I think having this behavior as _optional_ is probably O=
K =E2=80=A6 If accepted, and something is implemented here, it may be a=
 good opportunity to have it documented (and the pros and cons of its u=
se) for the more general Linux community.

Yes, a UDP socket with sufficiently deep qdisc and tun queues
would previously get slowed down so it matches the speed of
the interface.

But IIUC this was not really designed to be a flow control measure,
so depending on what else is in the qdisc you could easily get
into a setup where it behaves exactly as it does now.
=46or example, have several UDP sockets send data out a single
interface.

Another problem is that this depends on userspace to be
well-behaved and consume packets in a timely manner:
a misbehaving userspace operating a tun device can cause other
tun devices and/or sockets to get blocked forever and prevent them
from communicating with all destinations (not just the misbehaving one)
as their wmem limit is exhausted.

It should be possible to reproduce with an old kernel and your userspac=
e
drivers, too - just stop the daemon temporarily.
I realize that your daemon normally is well-behaved, and
simply moves all incoming packets to the backend without
delay, but I'd like to find a solution that addresses
this without trusting userspace to be responsive.




At the moment, for this use-case it's possible to limit the speed of tu=
n
interface using a non work conserving qdisc.  Make that match the speed
of the backend device, and you get back basically the old behaviour
without the security problem in that the rate is basically ensured
by kernel and all packets queued are eventually consumed.

Does this solve the problem for you?


> BTW, in my initial noticing this issue, it _seemed_ that even the def=
ault interface pfifo_fast priority bands were not being properly enforc=
ed for the tap interface without the old flow control behavior?.  I nee=
d to do a little more "old vs new" comparison testing on this regard.
>=20
> best regards,
>=20
> Brian=20

I think that as tun is never stopped, nothing is ever queued in qdisc.


> On Apr 10, 2014, at 9:42 PM, Steven Galgano <sgalgano@adjacentlink.co=
m> wrote:
>=20
> > On 04/10/2014 06:29 AM, Michael S. Tsirkin wrote:
> >> On Wed, Apr 09, 2014 at 10:19:40PM -0400, Steven Galgano wrote:
> >>> Add tuntap flow control support for use by back pressure routing =
protocols. Setting the new TUNSETIFF flag IFF_FLOW_CONTROL, will signal=
 resources as unavailable when the tx queue limit is reached by issuing=
 a netif_tx_stop_all_queues() rather than discarding frames. A netif_tx=
_wake_all_queues() is issued after reading a frame from the queue to si=
gnal resource availability.
> >>>=20
> >>> Back pressure capability was previously supported by the legacy t=
un default mode. This change restores that functionality, which was las=
t present in v3.7.
> >>>=20
> >>> Reported-by: Brian Adamson <brian.adamson@nrl.navy.mil>
> >>> Tested-by: Joseph Giovatto <jgiovatto@adjacentlink.com>
> >>> Signed-off-by: Steven Galgano <sgalgano@adjacentlink.com>
> >>=20
> >> I don't think it's a good idea.
> >>=20
> >> This trivial flow control really created more problems than it was=
 worth.
> >>=20
> >> In particular this blocks all flows so it's trivially easy for one=
 flow
> >> to block and starve all others: just send a bunch of packets to lo=
opback
> >> destinations that get queued all over the place.
> >>=20
> >> Luckily it was never documented so we changed the default and noth=
ing
> >> seems to break, but we won't be so lucky if we add an explicit API=
=2E
> >>=20
> >>=20
> >> One way to implement this would be with ubuf_info callback this is
> >> already invoked in most places where a packet might get stuck for =
a long
> >> time.  It's still incomplete though: this will prevent head of que=
ue
> >> blocking literally forever, but a single bad flow can still degrad=
e
> >> performance significantly.
> >>=20
> >> Another alternative is to try and isolate the flows that we
> >> can handle and throttle them.
> >>=20
> >> It's all fixable but we really need to fix the issues *before*
> >> exposing the interface to userspace.
> >>=20
> >>=20
> >>=20
> >=20
> > It was only after recent upgrades that we picked up a newer kernel =
and
> > discovered the change to the default tun mode.
> >=20
> > The new default behavior has broken applications that depend on the
> > legacy behavior. Although not documented, the legacy behavior was w=
ell
> > known at least to those working in the back pressure research commu=
nity.
> > The default legacy mode was/is a valid use case although I am not s=
ure
> > it fits with recent multiqueue support.
> >=20
> > When back pressure protocols are running over a tun interface they
> > require legacy flow control in order to communicate congestion dete=
cted
> > on the physical media they are using. Multiqueues do not apply here=
=2E
> > These protocols only use one queue, so netif_tx_stop_all_queues() i=
s the
> > necessary behavior.
> >=20
> > I'm not tied to the idea of IFF_FLOW_CONTROL. I was aiming for midd=
le
> > ground where an application controlling the tun interface can state=
 it
> > wants the legacy flow control behavior understanding its limitation=
s
> > concerning multiple queues.
> >=20
> > What if we resurrect IFF_ONE_QUEUE and use that as a mechanism to
> > indicate legacy flow control. A tun instance initially configured w=
ith
> > IFF_ONE_QUEUE would not be allowed to attach or detach queues with
> > TUNSETQUEUE and any additional opens with the same device name woul=
d
> > fail. This mode would use the
> > netif_tx_stop_all_queues()/netif_tx_wake_all_queues() flow control
> > mechanism.
> >=20
> > If a tun application wants the current default behavior with only a
> > single queue, it would not set the IFF_ONE_QUEUE flag. Not setting
> > IFF_MULTI_QUEUE would not imply IFF_ONE_QUEUE.
> >=20
> > I'd be happy to implement this change if it is an acceptable soluti=
on.
> > This would allow multiqueue tun development to advance while still
> > supporting use cases dependent on legacy flow control.
> >=20
> > -steve
> >=20
> >>> ---
> >>> diff --git a/drivers/net/tun.c b/drivers/net/tun.c
> >>> index ee328ba..268130c 100644
> >>> --- a/drivers/net/tun.c
> >>> +++ b/drivers/net/tun.c
> >>> @@ -783,8 +783,19 @@ static netdev_tx_t tun_net_xmit(struct sk_bu=
ff *skb, struct net_device *dev)
> >>> 	 * number of queues.
> >>> 	 */
> >>> 	if (skb_queue_len(&tfile->socket.sk->sk_receive_queue) * numqueu=
es
> >>> -			  >=3D dev->tx_queue_len)
> >>> -		goto drop;
> >>> +			>=3D dev->tx_queue_len) {
> >>> +		if (tun->flags & TUN_FLOW_CONTROL) {
> >>> +			/* Resources unavailable stop transmissions */
> >>> +			netif_tx_stop_all_queues(dev);
> >>> +
> >>> +			/* We won't see all dropped packets individually, so
> >>> +			 * over run error is more appropriate.
> >>> +			 */
> >>> +			dev->stats.tx_fifo_errors++;
> >>> +		} else {
> >>> +			goto drop;
> >>> +		}
> >>> +	}
> >>>=20
> >>> 	if (unlikely(skb_orphan_frags(skb, GFP_ATOMIC)))
> >>> 		goto drop;
> >>> @@ -1362,6 +1373,9 @@ static ssize_t tun_do_read(struct tun_struc=
t *tun, struct tun_file *tfile,
> >>> 			continue;
> >>> 		}
> >>>=20
> >>> +		/* Wake in case resources previously signaled unavailable */
> >>> +		netif_tx_wake_all_queues(tun->dev);
> >>> +
> >>> 		ret =3D tun_put_user(tun, tfile, skb, iv, len);
> >>> 		kfree_skb(skb);
> >>> 		break;
> >>> @@ -1550,6 +1564,9 @@ static int tun_flags(struct tun_struct *tun=
)
> >>> 	if (tun->flags & TUN_PERSIST)
> >>> 		flags |=3D IFF_PERSIST;
> >>>=20
> >>> +	if (tun->flags & TUN_FLOW_CONTROL)
> >>> +		flags |=3D IFF_FLOW_CONTROL;
> >>> +
> >>> 	return flags;
> >>> }
> >>>=20
> >>> @@ -1732,6 +1749,11 @@ static int tun_set_iff(struct net *net, st=
ruct file *file, struct ifreq *ifr)
> >>> 	else
> >>> 		tun->flags &=3D ~TUN_TAP_MQ;
> >>>=20
> >>> +	if (ifr->ifr_flags & IFF_FLOW_CONTROL)
> >>> +		tun->flags |=3D TUN_FLOW_CONTROL;
> >>> +	else
> >>> +		tun->flags &=3D ~TUN_FLOW_CONTROL;
> >>> +
> >>> 	/* Make sure persistent devices do not get stuck in
> >>> 	 * xoff state.
> >>> 	 */
> >>> @@ -1900,7 +1922,8 @@ static long __tun_chr_ioctl(struct file *fi=
le, unsigned int cmd,
> >>> 		 * This is needed because we never checked for invalid flags on
> >>> 		 * TUNSETIFF. */
> >>> 		return put_user(IFF_TUN | IFF_TAP | IFF_NO_PI | IFF_ONE_QUEUE |
> >>> -				IFF_VNET_HDR | IFF_MULTI_QUEUE,
> >>> +				IFF_VNET_HDR | IFF_MULTI_QUEUE |
> >>> +				IFF_FLOW_CONTROL,
> >>> 				(unsigned int __user*)argp);
> >>> 	} else if (cmd =3D=3D TUNSETQUEUE)
> >>> 		return tun_set_queue(file, &ifr);
> >>> diff --git a/include/uapi/linux/if_tun.h b/include/uapi/linux/if_=
tun.h
> >>> index e9502dd..bcf2790 100644
> >>> --- a/include/uapi/linux/if_tun.h
> >>> +++ b/include/uapi/linux/if_tun.h
> >>> @@ -36,6 +36,7 @@
> >>> #define TUN_PERSIST 	0x0100=09
> >>> #define TUN_VNET_HDR 	0x0200
> >>> #define TUN_TAP_MQ      0x0400
> >>> +#define TUN_FLOW_CONTROL 0x0800
> >>>=20
> >>> /* Ioctl defines */
> >>> #define TUNSETNOCSUM  _IOW('T', 200, int)=20
> >>> @@ -70,6 +71,7 @@
> >>> #define IFF_MULTI_QUEUE 0x0100
> >>> #define IFF_ATTACH_QUEUE 0x0200
> >>> #define IFF_DETACH_QUEUE 0x0400
> >>> +#define IFF_FLOW_CONTROL 0x0010
> >>> /* read-only flag */
> >>> #define IFF_PERSIST	0x0800
> >>> #define IFF_NOFILTER	0x1000
