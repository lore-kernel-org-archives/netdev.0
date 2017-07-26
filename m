From: Stephen Hemminger <stephen@networkplumber.org>
Subject: [PATCH net-next v2 00/10] netvsc fixes and new features
Date: Wed, 26 Jul 2017 16:40:19 -0700
Message-ID: <20170726234029.7342-1-sthemmin@microsoft.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: devel@linuxdriverproject.org, linux-doc@vger.kernel.org,
        netdev@vger.kernel.org
To: kys@microsoft.com, haiyangz@microsoft.com, sthemmin@microsoft.com,
        corbet@lwn.net
Return-path: <linux-doc-owner@vger.kernel.org>
Sender: linux-doc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This series has updates for Hyper-V network driver.
The first four patches are just minor fixes.

The next group of patches aims to reduce the driver memory footprint
by reducing the size of the per-device receive and send buffers, and
the per-channel receive completion queue.

The biggest change is in the last three patches that implement transparent
management of SR-IOV VF device. A little more explaination is required.

What does it do?

With the new netvsc VF logic, the Linux hyper-V network
virtual driver will directly manage the link to SR-IOV VF device.
When VF device is detected (hot plug) it is automatically made a
slave device of the netvsc device. The VF device state reflects
the state of the netvsc device; i.e. if netvsc is set down, then
VF is set down. If netvsc is set up, then VF is brought up.
 
Packet flow is independent of VF status; all packets are sent and
received as if they were associated with the netvsc device. If VF is
removed or link is down then the synthetic VMBUS path is used.
 
What was wrong with using bonding script?

A lot of work went into getting the bonding script to work on all
distributions, but it was a major struggle. Linux network devices
can be configured many, many ways and there is no one solution from
userspace to make it all work. What is really hard is when
configuration is attached to synthetic device during boot (eth0) and
then the same addresses and firewall rules needs to also work later if
doing bonding. The new code gets around all of this.
 
How does VF work during initialization?

Since all packets are sent and received through the logical netvsc
device, initialization is much easier. Just configure the regular
netvsc Ethernet device; when/if SR-IOV is enabled it just
works. Provisioning and cloud init only need to worry about setting up
netvsc device (eth0). If SR-IOV is enabled (even as a later step), the
address and rules stay the same.
 
What devices show up?

Both netvsc and PCI devices are visible in the system. The netvsc
device is active and named in usual manner (eth0). The PCI device is
visible to Linux and gets renamed by udev to a persistent name
(enP2p3s0). The PCI device name is now irrelevant now.

The logica also sets the PCI VF device SLAVE flag on the network
device so network tools can see the relationship if they are smart
enough to understand how layered devices work.
 
This is a lot like how I see Windows working.
The VF device is visible in Device Manager, but is not configured.
 
Is there any performance impact?
There is no visible change in performance. The bonding
and netvsc driver both have equivalent steps.
 
Is it compatible with old bonding script?

It turns out that if you use the old bonding script, then everything
still works but in a sub-optimum manner. What happens is that bonding
is unable to steal the VF from the netvsc device so it creates a one
legged bond.  Packet flow then is:
	bond0 <--> eth0 <- -> VF (enP2p3s0).
In other words, if you get it wrong it still works, just
awkward and slower.
 
What if I add address or firewall rule onto the VF?

Same problems occur with now as already occur with bonding, bridging,
teaming on Linux if user incorrectly does configuration onto
an underlying slave device. It will sort of work, packets will come in
and out but the Linux kernel gets confused and things like ARP don’t
work right.  There is no way to block manipulation of the slave
device, and I am sure someone will find some special use case where
they want it.

Stephen Hemminger (10):
  netvsc: fix return value for set_channels
  netvsc: fix warnings reported by lockdep
  netvsc: don't print pointer value in error message
  netvsc: remove unnecessary indirection of page_buffer
  netvsc: optimize receive completions
  netvsc: signal host if receive ring is emptied
  netvsc: allow smaller send/recv buffer size
  netvsc: transparent VF management
  netvsc: add documentation
  netvsc: remove bonding setup script

 Documentation/networking/netvsc.txt |  50 ++++
 MAINTAINERS                         |   1 +
 drivers/net/hyperv/hyperv_net.h     |  33 ++-
 drivers/net/hyperv/netvsc.c         | 317 +++++++++++-------------
 drivers/net/hyperv/netvsc_drv.c     | 476 ++++++++++++++++++++++++++++--------
 drivers/net/hyperv/rndis_filter.c   | 108 ++++----
 tools/hv/bondvf.sh                  | 255 -------------------
 7 files changed, 642 insertions(+), 598 deletions(-)
 create mode 100644 Documentation/networking/netvsc.txt
 delete mode 100755 tools/hv/bondvf.sh

-- 
2.11.0

