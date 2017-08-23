From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: UDP sockets oddities
Date: Wed, 23 Aug 2017 16:04:36 -0700
Message-ID: <1503529476.2499.65.camel@edumazet-glaptop3.roam.corp.google.com>
References: <3fed7679-0e19-8a0a-eee6-11baa5654fac@gmail.com>
         <1503527210.2499.63.camel@edumazet-glaptop3.roam.corp.google.com>
         <9a9c1c94-4902-2ec9-d216-3f5cfb3044af@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, edumazet@gmail.com, pabeni@redhat.com,
        willemb@google.com, davem@davemloft.net
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f47.google.com ([74.125.83.47]:33046 "EHLO
        mail-pg0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751038AbdHWXEj (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 23 Aug 2017 19:04:39 -0400
Received: by mail-pg0-f47.google.com with SMTP id t3so6759896pgt.0
        for <netdev@vger.kernel.org>; Wed, 23 Aug 2017 16:04:39 -0700 (PDT)
In-Reply-To: <9a9c1c94-4902-2ec9-d216-3f5cfb3044af@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2017-08-23 at 15:49 -0700, Florian Fainelli wrote:
> On 08/23/2017 03:26 PM, Eric Dumazet wrote:
> > On Wed, 2017-08-23 at 13:02 -0700, Florian Fainelli wrote:
> >> Hi,
> >>
> >> On Broadcom STB chips using bcmsysport.c and bcm_sf2.c we have an out of
> >> band HW mechanism (not using per-flow pause frames) where we can have
> >> the integrated network switch backpressure the CPU Ethernet controller
> >> which translates in completing TX packets interrupts at the appropriate
> >> pace and therefore get flow control applied end-to-end from the host CPU
> >> port towards any downstream port. At least that is the premise and this
> >> works reasonably well.
> >>
> >> This has a few drawbacks in that each of the bcmsysport TX queues need
> >> to semi-statically map to their switch port output queues such that the
> >> switch can calculate buffer occupancy and report congestion status,
> >> which prompted this email [1] but this is tangential and is a policy not
> >> a mechanism issue.
> >>
> >> [1]: https://www.spinics.net/lists/netdev/msg448153.html
> >>
> >> This is useful when your CPU / integrated switch links up at 1Gbits/sec
> >> internally, and tries to push 1Gbits/sec worth of UDP traffic to e.g: a
> >> downstream port linking at 100Mbits/sec, which could happen depending on
> >> what you have connected to this device.
> >>
> >> Now the problem that I am facing, is the following:
> >>
> >> - net.core.wmem_default = 160KB (default value)
> >> - using iperf -b 800M -u towards an iperf UDP server with the physical
> >> link to that server established at 100Mbits/sec
> >> - iperf does synchronous write(2) AFAICT so this gives it flow control
> >> - using the default duration of 10s, you can barely see any packet loss
> >> from one run to another
> >> - the longer the run, the higher you are going to see some packet loss,
> >> usually in the range of ~0.15% top
> >>
> >> The transmit flow looks like this:
> >>
> >> gphy (net/dsa/slave.c::dsa_slave_xmit, IFF_NO_QUEUE device)
> >>  -> eth0 (drivers/net/ethernet/broadcom/bcmsysport.c, "regular" network
> >> device)
> >>
> >> I can clearly see that the network stack pushed N UDP packets (Udp and
> >> Ip counters in /proc/net/snmp concur) however what the driver
> >> transmitted and what the switch transmistted is N - M, and matches the
> >> packet loss reported by the UDP server. I don't measure any SndbufErrors
> >> which is not making sense yet.
> >>
> >> If I reduce the default socket size to say, 10x less than 160KB, 16KB,
> >> then I either don't see any packet loss at 100Mbits/sec for 5 minutes or
> >> more, or just very very little, down to 0.001%. Now if I repeat the
> >> experiment with the physical link at 10Mbits/sec, same thing, the 16KB
> >> wmem_default setting is no longer working and we need to lower the
> >> socket write buffer size again.
> >>
> >> So what I am wondering is:
> >>
> >> - do I have an obvious flow control problem in my network driver that
> >> usually does not lead to packet loss, but may sometime happen?
> >>
> >> - why would lowering the socket write size appear to masquerade or solve
> >> this problem?
> >>
> >> I can consistently reproduce this across several kernel versions, 4.1,
> >> 4.9 and latest net-next and therefore can also test patches.
> >>
> >> Thanks for reading thus far!
> > 
> > Have you checked qdisc counters ? Maybe drops happen there.
> 
> CONFIG_NET_SCHED is actually disabled in this kernel configuration.
> 
> But even with that enabled, I don't see any drops being reported at the
> qdisc level, see below.

You might try

perf record -a -g -e skb:kfree_skb sleep 10
perf report
