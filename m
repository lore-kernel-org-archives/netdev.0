From: Denys Fedoryshchenko <nuclearcat@nuclearcat.com>
Subject: Re: SNAT --random & fully is not actually random for ips
Date: Mon, 28 Nov 2016 13:12:07 +0200
Message-ID: <fb3151804cc3b2c57e69d1059b3417ee@nuclearcat.com>
References: <97a6a1c557f0f1e6d55d8d09b326f8b1@nuclearcat.com>
 <20161128110651.GA1024@salvia>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII;
 format=flowed
Content-Transfer-Encoding: 7bit
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
        netfilter-devel@vger.kernel.org
To: Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nuclearcat.com ([144.76.183.226]:49590 "EHLO nuclearcat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754525AbcK1LMM (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 28 Nov 2016 06:12:12 -0500
In-Reply-To: <20161128110651.GA1024@salvia>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2016-11-28 13:06, Pablo Neira Ayuso wrote:
> On Mon, Nov 28, 2016 at 12:45:59PM +0200, Denys Fedoryshchenko wrote:
>> Hello,
>> 
>> I noticed that if i specify -j SNAT with options --random 
>> --random-fully
>> still it keeps persistence for source IP.
> 
> So you specify both?
> 
>> Actually truly random src ip required in some scenarios like links 
>> balanced
>> by IPs, but seems since 2012 at least it is not possible.
>> 
>> But actually if i do something like:
>> --- nf_nat_core.c.new	2016-11-28 09:55:54.000000000 +0000
>> +++ nf_nat_core.c	2016-11-21 09:11:59.000000000 +0000
>> @@ -282,13 +282,9 @@
>>  	 * client coming from the same IP (some Internet Banking sites
>>  	 * like this), even across reboots.
>>  	 */
>> -	if (range->flags & NF_NAT_RANGE_PROTO_RANDOM_FULLY) {
>> -	    j = prandom_u32();
>> -	} else {
>> -	    j = jhash2((u32 *)&tuple->src.u3, sizeof(tuple->src.u3) / 
>> sizeof(u32),
>> +	j = jhash2((u32 *)&tuple->src.u3, sizeof(tuple->src.u3) / 
>> sizeof(u32),
>>  		   range->flags & NF_NAT_RANGE_PERSISTENT ?
>>  			0 : (__force u32)tuple->dst.u3.all[max] ^ zone->id);
>> -	}
>> 
>>  	full_range = false;
>>  	for (i = 0; i <= max; i++) {
>> 
>> It works as intended. But i guess to not break compatibility it is 
>> better
>> should be introduced as new option?
>> Or maybe there is no really need for such option?
> 
> Why does your patch reverts NF_NAT_RANGE_PROTO_RANDOM_FULLY?
Ops, sorry i just did mistake with files, actually it is in reverse ( 
did this patch, and it worked properly with it, with random source ip).
--- nf_nat_core.c	2016-11-21 09:11:59.000000000 +0000
+++ nf_nat_core.c.new	2016-11-28 09:55:54.000000000 +0000
@@ -282,9 +282,13 @@
  	 * client coming from the same IP (some Internet Banking sites
  	 * like this), even across reboots.
  	 */
-	j = jhash2((u32 *)&tuple->src.u3, sizeof(tuple->src.u3) / sizeof(u32),
+	if (range->flags & NF_NAT_RANGE_PROTO_RANDOM_FULLY) {
+	    j = prandom_u32();
+	} else {
+	    j = jhash2((u32 *)&tuple->src.u3, sizeof(tuple->src.u3) / 
sizeof(u32),
  		   range->flags & NF_NAT_RANGE_PERSISTENT ?
  			0 : (__force u32)tuple->dst.u3.all[max] ^ zone->id);
+	}

  	full_range = false;
  	for (i = 0; i <= max; i++) {

This is current situation, RANDOM_FULLY actually does prandom_u32 for 
source port only, but not for IP.
IP kept as persistent and kind of predictable, because hash function 
based on source ip.

Sure i did tried to specify any combination of flags, but looking to 
"find_best_ips_proto" function, it wont have any effect.
