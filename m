From: jamal <hadi@cyberus.ca>
Subject: Re: [patch/RFC]: Asynchronous IPsec processing benchmark.
Date: Thu, 05 May 2005 09:04:29 -0400
Message-ID: <1115298270.7680.65.camel@localhost.localdomain>
References: <20050429144103.A23268@2ka.mipt.ru>
	 <20050503095312.GA29788@gondor.apana.org.au>
	 <1115115502.3414.22.camel@uganda>
	 <20050503101447.GA29973@gondor.apana.org.au>
	 <1115116295.3414.30.camel@uganda>
	 <20050503102929.GA30097@gondor.apana.org.au>
	 <1115117728.3414.48.camel@uganda> <1115127507.3414.58.camel@uganda>
	 <1115203214.7665.58.camel@localhost.localdomain>
	 <20050504201143.7f6bdcce@zanzibar.2ka.mipt.ru>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Herbert Xu <herbert@gondor.apana.org.au>, netdev@oss.sgi.com,
        Patrick McHardy <kaber@trash.net>,
        "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-bounce@oss.sgi.com>
To: johnpol@2ka.mipt.ru
In-Reply-To: <20050504201143.7f6bdcce@zanzibar.2ka.mipt.ru>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 2005-04-05 at 20:11 +0400, Evgeniy Polyakov wrote:
> On Wed, 04 May 2005 06:40:14 -0400
> jamal <hadi@cyberus.ca> wrote:
> 
> > On Tue, 2005-03-05 at 17:38 +0400, Evgeniy Polyakov wrote:
> > > Here are some numbers:
> > > 
> > > ./netperf -l 60 -H gw -t TCP_STREAM -i 10,2 -I 99,5 -- -m 4096 -s 57344
> > > -S 57344
> > > 
> > > TCP STREAM TEST to gw : +/-2.5% @ 99% conf.
> > > 
> > > async-ipsec, 10^6bits/sec:  35.42
> > >  sync-ipsec, 10^6bits/sec:  37.11
> > > 
> > > So even with existing timer deferring it is not noticebly slower [about
> > > 4%].
> > > 
> > 
> > by "sync" i hope you mean the original code without your change?
> 
> Yes, it is vanilla 2.6.12-rc2 kernel with native IPsec.
> 

Very nice numbers then - considering the async was at least delaying
things by at least a jiffie.


> > The one thing i see in your POC code that may affect numbers a bit is
> > allocation of struct esp_async every time in the path. Perhaps precreate
> > a pool of those and then just grab/return to/fro pool;
> 
> That could be skb too - since both skb/kmalloc 
> atomic allocations end up in kmem_cache_alloc().

The skb is a little tricky in particular if you allocate in one CPU and 
free on another. If this could happen with the esp_async struct as well
then it is not worth it.

>  
> > BTW, you may need to incr ref counter of x pre-callback and decrement
> > when done in callback.
> 
> It looks like dst entry holding is enough since 
> direct dst->output(), i.e. xfrm_state->output(), 
> call itself is not protected by reference counter,
> but dst entry is being held during that call.
> 

makes sense.

cheers,
jamal
