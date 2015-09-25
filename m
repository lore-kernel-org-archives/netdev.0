From: Tejun Heo <tj@kernel.org>
Subject: Re: netlink: Add barrier to netlink_connect for theoretical case
Date: Fri, 25 Sep 2015 11:09:13 -0400
Message-ID: <20150925150913.GE4449@mtj.duckdns.org>
References: <20150921133415.GA1740@gondor.apana.org.au>
 <20150921182022.GB13263@mtj.duckdns.org>
 <20150922033856.GA7851@gondor.apana.org.au>
 <20150924.121142.870602292135442487.davem@davemloft.net>
 <20150924200510.GE25415@mtj.duckdns.org>
 <20150925014327.GA3725@gondor.apana.org.au>
 <CA+55aFxSqK1dcuKapCkn+VaN0E1XwxGrz_5WzrJB5Ej52zsn9w@mail.gmail.com>
 <20150925033957.GA4675@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linus Torvalds <torvalds@linux-foundation.org>,
	David Miller <davem@davemloft.net>,
	Cong Wang <cwang@twopensource.com>,
	Tom Herbert <tom@herbertland.com>, kafai@fb.com,
	kernel-team@fb.com,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Network Development <netdev@vger.kernel.org>,
	=?utf-8?B?SmnFmcOtIFDDrXJrbw==?= <jiri@resnulli.us>,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>,
	Thomas Graf <tgraf@suug.ch>, Scott Feldman <sfeldma@gmail.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yk0-f172.google.com ([209.85.160.172]:34727 "EHLO
	mail-yk0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755269AbbIYPJ2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Sep 2015 11:09:28 -0400
Content-Disposition: inline
In-Reply-To: <20150925033957.GA4675@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello, Herbert.

On Fri, Sep 25, 2015 at 11:39:57AM +0800, Herbert Xu wrote:
> +static inline bool netlink_bound(struct netlink_sock *nlk)
> +{
> +	bool bound = READ_ONCE(nlk->bound);
> +
> +	/* Ensure nlk is hashed and visible. */
> +	if (bound)
> +		smp_rmb();
> +
> +	return bound;
> +}

While I can't see anything wrong with the above, I'm not a fan of it
for whatever worth that may be.  I don't think it adds anything in
terms of readability or clarity of the code.  It does avoid smp_rmb()
when @bound is false but that's unlikely to be helfpul - where the
barrier is being avoided is a cold path.  This is largely a generic
characteristic because if where the barrier is being avoided is a hot
path, why wouldn't the code just grab a lock in that path instead of
using a gated barrier?  So, there's a reason why we don't see code
like the above commonly.  It doesn't buy us anything meaningful while
making the code more complicated and sometimes more fragile.

Thanks.

-- 
tejun
