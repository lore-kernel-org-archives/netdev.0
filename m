From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 1/7] bpf: Track alignment of register values in the
 verifier.
Date: Thu, 11 May 2017 21:14:06 -0400 (EDT)
Message-ID: <20170511.211406.1201174799693258613.davem@davemloft.net>
References: <20170511.120516.2089919860112370473.davem@davemloft.net>
        <06d46f08-2c62-d167-1fe5-a49284c614bb@fb.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: daniel@iogearbox.net, alexei.starovoitov@gmail.com,
        netdev@vger.kernel.org
To: ast@fb.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:56508 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755030AbdELBOQ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 11 May 2017 21:14:16 -0400
In-Reply-To: <06d46f08-2c62-d167-1fe5-a49284c614bb@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexei Starovoitov <ast@fb.com>
Date: Thu, 11 May 2017 15:53:06 -0700

> On 5/11/17 9:05 AM, David Miller wrote:
>> +		had_id = (dst_reg->id != 0);
>> +
>>  		/* dst_reg stays as pkt_ptr type and since some positive
>>  		 * integer value was added to the pointer, increment its 'id'
>>  		 */
>>  		dst_reg->id = ++env->id_gen;
>>
>> -		/* something was added to pkt_ptr, set range and off to zero */
>> +		/* something was added to pkt_ptr, set range to zero */
>> +		dst_reg->aux_off = dst_reg->off;
> 
> what about 2nd addition of a variable to pkt_ptr ?
> aux_off sort-of remembers already accumulated offset in pkt_ptr, but
> above line will hard assign it which doesn't seem right for the 2nd
> addition.
> Ex:
> before first add, reg->off == 14
> after first add, aux_off = 14, off = 0
> then imm4 added, now we have reg->off=4, aux_off=14
> now we do 2nd add of variable and
> reg->aux_off becomes 4
> and if we later do u64 load from the packet it will be rejected
> due to (net_ip_align + 4) whereas it should have been ok
> due to (net_ip_align + 14 + 4).

Indeed, we have to accumulate.  I was just thinking about this earlier
today.

Thanks for pointing this out, I'll work on a fix and write some test
cases.
