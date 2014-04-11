From: Brian Adamson <Brian.Adamson@nrl.navy.mil>
Subject: Re: [PATCH] tuntap: add flow control to support back pressure
Date: Fri, 11 Apr 2014 12:41:42 -0400
Message-ID: <34F30F7A-5AEF-4E7B-9513-7A008CEE8820@nrl.navy.mil>
References: <5345FFBC.7020502@adjacentlink.com> <20140410102931.GA12077@redhat.com> <5347487B.4040608@adjacentlink.com>
Mime-Version: 1.0 (Mac OS X Mail 6.6 \(1510\))
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "Michael S. Tsirkin" <mst@redhat.com>, davem@davemloft.net,
	jasowang@redhat.com, xemul@parallels.com, wuzhy@linux.vnet.ibm.com,
	therbert@google.com, yamato@redhat.com, richardcochran@gmail.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Joseph Giovatto <jgiovatto@adjacentlink.com>
To: Steven Galgano <sgalgano@adjacentlink.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <5347487B.4040608@adjacentlink.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

To weigh in on the desire to have support (at least as an optional beha=
vior) for the legacy flow control behavior, there are many existing use=
s of it.  Many these are related to experimental purposes where the tun=
tap driver can be used (with a little user space code) as a surrogate f=
or a network interface type that may not even yet exist.  And in some c=
ases these experimental purposes have had utility for actual deployment=
 (e.g. disaster relief wireless networks where  the TAP device has prov=
ided some intermediate assistance for routing or other protocols, even =
an underwater acoustic sensor network proposed for reef monitoring, etc=
 where a TAP device provides a network interface and the sound card is =
used as a modem on an embedded system).  Some of these networks have lo=
w data rates or packet loss and delays that make TCP (which provides fl=
ow control as part of its usual reliable transport for more typical net=
working purpose) not an ideal protocol to use and so UDP or other alter=
natives or used.  To keep this short, I'll list a few use cases here I =
know (and was involved with the implementation of some) with some links=
 (where I know them):

1) CORE network emulation tool  (http://code.google.com/p/coreemu/)

2) EMANE network emulation tool (https://github.com/adjacentlink/emane)

(likely other network emulation tools exist that have used tuntap as su=
rrogates for real physical interfaces and expect the same backpressure =
to sockets and queues that physical interfaces provide)

3) I don't have a link to it but I implemented an experimental IP inter=
face/ MAC protocol called SLIDE (serial-link internet daemon) that impl=
emented a user-space CSMA MAC protocol where an underwater acoustic mod=
em was connected to the serial port and TAP was used to present a virtu=
al network interface to the IP stack.  Because of the low data rates in=
volved, the back pressure flow control to application sockets (and prot=
ocol daemons and qdiscs applied)  was important.

4)  User space implementation of Simplified Multicast Forwarding (SMF) =
of RFC 6621 has a "device" option that establishes TAP interfaces to pe=
rform distributed "backpressure" based flow control (and potentially ro=
uting) for MANET wireless networks.  (http://www.nrl.navy.mil/itd/ncs/p=
roducts/smf)

There are probably some more, among the more esoteric wireless and othe=
r special networking communities, where host (or routing/gateway/proxy =
non-host), e.g. special embedded system devices based on Linux such as =
sensors, etc) have a first hop network attachment that is _not_ the typ=
ical Ethernet or something and may be using tuntap along with a sort of=
 user-space "driver" to present an IP interface to the network stack. s=
ome of this stuff, especially embedded systems, tend to lag behind with=
 respect to kernel versions and this behavior change in Linux may be ye=
t undiscovered so far even though the change was put in a couple years =
ago.

Several of these are implemented across multiple platforms, and, for ex=
ample, BSD-based systems tuntap provides the same flow control behavior=
=2E  Even if it was never formally documented, I think this behavior wa=
s fairly well known (at least for these sorts of experimental purposes)=
 and used.  I understand the concern that a single bad behaving flow ca=
n possibly block the flow of others unless traffic control queuing disc=
iplines (as done for other network interfaces).  For the purposes of wh=
ich I'm aware, I think having this behavior as _optional_ is probably O=
K =85 If accepted, and something is implemented here, it may be a good =
opportunity to have it documented (and the pros and cons of its use) fo=
r the more general Linux community.

BTW, in my initial noticing this issue, it _seemed_ that even the defau=
lt interface pfifo_fast priority bands were not being properly enforced=
 for the tap interface without the old flow control behavior?.  I need =
to do a little more "old vs new" comparison testing on this regard.

best regards,

Brian=20

On Apr 10, 2014, at 9:42 PM, Steven Galgano <sgalgano@adjacentlink.com>=
 wrote:

> On 04/10/2014 06:29 AM, Michael S. Tsirkin wrote:
>> On Wed, Apr 09, 2014 at 10:19:40PM -0400, Steven Galgano wrote:
>>> Add tuntap flow control support for use by back pressure routing pr=
otocols. Setting the new TUNSETIFF flag IFF_FLOW_CONTROL, will signal r=
esources as unavailable when the tx queue limit is reached by issuing a=
 netif_tx_stop_all_queues() rather than discarding frames. A netif_tx_w=
ake_all_queues() is issued after reading a frame from the queue to sign=
al resource availability.
>>>=20
>>> Back pressure capability was previously supported by the legacy tun=
 default mode. This change restores that functionality, which was last =
present in v3.7.
>>>=20
>>> Reported-by: Brian Adamson <brian.adamson@nrl.navy.mil>
>>> Tested-by: Joseph Giovatto <jgiovatto@adjacentlink.com>
>>> Signed-off-by: Steven Galgano <sgalgano@adjacentlink.com>
>>=20
>> I don't think it's a good idea.
>>=20
>> This trivial flow control really created more problems than it was w=
orth.
>>=20
>> In particular this blocks all flows so it's trivially easy for one f=
low
>> to block and starve all others: just send a bunch of packets to loop=
back
>> destinations that get queued all over the place.
>>=20
>> Luckily it was never documented so we changed the default and nothin=
g
>> seems to break, but we won't be so lucky if we add an explicit API.
>>=20
>>=20
>> One way to implement this would be with ubuf_info callback this is
>> already invoked in most places where a packet might get stuck for a =
long
>> time.  It's still incomplete though: this will prevent head of queue
>> blocking literally forever, but a single bad flow can still degrade
>> performance significantly.
>>=20
>> Another alternative is to try and isolate the flows that we
>> can handle and throttle them.
>>=20
>> It's all fixable but we really need to fix the issues *before*
>> exposing the interface to userspace.
>>=20
>>=20
>>=20
>=20
> It was only after recent upgrades that we picked up a newer kernel an=
d
> discovered the change to the default tun mode.
>=20
> The new default behavior has broken applications that depend on the
> legacy behavior. Although not documented, the legacy behavior was wel=
l
> known at least to those working in the back pressure research communi=
ty.
> The default legacy mode was/is a valid use case although I am not sur=
e
> it fits with recent multiqueue support.
>=20
> When back pressure protocols are running over a tun interface they
> require legacy flow control in order to communicate congestion detect=
ed
> on the physical media they are using. Multiqueues do not apply here.
> These protocols only use one queue, so netif_tx_stop_all_queues() is =
the
> necessary behavior.
>=20
> I'm not tied to the idea of IFF_FLOW_CONTROL. I was aiming for middle
> ground where an application controlling the tun interface can state i=
t
> wants the legacy flow control behavior understanding its limitations
> concerning multiple queues.
>=20
> What if we resurrect IFF_ONE_QUEUE and use that as a mechanism to
> indicate legacy flow control. A tun instance initially configured wit=
h
> IFF_ONE_QUEUE would not be allowed to attach or detach queues with
> TUNSETQUEUE and any additional opens with the same device name would
> fail. This mode would use the
> netif_tx_stop_all_queues()/netif_tx_wake_all_queues() flow control
> mechanism.
>=20
> If a tun application wants the current default behavior with only a
> single queue, it would not set the IFF_ONE_QUEUE flag. Not setting
> IFF_MULTI_QUEUE would not imply IFF_ONE_QUEUE.
>=20
> I'd be happy to implement this change if it is an acceptable solution=
=2E
> This would allow multiqueue tun development to advance while still
> supporting use cases dependent on legacy flow control.
>=20
> -steve
>=20
>>> ---
>>> diff --git a/drivers/net/tun.c b/drivers/net/tun.c
>>> index ee328ba..268130c 100644
>>> --- a/drivers/net/tun.c
>>> +++ b/drivers/net/tun.c
>>> @@ -783,8 +783,19 @@ static netdev_tx_t tun_net_xmit(struct sk_buff=
 *skb, struct net_device *dev)
>>> 	 * number of queues.
>>> 	 */
>>> 	if (skb_queue_len(&tfile->socket.sk->sk_receive_queue) * numqueues
>>> -			  >=3D dev->tx_queue_len)
>>> -		goto drop;
>>> +			>=3D dev->tx_queue_len) {
>>> +		if (tun->flags & TUN_FLOW_CONTROL) {
>>> +			/* Resources unavailable stop transmissions */
>>> +			netif_tx_stop_all_queues(dev);
>>> +
>>> +			/* We won't see all dropped packets individually, so
>>> +			 * over run error is more appropriate.
>>> +			 */
>>> +			dev->stats.tx_fifo_errors++;
>>> +		} else {
>>> +			goto drop;
>>> +		}
>>> +	}
>>>=20
>>> 	if (unlikely(skb_orphan_frags(skb, GFP_ATOMIC)))
>>> 		goto drop;
>>> @@ -1362,6 +1373,9 @@ static ssize_t tun_do_read(struct tun_struct =
*tun, struct tun_file *tfile,
>>> 			continue;
>>> 		}
>>>=20
>>> +		/* Wake in case resources previously signaled unavailable */
>>> +		netif_tx_wake_all_queues(tun->dev);
>>> +
>>> 		ret =3D tun_put_user(tun, tfile, skb, iv, len);
>>> 		kfree_skb(skb);
>>> 		break;
>>> @@ -1550,6 +1564,9 @@ static int tun_flags(struct tun_struct *tun)
>>> 	if (tun->flags & TUN_PERSIST)
>>> 		flags |=3D IFF_PERSIST;
>>>=20
>>> +	if (tun->flags & TUN_FLOW_CONTROL)
>>> +		flags |=3D IFF_FLOW_CONTROL;
>>> +
>>> 	return flags;
>>> }
>>>=20
>>> @@ -1732,6 +1749,11 @@ static int tun_set_iff(struct net *net, stru=
ct file *file, struct ifreq *ifr)
>>> 	else
>>> 		tun->flags &=3D ~TUN_TAP_MQ;
>>>=20
>>> +	if (ifr->ifr_flags & IFF_FLOW_CONTROL)
>>> +		tun->flags |=3D TUN_FLOW_CONTROL;
>>> +	else
>>> +		tun->flags &=3D ~TUN_FLOW_CONTROL;
>>> +
>>> 	/* Make sure persistent devices do not get stuck in
>>> 	 * xoff state.
>>> 	 */
>>> @@ -1900,7 +1922,8 @@ static long __tun_chr_ioctl(struct file *file=
, unsigned int cmd,
>>> 		 * This is needed because we never checked for invalid flags on
>>> 		 * TUNSETIFF. */
>>> 		return put_user(IFF_TUN | IFF_TAP | IFF_NO_PI | IFF_ONE_QUEUE |
>>> -				IFF_VNET_HDR | IFF_MULTI_QUEUE,
>>> +				IFF_VNET_HDR | IFF_MULTI_QUEUE |
>>> +				IFF_FLOW_CONTROL,
>>> 				(unsigned int __user*)argp);
>>> 	} else if (cmd =3D=3D TUNSETQUEUE)
>>> 		return tun_set_queue(file, &ifr);
>>> diff --git a/include/uapi/linux/if_tun.h b/include/uapi/linux/if_tu=
n.h
>>> index e9502dd..bcf2790 100644
>>> --- a/include/uapi/linux/if_tun.h
>>> +++ b/include/uapi/linux/if_tun.h
>>> @@ -36,6 +36,7 @@
>>> #define TUN_PERSIST 	0x0100=09
>>> #define TUN_VNET_HDR 	0x0200
>>> #define TUN_TAP_MQ      0x0400
>>> +#define TUN_FLOW_CONTROL 0x0800
>>>=20
>>> /* Ioctl defines */
>>> #define TUNSETNOCSUM  _IOW('T', 200, int)=20
>>> @@ -70,6 +71,7 @@
>>> #define IFF_MULTI_QUEUE 0x0100
>>> #define IFF_ATTACH_QUEUE 0x0200
>>> #define IFF_DETACH_QUEUE 0x0400
>>> +#define IFF_FLOW_CONTROL 0x0010
>>> /* read-only flag */
>>> #define IFF_PERSIST	0x0800
>>> #define IFF_NOFILTER	0x1000
