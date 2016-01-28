From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Subject: Re: bonding (IEEE 802.3ad) not working with qemu/virtio
Date: Thu, 28 Jan 2016 14:53:41 +0100
Message-ID: <56AA1D65.2000509@cumulusnetworks.com>
References: <CAJO99TmB3957Wq3Cse7azgBxKeZ2BV6QihoyAsjUjyvzc-V8dQ@mail.gmail.com>
 <20160128133350.GA2231@nanopsycho.orion>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: Jiri Pirko <jiri@resnulli.us>,
	=?UTF-8?Q?Bj=c3=b8rnar_Ness?= <bjornar.ness@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f52.google.com ([74.125.82.52]:34466 "EHLO
	mail-wm0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751273AbcA1Nxn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Jan 2016 08:53:43 -0500
Received: by mail-wm0-f52.google.com with SMTP id 128so11541505wmz.1
        for <netdev@vger.kernel.org>; Thu, 28 Jan 2016 05:53:43 -0800 (PST)
In-Reply-To: <20160128133350.GA2231@nanopsycho.orion>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/28/2016 02:33 PM, Jiri Pirko wrote:
> Mon, Jan 25, 2016 at 05:24:48PM CET, bjornar.ness@gmail.com wrote:
>> As subject says, 802.3ad bonding is not working with virtio network model.
>>
>> The only errors I see is:
>>
>> No 802.3ad response from the link partner for any adapters in the bond.
>>
>> Dumping the network traffic shows that no LACP packets are sent from the
>> host running with virtio driver, changing to for example e1000 solves
>> this problem
>> with no configuration changes.
>>
>> Is this a known problem?
Can you show your bond's /proc/net/bonding/bond<X> ? And also in order to
better see what's going on I'd suggest enabling the pr_debug() calls in the 3ad
code:
echo 'file bond_3ad.c +p' > /sys/kernel/debug/dynamic_debug/control
(assuming you have debugfs mounted at /sys/kernel/debug)
Then you can follow the logs to see what's going on.
I can clearly see LACP packets sent over virtio net devices:
14:53:05.323490 52:54:00:51:25:3c > 01:80:c2:00:00:02, ethertype Slow Protocols (0x8809), length 124: LACPv1, length 110

> 
> I believe the problem is virtio_net for obvious reasons does not report
> speed and duplex. Bonding 3ad mode makes that unconfortable :)
root@dev:~# ethtool -i eth1
driver: virtio_net
root@dev:~# ethtool eth1
Settings for eth1:
	Supported ports: [ ]
	Supported link modes:   Not reported
	Supported pause frame use: No
	Supports auto-negotiation: No
	Advertised link modes:  Not reported
	Advertised pause frame use: No
	Advertised auto-negotiation: No
	*Speed: 10Mb/s*
	*Duplex: Full*
	Port: Twisted Pair
	PHYAD: 0
	Transceiver: internal
	Auto-negotiation: off
	MDI-X: Unknown
	Link detected: yes

The bonding catches that correctly,
[54569.138572] bond0: Adding slave eth1
[54569.139686] bond0: Port 1 Received status full duplex update from adapter
[54569.139690] bond0: Port 1 Received link speed 2 update from adapter

The debug messages are from enabled 3ad mode pr_debugs().
Added 2 virtio_net adapters and they successfully went in a single LAG
when it was enabled on the other side.
root@dev:~# cat /proc/net/bonding/bond0 
Ethernet Channel Bonding Driver: v3.7.1 (April 27, 2011)

Bonding Mode: IEEE 802.3ad Dynamic link aggregation
Transmit Hash Policy: layer2 (0)
MII Status: up
MII Polling Interval (ms): 100
Up Delay (ms): 0
Down Delay (ms): 0

802.3ad info
LACP rate: slow
Min links: 0
Aggregator selection policy (ad_select): stable
System priority: 65535
System MAC address: 52:54:00:51:25:3c
Active Aggregator Info:
	Aggregator ID: 1
	Number of ports: 2
	Actor Key: 5
	Partner Key: 0
	Partner Mac Address: 52:54:00:2f:30:f7

Slave Interface: eth1
MII Status: up
Speed: 10 Mbps
Duplex: full
Link Failure Count: 0
Permanent HW addr: 52:54:00:51:25:3c
Slave queue ID: 0
Aggregator ID: 1
Actor Churn State: monitoring
Partner Churn State: monitoring
Actor Churned Count: 0
Partner Churned Count: 0
details actor lacp pdu:
    system priority: 65535
    system mac address: 52:54:00:51:25:3c
    port key: 5
    port priority: 255
    port number: 1
    port state: 61
details partner lacp pdu:
    system priority: 65535
    system mac address: 52:54:00:2f:30:f7
    oper key: 0
    port priority: 255
    port number: 1
    port state: 73

Slave Interface: eth2
MII Status: up
Speed: 10 Mbps
Duplex: full
Link Failure Count: 0
Permanent HW addr: 52:54:00:bf:57:16
Slave queue ID: 0
Aggregator ID: 1
Actor Churn State: monitoring
Partner Churn State: monitoring
Actor Churned Count: 0
Partner Churned Count: 0
details actor lacp pdu:
    system priority: 65535
    system mac address: 52:54:00:51:25:3c
    port key: 5
    port priority: 255
    port number: 2
    port state: 61
details partner lacp pdu:
    system priority: 65535
    system mac address: 52:54:00:2f:30:f7
    oper key: 0
    port priority: 255
    port number: 1
    port state: 73

> 
> Use team ;)
