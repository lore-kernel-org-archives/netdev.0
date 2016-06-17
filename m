From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [patch net-next v4 0/4] return offloaded stats as default and
 expose original sw stats
Date: Fri, 17 Jun 2016 10:24:11 +0200
Message-ID: <20160617082411.GA1981@nanopsycho.orion>
References: <1466066237-7719-1-git-send-email-jiri@resnulli.us>
 <20160616.172632.1759391103978744570.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, nogahf@mellanox.com, idosch@mellanox.com,
	eladr@mellanox.com, yotamg@mellanox.com, ogerlitz@mellanox.com,
	roopa@cumulusnetworks.com, nikolay@cumulusnetworks.com,
	linville@tuxdriver.com, tgraf@suug.ch, gospo@cumulusnetworks.com,
	sfeldma@gmail.com, sd@queasysnail.net, eranbe@mellanox.com,
	ast@plumgrid.com, edumazet@google.com, hannes@stressinduktion.org,
	f.fainelli@gmail.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f67.google.com ([74.125.82.67]:33337 "EHLO
	mail-wm0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752337AbcFQIYO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Jun 2016 04:24:14 -0400
Received: by mail-wm0-f67.google.com with SMTP id r201so2645562wme.0
        for <netdev@vger.kernel.org>; Fri, 17 Jun 2016 01:24:14 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20160616.172632.1759391103978744570.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fri, Jun 17, 2016 at 02:26:32AM CEST, davem@davemloft.net wrote:
>From: Jiri Pirko <jiri@resnulli.us>
>Date: Thu, 16 Jun 2016 10:37:13 +0200
>
>> Until now we had stats functions return SW statistics. However, it makes
>> a lot of sense to return HW stats as default. The existing apps count with
>> having the defaults stats complete, but that is not true now as the offloaded
>> forward traffic is not visible there.
>> 
>> If user wants to know real SW stats, this patchset provides way to get
>> it as well.
>
>I think we haven't been very good about defining good rules nor
>guidelines for how to handle HW vs SW stats, and I'm talking
>strictly about what we publish via rtnl_link_stats64.
>
>However, if I were working from scratch on a new driver what I would
>be inclined to do is use HW stats for everything that the chip
>provides direct and accurate support for, and fill in the gaps with SW
>stats.
>
>Because to me, stats are stats, the user wants to know (for example)
>how many broadcast packets have gone through the port and doesn't care
>how you obtain that number.
>
>If the problem being addressed is that drivers aren't reporting
>information on all the packets going through the device, then that's a
>bug.
>
>But it seems to me like mlxsw is already maintaining the software
>statistic counters, so I can't see a performance reason for not
>properly providing all of the statistics using HW vs. SW as is
>appropriate for each and every value to fix this problem.  Why
>create an entire new facility just for that?  It doesn't seem to
>be needed.
>
>Maybe you just need to describe things a bit more completely in this
>header posting.


The problem we try to handle is different, it's about offloaded
forwarded packets which are not seen by kernel. Let me try to draw it :)

    port1                       port2 (HW stats are counted here)
      \                          /
       \                        /
        \                      /
         --(A)---- ASIC --(B)--
                    |
                   (C)
                    |
                   CPU (SW stats are counted here)


Now we have couple of flows for TX and RX (direction does not matter here):

1) port1->A->ASIC->C->CPU

   For this flow, HW and SW stats are equal.

2) port1->A->ASIC->C->CPU->C->ASIC->B->port2

   For this flow, HW and SW stats are equal.

3) port1->A->ASIC->B->port2

   For this flow, SW stats are 0.

The purpose of this patchset is to provide facility for user to
find out the difference between flows 1+2 and 3. In other words, user
will be able to see the statistics for his slow-path (through kernel).

Also, as a default the accumulated stats (HW) will be exposed to user
so the userspace apps can react properly.
