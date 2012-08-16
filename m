From: Chris Webb <chris@arachsys.com>
Subject: Slow inbound traffic on macvtap interfaces
Date: Thu, 16 Aug 2012 10:20:05 +0100
Message-ID: <20120816092004.GA1894@arachsys.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jason Wang <jasowang@redhat.com>, Arnd Bergmann <arnd@arndb.de>,
	"Michael S. Tsirkin" <mst@redhat.com>
To: netdev@vger.kernel.org, qemu-devel@nongnu.org
Return-path: <qemu-devel-bounces+gceq-qemu-devel=gmane.org@nongnu.org>
Content-Disposition: inline
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

I'm experiencing a problem with qemu + macvtap which I can reproduce on a
variety of hardware, with kernels varying from 3.0.4 (the oldest I tried) to
3.5.1 and with qemu[-kvm] versions 0.14.1, 1.0, and 1.1.

Large data transfers over TCP into a guest from another machine on the
network are very slow (often less than 100kB/s) whereas transfers outbound
from the guest, between two guests on the same host, or between the guest
and its host run at normal speeds (>= 50MB/s).

The slow inbound data transfer speeds up substantially when a ping flood is
aimed either at the host or the guest, or when the qemu process is straced.
Presumably both of these are ways to wake up something that is otherwise
sleeping too long?

For example, I can run

  ip addr add 192.168.1.2/24 dev eth0
  ip link set eth0 up
  ip link add link eth0 name tap0 address 02:02:02:02:02:02 type macvtap mode bridge
  ip link set tap0 up
  qemu-kvm -hda debian.img -cpu host -m 512 -vnc :0 \
    -net nic,model=virtio,macaddr=02:02:02:02:02:02 \
    -net tap,fd=3 3<>/dev/tap$(< /sys/class/net/tap0/ifindex)

on one physical host which is otherwise completely idle. From a second
physical host on the same network, I then scp a large (say 50MB) file onto
the new guest. On a gigabit LAN, speeds consistently drop to less than
100kB/s as the transfer progresses, within a second of starting.

The choice of virtio virtual nic in the above isn't significant: the same thing
happens with e1000 or rtl8139. You can also replace the scp with a straight
netcat and see the same effect.

Doing the transfer in the other direction (i.e. copying a large file from the
guest to an external host) achieves 50MB/s or faster as expected. Copying
between two guests on the same host (i.e. taking advantage of the 'mode
bridge') is also fast.

If I create a macvlan device attached to eth0 and move the host IP address to
that, I can communicate between the host itself and the guest because of the
'mode bridge'. Again, this case is fast in both directions.

Using a bridge and a standard tap interface, transfers in and out are fast
too:

  ip tuntap add tap0 mode tap
  brctl addbr br0
  brctl addif br0 eth0
  brctl addif br0 tap1
  ip link set eth0 up
  ip link set tap0 up
  ip link set br0 up
  ip addr add 192.168.1.2/24 dev br0
  qemu-kvm -hda debian.img -cpu host -m 512 -vnc :0 \
    -net nic,model=virtio,macaddr=02:02:02:02:02:02 \
    -net tap,script=no,downscript=no,ifname=tap0

As mentioned in the summary at the beginning of this report, when I strace a
guest in the original configuration which is receiving data slowly, the data
rate improves from less than 100kB/s to around 3.1MB/s. Similarly, if I ping
flood either the guest or the host it is running on from another machine on
the network, the transfer rate improves to around 1.1MB/s. This seems quite
suggestive of a problem with delayed wake-up of the guest.

Two reasonably up-to-date examples of machines I've reproduced this on are
my laptop with an r8169 gigabit ethernet card, Debian qemu-kvm 1.0 and
upstream 3.4.8 kernel whose .config and boot dmesg are at

  http://cdw.me.uk/tmp/laptop-config.txt
  http://cdw.me.uk/tmp/laptop-dmesg.txt

and one of our large servers with an igb gigabit ethernet card, upstream
qemu-kvm 1.1.1 and upstream 3.5.1 linux:

  http://cdw.me.uk/tmp/server-config.txt
  http://cdw.me.uk/tmp/server-dmesg.txt

For completeness, I've put the Debian 6 test image I've been using for
testing at

  http://cdw.me.uk/tmp/test-debian.img.xz

though I've see the same problem from a variety of guest operating systems.
(In fact, I've not yet found any combination of host kernel, guest OS and
hardware which doesn't show these symptoms, so it seems to be very easy to
reproduce.)

Cheers,

Chris.
