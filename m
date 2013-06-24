From: John Fastabend <john.fastabend@gmail.com>
Subject: Re: [RFC PATCH] net: add a tx_queue attribute rate_queue_limits in
 Mbps
Date: Mon, 24 Jun 2013 11:03:45 -0700
Message-ID: <51C88A01.8010603@gmail.com>
References: <20130624032407.7546.96685.stgit@nitbit.x32> <20130624081143.7424f455@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, therbert@google.com, ben@decadent.org.uk,
	jesse.brandeburg@intel.com, jeffrey.t.kirsher@intel.com
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gh0-f173.google.com ([209.85.160.173]:59657 "EHLO
	mail-gh0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751426Ab3FXSJH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Jun 2013 14:09:07 -0400
Received: by mail-gh0-f173.google.com with SMTP id g16so3523331ghb.4
        for <netdev@vger.kernel.org>; Mon, 24 Jun 2013 11:09:06 -0700 (PDT)
In-Reply-To: <20130624081143.7424f455@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/24/2013 08:11 AM, Stephen Hemminger wrote:
> On Sun, 23 Jun 2013 20:24:11 -0700
> John Fastabend <john.fastabend@gmail.com> wrote:
>
>> This adds a rate_queue_limit attribute to the tx_queue sysfs entry
>> to allow rate limiting in units of Mpbs. Along with mqprio and BQL
>> this provides another knob to tune queue performance. By default it
>> is disabled with a setting of '0'.
>>
>> By adding this as a queue attribute and _not_ a qdisc option allows
>> using rate limits with qdisc schemes that may not align with tx rings
>> and also allows using QOS schemes along with rate limits.
>>
>> A sample implementation is provided for ixgbe. Any improvements or
>> suggestions welcome I would also be interested to know if this works
>> with other hardware and if Mbps is a good default unit.
>>
>> I tested this briefly with iperf/netperf,
>>
>> # echo 4000 > /sys/class/net/p3p2/queues/tx-0/tx_rate_limit
>> # cat /sys/class/net/p3p2/queues/tx-0/tx_rate_limit
>> 4000
>
> I like the facility and there is a real need for it, but we need
> to think about what best API for it is.
>
> There are several possible API's for this. My preference in order is:
>    1. Netlink:
>         PRO: most well structured and can notify control applications
>         CON: doesn't propagate well down to device

Not sure I understand the con here. We push a lot of netlink messages
down to the device already via ndo_ops/rtnetlink.

Having a mechanism in place to notify control applications is nice.

>    2. Ethtool:
>         PRO: fits current model of speed/duplex
>         CON: still and ioctl based model, non-extensible structures

I prefer netlink or sysfs but this is likely my own bias. Being able
to extend the interface easily if/when we get more queue attributes
will help in the future.

>    3. Sysfs
>         PRO: easy to add
>         CON: not a general mechanism, ends up being per-device

There are already entries for other queue attributes here namely
byte_queue_limits, tx_timeout, and xps_cpus. And net-sysfs.c keeps all
of this reasonable sane IMO and not really device specific. My thought
for using this was to keep all the queue attributes in one location.

>    4. Module parameter
>         PRO: easy to code
>         CON: hard to manage from application, hard to associate with multiple devices
>
>
>

I would prefer Netlink (for notifications) or Sysfs (to keep attributes
in one place). I don't really have a strong preference either way.

.John

-- 
John Fastabend         Intel Corporation
