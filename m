From: "Xin, Xiaohui" <xiaohui.xin@intel.com>
Subject: RE: Is it a possible bug in dev_gro_receive()?
Date: Tue, 3 Aug 2010 10:33:24 +0800
Message-ID: <F2E9EB7348B8264F86B6AB8151CE2D791BAB3078E0@shsmsx502.ccr.corp.intel.com>
References: <1280454855-7893-1-git-send-email-xiaohui.xin@intel.com>
 <20100802102906.GA8439@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"herbert@gondor.apana.org.au" <herbert@gondor.apana.org.au>,
	"davem@davemloft.net" <davem@davemloft.net>
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:56342 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751988Ab0HCCew convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Aug 2010 22:34:52 -0400
In-Reply-To: <20100802102906.GA8439@ff.dom.local>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>-----Original Message-----
>From: Jarek Poplawski [mailto:jarkao2@gmail.com]
>Sent: Monday, August 02, 2010 6:29 PM
>To: Xin, Xiaohui
>Cc: netdev@vger.kernel.org; herbert@gondor.apana.org.au; davem@davemloft.net
>Subject: Re: Is it a possible bug in dev_gro_receive()?
>
>Xin Xiaohui wrote:
>> I looked into the code dev_gro_receive(), found the code here:
>> if the frags[0] is pulled to 0, then the page will be released,
>> and memmove() frags left.
>> Is that right? I'm not sure if memmove do right or not, but
>> frags[0].size is never set after memove at least. what I think
>> a simple way is not to do anything if we found frags[0].size == 0.
>> The patch is as followed.
>>
>> Or am I missing something here?
>
>I think, you're right, but fixing memmove looks nicer to me:
>
> -	--skb_shinfo(skb)->nr_frags);
> +	--skb_shinfo(skb)->nr_frags * sizeof(skb_frag_t));
>
>Jarek P.

Is there a little hurt of performance to do memmove() if skb_shinfo(skb)->nr_frags is large?
We're now working on the zero-copy patches based on napi_gro_frags() interface, and in 
this case, we have found a lot of skbs which frags[0] is pulled to 0. And after the memmove is
fixed, each frags[x].size is needed to modify too.
So I think don't do anything is better. Or is there any side effect with a null page in the stack?

Thanks
Xiaohui
>
>>
>> ---
>>  net/core/dev.c |    7 -------
>>  1 files changed, 0 insertions(+), 7 deletions(-)
>>
>> diff --git a/net/core/dev.c b/net/core/dev.c
>> index 264137f..28cdbbf 100644
>> --- a/net/core/dev.c
>> +++ b/net/core/dev.c
>> @@ -2730,13 +2730,6 @@ pull:
>>
>>  		skb_shinfo(skb)->frags[0].page_offset += grow;
>>  		skb_shinfo(skb)->frags[0].size -= grow;
>> -
>> -		if (unlikely(!skb_shinfo(skb)->frags[0].size)) {
>> -			put_page(skb_shinfo(skb)->frags[0].page);
>> -			memmove(skb_shinfo(skb)->frags,
>> -				skb_shinfo(skb)->frags + 1,
>> -				--skb_shinfo(skb)->nr_frags);
>> -		}
>>  	}
>>
>>  ok:
>
>

