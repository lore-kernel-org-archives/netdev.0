From: zhangfei <zhangfei.gao@linaro.org>
Subject: Re: [PATCH 3/3] net: hisilicon: new hip04 ethernet driver
Date: Thu, 27 Mar 2014 20:53:00 +0800
Message-ID: <53341F2C.2030303@linaro.org>
References: <1395670496-17381-1-git-send-email-zhangfei.gao@linaro.org> <21873900.AIOr1ryy37@wuerfel> <1395768102.12610.159.camel@edumazet-glaptop2.roam.corp.google.com> <7101996.LQrASEuksF@wuerfel>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Florian Fainelli <f.fainelli@gmail.com>,
	Zhangfei Gao <zhangfei.gao@gmail.com>,
	linux-arm-kernel <linux-arm-kernel@lists.infradead.org>,
	Mark Rutland <mark.rutland@arm.com>,
	"devicetree@vger.kernel.org" <devicetree@vger.kernel.org>,
	Russell King - ARM Linux <linux@arm.linux.org.uk>,
	Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
	netdev <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>
To: Arnd Bergmann <arnd@arndb.de>,
	Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f47.google.com ([209.85.220.47]:60165 "EHLO
	mail-pa0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753781AbaC0Mx0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Mar 2014 08:53:26 -0400
Received: by mail-pa0-f47.google.com with SMTP id lj1so3428680pab.34
        for <netdev@vger.kernel.org>; Thu, 27 Mar 2014 05:53:26 -0700 (PDT)
In-Reply-To: <7101996.LQrASEuksF@wuerfel>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 03/26/2014 01:54 AM, Arnd Bergmann wrote:
> On Tuesday 25 March 2014 10:21:42 Eric Dumazet wrote:
>> On Tue, 2014-03-25 at 18:05 +0100, Arnd Bergmann wrote:
>>> On Tuesday 25 March 2014 10:00:30 Florian Fainelli wrote:
>>>
>>>> Using a timer to ensure completion of TX packets is a trick that
>>>> worked in the past, but now that the networking stack got smarter,
>>>> this might artificially increase the processing time of packets in the
>>>> transmit path, and this will defeat features like TCP small queues
>>>> etc.. as could be seen with the mvneta driver [1]. The best way really
>>>> is to rely on TX completion interrupts when those exist as they cannot
>>>> lie about the hardware status (in theory) and they should provide the
>>>> fastest way to complete TX packets.
>>>
>>> By as Zhangfei Gao pointed out, this hardware does not have a working
>>> TX completion interrupt. Using timers to do this has always just been
>>> a workaround for broken hardware IMHO.
>>
>> For this kind of drivers, calling skb_orphan() from ndo_start_xmit() is
>> mandatory.
>
> Cool, thanks for the information, I was wondering already if there was
> a way to deal with hardware like this.
>

That's great,
In the experiment, keeping reclaim in the ndo_start_xmit always get the 
best throughput, also simpler, even no requirement of spin_lock.

By the way, still have confusion about build_skb.

At first, I thought we can malloc n*buffers as a ring and keep using 
them for dma, every time when packet coming, using build_skb adds a 
head, send to upper layer.
After data is consumed, we can continue reuse the buffer next time.

However, in the iperf stress test, always error happen.
The buffer is released in fact, and we need alloc new buffer for the 
next transfer.

So the build_skb is not used for reusing buffers, but only for keeping 
hot data in cache, right?

Thanks
