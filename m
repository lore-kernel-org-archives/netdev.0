From: Veli-Matti Lintu <veli-matti.lintu@opinsys.fi>
Subject: Fwd: 802.3ad bonding aggregator reselection
Date: Fri, 17 Jun 2016 13:40:00 +0300
Message-ID: <CAKdSkDUfat0bM=WBv-Numnaa0MVKu2V6Rcx8eUeTZjcuDiYLpw@mail.gmail.com>
References: <CAKdSkDUb94mR7cDiZbxsc6fgm_8O5wagjUec4g-t5DF7R_GFDw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Jay Vosburgh <fubar@us.ibm.com>,
	Andy Gospodarek <andy@greyhouse.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f54.google.com ([209.85.218.54]:35262 "EHLO
	mail-oi0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755121AbcFQKkC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Jun 2016 06:40:02 -0400
Received: by mail-oi0-f54.google.com with SMTP id v7so51620oig.2
        for <netdev@vger.kernel.org>; Fri, 17 Jun 2016 03:40:02 -0700 (PDT)
In-Reply-To: <CAKdSkDUb94mR7cDiZbxsc6fgm_8O5wagjUec4g-t5DF7R_GFDw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

I have been trying to get the bonding driver working with multiple
aggregators with two switches in mode=802.3ad to handle failing links
properly. The goal is to have always the best possible bonded link in
use if one or physical links fail.

The bonding documentation describes that 802.3ad with
ad_select=bandwidth/count should do this, but I wasn't able to get
those or ad_select=stable working without patching the kernel. As I'm
not really familiar with the codebase, I'm not sure if this is really
a kernel problem or a configuration problem.

Documentation/networking/bonding.txt

ad_select
...
        The bandwidth and count selection policies permit failover of
        802.3ad aggregations when partial failure of the active aggregator
        occurs.  This keeps the aggregator with the highest availability
        (either in bandwidth or in number of ports) active at all times.

        This option was added in bonding version 3.4.0.




The hardware setup consists of two HP 2530-48G switches and servers
that have 6 ports in total that are connected to both switches using
3x1Gbps links. Port groups are configured as LACP on the switches. The
switches are connected to each other, but they do not create a single
aggregator so that all 6 links could be active at the same time. The
NICs use ixgbe and igb drivers.



Here are the tested steps:

ad_select=stable

1. Enable all links on both switches and boot the server, 3 ports are up
2. Disable one link on switch that is the active aggregator

expected: link goes down and port count in /proc/net/bonding/bond0 goes down
result: link goes down and port count in /proc/net/bonding/bond0 does not change

3. Disable all links on switch that is the active aggregator

expected: link goes down and bond switches to using aggregator that has links up
result: link goes down and port count in /proc/net/bonding/bond0 does
not change and connection is lost as there are no links up in active
aggregator.

4. Enable a single link that on active aggregator that has all links down

expect: ?
result: aggregator with most links up is activated (in this case the
previously non-active switch that had 3 links up all the time)



ad_select=bandwidth/count

1. Enable all links on both switches and boot the server, 3 ports are up
2. Disable one link on switch that is the active aggregator

expected: link goes down and aggregator reselection is started and
non-active aggregator with 3 links up becomes active
result: link goes down and port count in /proc/net/bonding/bond0 does
not change, aggregator reselection does not occur

3. Same as with ad_select=stable

4. Enable a single link that on active aggregator that has all links down

expect: aggregator with most links up is activated
result: aggregator with most links up is activated (in this case the
previously non-active switch that had 3 links up all the time)


In all cases miimon does detect the link going down and if I bring one
slaved interface down and back up (ifconfig/ip) in non-active
aggregator, aggregator reselection is done. For me it looks like the
problem is that when link goes down, there's nothing to check the
remaining status of the bond.

I could get this to happen with the following patch, but I'm not sure
what side effects it might cause. Most of the examples googling
revealed seemed to refer to Cisco gear, so I'm wondering if there's
something hardware specific here.



--- a/drivers/net/bonding/bond_3ad.c 2016-06-17 09:49:56.236636742 +0300
+++ b/drivers/net/bonding/bond_3ad.c 2016-06-17 10:04:34.309353452 +0300
@@ -2458,6 +2458,7 @@
  /* link has failed */
  port->is_enabled = false;
  ad_update_actor_keys(port, true);
+ port->sm_vars &= ~AD_PORT_SELECTED;
  }
  netdev_dbg(slave->bond->dev, "Port %d changed link status to %s\n",
    port->actor_port_number,



Here's /proc/net/bonding/bond0 on unmodified 4.7-rc3 after disabling
two ports on the switch with active aggregator. The active aggregator
info still shows 3 ports. The results are the same on 4.4.x and 4.6.x
kernels.

The following options were used:

options bonding mode=4 miimon=100 downdelay=200 updelay=200
xmit_hash_policy=layer3+4 ad_select=1 max_bonds=0 min_links=0


Ethernet Channel Bonding Driver: v3.7.1 (April 27, 2011)

Bonding Mode: IEEE 802.3ad Dynamic link aggregation
Transmit Hash Policy: layer3+4 (1)
MII Status: up
MII Polling Interval (ms): 1000
Up Delay (ms): 2000
Down Delay (ms): 2000

802.3ad info
LACP rate: fast
Min links: 0
Aggregator selection policy (ad_select): bandwidth
System priority: 65535
System MAC address: f2:07:89:4a:7c:9f
Active Aggregator Info:
Aggregator ID: 1
Number of ports: 3
Actor Key: 9
Partner Key: 57
Partner Mac Address: 6c:3b:e5:df:7a:80

Slave Interface: enp5s0f1
MII Status: up
Speed: 1000 Mbps
Duplex: full
Link Failure Count: 0
Permanent HW addr: 0c:c4:7a:34:c7:f1
Slave queue ID: 0
Aggregator ID: 1
Actor Churn State: none
Partner Churn State: none
Actor Churned Count: 0
Partner Churned Count: 0
details actor lacp pdu:
    system priority: 65535
    system mac address: f2:07:89:4a:7c:9f
    port key: 9
    port priority: 255
    port number: 1
    port state: 63
details partner lacp pdu:
    system priority: 31360
    system mac address: 6c:3b:e5:df:7a:80
    oper key: 57
    port priority: 0
    port number: 23
    port state: 61

Slave Interface: enp5s0f0
MII Status: up
Speed: 1000 Mbps
Duplex: full
Link Failure Count: 0
Permanent HW addr: 0c:c4:7a:34:c7:f0
Slave queue ID: 0
Aggregator ID: 2
Actor Churn State: none
Partner Churn State: none
Actor Churned Count: 0
Partner Churned Count: 0
details actor lacp pdu:
    system priority: 65535
    system mac address: f2:07:89:4a:7c:9f
    port key: 9
    port priority: 255
    port number: 2
    port state: 63
details partner lacp pdu:
    system priority: 36992
    system mac address: 6c:3b:e5:e0:90:80
    oper key: 57
    port priority: 0
    port number: 23
    port state: 61

Slave Interface: ens6f1
MII Status: down
Speed: Unknown
Duplex: Unknown
Link Failure Count: 1
Permanent HW addr: a0:36:9f:83:3c:41
Slave queue ID: 0
Aggregator ID: 1
Actor Churn State: none
Partner Churn State: none
Actor Churned Count: 0
Partner Churned Count: 0
details actor lacp pdu:
    system priority: 65535
    system mac address: f2:07:89:4a:7c:9f
    port key: 0
    port priority: 255
    port number: 3
    port state: 63
details partner lacp pdu:
    system priority: 31360
    system mac address: 6c:3b:e5:df:7a:80
    oper key: 57
    port priority: 0
    port number: 29
    port state: 61

Slave Interface: ens6f0
MII Status: up
Speed: 1000 Mbps
Duplex: full
Link Failure Count: 0
Permanent HW addr: a0:36:9f:83:3c:40
Slave queue ID: 0
Aggregator ID: 2
Actor Churn State: churned
Partner Churn State: churned
Actor Churned Count: 1
Partner Churned Count: 1
details actor lacp pdu:
    system priority: 65535
    system mac address: f2:07:89:4a:7c:9f
    port key: 9
    port priority: 255
    port number: 4
    port state: 7
details partner lacp pdu:
    system priority: 36992
    system mac address: 6c:3b:e5:e0:90:80
    oper key: 57
    port priority: 0
    port number: 29
    port state: 53

Slave Interface: ens5f1
MII Status: down
Speed: Unknown
Duplex: Unknown
Link Failure Count: 1
Permanent HW addr: a0:36:9f:83:3d:1f
Slave queue ID: 0
Aggregator ID: 1
Actor Churn State: none
Partner Churn State: churned
Actor Churned Count: 0
Partner Churned Count: 1
details actor lacp pdu:
    system priority: 65535
    system mac address: f2:07:89:4a:7c:9f
    port key: 0
    port priority: 255
    port number: 5
    port state: 143
details partner lacp pdu:
    system priority: 31360
    system mac address: 6c:3b:e5:df:7a:80
    oper key: 57
    port priority: 0
    port number: 28
    port state: 55

Slave Interface: ens5f0
MII Status: up
Speed: 1000 Mbps
Duplex: full
Link Failure Count: 0
Permanent HW addr: a0:36:9f:83:3d:1e
Slave queue ID: 0
Aggregator ID: 2
Actor Churn State: none
Partner Churn State: none
Actor Churned Count: 0
Partner Churned Count: 0
details actor lacp pdu:
    system priority: 65535
    system mac address: f2:07:89:4a:7c:9f
    port key: 9
    port priority: 255
    port number: 6
    port state: 63
details partner lacp pdu:
    system priority: 36992
    system mac address: 6c:3b:e5:e0:90:80
    oper key: 57
    port priority: 0
    port number: 28
    port state: 61




The results with the patch after disabling links and aggregator has
been reselected:

Ethernet Channel Bonding Driver: v3.7.1 (April 27, 2011)

Bonding Mode: IEEE 802.3ad Dynamic link aggregation
Transmit Hash Policy: layer3+4 (1)
MII Status: up
MII Polling Interval (ms): 1000
Up Delay (ms): 2000
Down Delay (ms): 2000

802.3ad info
LACP rate: fast
Min links: 0
Aggregator selection policy (ad_select): bandwidth
System priority: 65535
System MAC address: f2:07:89:4a:7c:9f
Active Aggregator Info:
Aggregator ID: 2
Number of ports: 2
Actor Key: 9
Partner Key: 57
Partner Mac Address: 6c:3b:e5:e0:90:80

Slave Interface: enp5s0f1
MII Status: up
Speed: 1000 Mbps
Duplex: full
Link Failure Count: 0
Permanent HW addr: 0c:c4:7a:34:c7:f1
Slave queue ID: 0
Aggregator ID: 1
Actor Churn State: none
Partner Churn State: none
Actor Churned Count: 0
Partner Churned Count: 0
details actor lacp pdu:
    system priority: 65535
    system mac address: f2:07:89:4a:7c:9f
    port key: 9
    port priority: 255
    port number: 1
    port state: 63
details partner lacp pdu:
    system priority: 31360
    system mac address: 6c:3b:e5:df:7a:80
    oper key: 57
    port priority: 0
    port number: 23
    port state: 61

Slave Interface: enp5s0f0
MII Status: up
Speed: 1000 Mbps
Duplex: full
Link Failure Count: 0
Permanent HW addr: 0c:c4:7a:34:c7:f0
Slave queue ID: 0
Aggregator ID: 2
Actor Churn State: none
Partner Churn State: none
Actor Churned Count: 1
Partner Churned Count: 1
details actor lacp pdu:
    system priority: 65535
    system mac address: f2:07:89:4a:7c:9f
    port key: 9
    port priority: 255
    port number: 2
    port state: 63
details partner lacp pdu:
    system priority: 36992
    system mac address: 6c:3b:e5:e0:90:80
    oper key: 57
    port priority: 0
    port number: 23
    port state: 61

Slave Interface: ens6f1
MII Status: down
Speed: Unknown
Duplex: Unknown
Link Failure Count: 1
Permanent HW addr: a0:36:9f:83:3c:41
Slave queue ID: 0
Aggregator ID: 3
Actor Churn State: none
Partner Churn State: none
Actor Churned Count: 0
Partner Churned Count: 0
details actor lacp pdu:
    system priority: 65535
    system mac address: f2:07:89:4a:7c:9f
    port key: 0
    port priority: 255
    port number: 3
    port state: 7
details partner lacp pdu:
    system priority: 31360
    system mac address: 6c:3b:e5:df:7a:80
    oper key: 57
    port priority: 0
    port number: 29
    port state: 61

Slave Interface: ens6f0
MII Status: down
Speed: Unknown
Duplex: Unknown
Link Failure Count: 1
Permanent HW addr: a0:36:9f:83:3c:40
Slave queue ID: 0
Aggregator ID: 4
Actor Churn State: monitoring
Partner Churn State: monitoring
Actor Churned Count: 1
Partner Churned Count: 1
details actor lacp pdu:
    system priority: 65535
    system mac address: f2:07:89:4a:7c:9f
    port key: 0
    port priority: 255
    port number: 4
    port state: 135
details partner lacp pdu:
    system priority: 36992
    system mac address: 6c:3b:e5:e0:90:80
    oper key: 57
    port priority: 0
    port number: 29
    port state: 55

Slave Interface: ens5f1
MII Status: down
Speed: Unknown
Duplex: Unknown
Link Failure Count: 1
Permanent HW addr: a0:36:9f:83:3d:1f
Slave queue ID: 0
Aggregator ID: 5
Actor Churn State: churned
Partner Churn State: churned
Actor Churned Count: 1
Partner Churned Count: 1
details actor lacp pdu:
    system priority: 65535
    system mac address: f2:07:89:4a:7c:9f
    port key: 0
    port priority: 255
    port number: 5
    port state: 135
details partner lacp pdu:
    system priority: 31360
    system mac address: 6c:3b:e5:df:7a:80
    oper key: 57
    port priority: 0
    port number: 28
    port state: 55

Slave Interface: ens5f0
MII Status: up
Speed: 1000 Mbps
Duplex: full
Link Failure Count: 0
Permanent HW addr: a0:36:9f:83:3d:1e
Slave queue ID: 0
Aggregator ID: 2
Actor Churn State: none
Partner Churn State: none
Actor Churned Count: 1
Partner Churned Count: 1
details actor lacp pdu:
    system priority: 65535
    system mac address: f2:07:89:4a:7c:9f
    port key: 9
    port priority: 255
    port number: 6
    port state: 63
details partner lacp pdu:
    system priority: 36992
    system mac address: 6c:3b:e5:e0:90:80
    oper key: 57
    port priority: 0
    port number: 28
    port state: 61


Happy hacking!

Veli-Matti
