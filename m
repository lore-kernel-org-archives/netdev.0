From: Ming Lei <tom.leiming@gmail.com>
Subject: Re: TCP transmit performance regression
Date: Thu, 5 Jul 2012 16:27:47 +0800
Message-ID: <CACVXFVNxcdEYd-KmkUe9=8+x_9s-ZVuoM=FfZ=QXa7w_qRiTnw@mail.gmail.com>
References: <CACVXFVNM-Db=_793SVfRj+nxGtNG0pRFrwc_F9TGbU0FfES63A@mail.gmail.com>
	<1341474192.2583.3299.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Network Development <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f46.google.com ([209.85.213.46]:39454 "EHLO
	mail-yw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755800Ab2GEI1s (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Jul 2012 04:27:48 -0400
Received: by yhmm54 with SMTP id m54so7904977yhm.19
        for <netdev@vger.kernel.org>; Thu, 05 Jul 2012 01:27:47 -0700 (PDT)
In-Reply-To: <1341474192.2583.3299.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jul 5, 2012 at 3:43 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Thu, 2012-07-05 at 09:45 +0800, Ming Lei wrote:
>> Hi,
>>
>> I observed that on both 3.5-rc5 and 3.5-rc5-next, TCP transmit performance
>> degrades a lot, see my below simple test:
>>
>> 1, test box
>> NIC: 100M USB, normally can reach > 90Mbits/sec
>>
>
> What was the last "OK" kernel version ?

After some investigation, the problem is caused by enabling
DEBUG_SLAB, so it is not a regression.

>
> What NIC driver is it ?
>
>> 2, run below command on the box:
>> [root@root]#iperf -c 192.168.0.103 -w 131072 -t 10
>> ------------------------------------------------------------
>> Client connecting to 192.168.0.103, TCP port 5001
>> TCP window size:   256 KByte (WARNING: requested   128 KByte)
>> ------------------------------------------------------------
>> [  3] local 192.168.0.108 port 59315 connected with 192.168.0.103 port 5001
>> [ ID] Interval       Transfer     Bandwidth
>> [  3]  0.0-10.0 sec  40.4 MBytes  33.9 Mbits/sec
>>
>> note: 192.168.0.103 is another production machine running 'iperf -s -w 131072'
>>
>> 3, from traffic captured in wireshark, the window size of most of tcp packets
>> from the test box to 192.168.0.103 is set as 229, looks very weird and should
>> be the cause of performance regression.
>>
>
> Packets sent to 192.168.0.103 announce the window suitable for packets
> in the other way, so not relevant to your problem.
>
> Could you do
>
> # tcpdump -i eth0 -s 100 -c 1000 -w tcp.pcap host 192.168.0.103 &
> # iperf -c 192.168.0.103 -w 131072 -t 10
>
> and post the tcp.pcap file ?
>
> By the way, if you remove -w 131072 (on both sides), I guess throughput
> will increase.

Looks no improvement. I still don't know why the window size becomes so
small even in good situation(disabling DEBUG_SLAB), and the small
window size will cause almost every tcp data packet acked.


Thanks,
-- 
Ming Lei
