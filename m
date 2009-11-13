From: William Allen Simpson <william.allen.simpson@gmail.com>
Subject: Re: [net-next-2.6 PATCH v6 3/7 RFC] TCPCT part 1c: sysctl_tcp_cookie_size,
 socket option TCP_COOKIE_TRANSACTIONS
Date: Fri, 13 Nov 2009 14:45:04 -0500
Message-ID: <4AFDB740.3060509@gmail.com>
References: <4AFCDA9E.8050003@gmail.com>  <4AFCE13B.4060006@gmail.com> <1258137443.16857.124.camel@Joe-Laptop.home>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f227.google.com ([209.85.218.227]:65052 "EHLO
	mail-bw0-f227.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757124AbZKMTpF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Nov 2009 14:45:05 -0500
Received: by bwz27 with SMTP id 27so3815028bwz.21
        for <netdev@vger.kernel.org>; Fri, 13 Nov 2009 11:45:09 -0800 (PST)
In-Reply-To: <1258137443.16857.124.camel@Joe-Laptop.home>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Joe Perches wrote:
> On Thu, 2009-11-12 at 23:31 -0500, William Allen Simpson wrote:
>> Define sysctl (tcp_cookie_size) to turn on and off the cookie option
>> default globally, instead of a compiled configuration option.
> []
> 
>> +#define TCP_COOKIE_MIN		 8		/*  64-bits */
>> +#define TCP_COOKIE_MAX		16		/* 128-bits */
> 
> perhaps something like:
> 
> static const int TCP_COOKIE_MIN = 8;
> static const int TCP_COOKIE_MAX = 16;
> 
> []
> 
>> --- a/net/ipv4/sysctl_net_ipv4.c
>> +++ b/net/ipv4/sysctl_net_ipv4.c
>> @@ -714,6 +714,14 @@ static struct ctl_table ipv4_table[] = {
>>  	},
>>  	{
>>  		.ctl_name	= CTL_UNNUMBERED,
>> +		.procname	= "tcp_cookie_size",
>> +		.data		= &sysctl_tcp_cookie_size,
>> +		.maxlen		= sizeof(int),
>> +		.mode		= 0644,
>> +		.proc_handler	= proc_dointvec
> 
> with proc_dointvec_minmax
> 
> 		.extra1		= &TCP_COOKIE_MIN,
> 		.extra2		= &TCP_COOKIE_MAX,
> 
> or even adding proc_dointvec_minmax_even
> might save some cycles during cookie handling.
> 
Well, that would have to be proc_dointvec_minmax_even_zero(), as the
valid values can be 0, 8, 10, 12, 14, or 16.  But my guess (based on
experience owning an ISP and teaching student operators) is that folks
will remember to turn it off (0) or on (1) or "bigger" (255), and not
really care about the finer gradations.

Error messages have a tendency to scroll off the screen and be forgotten.

And it seems to me a case of "premature optimization" -- it might save
1 or 2 tests in the order I've listed them in tcp_cookie_size_check(),
those tests only happen on the SYN the first time the _client_ calls,
and the result is saved for the future.  See part 1f:

+	u8 cookie_size = (!tp->rx_opt.cookie_out_never && cvp != NULL)
+			 ? tcp_cookie_size_check(cvp->cookie_desired)
+			 : 0;

[]

+			/* Remember for future incarnations. */
+			cvp->cookie_desired = cookie_size;

On the server side, we have to test during parsing anyway.  I never trust
any data that comes over the network....
