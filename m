From: "Oleg V. Ukhno" <olegu@yandex-team.ru>
Subject: Re: [PATCH] bonding: added 802.3ad round-robin hashing policy for
 single TCP session balancing
Date: Tue, 18 Jan 2011 15:40:39 +0300
Message-ID: <4D358A47.4020009@yandex-team.ru>
References: <20110114190714.GA11655@yandex-team.ru> <17405.1295036019@death> <4D30D37B.6090908@yandex-team.ru> <26330.1295049912@death> <4D35060D.5080004@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jay Vosburgh <fubar@us.ibm.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>
To: John Fastabend <john.r.fastabend@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from archeopterix.yandex.ru ([93.158.136.52]:41415 "EHLO
	archeopterix.yandex.ru" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750709Ab1ARMkn convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Jan 2011 07:40:43 -0500
In-Reply-To: <4D35060D.5080004@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/18/2011 06:16 AM, John Fastabend wrote:
> On 1/14/2011 4:05 PM, Jay Vosburgh wrote:
>> 	Can somebody (John?) more knowledgable than I about dm-multipath
>> comment on the above?
>
> Here I'll give it a go.
>
> I don't think detecting L2 link failure this way is very robust. If t=
here
> is a failure farther away then your immediate link your going to brea=
k
> completely? Your bonding hash will continue to round robin the iscsi
> packets and half them will get dropped on the floor. dm-multipath han=
dles
> this reasonably gracefully. Also in this bonding environment you seem=
 to
> be very sensitive to RTT times on the network. Maybe not bad out righ=
t but
> I wouldn't consider this robust either.

John, I agree - this bonding mode should be used in quite limited numbe=
r=20
of situations, but as for failure farther away then immediate link -=20
every bonding mode will suffer same problems in this case - bonding=20
detects only L2 failures, other is done by upper-layer mechanisms. And=20
almost all bonding modes depend on equal RTT on slaves. And, there is=20
already similar load balancing mode - balance-alb - what I did is=20
approximately the same, but for 802.3ad bonding mode and provides=20
"better"(more equal and non-conditional layser2) load striping for tx=20
and _rx_ .

I think I shouldn't mention the particular use case of this patch - whe=
n=20
I wrote it I tried to make a more general solution - my goal was "make=20
equal or near-equal load striping for TX and (most important part) RX=20
within single ethernet(layer 2) domain for  TCP transmission". This=20
bonding mode  just introduces ability to stripe rx and tx load for=20
single TCP connection between hosts inside of one ethernet segment.=20
iSCSI is just an example. It is possible to stripe load between a=20
linux-based router and linux-based web/ftp/etc server as well in the=20
same manner. I think this feature will be useful in some number of=20
network configurations.

  Also, I looked into net-next code - it seems to me that it can be=20
implemented(adapted to net-next bonding code) without any difficulties=20
and hashing function change makes no problem here.

What I've written below is just my personal experience and opinion afte=
r=20
5 years of using Oracle +iSCSI +mpath(later - patched bonding).

 From my personal experience I just can say that most iSCSI failures ar=
e=20
caused by link failures, and also I would never send any significant=20
iSCSI traffic via router - router would be a bottleneck in this case.
So, in my case iSCSI traffic flows within one ethernet domain and in=20
case of link failure bonding driver simply fails one slave(in case of=20
bonding) , instead of checking and failing hundreths of paths (in case=20
of mpath) and first case significantly less cpu, net and time=20
consuming(if using default mpath checker - readsector0).
Mpath is good for me, when I use it to "merge" drbd mirrors from=20
different hosts, but for just doing simple load striping within single=20
L2 network switch  between 2 .. 16 hosts is some overkill(particularly=20
in maintaining human-readable device naming) :).

John, what is you opinion on such load balancing method in general,=20
without referring to particular use cases?


>
> You could tweak your scsi timeout values and fail_fast values, set th=
e io
> retry to 0 to cause the fail over to occur faster. I suspect you alre=
ady
> did this and still it is too slow? Maybe adding a checker in multipat=
hd to
> listen for link events would be fast enough. The checker could then f=
ail
> the path immediately.
>
> I'll try to address your comments from the other thread here. In gene=
ral I
> wonder if it would be better to solve the problems in dm-multipath ra=
ther than
> add another bonding mode?
Of course I did this, but mpath is fine when device quantity is below=20
30-40 devices with two paths, 150-200 devices with 2+ paths can make=20
life far more interesting :)
>
> OVU - it is slow(I am using ISCSI for Oracle , so I need to minimize =
latency)
>
> The dm-multipath layer is adding latency? How much? If this is really=
 true
> maybe its best to the address the real issue here and not avoid it by
> using the bonding layer.

I do not remember exact number now, but switching one of my databases ,=
=20
about 2 years ago to bonding increased read throughput for the entire d=
b=20
from 15-20 Tb/day to approximately 30-35 Tb/day (4 iscsi initiators and=
=20
8 iscsi targets, 4 ethernet links for iSCSI on each host, all plugged i=
n=20
one switch) because of "full" bandwidth use. Also, bonding usage=20
simplifies network and application setup greatly(compared to mpath)

>
> OVU - it handles any link failures bad, because of it's command queue
> limitation(all queued commands above 32 are discarded in case of path
> failure, as I remember)
>
> Maybe true but only link failures with the immediate peer are handled
> with a bonding strategy. By working at the block layer we can detect
> failures throughout the path. I would need to look into this again I
> know when we were looking at this sometime ago there was some talk ab=
out
> improving this behavior. I need to take some time to go back through =
the
> error recovery stuff to remember how this works.
>
> OVU - it performs very bad when there are many devices and ma=D1=82y =
paths(I was
> unable to utilize more that 2Gbps of 4 even with 100 disks with 4 pat=
hs
> per each disk)

Well, I think that behavior can be explained in such a way:
when balancing by I/Os number per path(rr_min_io), and there is a huge=20
number of devices, mpath is doing load-balaning per-device, and it is=20
not possible to quarantee equal device use for all devices, so there=20
will be imbalance over network interface(mpath is unaware of it's=20
existence, etc), and it is likely it becomes more imbalanced when there=
=20
are many devices. Also, counting I/O's for many devices and paths=20
consumes some CPU resources and also can cause excessive context switch=
es.

>
> Hmm well that seems like something is broken. I'll try this setup whe=
n
> I get some time next few days. This really shouldn't be the case dm-m=
ultipath
> should not add a bunch of extra latency or effect throughput signific=
antly.
> By the way what are you seeing without mpio?

And one more obsevation from my 2-years old tests - reading device(usin=
g=20
dd) (rhel 5 update 1 kernel, ramdisk via ISCSI via loopback ) as mpath=20
device with single path was done at approximately 120-150mb/s, and same=
=20
test on non-mpath device at 800-900mb/s. Here I am quite sure, it was a=
=20
kind of revelation to me that time.

>
> Thanks,
> John
>


--=20
Best regards,
Oleg Ukhno.
ITO Team Lead,
Yandex LLC.

