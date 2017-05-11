From: Alexei Starovoitov <ast@fb.com>
Subject: Re: [PATCH v2 1/7] bpf: Track alignment of register values in the
 verifier.
Date: Thu, 11 May 2017 15:53:06 -0700
Message-ID: <06d46f08-2c62-d167-1fe5-a49284c614bb@fb.com>
References: <20170511.120516.2089919860112370473.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <alexei.starovoitov@gmail.com>, <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>, <daniel@iogearbox.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:60304 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751248AbdEKWxa (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 11 May 2017 18:53:30 -0400
In-Reply-To: <20170511.120516.2089919860112370473.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 5/11/17 9:05 AM, David Miller wrote:
> +		had_id = (dst_reg->id != 0);
> +
>  		/* dst_reg stays as pkt_ptr type and since some positive
>  		 * integer value was added to the pointer, increment its 'id'
>  		 */
>  		dst_reg->id = ++env->id_gen;
>
> -		/* something was added to pkt_ptr, set range and off to zero */
> +		/* something was added to pkt_ptr, set range to zero */
> +		dst_reg->aux_off = dst_reg->off;

what about 2nd addition of a variable to pkt_ptr ?
aux_off sort-of remembers already accumulated offset in pkt_ptr, but
above line will hard assign it which doesn't seem right for the 2nd
addition.
Ex:
before first add, reg->off == 14
after first add, aux_off = 14, off = 0
then imm4 added, now we have reg->off=4, aux_off=14
now we do 2nd add of variable and
reg->aux_off becomes 4
and if we later do u64 load from the packet it will be rejected
due to (net_ip_align + 4) whereas it should have been ok
due to (net_ip_align + 14 + 4).


>  		dst_reg->off = 0;
>  		dst_reg->range = 0;
> +		if (had_id)
> +			dst_reg->aux_off_align = min(dst_reg->aux_off_align,
> +						     src_reg->min_align);
> +		else
> +			dst_reg->aux_off_align = src_reg->min_align;

all aux_off_align logic here and in other places looks fine to me,
since it's conservative.
