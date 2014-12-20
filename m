From: David Miller <davem@davemloft.net>
Subject: Re: net: Detect drivers that reschedule NAPI and exhaust budget
Date: Fri, 19 Dec 2014 21:40:00 -0500 (EST)
Message-ID: <20141219.214000.819506179607476836.davem@davemloft.net>
References: <20141220002327.GA31975@gondor.apana.org.au>
	<20141220003636.GA32187@gondor.apana.org.au>
	<1419039288.11185.4.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, david.vrabel@citrix.com,
	netdev@vger.kernel.org, xen-devel@lists.xenproject.org,
	konrad.wilk@oracle.com, boris.ostrovsky@oracle.com,
	edumazet@google.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:34741 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751762AbaLTCkG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Dec 2014 21:40:06 -0500
In-Reply-To: <1419039288.11185.4.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Fri, 19 Dec 2014 17:34:48 -0800

>> @@ -4620,7 +4620,11 @@ static void net_rx_action(struct softirq_action *h)
>>  					 */
>>  					napi_gro_flush(n, HZ >= 1000);
>>  				}
>> -				list_add_tail(&n->poll_list, &repoll);
>> +				/* Some drivers may have called napi_schedule
>> +				 * prior to exhausting their budget.
>> +				 */
>> +				if (!WARN_ON_ONCE(!list_empty(&n->poll_list)))
>> +					list_add_tail(&n->poll_list, &repoll);
>>  			}
>>  		}
>>  
> 
> I do not think stack trace will point to the buggy driver ?
> 
> IMO it would be better to print a single line with the netdev name ?

Right, we are already back from the poll routine and will just end
up seeing the call trace leading to the software interrupt.
