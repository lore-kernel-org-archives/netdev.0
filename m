From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: "Badness" again
Date: Fri, 14 Jan 2005 23:20:30 -0500
Message-ID: <41E89A0E.5020207@pobox.com>
References: <41E83B8D.8020003@pobox.com> <20050114215833.GA12981@gondor.apana.org.au> <41E844AC.6040200@pobox.com> <20050115002638.GA13849@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: YOSHIFUJI Hideaki / ???????????? <yoshfuji@linux-ipv6.org>,
        "David S. Miller" <davem@davemloft.net>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20050115002638.GA13849@gondor.apana.org.au>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Herbert Xu wrote:
> On Fri, Jan 14, 2005 at 05:16:12PM -0500, Jeff Garzik wrote:
> 
>>Blah.  Any other suggestions for debugging this thing?
> 
> 
> Yes I have a better theory now :)
> 
> All your "badness" messages start with a call to udpv6_sendmsg().
> That function calls ip6_dst_lookup() to get its dst entry.  Note
> that udpv6_sendmsg() does not hold a lock on the sk at all.  However,
> ip6_dst_lookup() uses __sk_dst_check() which is only safe if you can
> either guarantee single-threadedness or if you hold sk_dst_lock.
> 
> Neither is true here and therefore we may have a situation where
> the cached dst is released twice.  In fact I tracked down the
> address closest to the "badness" messages and it belongs to
> one of your domain's name servers.  That means the requests were
> probably made by named, which is multi-threaded.
> 
> So please give this patch a spin and see if it makes things any
> better.  I've verified that no callers to ip6_dst_lookup() holds
> sk_dst_lock so it's safe (but possibly redundant in cases where
> they hold locks on the sk itself) to use sk_dst_check().

Running with this patch now, we'll see how it goes.  Thanks.

FWIW I also see ICMP code paths in the tracebacks (but that may be 
"second message" noise).

	Jeff
