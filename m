From: Florian Fainelli <f.fainelli@gmail.com>
Subject: UDP sockets oddities
Date: Wed, 23 Aug 2017 13:02:28 -0700
Message-ID: <3fed7679-0e19-8a0a-eee6-11baa5654fac@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: davem@davemloft.net
To: netdev@vger.kernel.org, edumazet@gmail.com, pabeni@redhat.com,
        willemb@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f180.google.com ([209.85.128.180]:34112 "EHLO
        mail-wr0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932443AbdHWUCe (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 23 Aug 2017 16:02:34 -0400
Received: by mail-wr0-f180.google.com with SMTP id p14so3763546wrg.1
        for <netdev@vger.kernel.org>; Wed, 23 Aug 2017 13:02:33 -0700 (PDT)
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

On Broadcom STB chips using bcmsysport.c and bcm_sf2.c we have an out of
band HW mechanism (not using per-flow pause frames) where we can have
the integrated network switch backpressure the CPU Ethernet controller
which translates in completing TX packets interrupts at the appropriate
pace and therefore get flow control applied end-to-end from the host CPU
port towards any downstream port. At least that is the premise and this
works reasonably well.

This has a few drawbacks in that each of the bcmsysport TX queues need
to semi-statically map to their switch port output queues such that the
switch can calculate buffer occupancy and report congestion status,
which prompted this email [1] but this is tangential and is a policy not
a mechanism issue.

[1]: https://www.spinics.net/lists/netdev/msg448153.html

This is useful when your CPU / integrated switch links up at 1Gbits/sec
internally, and tries to push 1Gbits/sec worth of UDP traffic to e.g: a
downstream port linking at 100Mbits/sec, which could happen depending on
what you have connected to this device.

Now the problem that I am facing, is the following:

- net.core.wmem_default = 160KB (default value)
- using iperf -b 800M -u towards an iperf UDP server with the physical
link to that server established at 100Mbits/sec
- iperf does synchronous write(2) AFAICT so this gives it flow control
- using the default duration of 10s, you can barely see any packet loss
from one run to another
- the longer the run, the higher you are going to see some packet loss,
usually in the range of ~0.15% top

The transmit flow looks like this:

gphy (net/dsa/slave.c::dsa_slave_xmit, IFF_NO_QUEUE device)
 -> eth0 (drivers/net/ethernet/broadcom/bcmsysport.c, "regular" network
device)

I can clearly see that the network stack pushed N UDP packets (Udp and
Ip counters in /proc/net/snmp concur) however what the driver
transmitted and what the switch transmistted is N - M, and matches the
packet loss reported by the UDP server. I don't measure any SndbufErrors
which is not making sense yet.

If I reduce the default socket size to say, 10x less than 160KB, 16KB,
then I either don't see any packet loss at 100Mbits/sec for 5 minutes or
more, or just very very little, down to 0.001%. Now if I repeat the
experiment with the physical link at 10Mbits/sec, same thing, the 16KB
wmem_default setting is no longer working and we need to lower the
socket write buffer size again.

So what I am wondering is:

- do I have an obvious flow control problem in my network driver that
usually does not lead to packet loss, but may sometime happen?

- why would lowering the socket write size appear to masquerade or solve
this problem?

I can consistently reproduce this across several kernel versions, 4.1,
4.9 and latest net-next and therefore can also test patches.

Thanks for reading thus far!
-- 
Florian
