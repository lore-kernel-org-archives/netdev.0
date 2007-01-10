From: Ben Greear <greearb@candelatech.com>
Subject: Re: Question on advanced routing and/or virtual routers.
Date: Tue, 09 Jan 2007 18:53:03 -0800
Message-ID: <45A4550F.4040802@candelatech.com>
References: <45A27A78.8010200@candelatech.com> <20070108182327.GB19417@ventoux.cs.ubc.ca>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns2.lanforge.com ([66.165.47.211]:46638 "EHLO ns2.lanforge.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932685AbXAJCxW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 9 Jan 2007 21:53:22 -0500
To: Brendan Cully <brendan@kublai.com>
In-Reply-To: <20070108182327.GB19417@ventoux.cs.ubc.ca>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Brendan Cully wrote:

> I started something like this a while ago (posted at
> <20051006215312.GD24375@zakopane.cs.ubc.ca> with a couple of replies
> by Thomas Graf, but I can't seem to find it in the archives) but then
> dropped the ball. It seems to work fairly well with a one-line kernel
> patch to allow route lookup before the local address check. Oh, and I
> didn't get traceroute working quite right either - I think there was
> some trick to finding the source address for the generated reply.
> 
> I've got some info and code here: http://dsg.cs.ubc.ca/~brendan/remus/

Thanks for the pointers!

I took a look at this, and I think I'm starting to understand it.
But, I am not sure why the patch is needed.  I was thinking that something
like this should cause packets entering a particular interface to use
a particular routing table.  However, this does not seem to work for me
(without the patch).  I have yet to try with the patch.

I'm using my re-direct device patch, which is a pair of network devices
that act like two ethernet interfaces connected with a cross-over cable.
So, when you tx on A, the pkt is RX'd on B.

I am trying to set up two 'routers':

router 1001:
  rddA2:  10.0.3.1/24  -- connects to rddA1, which is in router 2
  rddC1:  10.0.4.1/24  -- connects to rest of world...unused currently

router 1002:
  rddA1:  10.0.3.2/24  -- connects to rddA2 in router 1
  rddB1:  10.0.2.1/24  -- connects to private network...unused currently


I want any packets received on the rddA1 and rddB1 interfaces to use routing table 1002,
and those received on rddA2 and rddC1 to use routing table 1001.

It appears that the ping-response packets are using the local table,
so matching by incoming device does not appear to be working as I expected.
The ping requests are going out the right interface, so I think that matching
on source IP addr is working.

My ip route related commands:

ip ru del from 10.0.3.1 lookup 1001
ip ru del from 0/0 lookup 1001
ip ru del from 10.0.4.1 lookup 1001
ip ru del from 0/0 lookup 1001
ip ru del from 10.0.2.1 lookup 1002
ip ru del from 0/0 lookup 1002
ip ru del from 10.0.3.2 lookup 1002
ip ru del from 0/0 lookup 1002
ip link set rddC1 down
ip link set rddC1 up
ip addr flush dev rddC1
ip addr add 10.0.4.1/24 broadcast 10.0.4.255 dev rddC1
ip rule add iif rddC1 lookup 1001
ip rule add from 10.0.4.1/32 table 1001
ip route add 10.0.4.0/24 via 10.0.4.2 table 1001
ip link set rddA2 down
ip link set rddA2 up
ip addr flush dev rddA2
ip addr add 10.0.3.1/24 broadcast 10.0.3.255 dev rddA2
ip rule add iif rddA2 lookup 1001
ip rule add from 10.0.3.1/32 table 1001
ip route add 10.0.3.0/24 via 10.0.3.2 table 1001
ip link set rddA1 down
ip link set rddA1 up
ip addr flush dev rddA1
ip addr add 10.0.3.2/24 broadcast 10.0.3.255 dev rddA1
ip rule add iif rddA1 lookup 1002
ip rule add from 10.0.3.2/32 table 1002
ip route add 10.0.3.0/24 via 10.0.3.1 table 1002
ip link set rddB1 down
ip link set rddB1 up
ip addr flush dev rddB1
ip addr add 10.0.2.1/24 broadcast 10.0.2.255 dev rddB1
ip rule add iif rddB1 lookup 1002
ip rule add from 10.0.2.1/32 table 1002
ip route add 10.0.2.0/24 via 10.0.2.2 table 1002
[root@lanforge-33-1E ~]# ping -I 10.0.3.1 10.0.3.2
PING 10.0.3.2 (10.0.3.2) from 10.0.3.1 : 56(84) bytes of data.
64 bytes from 10.0.3.2: icmp_seq=1 ttl=64 time=0.079 ms
64 bytes from 10.0.3.2: icmp_seq=2 ttl=64 time=0.062 ms
64 bytes from 10.0.3.2: icmp_seq=3 ttl=64 time=0.065 ms
64 bytes from 10.0.3.2: icmp_seq=4 ttl=64 time=0.062 ms

rddA2     Link encap:Ethernet  HWaddr 00:19:DC:3A:39:50
           inet addr:10.0.3.1  Bcast:10.0.3.255  Mask:255.255.255.0
           UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
           RX packets:1 errors:0 dropped:0 overruns:0 frame:0
           TX packets:45 errors:0 dropped:0 overruns:0 carrier:0
           collisions:0 txqueuelen:0
           RX bytes:42 (42.0 b)  TX bytes:4186 (4.0 KiB)

[root@lanforge-33-1E ~]# ifconfig rddA1
rddA1     Link encap:Ethernet  HWaddr 00:62:D5:12:AF:31
           inet addr:10.0.3.2  Bcast:10.0.3.255  Mask:255.255.255.0
           UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
           RX packets:45 errors:0 dropped:0 overruns:0 frame:0
           TX packets:1 errors:0 dropped:0 overruns:0 carrier:0
           collisions:0 txqueuelen:0
           RX bytes:4186 (4.0 KiB)  TX bytes:42 (42.0 b)


For other's benefit, here is the patch suggested by Mr. Cully:


--- net/ipv4/fib_rules.c.orig   2005-08-02 16:19:50.441632971 -0700
+++ net/ipv4/fib_rules.c        2005-08-02 16:20:06.844088253 -0700
@@ -94,6 +94,7 @@
  static struct fib_rule local_rule = {
         .r_next =       &main_rule,
         .r_clntref =    ATOMIC_INIT(2),
+       .r_preference = 0x100,
         .r_table =      RT_TABLE_LOCAL,
         .r_action =     RTN_UNICAST,
  };


Thanks,
Ben


-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com

