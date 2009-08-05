From: Or Gerlitz <ogerlitz@Voltaire.com>
Subject: Re: bridge vs macvlan performance
Date: Wed, 05 Aug 2009 10:02:22 +0300
Message-ID: <4A792E7E.10007@Voltaire.com>
References: <Pine.LNX.4.64.0908041650560.13803@zuben.voltaire.com>	<4A785824.2030500@candelatech.com> <4A790D24.9000008@voltaire.com>	<4A790F35.60204@candelatech.com> <4A791BA2.1040503@voltaire.com> <4A791DA5.3090202@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@linux-foundation.org>,
	netdev@vger.kernel.org,
	Vytautas Valancius <vytautas.valancius@gmail.com>,
	Sapan Bhatia <sapanb@cs.princeton.edu>,
	virtualization@lists.linux-foundation.org
To: Ben Greear <greearb@candelatech.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fwil.voltaire.com ([193.47.165.2]:48271 "EHLO exil.voltaire.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S933504AbZHEHCd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 5 Aug 2009 03:02:33 -0400
In-Reply-To: <4A791DA5.3090202@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ben Greear wrote:
> Or Gerlitz wrote:

>> Using the same pktgen script (i.e with clone=0) I see that a
>> veth-->bridge-->veth configuration gives about 400K PPS forwarding
>> performance where macvlan-->veth-->macvlan gives 680K PPS (again, I
>> made sure that the bridge has applied learning before I start the test).

(its interesting how many times the same mistake can be done...) setting net.bridge.bridge-nf-call-iptables=0 made the veth-->bridge-->veth test to deliver 600K PPS thus reducing the gain achieved by the macvlan-->veth-->macvlan test from 70% to 20% which is way less but still notable.

> A VETH has to send to it's peer, so your descriptions are a bit vague.
> What are you really configuring?  Maybe show us your script or commands
> that set up each of these tests?

Yes, VETH has to send to its peer, so the veth/bridge/veth test has actually two more hops vs the macvlan/veth/macvlan test, maybe this can explain the difference, as for you question see below my configuration.

I am looking for the simplest setup to test the Linux bridge forwarding performance, I could do a tap-->bridge-->tap test with two processes sitting in user space, but I tend to think that user/kernel switches and the tap code may become the bottleneck in that case, where the kernel pktgen is much more efficient. 

Or.

------> for veth/bridge/veth test I do the below such that my config is
------> pktgen --> veth1 --> veth0 --> br0 --> veth2 --> veth3

BRIDGE=br0

brctl addbr $BRIDGE
ifconfig $BRIDGE up

# set the bridge such that it does NOT call iptables 
sysctl -w net.bridge.bridge-nf-call-iptables=0

DEV_A=veth0
DEV_B=veth1
MAC_A=72:EC:8E:4F:89:00
MAC_B=72:EC:8E:4F:89:01

DEV_B_IP=20.20.49.11
MASK=16

# create the 1st veth device pair
ip link add name $DEV_A address $MAC_A type veth peer name $DEV_B address $MAC_B

# bring up and connect one veth device to the bridge
ifconfig $DEV_A up
brctl addif $BRIDGE $DEV_A

# configure the other veth device as NIC
ifconfig $DEV_B $DEV_B_IP/$MASK up

DEV_C=veth2
DEV_D=veth3
MAC_C=72:EC:8E:4F:89:02
MAC_D=72:EC:8E:4F:89:03

DEV_D_IP=20.20.49.13

# create the 2nd veth device pair
ip link add name $DEV_C address $MAC_C type veth peer name $DEV_D address $MAC_D

# bring up and connect the other veth device to the bridge
ifconfig $DEV_C up
brctl addif $BRIDGE $DEV_C

# configure the other veth device as NIC
ifconfig $DEV_D $DEV_D_IP/$MASK up

# make local Linux bridge learning come into play, populate the bridge FDB 
REMOTE=1.1.1.1
ping -I $DEV_B $REMOTE -i 0.05 -c 10 -q
ping -I $DEV_D $REMOTE -i 0.05 -c 10 -q

# examine the bridge FDB to make sure learning happened
brctl showmacs $BRIDGE

------> for macvlan/veth/macvlan test I do the below such that my config is
------> pktgen --> mv0 --> veth1 --> veth0 --> mv1

DEV_A=veth0
DEV_B=veth1
MAC_A=72:EC:8E:4F:89:00
MAC_B=72:EC:8E:4F:89:01

# create the 1st veth device pair
ip link add name $DEV_A address $MAC_A type veth peer name $DEV_B address $MAC_B

# bring up and connect one veth device to the bridge
ifconfig $DEV_A up
ifconfig $DEV_B up

UPLINK_DEV_A=veth1
UPLINK_DEV_B=veth0

DEV_A=mv1
DEV_B=mv0

MAC_A=00:19:d1:29:d2:01
MAC_B=00:19:d1:29:d2:00

ip link add link $UPLINK_DEV_A address $MAC_A $DEV_A type macvlan
ip link add link $UPLINK_DEV_B address $MAC_B $DEV_B type macvlan
