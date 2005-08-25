From: Simon Kirby <sim@netnation.com>
Subject: Re: Route cache performance
Date: Thu, 25 Aug 2005 11:11:11 -0700
Message-ID: <20050825181111.GB14336@netnation.com>
References: <20050815213855.GA17832@netnation.com> <43014E27.1070104@cosmosbay.com> <20050823190852.GA20794@netnation.com> <17163.32645.202453.145416@robur.slu.se> <20050824000158.GA8137@netnation.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Eric Dumazet <dada1@cosmosbay.com>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Robert Olsson <Robert.Olsson@data.slu.se>, kuznet@ms2.inr.ac.ru
Content-Disposition: inline
In-Reply-To: <20050824000158.GA8137@netnation.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

[ Alexei / kuznet, I've included you here as I suspect you'll know what's
  going on. :) ]

I've been working with 2.6.13-rc6 to try to figure out why it's breaking.
I've added a more rt_cache statistics and flung more DoS traffic at it. 
I've determined that when the gc_goal_miss counter is increased, it seems
to be because the refcnt is non-zero in rt_may_expire().

The static "expire" variable reaches 0 easily this case and the rover
variables and loop aren't overflowing or anything -- it's just that
something is holding the refcnt > 0 for almost all of the entries that
rt_garbage_collect() walks.  Here are some statistics I recorded:

rt_cache
entries|in_slow|gc_tota|gc_igno|gc_aggr|gc_zero|gc_expi|gc_expi|gc_goa|gc_dst|in_hlis|
       |   _tot|      l|    red| essive|_expire|  re_no| re_yes|l_miss|overfl| t_srch|
     14|      4|      0|      0|      0|      0|      0|      0|     0|     0|      0|
  24012|  24003|  15819|  15818|      0|      0|      0|      0|     0|     0|  35182|
 131062| 112232| 112229| 110515|   1714|   1703|  10309|  79489|  1711|  1711| 767998|
 131062|  14279|  14276|    900|  13376|  13376|  75352|    900| 13376| 13376|      8|
 131062|   9542|   9538|    600|   8938|   8938|  50276|    600|  8938|  8938|      5|
 131062|   9543|   9539|    600|   8939|   8939|  50278|    600|  8939|  8939|      5|
 131062|   9542|   9538|    600|   8938|   8938|  50276|    600|  8938|  8938|     10|
 131062|   9542|   9536|    600|   8936|   8936|  50272|    600|  8936|  8936|      6|
 131062|   9475|   9472|    600|   8872|   8872|  50144|    600|  8872|  8872|      5|
 131062|   9540|   9538|    600|   8938|   8938|  50276|    600|  8938|  8938|      4|

gc_aggressive: Times the "we are in dangerous area" block executes.
gc_zero_expire: Times the loop is broken because expire == 0.
gc_expire_no: Times rt_may_expire() said no.
gc_expire_yes: Times rt_may_expire() said yes.

It seems the code is all the same in 2.4 in rt_may_expire(), so something
outside must have changed.  I can't even find anything in route.c that
decrements or zeros the refcnt.  Does anybody know why this is happening?

Simon-

On Tue, Aug 23, 2005 at 05:01:58PM -0700, Simon Kirby wrote:

> On Tue, Aug 23, 2005 at 09:56:53PM +0200, Robert Olsson wrote:
> 
> >  Yes your GC does not work at all in your 2.6 setups...Why?
> 
> Good question. :)
> 
> >  echo 50 >  /proc/sys/net/ipv4/route/gc_min_interval_ms
> 
> The output looks exactly the same with gc_min_interval_ms set to 50.
> 
> If I set it to 0, it does change a little but _still_ overflows:
> 
> rt_cache|rt_cache|rt_cache|rt_cache|rt_cache|rt_cache|rt_cache|rt_cache|
>  entries|  in_hit|in_slow_|gc_total|gc_ignor|gc_goal_|gc_dst_o|in_hlist|
>         |        |     tot|        |      ed|    miss| verflow| _search|
>        3|       3|       1|       1|       1|       0|       0|       0|
>        4|      11|       5|       0|       0|       0|       0|       0|
>        5|       5|       2|       0|       0|       0|       0|       0|
>    23615|       1|   24002|   15812|       0|       0|       0|   11470|
>    68692|       0|   46780|   46777|       0|    4687|       0|    4492|
>    86046|       0|   18763|   18754|       0|   18754|       0|     119|
>    94884|       0|    9540|    9538|       0|    9538|       0|      47|
>   104901|       0|   10819|   10817|       0|   10817|       0|      61|
>   114919|       0|   10817|   10818|       0|   10818|       0|      68|
>   127424|       0|   13512|   13505|       0|   13505|       0|      74|
>   131062|       0|   15113|   15106|       0|   15106|   10368|      28|
>   131062|       0|   12503|   12482|       0|   12482|   11582|       9|
>   131062|       0|    8146|    8130|       0|    8130|    7530|       5|
>   131062|       0|    8204|    8194|       0|    8194|    7594|       2|
>   131062|       0|    8132|    8131|       0|    8131|    7531|       5|
>   131062|       0|    8196|    8195|       0|    8195|    7595|       4|
>   131062|       0|    8130|    8129|       0|    8129|    7529|       8|
