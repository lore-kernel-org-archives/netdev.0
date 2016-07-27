From: Patrick Schaaf <netdev@bof.de>
Subject: CPU utilization with kvm / vhost, differences 3.14 / 4.4 / 4.6
Date: Wed, 27 Jul 2016 18:04:27 +0200
Message-ID: <14276407.TsEd2NX9sg@rofl>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
To: netdev@vger.kernel.org, linux-kernel <linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

I'm stumped by a weird development in measured CPU utilization when testing an 
upgrade path from 3.14.70 to 4.4.14.

I'm running, on identical hardware (2 4-core Xeon E5420), a HA 
(active/standby) pair of firewall/loadbalancer VMs. The OS on the host and the 
VM is identical - openSUSE 13.1 userlevel, qemu 1.6.2 KVM, and kernels self-
built from vanilla sources. Inside the VM I make pretty heavy use of ipset, 
iptables, and ipvs. Traffic level is around 100 mbit/s, mostly ordinary web 
traffic, translating to around 10 kpps.

For the last X months I have been running this on 3.14.x kernels, currently 
3.14.70. As that's nearing its end of support, I aim for an upgrade to 4.4.x, 
testing with 4.4.14.

For testing, I keep the kernel _within_ the VM stable - i.e. 3.14.70, and 
upgrade only the host kernel of one of the two machines, to 4.4.14, and due to 
the weirdness I'll describe next, to 4.6.4.

What I see, and what is totally unexpected, is a severe variation in the 
system and irq time measured on the host system, and less so inside the VM.

The 3.14.70 running host shows 0.6 cores system and 0.4 cores IRQ time.

The 4.4.14 running host shows 2.3 cores system and 0.4 cores IRQ time.

The same host on 4.6.4, is again back at 0.6 cores system and 0.4 cores IRQ, 
while the guest (showing as user outside) is down from the 1 core on the 
previous to kernels, to about 0.6 cores (which I wouldn't complain about)

But my desired target kernel, 4.4.14, clearly uses about 1 1/2 cores more on 
the same load... (all other indicators and measurements I have show that the 
load served is pretty much stable over the situations I tested).

Some details on the networking setup (invariant over the tested kernels):
* host bonds 4 NICs, half on on-board BNX2 BCM5708, other half on PCIe card 
intel 82571EB hardware. The bond mode is LACP.
* host lacp bond is then member of an ordinary software bridge interface,
  which then also has the tap interface to the VM added. There is vlan
  filtering active on the bridge.
* two bridge vlans are separately broken out and member of a second layer 
bridge with an extra tap interface to my VM. Don't ask why :) but one of these 
carries about half of the traffic
* within the VM, I have another bridge with the VLANs on top and macvlan 
sprinkled in (keepalived VRRP setup on several legs)
* host/vm network is virtio, of course
* I had to disable (already some time ago, identical in all tests described 
here) TSO / GSO / UFO on the tap interfaces to my VM, to alleviate severe 
performance regressions. Different story, mentioning it just for completeness.

Regarding the host hardware, I actually have a third system, software 
identical, but with some more cores and purely on BNX2 BCM5719. The 4.4.14-
needs-lots-more-systemtime symptoms were practically the same there.

To end this tale, let me note that I have NO operational problems with the 
test using the 4.4.14 kernel, as far as one can know that within some hours of 
testing. All production metrics (and I have lots of them) are fine - except 
for that system time usage on the host system...

Anybody got a clue what may be happening?

I'm a bit reluctant to jump to 4.6.x or newer kernels, as I like the concept 
of long term stable kernels somehow... :)


best regards
  Patrick
