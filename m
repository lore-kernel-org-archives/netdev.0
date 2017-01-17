From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: [PATCH net-next v2 1/3] net: ipv6: Allow shorthand delete of all
 nexthops in multipath route
Date: Mon, 16 Jan 2017 18:27:36 -0700
Message-ID: <06d4b3c0-0713-04b8-32d2-99b9b083b825@cumulusnetworks.com>
References: <1484510826-2723-1-git-send-email-dsa@cumulusnetworks.com>
 <1484510826-2723-2-git-send-email-dsa@cumulusnetworks.com>
 <20170116.195139.2265183195514595519.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ddutt@cumulusnetworks.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f174.google.com ([209.85.192.174]:33687 "EHLO
        mail-pf0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750917AbdAQBzQ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 16 Jan 2017 20:55:16 -0500
Received: by mail-pf0-f174.google.com with SMTP id y143so57604715pfb.0
        for <netdev@vger.kernel.org>; Mon, 16 Jan 2017 17:54:26 -0800 (PST)
In-Reply-To: <20170116.195139.2265183195514595519.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 1/16/17 5:51 PM, David Miller wrote:
> From: David Ahern <dsa@cumulusnetworks.com>
> Date: Sun, 15 Jan 2017 12:07:04 -0800
> 
>> @@ -2143,6 +2143,26 @@ int ip6_del_rt(struct rt6_info *rt)
>>  	return __ip6_del_rt(rt, &info);
>>  }
>>  
>> +/* called with table lock held */
>  ...
>> @@ -2176,10 +2196,9 @@ static int ip6_route_del(struct fib6_config *cfg)
>>  				continue;
>>  			if (cfg->fc_protocol && cfg->fc_protocol != rt->rt6i_protocol)
>>  				continue;
>> -			dst_hold(&rt->dst);
>> -			read_unlock_bh(&table->tb6_lock);
>>  
>> -			return __ip6_del_rt(rt, &cfg->fc_nlinfo);
>> +			err = __ip6_route_del(rt, cfg);
>> +			break;
>>  		}
> 
> fib6_del() (invoked by __ip6_route_del()) has to be invoked with the
> table lock held a sa writer, but here you are only holding it as a
> reader.

That table lock is still held. If you look up 2 lines I remove the line that releases the lock.

> 
> I also think some more thought has to be put into whether we can
> change behavior like this without using a flag, as suggested by Roopa.
> 

I'm all for changing the behavior by default, but AIUI that breaks the golden rule.

libnl as of libnl3_2_16-16-g29b71371e764  (a patch by Roopa) already handles both flavors -- if RTA_MULTIPATH is sent it handles it fine and if a series of routes are sent they are consolidated to 1 object with next hops.

iproute2 can handle it just fine as well. I made no changes to get the display format consistent. The problem here is scripts that rely on the old format.

quagga does *not* correctly handle the RTA_MULTIPATH attribute for IPv6 but then it does not properly handle IPv6 multipath routes it receives from the kernel at all. Same result with current kernel code or with this patch set - only the last nexthop is retained. (quagga routes pushed to kernel works, but kernel routes fed to quagga does not)
