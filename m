From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: RFC: Established connections hash function
Date: Thu, 22 Mar 2007 18:52:27 +0300
Message-ID: <20070322155227.GA18557@2ka.mipt.ru>
References: <10189ABA61CF4D5AB3881F96C9CACE87@XEON>
Mime-Version: 1.0
Content-Type: text/plain; charset=koi8-r
Cc: netdev@vger.kernel.org
To: "Nikolaos D. Bougalis" <nikb@webmaster.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:57795 "EHLO 2ka.mipt.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933214AbXCVPwe (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 22 Mar 2007 11:52:34 -0400
Content-Disposition: inline
In-Reply-To: <10189ABA61CF4D5AB3881F96C9CACE87@XEON>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Mar 22, 2007 at 08:39:04AM -0700, Nikolaos D. Bougalis (nikb@webmaster.com) wrote:
>    This particular hash seems to be the odd-man out, since most other
> network related hashes in the kernel seem to be Jenkins-based, and some use
> tagged hashing to defeat algorithmic complexity attacks. For example, the
> route hash uses this:

It seems you do not know a history...
It is the fastest and actually the best hash for that workloads where it
is used, but unfortunately it is too simple for attacker to predict end
result.

> static unsigned int rt_hash_rnd;
> 
> static unsigned int rt_hash_code(u32 daddr, u32 saddr)
> {
>        return (jhash_2words(daddr, saddr, rt_hash_rnd)
>                & rt_hash_mask);
> }
> 
>    With this in mind, I propose the following replacement for inet_ehashfn,
> which defeats algorithmic complexity attacks and achieves excellent
> distribution:
> 
> unsigned int inet_ehashfn(const __be32 laddr, const __u16 lport,
>                          const __be32 faddr, const __be16 fport)
> {
>    return jhash_3words((__force __u32)faddr, (__force __u32)laddr,
>                        (((__force __u32)fport) << 16) + lport,
>                        inet_ehash_rnd);
> }

And this is utterly broken. For more details please read netdev@
archives and trivial analysis of jhash_3words().

We can use jhash_2words(laddr, faddr, portpair^inet_ehash_rnd) though.

-- 
	Evgeniy Polyakov
