From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: problem with MPLS and TSO/GSO
Date: Mon, 25 Jul 2016 19:39:15 +0300
Message-ID: <20160725163915.GE10080@wantstofly.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Alexander Duyck <aduyck@mirantis.com>, netdev@vger.kernel.org
To: David Ahern <dsa@cumulusnetworks.com>,
	Roopa Prabhu <roopa@cumulusnetworks.com>,
	Robert Shearman <rshearma@brocade.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hmm.wantstofly.org ([138.201.34.84]:59186 "EHLO
	mail.wantstofly.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752611AbcGYQjR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Jul 2016 12:39:17 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi!

I am seeing pretty horrible TCP transmit performance (anywhere between
1 and 10 Mb/s, on a 10 Gb/s interface) when traffic is sent out over a
route that involves MPLS labeling, and this seems to be due to an
interaction between MPLS and TSO/GSO that causes all segmentable TCP
frames that are MPLS-labeled to be dropped on egress.

I initially ran into this issue with the ixgbe driver, but it is easily
reproduced with veth interfaces, and the script attached below this
email reproduces the issue.  The script configures three network
namespaces: one that transmits TCP data (netperf) with MPLS labels,
one that takes the MPLS traffic and pops the labels and forwards the
traffic on, and one that receives the traffic (netserver).  When not
using MPLS labeling, I get ~30000 Mb/s single-stream TCP performance
in this setup on my test box, and with MPLS labeling, I get ~2 Mb/s.

Some investigating shows that egress TCP frames that need to be
segmented are being dropped in validate_xmit_skb(), which calls
skb_gso_segment() which calls skb_mac_gso_segment() which returns
-EPROTONOSUPPORT because we apparently didn't have the right kernel
module (mpls_gso) loaded.

(It's somewhat poor design, IMHO, to degrade network performance by
15000x if someone didn't load a kernel module they didn't know they
should have loaded, and in a way that doesn't log any warnings or
errors and can only be diagnosed by adding printk calls to net/core/
and recompiling your kernel.)

(Also, I'm not sure why mpls_gso is needed when ixgbe seems to be
able to natively do TSO on MPLS-labeled traffic, maybe because ixgbe
doesn't advertise the necessary features in ->mpls_features?  But
adding those bits doesn't seem to change much.)

But, loading mpls_gso doesn't change much -- skb_gso_segment() then
starts return -EINVAL instead, which is due to the
skb_network_protocol() call in skb_mac_gso_segment() returning zero.
And looking at skb_network_protocol(), I don't see how this is
supposed to work -- skb->protocol is 0 at this point, and there is no
way to figure out that what we are encapsulating is IP traffic, because
unlike what is the case with VLAN tags, MPLS labels aren't followed by
an inner ethertype that says what kind of traffic is in here, you have
to have explicit knowledge of the payload type for MPLS.

Any ideas?

Thanks in advance!


Cheers,
Lennert



=== problem.sh
#!/bin/sh

# ns0 sends out packets with mpls labels
# ns1 receives the labelled packets, pops the labels, and forwards to ns2
# ns2 receives the unlabelled packets and replies to ns0

ip netns add ns0
ip netns add ns1
ip netns add ns2

ip link add virt01 type veth peer name virt10
ip link set virt01 netns ns0
ip link set virt10 netns ns1

ip link add virt12 type veth peer name virt21
ip link set virt12 netns ns1
ip link set virt21 netns ns2

ip netns exec ns0 ip addr add 127.0.0.1/8 dev lo
ip netns exec ns0 ip link set lo up
ip netns exec ns0 ip addr add 172.16.20.20/24 dev virt01
ip netns exec ns0 ip link set virt01 up

ip netns exec ns1 ip addr add 127.0.0.1/8 dev lo
ip netns exec ns1 ip link set lo up
ip netns exec ns1 ip addr add 172.16.20.21/24 dev virt10
ip netns exec ns1 ip link set virt10 up
ip netns exec ns1 ip addr add 172.16.21.21/24 dev virt12
ip netns exec ns1 ip link set virt12 up

ip netns exec ns2 ip addr add 127.0.0.1/8 dev lo
ip netns exec ns2 ip link set lo up
ip netns exec ns2 ip addr add 172.16.21.22/24 dev virt21
ip netns exec ns2 ip link set virt21 up

modprobe mpls_iptunnel

ip netns exec ns0 ip route add 10.10.10.10/32 encap mpls 100 via inet 172.16.20.21 mtu lock 1496
#ip netns exec ns0 ip route add 172.16.21.0/24 via 172.16.20.21
ip netns exec ns0 ip route add 172.16.21.0/24 via 172.16.20.21 mtu lock 1496

ip netns exec ns1 sysctl -w net.ipv4.conf.all.rp_filter=0
ip netns exec ns1 sysctl -w net.ipv4.conf.default.rp_filter=0
ip netns exec ns1 sysctl -w net.ipv4.conf.lo.rp_filter=0
ip netns exec ns1 sysctl -w net.ipv4.conf.virt10.rp_filter=0
ip netns exec ns1 sysctl -w net.ipv4.conf.virt12.rp_filter=0
ip netns exec ns1 sysctl -w net.ipv4.ip_forward=1
ip netns exec ns1 sysctl -w net.mpls.conf.virt10.input=1
ip netns exec ns1 sysctl -w net.mpls.platform_labels=1000
ip netns exec ns1 ip -f mpls route add 100 via inet 172.16.21.22

ip netns exec ns2 ip addr add 10.10.10.10/32 dev lo
ip netns exec ns2 ip route add 172.16.20.0/24 via 172.16.21.21

ip netns exec ns0 ping -c 1 10.10.10.10

ip netns exec ns2 netserver

# non-mpls
ip netns exec ns0 netperf -c -C -H 172.16.21.22 -l 10 -t TCP_STREAM

# mpls (retry this with mpls_gso loaded)
ip netns exec ns0 netperf -c -C -H 10.10.10.10 -l 10 -t TCP_STREAM
