From: Patrick McHardy <kaber@trash.net>
Subject: Re: Netfilter+IPsec
Date: Fri, 25 Mar 2005 06:10:36 +0100
Message-ID: <42439D4C.7050606@trash.net>
References: <20050315091904.GA6256@gondor.apana.org.au> <20050315095837.GA7130@gondor.apana.org.au> <20050318090310.GA28443@gondor.apana.org.au> <20050318091129.GA28658@gondor.apana.org.au> <20050318104013.57d65e99.davem@davemloft.net> <423D9ADA.6050407@trash.net> <20050322194910.6a9fa3a4.davem@davemloft.net> <4240EA78.5050402@trash.net> <42424AAE.9080403@trash.net> <20050323214340.70a1c950.davem@davemloft.net> <20050325025349.GA24252@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, kuznet@ms2.inr.ac.ru,
        yoshfuji@linux-ipv6.org, netdev@oss.sgi.com
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20050325025349.GA24252@gondor.apana.org.au>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Herbert Xu wrote:
> On Wed, Mar 23, 2005 at 09:43:40PM -0800, David S. Miller wrote:
>>
>>>This patch (not entirely reviewed myself yet) contains the parts
>>>necessary for hooking output IPsec packets for netfilter.
>>
>>This is actually much cleaner than I had ever anticipated.
>>I like it.
> 
> I completely agree.  The output patch is an elegant piece of work.

Thanks. Unfortunantely it might need to be replaced because of
issues with the input side.

>>I suppose the input side will be quite a bit more involved?
> 
> Maybe it won't be that bad when we actually see it :)

Stealing the packets in xfrm_policy_check() didn't work out, a packet
can be checked multiple times, and before all IPsec processing is
done, because of raw sockets. Even worse, a raw socket can have its
own policy and accept packets that will be further processed by
IPsec. This suggests that the whole idea of skipping netfilter hooks
before all IPsec processing is done was wrong and we need to call
them on each pass through the stack as usual to be able to filter
before raw sockets. For symetry in the output path we would need to
pass the packet through POST_ROUTING and OUTPUT for each tunnel mode
transform. I wanted to avoid this so far because I can't think of
anything useful netfilter could do between two transforms on output,
but the good part is that it shouldn't require any changes in the
input path. I'm trying it now ..

> BTW Patrick, what about the other bits in your original patch set?
> In particular, have you still got the bit that does policy lookups
> after SNAT?

I haven't got up-to-date patches, but Christophe Saoute has ported
them to 2.6.12-rc1 and published on his page:
http://www.saout.de/misc/linux-2.6.12-rc1-ipsec-nat/
There are two patches that will probably be required either way,
the policy lookup after SNAT patch you mentioned, and a patch that
adds a function to restore struct flowi as it would have looked
without NAT for policy checks. Both are small and should be
painless.

Regards
Patrick
