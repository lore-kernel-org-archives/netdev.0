From: Nicholas Thomas <nick@bytemark.co.uk>
Subject: Re: tap devices not receiving packets from a bridge
Date: Tue, 14 May 2013 15:21:24 +0100
Message-ID: <1368541284.15129.317.camel@eboracum.office.bytemark.co.uk>
References: <50AE36E0.8000307@dlhnet.de>
	<20121123070211.GC22787@stefanha-thinkpad.hitronhub.home>
	<E85C6011-548D-4507-A776-1028DD3E3515@dlhnet.de>
	<20121123110146.GC7051@redhat.com> <50FE5607.9020405@dlhnet.de>
	<20130123100312.GA8108@redhat.com>  <5119E9DC.3000505@dlhnet.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Stefan Hajnoczi <stefanha@gmail.com>, netdev@vger.kernel.org,
	qemu-devel@nongnu.org, "Michael S. Tsirkin" <mst@redhat.com>
To: Peter Lieven <pl@dlhnet.de>
Return-path: <qemu-devel-bounces+gceq-qemu-devel=gmane.org@nongnu.org>
In-Reply-To: <5119E9DC.3000505@dlhnet.de>
List-Unsubscribe: <https://lists.nongnu.org/mailman/options/qemu-devel>,
	<mailto:qemu-devel-request@nongnu.org?subject=unsubscribe>
List-Archive: <http://lists.nongnu.org/archive/html/qemu-devel>
List-Post: <mailto:qemu-devel@nongnu.org>
List-Help: <mailto:qemu-devel-request@nongnu.org?subject=help>
List-Subscribe: <https://lists.nongnu.org/mailman/listinfo/qemu-devel>,
	<mailto:qemu-devel-request@nongnu.org?subject=subscribe>
Errors-To: qemu-devel-bounces+gceq-qemu-devel=gmane.org@nongnu.org
Sender: qemu-devel-bounces+gceq-qemu-devel=gmane.org@nongnu.org
List-Id: netdev.vger.kernel.org

Hi all,

On Tue, 2013-02-12 at 08:06 +0100, Peter Lieven wrote:
> On 23.01.2013 11:03, Michael S. Tsirkin wrote:
> > For future, we can try to set TUN_ONE_QUEUE flag on the interface,
> > or try applying this patch
> > 5d097109257c03a71845729f8db6b5770c4bbedc
> > in kernel see if this helps.
> >
> 
> If have set this option for 2 weeks now and not seen this problem again.
> How does this flag work with the recently added tap multiqueue support?
> 
> Peter

( Host systems are Linux kernel 3.2, from debian squeeze-backports, in
all cases. The guests use virtio-net, the hosts use netxen_nic )

We run QEMU like: 

qemu-system-x86_64 -enable-kvm -[...] \
  -net user,vlan=50,name=user,restrict=y
  -net nic,macaddr=fe:ff:00:00:00:00,name=t100,model=virtio,vlan=748
  -net tap,downscript=no,name=t100,script=no,vlan=748,ifname=t100 [...]

The TAP devices are created by us, by calling the appropriate ioctls,
more or less like:
fd = open("/dev/net/tun", "a+")
ioctl(fd, TUNSETIFF, "t100", IFF_TAP | IFF_NO_PI | IFF_ONE_QUEUE )
ioctl(fd, TUNSETOWNER, "t100", 20000)
ioctl(fd, TUNSETGROUP, "t100", 108)
ioctl(fd, SIOCSIFHWADDR, "t100", ARPHRD_ETHER, "fe:ff:00:00:00:00")
ioctl(fd, TUNSETPERSIST, "t100", 1)

(I'm translating ruby code here, but that's the gist of it)

We used to run QEMU 0.15.0, and didn't set IFF_ONE_QUEUE on the tap
devices we created. We never saw this bug. Last week, we began upgrading
to QEMU 1.4.1; our imager setup (netboot, download a large disc image
over HTTP, run a script in it) immediately began triggering this bug,
quite reliably. 

We changed our code to set IFF_ONE_QUEUE on the tap devices we created,
and this has reduced the frequency with which the bug is triggered, but
we still experience it from time to time. Over 5 trials, I triggered the
bug three times.

Interestingly, while the guest fails to receive packets, no TX overruns
to the tap device are initially reported on the host (by ifconfig). The
overrun counter ticks to 1 after I ping the guest a few times, like so:

Before:

t100      Link encap:Ethernet  HWaddr ae:17:96:7d:32:3f  
          inet6 addr: fe80::ac17:96ff:fe7d:323f/64 Scope:Link
          UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
          RX packets:58006 errors:0 dropped:0 overruns:0 frame:0
          TX packets:57992 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:500 
          RX bytes:3825467 (3.6 MiB)  TX bytes:87661451 (83.6 MiB)


After:

t100      Link encap:Ethernet  HWaddr ae:17:96:7d:32:3f  
          inet6 addr: fe80::ac17:96ff:fe7d:323f/64 Scope:Link
          UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
          RX packets:58006 errors:0 dropped:0 overruns:0 frame:0
          TX packets:57992 errors:0 dropped:0 overruns:1 carrier:0
          collisions:0 txqueuelen:500 
          RX bytes:3825467 (3.6 MiB)  TX bytes:87661451 (83.6 MiB)


The packets are still visible coming in on the bridge interface, and the
bridge knows the MAC address of the guest. I'm afraid I'm at a bit of a
loss on how to track this down; can anyone advise? 

/Nick
