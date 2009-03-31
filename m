From: Gregory Haskins <ghaskins@novell.com>
Subject: [RFC PATCH 00/17] virtual-bus
Date: Tue, 31 Mar 2009 14:42:47 -0400
Message-ID: <20090331184057.28333.77287.stgit@dev.haskins.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: agraf@suse.de, pmullaney@novell.com, pmorreale@novell.com,
	anthony@codemonkey.ws, rusty@rustcorp.com.au,
	netdev@vger.kernel.org, kvm@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <kvm-owner@vger.kernel.org>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

applies to v2.6.29 (will port to git HEAD soon)

=46IRST OFF: Let me state that this is not a KVM or networking specific
technology.  Virtual-Bus is a mechanism for defining and deploying
software =E2=80=9Cdevices=E2=80=9D directly in a Linux kernel.  The exa=
mple use-case we
have provided supports a =E2=80=9Cvirtual-ethernet=E2=80=9D device bein=
g utilized in a
KVM guest environment, so comparisons to virtio-net will be natural.
However, please note that this is but one use-case, of many we have
planned for the future (such as userspace bypass and RT guest support).
The goal for right now is to describe what a virual-bus is and why we
believe it is useful.

We are intent to get this core technology merged, even if the networkin=
g
components are not accepted as is.  It should be noted that, in many wa=
ys,
virtio could be considered complimentary to the technology.  We could
in fact, have implemented the virtual-ethernet using a virtio-ring, but
it would have required ABI changes that we didn't want to yet propose
without having the concept in general vetted and accepted by the commun=
ity.

To cut to the chase, we recently measured our virtual-ethernet on=20
v2.6.29 on two 8-core x86_64 boxes with Chelsio T3 10GE connected back
to back via cross over.  We measured bare-metal performance, as well
as a kvm guest (running the same kernel) connected to the T3 via
a linux-bridge+tap configuration with a 1500 MTU.  The results are as
follows:

Bare metal: tput =3D 4078Mb/s, round-trip =3D 25593pps (39us rtt)
Virtio-net: tput =3D 4003Mb/s, round-trip =3D 320pps (3125us rtt)
Venet: tput =3D 4050Mb/s, round-trip =3D 15255 (65us rtt)

As you can see, all three technologies can achieve (MTU limited) line-r=
ate,
but the virtio-net solution is severely limited on the latency front (b=
y a
factor of 48:1)

Note that the 320pps is technically artificially low in virtio-net, cau=
sed by a
a known design limitation to use a timer for tx-mitigation.  However, n=
ote that
even when removing the timer from the path the best we could achieve wa=
s
350us-450us of latency, and doing so causes the tput to drop to 1300Mb/=
s.
So even in this case, I think the in-kernel results presents a compelli=
ng
argument for the new model presented.

When we jump to 9000 byte MTU, the situation looks similar

Bare metal: tput =3D 9717Mb/s, round-trip =3D 30396pps (33us rtt)
Virtio-net: tput =3D 4578Mb/s, round-trip =3D 249pps (4016us rtt)
Venet: tput =3D 5802Mb/s, round-trip =3D 15127 (66us rtt)


Note that even the throughput was slightly better in this test for vene=
t, though
neither venet nor virtio-net could achieve line-rate.  I suspect some t=
uning may
allow these numbers to improve, TBD.

So with that said, lets jump into the description:

Virtual-Bus: What is it?
--------------------

Virtual-Bus is a kernel based IO resource container technology.  It is =
modeled
on a concept similar to the Linux Device-Model (LDM), where we have bus=
es,
devices, and drivers as the primary actors.  However, VBUS has several
distinctions when contrasted with LDM:

  1) "Busses" in LDM are relatively static and global to the kernel (e.=
g.
     "PCI", "USB", etc).  VBUS buses are arbitrarily created and destro=
yed
     dynamically, and are not globally visible.  Instead they are defin=
ed as
     visible only to a specific subset of the system (the contained con=
text).
  2) "Devices" in LDM are typically tangible physical (or sometimes log=
ical)
     devices.  VBUS devices are purely software abstractions (which may=
 or
     may not have one or more physical devices behind them).  Devices m=
ay
     also be arbitrarily created or destroyed by software/administrativ=
e action
     as opposed to by a hardware discovery mechanism.
  3) "Drivers" in LDM sit within the same kernel context as the busses =
and
     devices they interact with.  VBUS drivers live in a foreign
     context (such as userspace, or a virtual-machine guest).

The idea is that a vbus is created to contain access to some IO service=
s.
Virtual devices are then instantiated and linked to a bus to grant acce=
ss to
drivers actively present on the bus.  Drivers will only have visibility=
 to
devices present on their respective bus, and nothing else.

Virtual devices are defined by modules which register a deviceclass wit=
h the
system.  A deviceclass simply represents a type of device that _may_ be
instantiated into a device, should an administrator wish to do so.  Onc=
e
this has happened, the device may be associated with one or more buses =
where
it will become visible to all clients of those respective buses.

Why do we need this?
----------------------

There are various reasons why such a construct may be useful.  One of t=
he
most interesting use cases is for virtualization, such as KVM.  Hypervi=
sors
today provide virtualized IO resources to a guest, but this is often at=
 a cost
in both latency and throughput compared to bare metal performance.  Uti=
lizing
para-virtual resources instead of emulated devices helps to mitigate th=
is
penalty, but even these techniques to date have not fully realized the
potential of the underlying bare-metal hardware.

Some of the performance differential is unavoidable just given the extr=
a
processing that occurs due to the deeper stack (guest+host).  However, =
some of
this overhead is a direct result of the rather indirect path most hyper=
visors
use to route IO.  For instance, KVM uses PIO faults from the guest to t=
rigger
a guest->host-kernel->host-userspace->host-kernel sequence of events.
Contrast this to a typical userspace application on the host which must=
 only
traverse app->kernel for most IO.

The fact is that the linux kernel is already great at managing access t=
o IO
resources.  Therefore, if you have a hypervisor that is based on the li=
nux
kernel, is there some way that we can allow the hypervisor to manage IO
directly instead of forcing this convoluted path?

The short answer is: "not yet" ;)

In order to use such a concept, we need some new facilties.  For one, w=
e
need to be able to define containers with their corresponding access-co=
ntrol so
that guests do not have unmitigated access to anything they wish.  Seco=
nd,
we also need to define some forms of memory access that is uniform in t=
he face
of various clients (e.g. "copy_to_user()" cannot be assumed to work for=
, say,
a KVM vcpu context).  Lastly, we need to provide access to these resour=
ces in
a way that makes sense for the application, such as asynchronous commun=
ication
paths and minimizing context switches.

So we introduce VBUS as a framework to provide such facilities.  The ne=
t
result is a *substantial* reduction in IO overhead, even when compared =
to
state of the art para-virtualization techniques (such as virtio-net).

=46or more details, please visit our wiki at:

http://developer.novell.com/wiki/index.php/Virtual-bus

Regards,
-Greg

---

Gregory Haskins (17):
      kvm: Add guest-side support for VBUS
      kvm: Add VBUS support to the host
      kvm: add dynamic IRQ support
      kvm: add a reset capability
      x86: allow the irq->vector translation to be determined outside o=
f ioapic
      venettap: add scatter-gather support
      venet: add scatter-gather support
      venet-tap: Adds a "venet" compatible "tap" device to VBUS
      net: Add vbus_enet driver
      venet: add the ABI definitions for an 802.x packet interface
      ioq: add vbus helpers
      ioq: Add basic definitions for a shared-memory, lockless queue
      vbus: add a "vbus-proxy" bus model for vbus_driver objects
      vbus: add bus-registration notifiers
      vbus: add connection-client helper infrastructure
      vbus: add virtual-bus definitions
      shm-signal: shared-memory signals


 Documentation/vbus.txt           |  386 +++++++++
 arch/x86/Kconfig                 |   16=20
 arch/x86/Makefile                |    3=20
 arch/x86/include/asm/irq.h       |    6=20
 arch/x86/include/asm/kvm_host.h  |    9=20
 arch/x86/include/asm/kvm_para.h  |   12=20
 arch/x86/kernel/io_apic.c        |   25 +
 arch/x86/kvm/Kconfig             |    9=20
 arch/x86/kvm/Makefile            |    6=20
 arch/x86/kvm/dynirq.c            |  329 ++++++++
 arch/x86/kvm/guest/Makefile      |    2=20
 arch/x86/kvm/guest/dynirq.c      |   95 ++
 arch/x86/kvm/x86.c               |   13=20
 arch/x86/kvm/x86.h               |   12=20
 drivers/Makefile                 |    2=20
 drivers/net/Kconfig              |   13=20
 drivers/net/Makefile             |    1=20
 drivers/net/vbus-enet.c          |  933 ++++++++++++++++++++++
 drivers/vbus/devices/Kconfig     |   17=20
 drivers/vbus/devices/Makefile    |    1=20
 drivers/vbus/devices/venet-tap.c | 1587 ++++++++++++++++++++++++++++++=
++++++++
 drivers/vbus/proxy/Makefile      |    2=20
 drivers/vbus/proxy/kvm.c         |  726 +++++++++++++++++
 fs/proc/base.c                   |   96 ++
 include/linux/ioq.h              |  410 ++++++++++
 include/linux/kvm.h              |    4=20
 include/linux/kvm_guest.h        |    7=20
 include/linux/kvm_host.h         |   27 +
 include/linux/kvm_para.h         |   60 +
 include/linux/sched.h            |    4=20
 include/linux/shm_signal.h       |  188 +++++
 include/linux/vbus.h             |  162 ++++
 include/linux/vbus_client.h      |  115 +++
 include/linux/vbus_device.h      |  423 ++++++++++
 include/linux/vbus_driver.h      |   80 ++
 include/linux/venet.h            |   82 ++
 kernel/Makefile                  |    1=20
 kernel/exit.c                    |    2=20
 kernel/fork.c                    |    2=20
 kernel/vbus/Kconfig              |   38 +
 kernel/vbus/Makefile             |    6=20
 kernel/vbus/attribute.c          |   52 +
 kernel/vbus/client.c             |  527 +++++++++++++
 kernel/vbus/config.c             |  275 +++++++
 kernel/vbus/core.c               |  626 +++++++++++++++
 kernel/vbus/devclass.c           |  124 +++
 kernel/vbus/map.c                |   72 ++
 kernel/vbus/map.h                |   41 +
 kernel/vbus/proxy.c              |  216 +++++
 kernel/vbus/shm-ioq.c            |   89 ++
 kernel/vbus/vbus.h               |  117 +++
 lib/Kconfig                      |   22 +
 lib/Makefile                     |    2=20
 lib/ioq.c                        |  298 +++++++
 lib/shm_signal.c                 |  186 ++++
 virt/kvm/kvm_main.c              |   37 +
 virt/kvm/vbus.c                  | 1307 ++++++++++++++++++++++++++++++=
+
 57 files changed, 9902 insertions(+), 1 deletions(-)
 create mode 100644 Documentation/vbus.txt
 create mode 100644 arch/x86/kvm/dynirq.c
 create mode 100644 arch/x86/kvm/guest/Makefile
 create mode 100644 arch/x86/kvm/guest/dynirq.c
 create mode 100644 drivers/net/vbus-enet.c
 create mode 100644 drivers/vbus/devices/Kconfig
 create mode 100644 drivers/vbus/devices/Makefile
 create mode 100644 drivers/vbus/devices/venet-tap.c
 create mode 100644 drivers/vbus/proxy/Makefile
 create mode 100644 drivers/vbus/proxy/kvm.c
 create mode 100644 include/linux/ioq.h
 create mode 100644 include/linux/kvm_guest.h
 create mode 100644 include/linux/shm_signal.h
 create mode 100644 include/linux/vbus.h
 create mode 100644 include/linux/vbus_client.h
 create mode 100644 include/linux/vbus_device.h
 create mode 100644 include/linux/vbus_driver.h
 create mode 100644 include/linux/venet.h
 create mode 100644 kernel/vbus/Kconfig
 create mode 100644 kernel/vbus/Makefile
 create mode 100644 kernel/vbus/attribute.c
 create mode 100644 kernel/vbus/client.c
 create mode 100644 kernel/vbus/config.c
 create mode 100644 kernel/vbus/core.c
 create mode 100644 kernel/vbus/devclass.c
 create mode 100644 kernel/vbus/map.c
 create mode 100644 kernel/vbus/map.h
 create mode 100644 kernel/vbus/proxy.c
 create mode 100644 kernel/vbus/shm-ioq.c
 create mode 100644 kernel/vbus/vbus.h
 create mode 100644 lib/ioq.c
 create mode 100644 lib/shm_signal.c
 create mode 100644 virt/kvm/vbus.c

--=20
Signature
