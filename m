From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [RFC net-next 0/8] net: dsa: Multi-queue awareness
Date: Thu, 31 Aug 2017 21:10:55 -0700
Message-ID: <7d738ef5-c312-e0b3-3605-1f31fa7dc019@gmail.com>
References: <1504138732-65383-1-git-send-email-f.fainelli@gmail.com>
 <20170901000502.GB28960@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org, davem@davemloft.net,
        xiyou.wangcong@gmail.com, vivien.didelot@savoirfairelinux.com
To: Andrew Lunn <andrew@lunn.ch>, jiri@resnulli.us, jhs@mojatatu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f65.google.com ([209.85.218.65]:38254 "EHLO
        mail-oi0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750753AbdIAEK7 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 1 Sep 2017 00:10:59 -0400
Received: by mail-oi0-f65.google.com with SMTP id r203so1229764oih.5
        for <netdev@vger.kernel.org>; Thu, 31 Aug 2017 21:10:59 -0700 (PDT)
In-Reply-To: <20170901000502.GB28960@lunn.ch>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 08/31/2017 05:05 PM, Andrew Lunn wrote:
> On Wed, Aug 30, 2017 at 05:18:44PM -0700, Florian Fainelli wrote:
>> This patch series is sent as reference, especially because the last patch
>> is trying not to be creating too many layer violations, but clearly there
>> are a little bit being created here anyways.
>>
>> Essentially what I am trying to achieve is that you have a stacked device which
>> is multi-queue aware, that applications will be using, and for which they can
>> control the queue selection (using mq) the way they want. Each of each stacked
>> network devices are created for each port of the switch (this is what DSA
>> does). When a skb is submitted from say net_device X, we can derive its port
>> number and look at the queue_mapping value to determine which port of the
>> switch and queue we should be sending this to. The information is embedded in a
>> tag (4 bytes) and is used by the switch to steer the transmission.
>>
>> These stacked devices will actually transmit using a "master" or conduit
>> network device which has a number of queues as well. In one version of the
>> hardware that I work with, we have up to 4 ports, each with 8 queues, and the
>> master device has a total of 32 hardware queues, so a 1:1 mapping is easy. With
>> another version of the hardware, same number of ports and queues, but only 16
>> hardware queues, so only a 2:1 mapping is possible.
>>
>> In order for congestion information to work properly, I need to establish a
>> mapping, preferably before transmission starts (but reconfiguration while
>> interfaces are running would be possible too) between these stacked device's
>> queue and the conduit interface's queue.
>>
>> Comments, flames, rotten tomatoes, anything!
> 
> Right, i think i understand.
> 
> This works just for traffic between the host and ports.  The host can
> set the egress queue. And i assume the queues are priorities, either
> absolute or weighted round robin, etc.
> 
> But this has no effect on traffic going from port to port. At some
> point, i expect you will want to offload TC for that.

You are absolutely right, this patch series aims at having the host be
able to steer traffic towards particular switch port egress queues which
are configured with specific priorities. At the moment it really is
mapping one priority value (in the 802.1p sense) to one queue number and
let the switch scheduler figure things out.

With this patch set you can now use the multiq filter of tc and do
exactly what is documented under Documentation/networking/multiqueue.txt
and get the desired matches to be steered towards the queue you defined.

> 
> How will the two interact? Could the TC rules also act on traffic from
> the host to a port? Would it be simpler in the long run to just
> implement TC rules?

I suppose that you could somehow use TC to influence how the traffic
from host to CPU works, but without a "CPU" port representor the
question is how do we get that done? If we used "eth0" we need to
callback into the switch driver for programming..

Regarding the last patch in this series, what I would ideally to replace
it with is something along the lines of:

tc bind dev sw0p0 queue 0 dev eth0 queue 16

I am not sure if this is an action, or a filter, or something else...
-- 
Florian
