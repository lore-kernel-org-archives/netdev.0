From: Or Gerlitz <ogerlitz@voltaire.com>
Subject: some veth related issues
Date: Tue, 4 Aug 2009 17:30:04 +0300 (IDT)
Message-ID: <Pine.LNX.4.64.0908041650560.13803@zuben.voltaire.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from fwil.voltaire.com ([193.47.165.2]:36441 "EHLO exil.voltaire.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1754506AbZHDOaP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 4 Aug 2009 10:30:15 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I'm trying to do some veth testing and came into couple of issues:

1. when doing a veth(1,0)->bridge->veth(2,3) test using pktgen the packet size reported
by the veth and bridge statistics is eight bytes wheres the pkt_size param to pktgen is 64

However, if doing ping -s 22 on a veth(1,0)->bridge->NIC config, the reported packet size
is 50 which makes sense since the NIC adds/removes the L2 header of 14 bytes.

2. veth(1,0)->bridge->veth(2,3) pktgen test works in the sense that packets are forwarded
by the bridge to the veth-(2,3) device pair, but pktgen veth(1,0)->bridge->NIC doesn't work
- no TX counters are increased on the NIC (I run some traffic "from" veth-3 and the NIC devices
to avoid the bridge flooding path).

To debug the issue failure to get veth(1,0)->bridge->NIC config working, I removed the bridge,
run pktgen over veth1 and opened a tcpdump on veth0, the resulted dump looks quite bad, see below.

Here's some data, any ideas will be very much appreciated, this is 2.6.30

Or.

ping on veth(1,0)->bridge->NIC the reported packet size (bytes/packets) is 64 on eth1 and 50 on veth1/0

Inter-|   Receive                                                |  Transmit
 face |bytes    packets errs drop fifo frame compressed multicast|bytes    packets
  eth1:24911352  389240    0    0    0     0          0         0 24926644  389304
 veth1:19466002  389256    0    0    0     0          0         0 19468999  389270
 veth0:19468999  389270    0    0    0     0          0         0 19466002  389256

pktgen veth(1,0)->bridge->veth(2,3) the reported packet size is 8 on veth1 and veth3 but
the pkt_size param was 64

Inter-|   Receive                                                |  Transmit
 face |bytes    packets errs drop fifo frame compressed multicast|bytes    packets
 veth1:    4066      17    0    0    0     0          0         0 80007992 10000030
 veth0:80007992 10000030    0    0    0     0          0         0     4066      17
 veth3:80004818 10000012    0    0    0     0          0         0     6370      30
 veth2:    6370      30    0    0    0     0          0         0 80004818 10000012


here's the tcpdump output, I told pktgen to send 10 packets and delay for a second between packets,
to make sure tcpdump captures everything. The first packet is what I was expecting, but none of the
ones that follow... below is the pktgen script I used and some config info

72:ec:8e:4f:89:01 > 72:ec:8e:4f:89:03, ethertype IPv4 (0x0800), length 64: 20.20.49.11.discard > 20.20.49.13.discard: UDP, length 22
00:00:20:11:ab:09 > 45:00:00:32:65:72, ethertype Unknown (0x1414), length 50:
	0x0000:  310b 1414 310d 0009 0009 001e 0000 be9b  1...1...........
	0x0010:  e955 0000 0001 4a78 a286 0001 5afc 6d6f  .U....Jx....Z.mo
	0x0020:  6465 000a                                de..
00:09:00:09:00:1e > 31:0b:14:14:31:0d, 802.3, length 36: LLC, dsap Unknown (0xbe), ssap Unknown (0x9a), cmd 0x55e9: Supervisory, Receiver Ready, rcv seq 42, Flags [Command, Poll], length 22
00:01:4a:78:a2:86 > be:9b:e9:55:00:00, 802.3, length 22: LLC, dsap Unknown (0x5a), ssap Unknown (0xfc), cmd 0x6f6d: Supervisory, Receiver not Ready, rcv seq 55, Flags [Command, Poll], length 8
[|ether]
[|ether]
[|ether]
[|ether]
[|ether]
[|ether]

# ifconfig | grep veth
veth0     Link encap:Ethernet  HWaddr 72:EC:8E:4F:89:00
veth1     Link encap:Ethernet  HWaddr 72:EC:8E:4F:89:01
veth2     Link encap:Ethernet  HWaddr 72:EC:8E:4F:89:02
veth3     Link encap:Ethernet  HWaddr 72:EC:8E:4F:89:03

#! /bin/sh

#modprobe pktgen


function pgset() {
    local result

    echo $1 > $PGDEV

    result=`cat $PGDEV | fgrep "Result: OK:"`
    if [ "$result" = "" ]; then
         cat $PGDEV | fgrep Result:
    fi
}

function pg() {
    echo inject > $PGDEV
    cat $PGDEV
}

# Config Start Here -----------------------------------------------------------


# thread config
# Each CPU has own thread. Two CPU exammple. We add veth1, eth2 respectivly.

PGDEV=/proc/net/pktgen/kpktgend_0
  echo "Removing all devices"
 pgset "rem_device_all"
  echo "Adding veth1"
 pgset "add_device veth1"
  echo "Setting max_before_softirq 10000"
 pgset "max_before_softirq 10000"


# device config
# delay 0 means maximum speed.

CLONE_SKB="clone_skb 1000000"
# NIC adds 4 bytes CRC
PKT_SIZE="pkt_size 64"

# COUNT 0 means forever
#COUNT="count 0"
COUNT="count 10"
DELAY="delay 1000000000"

PGDEV=/proc/net/pktgen/veth1
  echo "Configuring $PGDEV"
 pgset "$COUNT"
 pgset "$CLONE_SKB"
 pgset "$PKT_SIZE"
 pgset "$DELAY"

 pgset "src_min 20.20.49.11"
 pgset "src_max 20.20.49.11"
 pgset "src_mac 72:ec:8e:4f:89:01"

 pgset "dst 20.20.49.13"
 pgset "dst_mac 72:ec:8e:4f:89:03"

# Time to run
PGDEV=/proc/net/pktgen/pgctrl

 echo "Running... ctrl^C to stop"
 pgset "start"
 echo "Done"

# Result can be vieved in /proc/net/pktgen/veth1
