From: Emmanuel Jeanvoine <emmanuel.jeanvoine@inria.fr>
Subject: Poor TCP bandwidth between network namespaces
Date: Mon, 4 Feb 2013 15:43:20 +0100
Message-ID: <20130204144320.GG1353@tostaky>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail2-relais-roc.national.inria.fr ([192.134.164.83]:47091 "EHLO
	mail2-relais-roc.national.inria.fr" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753188Ab3BDOvY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Feb 2013 09:51:24 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

I'm trying to understand some performance issues when transferring 
data over TCP between two Linux network namespaces (with veth 
interfaces) on the same host.

Here is my approach:
I'm measuring the network performance thanks to netpipe-tcp (debian 
wheezy package) in two situations:
- using the loopback interface (i.e. launching netpipe client and 
server on the same node)
- using netpipe server inside a netns ans netpipe client inside 
another one, but both netns are on the same node.

This has been scripted in order to ease the reproducibility. This 
require to have an 'ip' utility that supports 'netns' argument and 
netpipe-tcp installed. Furthermore, this is using the 192.168.64/24 
network but this can changed if required. Here is the script:
#!/bin/sh
#This script has to be launched as root
#
###Reference measurement
echo "### Iperf execution without netns (localhost)"
NPtcp &
NPtcp -h localhost -o np-local
echo
###Netns measurement
#Prepare bridge and netns vnodes
brctl addbr br0
ip addr add 192.168.64.1/24 dev br0
ip link set br0 up
#First virtual node creation
ip link add name ext0 type veth peer name int0
ip link set ext0 up
brctl addif br0 ext0
ip netns add vnode0
ip link set dev int0 netns vnode0
ip netns exec vnode0 ip addr add 192.168.64.2/24 dev int0 
ip netns exec vnode0 ip link set dev int0 up
#Second virtual node creation
ip link add name ext1 type veth peer name int0
ip link set ext1 up
brctl addif br0 ext1
ip netns add vnode1
ip link set dev int0 netns vnode1
ip netns exec vnode1 ip addr add 192.168.64.3/24 dev int0
ip netns exec vnode1 ip link set dev int0 up
echo "### Iperf execution inside netns"
ip netns exec vnode0 NPtcp &
sleep 1
ip netns exec vnode1 NPtcp -h 192.168.64.2 -o np-netns
# Cleaning everything
ifconfig br0 down
brctl delbr br0
ip netns delete vnode0
ip netns delete vnode1


This experiment has been performed with 3.2 and 3.7 kernels, and here 
are the results:
- on a 3.2 kernel: 
http://www.loria.fr/~ejeanvoi/pub/netns-kernel-3.2.png
- on a 3.7 kernel: 
http://www.loria.fr/~ejeanvoi/pub/netns-kernel-3.7.png

I'm wondering why the overhead is so high when performing TCP 
transfers between two network namespaces. Do you have any idea about 
this issue? And possibly, how to increase the bandwidth (without 
modifying the MTU on the veths) between network namespaces?

Thanks in advance,
Emmanuel Jeanvoine.
