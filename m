From: Chris Webb <chris@arachsys.com>
Subject: How to use macvtap/macvlan correctly
Date: Fri, 30 Sep 2011 09:49:35 +0100
Message-ID: <20110930084935.GC12879@arachsys.com>
References: <20100826114355.GA455@arachsys.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: qemu-devel@nongnu.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from alpha.arachsys.com ([91.203.57.7]:57928 "EHLO
	alpha.arachsys.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752725Ab1I3JSa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Sep 2011 05:18:30 -0400
Content-Disposition: inline
In-Reply-To: <20100826114355.GA455@arachsys.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I'm trying to get bridge-mode communication between a macvtap and a host
macvlan working correctly, but I think I must be doing something wrong as
the host macvlan and guest macvtap apparently can't communicate. I'm aware
that the underlying eth0 interface can't communicate with the macvtap, but I
thought that creating a host macvlan device and configuring that was the
standard work-around?

On a clean host running linux 3.0.4 and iptables 2.6.39, with no networking
except lo up with 127.0.0.1/8, I did

  ip link add link eth0 name host address 02:a3:a6:ed:4b:94 type macvlan mode bridge
  ip addr add 10.0.0.3/24 dev host
  ip link set eth0 up
  ip link set host up

I can ping a second host 10.0.0.1 attached to the eth0 interface of the test
host without problem.

I then created a macvtap device and launched a qemu guest against it:

  ip link add link eth0 name macvtap0 type macvtap mode bridge
  qemu-kvm -nographic -kernel /boot/vmlinuz-guest \
    -append "console=ttyS0 root=/dev/vda" \
    -drive file=/tmp/testroot.img,if=virtio,cache=none \
    -net nic,model=virtio,macaddr=$(< /sys/class/net/macvtap0/address) \
    -net tap,fd=3 3<>/dev/tap$(< /sys/class/net/macvtap0/ifindex)

Configuring the eth0 inside the guest with 10.0.0.4/24, I discovered I can
ping the external machine, but not the host, despite the macvtap and macvlan
being in bridge mode.

  # ping 10.0.0.1
  PING 10.0.0.1 (10.0.0.1): 48 data bytes
  56 bytes from 10.0.0.1: icmp_seq=0 ttl=64 time=0.351 ms
  56 bytes from 10.0.0.1: icmp_seq=1 ttl=64 time=0.360 ms
  56 bytes from 10.0.0.1: icmp_seq=2 ttl=64 time=0.281 ms
  ^C--- 10.0.0.1 ping statistics ---
  3 packets transmitted, 3 packets received, 0% packet loss
  round-trip min/avg/max/stddev = 0.281/0.331/0.360/0.035 ms

  # ping 10.0.0.3
  PING 10.0.0.3 (10.0.0.3): 48 data bytes
  ^C--- 10.0.0.3 ping statistics ---
  3 packets transmitted, 0 packets received, 100% packet loss

However something is working, because inside the guest:

# ip neigh
10.0.0.1 dev eth0 lladdr c8:0a:a9:37:29:6a REACHABLE
10.0.0.3 dev eth0 lladdr 02:a3:a6:ed:4b:94 REACHABLE

...and the MAC address it has for 10.0.0.3 is correct, so somehow an arp
request and response has got out to the host and back.

The kernel has

CONFIG_MACVLAN=y
CONFIG_MACVTAP=y
[...]
CONFIG_BRIDGE_NETFILTER=y
CONFIG_BRIDGE_NF_EBTABLES=y
CONFIG_BRIDGE=y
CONFIG_BRIDGE_IGMP_SNOOPING=y

(I didn't know off the top of my head if the bridge options are needed for
macvlan/vtap bridge mode, but they're compiled in anyway just in case.)

Any guesses what I've missed here?

Cheers,

Chris.
