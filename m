From: Hideo AOKI <haoki@redhat.com>
Subject: Re: [PATCH 1/4] [UDP]: fix send buffer check
Date: Thu, 20 Dec 2007 22:43:17 -0500
Message-ID: <476B3655.4000508@redhat.com>
References: <47673195.80004@redhat.com>	<4767328B.70601@redhat.com> <20071220.033138.157714241.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, netdev@vger.kernel.org,
	tyasui@redhat.com, mhiramat@redhat.com,
	satoshi.oshima.fk@hitachi.com, billfink@mindspring.com,
	andi@firstfloor.org, johnpol@2ka.mipt.ru,
	shemminger@linux-foundation.org, yoshfuji@linux-ipv6.org,
	yumiko.sugita.yf@hitachi.com, haoki@redhat.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:48237 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750933AbXLUDsT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 20 Dec 2007 22:48:19 -0500
In-Reply-To: <20071220.033138.157714241.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

David Miller wrote:

>> diff -pruN net-2.6/net/ipv4/ip_output.c net-2.6-udp-take11a1-p1/net/ipv4/ip_output.c
>> --- net-2.6/net/ipv4/ip_output.c	2007-12-11 10:54:55.000000000 -0500
>> +++ net-2.6-udp-take11a1-p1/net/ipv4/ip_output.c	2007-12-17 14:42:31.000000000 -0500
>> @@ -1004,6 +1004,11 @@ alloc_new_skb:
>>  					frag = &skb_shinfo(skb)->frags[i];
>>  				}
>>  			} else if (i < MAX_SKB_FRAGS) {
>> +				if (atomic_read(&sk->sk_wmem_alloc) + PAGE_SIZE
>> +				    > 2 * sk->sk_sndbuf) {
>> +					err = -ENOBUFS;
>> +					goto error;
>> +				}
>>  				if (copy > PAGE_SIZE)
>>  					copy = PAGE_SIZE;
>>  				page = alloc_pages(sk->sk_allocation, 0);
> 
> If we are going to do this, we need to add the same check to
> skb_append_datato_frags() which is invoked via ip_ufo_append_data().
> 
> We also have to be very careful in this area.  One problem we had a
> long time ago was that we would socket account when fragmenting an
> outgoing frame.  This was bogus because even if the socket had enough
> space for one full sized frame, the packet send would fail because it
> could not fit the space for both the original frame and the
> fragmented copy of it.
> 
> This situation was cured by simply not enforcing accounting for the
> fragmented copy.  It is valid because after we fragment, we keep
> the fragmented copy but free the original.
> 
> This doesn't apply directly to this specific patch, but it is
> something to keep in mind when doing these changes.

Hello,

Thank you for sharing your experience.

Let me investigate this code and skb_append_datato_frags().

I'll include the check code in next patch set if it is really needed.

Regards,
Hideo

-- 
Hitachi Computer Products (America) Inc.
