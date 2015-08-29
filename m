From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH RFC V2 2/2] net: Optimize snmp stat aggregation by
 walking all the percpu data at once
Date: Fri, 28 Aug 2015 20:26:31 -0700
Message-ID: <1440818791.8932.128.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1440610653-14210-3-git-send-email-raghavendra.kt@linux.vnet.ibm.com>
	 <20150827.113823.214019265460582055.davem@davemloft.net>
	 <55E00238.10909@linux.vnet.ibm.com>
	 <20150828.112413.424099339331017970.davem@davemloft.net>
	 <20150829025715.GA5546@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, edumazet@google.com,
	kuznet@ms2.inr.ac.ru, jmorris@namei.org, yoshfuji@linux-ipv6.org,
	kaber@trash.net, jiri@resnulli.us, hannes@stressinduktion.org,
	tom@herbertland.com, azhou@nicira.com, ebiederm@xmission.com,
	ipm@chirality.org.uk, nicolas.dichtel@6wind.com,
	serge.hallyn@canonical.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, anton@au1.ibm.com,
	nacc@linux.vnet.ibm.com, srikar@linux.vnet.ibm.com
To: Raghavendra K T <raghavendra.kt@linux.vnet.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f52.google.com ([209.85.220.52]:33117 "EHLO
	mail-pa0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751815AbbH2D0e (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Aug 2015 23:26:34 -0400
In-Reply-To: <20150829025715.GA5546@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2015-08-29 at 08:27 +0530, Raghavendra K T wrote:
>  
>  	/* Use put_unaligned() because stats may not be aligned for u64. */
>  	put_unaligned(items, &stats[0]);


>  	for (i = 1; i < items; i++)
> -		put_unaligned(snmp_fold_field64(mib, i, syncpoff), &stats[i]);
> +		put_unaligned(buff[i], &stats[i]);
>  

I believe Joe suggested following code instead :

buff[0] = items;
memcpy(stats, buff, items * sizeof(u64));

Also please move buff[] array into __snmp6_fill_stats64() to make it
clear it is used in a 'leaf' function.

(even if calling memcpy()/memset() makes it not a leaf function)
