From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [RFC net-next 0/8] net: dsa: Multi-queue awareness
Date: Fri, 1 Sep 2017 09:46:26 -0700
Message-ID: <a0b9ab3a-45d8-3371-901b-2249a26b9192@gmail.com>
References: <1504138732-65383-1-git-send-email-f.fainelli@gmail.com>
 <20170901000502.GB28960@lunn.ch>
 <7d738ef5-c312-e0b3-3605-1f31fa7dc019@gmail.com>
 <20170901132921.GV22289@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org, davem@davemloft.net,
        xiyou.wangcong@gmail.com, vivien.didelot@savoirfairelinux.com
To: Andrew Lunn <andrew@lunn.ch>, jiri@resnulli.us, jhs@mojatatu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f172.google.com ([209.85.128.172]:34849 "EHLO
        mail-wr0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751863AbdIAQqh (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 1 Sep 2017 12:46:37 -0400
Received: by mail-wr0-f172.google.com with SMTP id y15so1955958wrc.2
        for <netdev@vger.kernel.org>; Fri, 01 Sep 2017 09:46:37 -0700 (PDT)
In-Reply-To: <20170901132921.GV22289@lunn.ch>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/01/2017 06:29 AM, Andrew Lunn wrote:
>> I suppose that you could somehow use TC to influence how the traffic
>> from host to CPU works, but without a "CPU" port representor the
>> question is how do we get that done? If we used "eth0" we need to
>> callback into the switch driver for programming..
> 
> We need to compare how the different switches work with respect to
> QoS. Marvell switches do a lot of the classification on the ingress
> port where it determines what queue the frame should be placed in on
> the egress port. The egress port then schedules its queues.
> 
> This does not map to TC too well.
> 
>> Regarding the last patch in this series, what I would ideally to replace
>> it with is something along the lines of:
>>
>> tc bind dev sw0p0 queue 0 dev eth0 queue 16
> 
> Why do you need this? sw0p0 has 8 queues? So i assume you use TC on
> sw0p0 to place frames into these queues? The queue then gets passed
> transparently down through the conduit interface and then used by the
> tagger. I don't see why you need eth0 here? We try our best to avoid
> eth0 wherever possible, it causes confusion. So i would prefer not to
> have to use eth0 with TC commands.

Well, if you read through patch 8 maybe this is explained. The dynamic
queue selection is working fine through the use of the DSA network
device's queue being passed to the Broadcom tag. If there was just I
would agree with you, but here is the catch below.

We also have this unique (AFAICT) hardware feature called Advanced
Congestion Buffering (ACB) where the CPU Ethernet MAC can receive
congestion information from the switch queues directly, but out of band
from specifically added HW logic and signals. This is not using pause
frames.

This is useful for instance when your CPU is linking at 1Gbits/sec (or
more) internally with the switch, but you have connected external hosts
that are only 10/100 capable. When you push 1Gbits/sec of traffic
towards such hosts, you would get severe packet loss, unless you have
pause frames enabled. The problem with Pause frames within the SF2
switch design is that they are not per-flow though, so you can't resolve
from the pause frames which egress queue to backpressure. With ACB
though, you get end-to-end backpressure between say, Port 8 and Port 0.
In order for this to work though, you need the CPU MAC to be inspecting
or rather receiving congestion notification from the switch port and
queues directly.

This is why I need to define a mapping between switch (port P,queue Q)
and CPU MAC queues (Q'). In the first generation HW, we have up to 4
ports exposed, each with 8 queues, and we have 32 CPU queues, 1:1
mapping is possible. On 2nd generation hardware, same number of ports
and queues per port, but only 16 queues, so a 2:1 mapping is possible only.

If I do not establish the mapping, several problems can occur but the
most severe is that congestion notification logic gets its congestion
information from the wrong port and queue, so it can be permanently
backpressuring the CPU queue based on e.g: a disabled port. This results
in the transmit queue being disabled, and so you get the netdev watchdog
to kick in and scream.

As you can see from the last patch, I used a notifier to receive
information when DSA slave network devices are added, from which I
extract their port number and set up an internal mapping to the CPU
queues, but this is creating a layering violation since I have now the
CPU driver extracting DSA specific net_device information.

The idea behind exposing a command like the proposed "tc bind" is to let
users define the mapping as they see fit. 1:1 or 2:1 mapping is fine as
a default, but may not be satisfactory for some use cases.

Hope this helps understand the bigger picture ;)
-- 
Florian
