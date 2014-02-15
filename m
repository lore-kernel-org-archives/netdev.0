From: Yang Yingliang <yangyingliang@huawei.com>
Subject: Re: [PATCH net-next 0/7] clear old options when old qdisc's replaced
Date: Sat, 15 Feb 2014 10:20:38 +0800
Message-ID: <52FECEF6.2070605@huawei.com>
References: <1392366970-11592-1-git-send-email-yangyingliang@huawei.com> <1392381841.24974.5.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <davem@davemloft.net>,
	<stephen@networkplumber.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga03-in.huawei.com ([119.145.14.66]:35028 "EHLO
	szxga03-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751416AbaBOCUr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Feb 2014 21:20:47 -0500
In-Reply-To: <1392381841.24974.5.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2014/2/14 20:44, Eric Dumazet wrote:
> On Fri, 2014-02-14 at 16:36 +0800, Yang Yingliang wrote:
>> I've added a netem qdisc with rate option, then I replace this qdisc
>> without rate option but with latency option. The rate option is still
>> there.
>>
>> E.g.
>>   # tc qdisc add dev eth4 handle 1: root netem rate 10mbit
>>   # tc qdisc show
>>     qdisc netem 1: dev eth4 root refcnt 2 limit 1000 rate 10Mbit
>>
>>   # tc qdisc replace dev eth4 handle 1: root netem latency 10ms
>>   # tc qdisc show
>>     qdisc netem 1: dev eth4 root refcnt 2 limit 1000 delay 10.0ms rate 10Mbit
>>
>> The old options need be cleared after the qdisc is replaced.
> 
> Not at all. Test your changes with "tc qdisc change ... "
> 
> 
With "tc qdisc change ... ", it will only change the options that specified in command.
It's proper, I think.

   # tc qdisc add dev eth4 handle 1: root netem rate 10mbit
   # tc qdisc show
     qdisc netem 1: dev eth4 root refcnt 2 limit 1000 rate 10Mbit

   # tc qdisc replace dev eth4 handle 1: root netem latency 10ms
   # tc qdisc show
     qdisc netem 1: dev eth4 root refcnt 2 limit 1000 delay 10.0ms rate 10Mbit

"rate" is not cleared.

But with other qdiscs, such as tbf and htb etc, their usage not complete same as netem's,
when we use "tc qdisc change ... ", the old options will be cleared. Maybe we should make
their useages of "change" same as netem's?

E.g.
  # tc qdisc replace dev eth4 handle 1: root tbf rate 10mbit burst 10kb latency 50ms mtu 64kb peakrate 20mbit
  # tc qdisc show
    qdisc tbf 1: dev eth4 root refcnt 2 rate 10Mbit burst 10Kb peakrate 20Mbit minburst 64Kb lat 50.0ms
  # tc qdisc change dev eth4 handle 1: root tbf rate 20mbit burst 10kb latency 50ms
  # tc qdisc show
    qdisc tbf 1: dev eth4 root refcnt 2 rate 20Mbit burst 10Kb lat 50.0ms

"peakrate" and "minburst" are cleared.

  # tc class add dev eth4 parent 1:0 classid 1:1 htb rate 10mbit ceil 10mbit burst 10kb cburst 10kb
  # tc class show dev eth4
    class htb 1:1 root prio 0 rate 10Mbit ceil 10Mbit burst 10Kb cburst 10Kb
  # tc class change dev eth4 parent 1:0 classid 1:1 htb rate 20mbit
  # tc class show dev eth4
    class htb 1:1 root prio 0 rate 20Mbit ceil 20Mbit burst 1600b cburst 1600b

"cburst" and "burst" are cleared.


Regards,
Yang
