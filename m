From: Simon Kirby <sim@netnation.com>
Subject: Re: Route cache performance
Date: Tue, 6 Sep 2005 16:57:00 -0700
Message-ID: <20050906235700.GA31820@netnation.com>
References: <20050815213855.GA17832@netnation.com> <43014E27.1070104@cosmosbay.com> <20050823190852.GA20794@netnation.com> <17163.32645.202453.145416@robur.slu.se> <20050824000158.GA8137@netnation.com> <20050825181111.GB14336@netnation.com> <20050825200543.GA6612@yakov.inr.ac.ru> <20050825212211.GA23384@netnation.com> <20050826115520.GA12351@yakov.inr.ac.ru> <17167.29239.469711.847951@robur.slu.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
        Eric Dumazet <dada1@cosmosbay.com>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Robert Olsson <Robert.Olsson@data.slu.se>
Content-Disposition: inline
In-Reply-To: <17167.29239.469711.847951@robur.slu.se>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, Aug 26, 2005 at 09:49:11PM +0200, Robert Olsson wrote:

> Hello!
> 
> This thread seems familar :)
> 
> I think Simon uses UP and it could be idea to check if the RCU deferred 
> deletion causes the problem. 
>...
> --- a/net/ipv4/route.c
> +++ b/net/ipv4/route.c
> @@ -485,7 +485,11 @@ static struct file_operations rt_cpu_seq
>  static __inline__ void rt_free(struct rtable *rt)
>  {
>  	multipath_remove(rt);
> +#ifdef CONFIG_SMP
>  	call_rcu_bh(&rt->u.dst.rcu_head, dst_rcu_free);
> +#else
> +	dst_free((struct dst_entry *)rt);
> +#endif
>  }
>  
>  static __inline__ void rt_drop(struct rtable *rt)

Woot!

Yes, this is the difference.  With the patch applied (ajust directly
freeing the dst_entry), everything balances easily, there are no
overflows, and the result of rt_may_expire() looks very reasonable.
(Yay!)

So, this seems to be the culprit.  Is NAPI supposed to allow the
queued bh to run or should we just not be queuing this?

Simon-
