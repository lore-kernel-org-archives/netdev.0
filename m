From: Patrick McHardy <kaber@trash.net>
Subject: Re: IPsec xfrm resolution
Date: Sat, 19 Feb 2005 07:03:32 +0100
Message-ID: <4216D6B4.5070901@trash.net>
References: <20050209085251.GA9030@gondor.apana.org.au> <420B9DF1.3020704@trash.net> <20050210202810.GA1609@gondor.apana.org.au> <42144C3F.2060501@trash.net> <20050217091137.GA9476@gondor.apana.org.au> <42152841.5000707@trash.net> <20050218100854.GA19427@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Maillist netdev <netdev@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20050218100854.GA19427@gondor.apana.org.au>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Herbert Xu wrote:

>On Fri, Feb 18, 2005 at 12:26:57AM +0100, Patrick McHardy wrote:
>  
>
>>I'm not sure yet how to deal with optional SAs. We shouldn't add
>>incomplete optional tunnel mode SAs to the bundle because then we
>>can't determine the output device, but if we don't nothing will
>>trigger resolving of optional SAs following a non-optional SA that
>>needs to be resolved.
>>    
>>
>
>I don't get it.  Can't you just add it into the bundle but ignore it
>for dst->output and other calculations until it's either realised or
>removed?
>  
>
An optional tunnel mode SA might change peer/dev/rt_gateway/rt_type if
successfully resolved. This introduces a couple of problems:

- MTU estimatation impossible
- netfilter LOCAL_OUT hook sees incorrect output device
- strict source routing check done with incorrect rt_gateway

Simply ignoring these SAs if they are not available when the bundle is
created looks like the easiest solution to me.

>>I thought about adding the queue to the xfrm_dst and adding a dummy
>>xfrm_state with a selector that matches only the current flow. This
>>    
>>
>
>The inner flow is probably not the best key for this.  How about
>keying it using the outer remote address on the template? The SAs
>have a bydst hash which makes this easy to look up.
>
>So we would attach each packet to a queue shared by all SAs to a
>specific (outer) remote address.
>  
>
That sounds reasonable. The selector initialized to the inner flow is
meant for cacheing the incomplete bundle at the policy. We can have
multiple SAs with equal family/reqid/saddr/daddr/mode/proto differing
only be SPI and selector. If we use a selector selecting more than the
inner flow we could create a conflict with an already existing cached
bundle.

Regards
Patrick
