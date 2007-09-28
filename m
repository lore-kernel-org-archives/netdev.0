From: Satoshi OSHIMA <satoshi.oshima.fk@hitachi.com>
Subject: Re: [RFC/PATCH 0/3] UDP memory usage accounting
Date: Fri, 28 Sep 2007 22:26:47 +0900
Message-ID: <46FD0117.9030407@hitachi.com>
References: <46F3B67F.4030007@hitachi.com> <20070921125843.GA15810@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, haoki@redhat.com,
	=?windows-1252?Q?=3F=3F_?= =?windows-1252?Q?=3F=3F?=
	<yoshfuji@linux-ipv6.org>,
	Yumiko SUGITA <yumiko.sugita.yf@hitachi.com>
To: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail7.hitachi.co.jp ([133.145.228.42]:54991 "EHLO
	mail7.hitachi.co.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751301AbXI1NmF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Sep 2007 09:42:05 -0400
Received: from mlsv16.hitachi.co.jp (unknown [133.144.234.166])
	by mail7.hitachi.co.jp (Postfix) with ESMTP id E44FE37ADC
	for <netdev@vger.kernel.org>; Fri, 28 Sep 2007 22:42:02 +0900 (JST)
In-Reply-To: <20070921125843.GA15810@2ka.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

Thank you for your comment.


Evgeniy Polyakov wrote:
> Hi.
>
> On Fri, Sep 21, 2007 at 09:18:07PM +0900, Satoshi OSHIMA
(satoshi.oshima.fk@hitachi.com) wrote:
>> This patch set try to introduce memory usage accounting for
>> UDP(currently ipv4 only).
>>
>> Currently, memory usage of UDP can be observed as the sam of
>> usage of tx_queue and rx_queue. But I believe that the system
>> wide accounting is usefull when heavy loaded condition.
>>
>> In the next step, I would like to add memory usage quota
>> for UDP to avoid unlimited memory consumption problem
>> under DDOS attack.
>
> Could you please desribed such attack in more details?
> Each UDP socket has its queue length which can not be exceeded
> (roughly), no new sockets are created when remote side sends a packet
> (like after special steps in TCP), so where is possibility to eat all
> the mem?

For example, sk_buff is put on the slab and
slab can be acquired only from ZONE_NORMAL in i386.

In such case, from 300 to 500MB memory consumption will
be fatal. Users can easily open 1000 sockets per process
under default ulimit. If such sockets hold messages but
user processes don't receive it. Almost all slab will
be occupied by sk_buff.


>> This patch set is for 2.6.23-rc7.
>
> I seriously doubt you want to put udp specific hacks and zillions of
> atomic ops all around the code just to know exact number of bytes eaten
> for UDP.
> Please use udp specific code (like udp_sendmsg()) for proper accounting
> if you need that, but not hacks in generic ip code.

I couldn't find the way to account UDP memory consumption
in UDP layer.

In receive path, accounting can be done in UDP layer
because sk_buff is marked for UDP in UDP layer and it is
released in UDP layer.

In send path, sk_buff is aquired in IP layer and also
released in IP layer. Especially, there is a possibility
 of "appending data" to the preceding sk_buff in send
queue.

On the other hand, I agree that UDP specific code
in IP layer is not preferable. So I generalize UDP
specific code in IP layer in take 2.

Could you take a look at my take 2 patch set?

Satoshi Oshima

