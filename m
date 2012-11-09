From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH] ipv6: add knob to send unsolicited ND on link-layer address change
Date: Fri, 9 Nov 2012 14:01:41 +0100
Message-ID: <20121109130141.GA31099@order.stressinduktion.org>
References: <20121107024620.GD26398@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:43244 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751658Ab2KINBm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Nov 2012 08:01:42 -0500
Content-Disposition: inline
In-Reply-To: <20121107024620.GD26398@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Nov 07, 2012 at 03:46:20AM +0100, Hannes Frederic Sowa wrote:
> This patch introduces a new knob ndisc_notify. If enabled, the kernel
> will transmit an unsolicited neighbour advertisement on link-layer address
> change to update the neighbour tables of the corresponding hosts more quickly.
> 
> This is the equivalent to arp_notify in ipv4 world.

If this eases review, I have a test script to demonstrate the behaviour
(this needs the patch to change the mac address of a running veth, which was
merged into net-next some time ago and does only work correctly if unsolicited
neighbour advertisments are send to all-nodes):

#!/bin/bash
set -ex
set -o pipefail
declare -r NETNS=2337 R=$RANDOM
declare -r ULAM="fd8b:abf9:283d:1::/64" ULAM_ADDR="fd8b:abf9:283d:1::1/64"
declare -r ULAS="fd8b:abf9:283d:2::/64" ULAS_ADDR="fd8b:abf9:283d:2::1/64"
declare -r NS="ip netns exec $NETNS"
declare -r NMACM=00:00:6c:55:56:9e NMACS=00:00:6c:55:56:9e
function enable_forward {
    declare -r F="sysctl -w net.ipv6.conf.all.forwarding=1"
    $F
    $NS $F
}
function fetch_gw {
    echo "ip -6 -o a l group $NETNS dev $1 scope link 
	                     | awk '{print \$4}'"
}
case $1 in
    clean)
	ip netns delete $NETNS || true # ignore errors
	# seems to be racy here because deconstruction happens in a workqueue
	sleep 1
	for i in $(ip -o l l group $NETNS|cut -f2 -d:|egrep 'vmeth|dummy'); do
	    ip l d $i || true
	done
	;;
    '')
	declare -r vmeth=vmeth$R vseth=vseth$R
	echo 'file net/ipv6/ndisc.c +pflmt' > /sys/kernel/debug/dynamic_debug/control
	ip netns add $NETNS
	enable_forward
	ip link add name $vmeth type veth peer name $vseth
	ip link set dev $vmeth group $NETNS up
	ip link set dev $vseth netns $NETNS
	$NS ip link set dev $vseth group $NETNS up
	$NS ip l a name dummy$R up type dummy
	$NS ip l set dev dummy$R group $NETNS up
	ip a a $ULAM_ADDR dev $vmeth
	$NS ip a a $ULAS_ADDR dev dummy$R
	declare -r GWS=$(eval $NS $(fetch_gw $vseth))
	declare -r GWM=$(eval $(fetch_gw $vmeth))
	ip -6 r a $ULAS via ${GWS%/64} dev $vmeth
	$NS ip -6 r a $ULAM via ${GWM%/64} dev $vseth
	sleep 5
	time ping6 -w 100 -c 1 ${ULAS_ADDR%/64}
	# perf probes
	$0 internal $vmeth
	;;
    internal)
	sleep 5
	ip l set dev $2 addr $NMACM
	sleep 5
	time ping6 -w 100 -c 1 ${ULAS_ADDR%/64}
	;;
esac

David, if you intend to merge this patch, could you please remove the empty
line I accidently added in the addrconf_sysctl_table, directly following
.proc_handler? As usual, I noticed it just after sending the patch.
