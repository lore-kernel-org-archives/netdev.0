From: Kouya Shimura <kouya@jp.fujitsu.com>
Subject: Re: [PATCH] ipv4: do not cache local route when using SO_BINDTODEVICE
Date: Fri, 26 Feb 2016 16:02:53 +0900
Message-ID: <87wppsc5sy.fsf@pingu.sky.yk.fujitsu.co.jp>
References: <87si0knghn.fsf@pingu.sky.yk.fujitsu.co.jp>
	<20160225.143106.1173673610254814867.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mgwym02.jp.fujitsu.com ([211.128.242.41]:54861 "EHLO
	mgwym02.jp.fujitsu.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750814AbcBZHDD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Feb 2016 02:03:03 -0500
Received: from g01jpfmpwkw03.exch.g01.fujitsu.local (g01jpfmpwkw03.exch.g01.fujitsu.local [10.0.193.57])
	by yt-mxauth.gw.nic.fujitsu.com (Postfix) with ESMTP id CDA94AC0A75
	for <netdev@vger.kernel.org>; Fri, 26 Feb 2016 16:02:55 +0900 (JST)
In-Reply-To: <20160225.143106.1173673610254814867.davem@davemloft.net> (David
	Miller's message of "Thu, 25 Feb 2016 14:31:06 -0500")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thanks for reviewing.

David Miller <davem@davemloft.net> writes:
> From: Kouya Shimura <kouya@jp.fujitsu.com>
> Date: Tue, 23 Feb 2016 14:27:32 +0900
>
>> After v3.6, output routes are cached, however, the 'rt_iif' field of
>> struct rtable can not be shared by various traffics using SO_BINDTODEVICE.
>> It causes that traffic can not reach the local receiver which also uses 
>> SO_BINDTODEVICE after another traffic creates a local route cache. 
>> 
>>   /* sender and receiver are running on same host. */
>>   sender:
>>     - socket(SOCK_DGRAM)
>>     - setsockopt(SO_BINDTODEVICE, "eth0")
>>     - connect(INADDR_ANY)
>>     - send("message") ------>[loopback]------+
>>                                              |
>>   receiver:                                  |
>>     - socket(SOCK_DGRAM)                     |
>>     - setsockopt(SO_BINDTODEVICE, "eth0")    |
>>     - bind(INADDR_ANY)                       |
>>     - recv()  <------------------------------+
>>       /* sometimes reach, sometimes not reach!!! */
>> 
>> Before v3.6, above traffics always reached. It seems to be a
>> regression. Actually the 'dhcp_release' command relies on it.
>> 
>> Commit 7bd86cc282a458b66c41e3f6 ("ipv4: Cache local output routes")
>> originated this issue. Revert it conditionally.
>> 
>> Signed-off-by: Kouya Shimura <kouya@jp.fujitsu.com>
>
> I strongly fear that this will cause a performance regression for some important
> cases.  If you elide the cache, it means that every route lookup has
> to allocate,
> create, and destroy the cache object.  This is really expensive.

The performace degradation was on my mind. Thus, I intended that this
patch affects only special (abnormal?) case that destination is local
and using SO_BINDTODEVICE. Isn't it acceptable?

This patch deesn't elide the existing cache. Normal (not using
SO_BINDTODEVICE) routes are still cached (not destoyed). Outer
routes, too. I confirmed it.

If you worry about non-zeroed 'orig_oif' case, this patch certainly
implies a perfomance problem. 'orig_oif' seems to be non-zero in
cases of ICMP, GRE, MULTICAST besides SO_BINDTODEVICE. 

>
> There has to be a better way to do so, so I'm not applying this patch,
> sorry.

Yes, it has to be. The root cause is sharing the 'rt_iif' field.
I'm looking forward to the right fix.

Thanks,
Kouya
