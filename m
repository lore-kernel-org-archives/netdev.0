From: Cong Wang <amwang@redhat.com>
Subject: Re: [Patch 3/3] net: reserve ports for applications using fixed port
 numbers
Date: Tue, 13 Apr 2010 15:13:24 +0800
Message-ID: <4BC41994.7030707@redhat.com>
References: <20100412100744.5302.92442.sendpatchset@localhost.localdomain> <20100412100816.5302.74919.sendpatchset@localhost.localdomain> <201004130121.o3D1Lhh7099571@www262.sakura.ne.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Cc: opurdila@ixiacom.com, eric.dumazet@gmail.com,
	netdev@vger.kernel.org, nhorman@tuxdriver.com, davem@davemloft.net,
	ebiederm@xmission.com, linux-kernel@vger.kernel.org
To: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:29977 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750880Ab0DMHKB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 13 Apr 2010 03:10:01 -0400
In-Reply-To: <201004130121.o3D1Lhh7099571@www262.sakura.ne.jp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Tetsuo Handa wrote:
> Hello.
> 
>> --- linux-2.6.orig/drivers/infiniband/core/cma.c
>> +++ linux-2.6/drivers/infiniband/core/cma.c
>> @@ -1980,6 +1980,8 @@ retry:
>>  	/* FIXME: add proper port randomization per like inet_csk_get_port */
>>  	do {
>>  		ret = idr_get_new_above(ps, bind_list, next_port, &port);
>> +		if (!ret && inet_is_reserved_local_port(port))
>> +			ret = -EAGAIN;
>>  	} while ((ret == -EAGAIN) && idr_pre_get(ps, GFP_KERNEL));
>>  
>>  	if (ret)
>>
> I think above part is wrong. Below program
...
> 
> This result suggests that above loop will continue until idr_pre_get() fails
> due to out of memory if all ports were reserved.
> 
> Also, if idr_get_new_above() returned 0, bind_list (which is a kmalloc()ed
> pointer) is already installed into a free slot (see comment on
> idr_get_new_above_int()). Thus, simply calling idr_get_new_above() again will
> install the same pointer into multiple slots. I guess it will malfunction later.

Thanks for testing!

How about:

+		if (!ret && inet_is_reserved_local_port(port))
+			ret = -EBUSY;

? So that it will break the loop and return error.
