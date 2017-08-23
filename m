From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: UDP sockets oddities
Date: Wed, 23 Aug 2017 15:49:30 -0700
Message-ID: <9a9c1c94-4902-2ec9-d216-3f5cfb3044af@gmail.com>
References: <3fed7679-0e19-8a0a-eee6-11baa5654fac@gmail.com>
 <1503527210.2499.63.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org, edumazet@gmail.com, pabeni@redhat.com,
        willemb@google.com, davem@davemloft.net
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f169.google.com ([209.85.128.169]:34964 "EHLO
        mail-wr0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751005AbdHWWtl (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 23 Aug 2017 18:49:41 -0400
Received: by mail-wr0-f169.google.com with SMTP id k46so4735429wre.2
        for <netdev@vger.kernel.org>; Wed, 23 Aug 2017 15:49:41 -0700 (PDT)
In-Reply-To: <1503527210.2499.63.camel@edumazet-glaptop3.roam.corp.google.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/23/2017 03:26 PM, Eric Dumazet wrote:
> On Wed, 2017-08-23 at 13:02 -0700, Florian Fainelli wrote:
>> Hi,
>>
>> On Broadcom STB chips using bcmsysport.c and bcm_sf2.c we have an out of
>> band HW mechanism (not using per-flow pause frames) where we can have
>> the integrated network switch backpressure the CPU Ethernet controller
>> which translates in completing TX packets interrupts at the appropriate
>> pace and therefore get flow control applied end-to-end from the host CPU
>> port towards any downstream port. At least that is the premise and this
>> works reasonably well.
>>
>> This has a few drawbacks in that each of the bcmsysport TX queues need
>> to semi-statically map to their switch port output queues such that the
>> switch can calculate buffer occupancy and report congestion status,
>> which prompted this email [1] but this is tangential and is a policy not
>> a mechanism issue.
>>
>> [1]: https://www.spinics.net/lists/netdev/msg448153.html
>>
>> This is useful when your CPU / integrated switch links up at 1Gbits/sec
>> internally, and tries to push 1Gbits/sec worth of UDP traffic to e.g: a
>> downstream port linking at 100Mbits/sec, which could happen depending on
>> what you have connected to this device.
>>
>> Now the problem that I am facing, is the following:
>>
>> - net.core.wmem_default = 160KB (default value)
>> - using iperf -b 800M -u towards an iperf UDP server with the physical
>> link to that server established at 100Mbits/sec
>> - iperf does synchronous write(2) AFAICT so this gives it flow control
>> - using the default duration of 10s, you can barely see any packet loss
>> from one run to another
>> - the longer the run, the higher you are going to see some packet loss,
>> usually in the range of ~0.15% top
>>
>> The transmit flow looks like this:
>>
>> gphy (net/dsa/slave.c::dsa_slave_xmit, IFF_NO_QUEUE device)
>>  -> eth0 (drivers/net/ethernet/broadcom/bcmsysport.c, "regular" network
>> device)
>>
>> I can clearly see that the network stack pushed N UDP packets (Udp and
>> Ip counters in /proc/net/snmp concur) however what the driver
>> transmitted and what the switch transmistted is N - M, and matches the
>> packet loss reported by the UDP server. I don't measure any SndbufErrors
>> which is not making sense yet.
>>
>> If I reduce the default socket size to say, 10x less than 160KB, 16KB,
>> then I either don't see any packet loss at 100Mbits/sec for 5 minutes or
>> more, or just very very little, down to 0.001%. Now if I repeat the
>> experiment with the physical link at 10Mbits/sec, same thing, the 16KB
>> wmem_default setting is no longer working and we need to lower the
>> socket write buffer size again.
>>
>> So what I am wondering is:
>>
>> - do I have an obvious flow control problem in my network driver that
>> usually does not lead to packet loss, but may sometime happen?
>>
>> - why would lowering the socket write size appear to masquerade or solve
>> this problem?
>>
>> I can consistently reproduce this across several kernel versions, 4.1,
>> 4.9 and latest net-next and therefore can also test patches.
>>
>> Thanks for reading thus far!
> 
> Have you checked qdisc counters ? Maybe drops happen there.

CONFIG_NET_SCHED is actually disabled in this kernel configuration.

But even with that enabled, I don't see any drops being reported at the
qdisc level, see below.

The NETDEV_TX_BUSY condition in bcmsysport.c is loud (netdev_info) and I
don't see it in my logs. One place that could result in packet loss is
the skb_put_padto() but I just added tx_errors/tx_dropped counters there
and don't see them incrementing.

# tc -s qdisc show
qdisc noqueue 0: dev lo root refcnt 2
 Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
 backlog 0b 0p requeues 0
qdisc mq 0: dev eth0 root
 Sent 863841007 bytes 569963 pkt (dropped 0, overlimits 0 requeues 1)
 backlog 0b 0p requeues 1
qdisc pfifo_fast 0: dev eth0 parent :10 bands 3 priomap  1 2 2 2 1 2 0 0
1 1 1 1 1 1 1 1
 Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
 backlog 0b 0p requeues 0
qdisc pfifo_fast 0: dev eth0 parent :f bands 3 priomap  1 2 2 2 1 2 0 0
1 1 1 1 1 1 1 1
 Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
 backlog 0b 0p requeues 0
qdisc pfifo_fast 0: dev eth0 parent :e bands 3 priomap  1 2 2 2 1 2 0 0
1 1 1 1 1 1 1 1
 Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
 backlog 0b 0p requeues 0
qdisc pfifo_fast 0: dev eth0 parent :d bands 3 priomap  1 2 2 2 1 2 0 0
1 1 1 1 1 1 1 1
 Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
 backlog 0b 0p requeues 0
qdisc pfifo_fast 0: dev eth0 parent :c bands 3 priomap  1 2 2 2 1 2 0 0
1 1 1 1 1 1 1 1
 Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
 backlog 0b 0p requeues 0
qdisc pfifo_fast 0: dev eth0 parent :b bands 3 priomap  1 2 2 2 1 2 0 0
1 1 1 1 1 1 1 1
 Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
 backlog 0b 0p requeues 0
qdisc pfifo_fast 0: dev eth0 parent :a bands 3 priomap  1 2 2 2 1 2 0 0
1 1 1 1 1 1 1 1
 Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
 backlog 0b 0p requeues 0
qdisc pfifo_fast 0: dev eth0 parent :9 bands 3 priomap  1 2 2 2 1 2 0 0
1 1 1 1 1 1 1 1
 Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
 backlog 0b 0p requeues 0
qdisc pfifo_fast 0: dev eth0 parent :8 bands 3 priomap  1 2 2 2 1 2 0 0
1 1 1 1 1 1 1 1
 Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
 backlog 0b 0p requeues 0
qdisc pfifo_fast 0: dev eth0 parent :7 bands 3 priomap  1 2 2 2 1 2 0 0
1 1 1 1 1 1 1 1
 Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
 backlog 0b 0p requeues 0
qdisc pfifo_fast 0: dev eth0 parent :6 bands 3 priomap  1 2 2 2 1 2 0 0
1 1 1 1 1 1 1 1
 Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
 backlog 0b 0p requeues 0
qdisc pfifo_fast 0: dev eth0 parent :5 bands 3 priomap  1 2 2 2 1 2 0 0
1 1 1 1 1 1 1 1
 Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
 backlog 0b 0p requeues 0
qdisc pfifo_fast 0: dev eth0 parent :4 bands 3 priomap  1 2 2 2 1 2 0 0
1 1 1 1 1 1 1 1
 Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
 backlog 0b 0p requeues 0
qdisc pfifo_fast 0: dev eth0 parent :3 bands 3 priomap  1 2 2 2 1 2 0 0
1 1 1 1 1 1 1 1
 Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
 backlog 0b 0p requeues 0
qdisc pfifo_fast 0: dev eth0 parent :2 bands 3 priomap  1 2 2 2 1 2 0 0
1 1 1 1 1 1 1 1
 Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
 backlog 0b 0p requeues 0
qdisc pfifo_fast 0: dev eth0 parent :1 bands 3 priomap  1 2 2 2 1 2 0 0
1 1 1 1 1 1 1 1
 Sent 863841007 bytes 569963 pkt (dropped 0, overlimits 0 requeues 1)
 backlog 0b 0p requeues 1
qdisc noqueue 0: dev gphy root refcnt 2
 Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
 backlog 0b 0p requeues 0
qdisc noqueue 0: dev rgmii_1 root refcnt 2
 Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
 backlog 0b 0p requeues 0
qdisc noqueue 0: dev rgmii_2 root refcnt 2
 Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
 backlog 0b 0p requeues 0
qdisc noqueue 0: dev asp root refcnt 2
 Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
 backlog 0b 0p requeues 0
-- 
Florian
