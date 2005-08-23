From: Simon Kirby <sim@netnation.com>
Subject: Re: Route cache performance
Date: Tue, 23 Aug 2005 12:08:53 -0700
Message-ID: <20050823190852.GA20794@netnation.com>
References: <20050815213855.GA17832@netnation.com> <43014E27.1070104@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Robert Olsson <Robert.Olsson@data.slu.se>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Eric Dumazet <dada1@cosmosbay.com>
Content-Disposition: inline
In-Reply-To: <43014E27.1070104@cosmosbay.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, Aug 16, 2005 at 04:23:35AM +0200, Eric Dumazet wrote:

> Hi Simon

Hi there!

> I think one of the reason linux 2.6 has worst results is because HZ=1000 
> (instead of HZ=100 for linux 2.4)
> So if rt_garbage_collect() has heavy work to do, it usually break out of 
> the loop because of :
> 
> } while (!in_softirq() && time_before_eq(jiffies, now));

I was under the impression, however, that the code Alexei added last time
I brought up this problem was intended to always allow gc when the the
table is full and another entry is attempting to be created, even when
under gc_min_interval.  I'm actually not even interested (yet) with
the gc_interval/timer case because I'm testing currently with a flow
creation rate of much larger than max_size per second (the minimum
gc_interval being one second).

> Could you please test latest 2.6.13-rc6 kernel on the Opteron machine, 
> compiled with HZ=100, with the appended kernel argument :
> 
> rhash_entries=8191  ( or rhash_entries=16383 )
> 
> and
> 
> echo 1 >/proc/sys/net/ipv4/route/gc_interval
> echo 2 >/proc/sys/net/ipv4/route/gc_elasticity
> 
> Could you also post some data from your router (like : rtstat -c 20 -i 1)

Sure.  Here are results from 2.6.13-rc6 with HZ=100 and
rhash_entries=8191, which sets the max_size to 131072.  I'm using
lnstat becuase the rtstat version I could find doesn't work on
newer kernels:

lnstat -c -1 -i 1 -f rt_cache -k entries,in_hit,in_slow_tot,gc_total,gc_ignored,gc_goal_miss,gc_dst_overflow,in_hlist_search

The sender is running "juno 192.168.1.1 31313 0" (juno-z.101f.c):

pid 18492: ran for 40s, 13595333 packets out, 16241091 bytes/s
(~340kpps)

Without tweaks to gc_interval and gc_elasticity:

rt_cache|rt_cache|rt_cache|rt_cache|rt_cache|rt_cache|rt_cache|rt_cache|
 entries|  in_hit|in_slow_|gc_total|gc_ignor|gc_goal_|gc_dst_o|in_hlist|
        |        |     tot|        |      ed|    miss| verflow| _search|
      32|     117|     419|       0|       0|       0|       0|       0|
      32|       6|       0|       0|       0|       0|       0|       0|
      32|       2|       0|       0|       0|       0|       0|       0|
      33|       2|       4|       0|       0|       0|       0|       0|
    9033|       2|    9002|     840|     839|       0|       0|    4962|
  131062|      22|  125633|  125629|  125447|     182|     181|  837163|
  131062|       0|   13511|   13509|     900|   12609|   12609|      10|
  131062|       0|    8772|    8770|     600|    8170|    8170|       7|
  131062|       0|    8709|    8706|     600|    8106|    8106|       8|
  131062|       0|    8771|    8770|     600|    8170|    8170|       6|
  131062|       0|    8770|    8768|     600|    8168|    8168|       6|
  131062|       0|    8706|    8704|     600|    8104|    8104|      10|
  131062|       0|    8770|    8770|     600|    8170|    8170|       5|
  131062|       0|    8708|    8706|     600|    8106|    8106|       5|
  131062|       0|    8770|    8769|     600|    8169|    8169|       6|
  131062|       0|    8770|    8769|     600|    8169|    8169|      10|
  131062|       0|    8713|    8706|     600|    8106|    8106|       7|
  131062|       0|    8786|    8769|     600|    8169|    8169|       9|

With tweaks (and after 60 seconds to wait for timer expiry):

rt_cache|rt_cache|rt_cache|rt_cache|rt_cache|rt_cache|rt_cache|rt_cache|
 entries|  in_hit|in_slow_|gc_total|gc_ignor|gc_goal_|gc_dst_o|in_hlist|
        |        |     tot|        |      ed|    miss| verflow| _search|
      28|     632|  424656|  413834|  145906|  267927|  267926|  842370|
      28|       2|       3|       0|       0|       0|       0|       0|
      28|       3|       2|       0|       0|       0|       0|       0|
      28|       2|       4|       0|       0|       0|       0|       0|
   35129|       3|   35999|   27826|   27825|       0|       0|   61913|
  131062|       6|  102045|  102043|   99432|    2611|    2610|  288926|
  131062|       0|   13446|   13442|     900|   12542|   12542|      11|
  131062|       0|   11914|   11909|     800|   11109|   11109|       5|
  131062|       0|    8772|    8770|     599|    8171|    8170|       5|
  131062|       0|    8708|    8708|     600|    8108|    8108|       7|
  131062|       0|    8774|    8771|     600|    8171|    8171|       2|
  131062|       0|    8769|    8769|     600|    8169|    8169|       9|
  131062|       0|    8706|    8704|     600|    8104|    8104|       4|
  131062|       0|    8769|    8768|     599|    8169|    8168|       5|
  131062|       0|    8707|    8706|     600|    8106|    8106|       7|
  131062|       0|    8771|    8768|     600|    8168|    8168|       6|
  131062|       0|    8770|    8768|     600|    8168|    8168|       8|
  131062|       0|    8705|    8704|     600|    8104|    8104|       6|
  131062|       0|    8771|    8768|     600|    8168|    8168|       5|

No visible difference to me.

On stock 2.4.31 with no alterations to the gc settings (and no
rhash_entries as it doesn't exist), lnstat shows:

rt_cache|rt_cache|rt_cache|rt_cache|rt_cache|rt_cache|rt_cache|rt_cache|
 entries|  in_hit|in_slow_|gc_total|gc_ignor|gc_goal_|gc_dst_o|in_hlist|
        |        |     tot|        |      ed|    miss| verflow| _search|
      21|      85|     160|       0|       0|       0|       0|       0|
      21|       4|       2|       0|       0|       0|       0|       0|
      21|       2|       3|       0|       0|       0|       0|       0|
      22|       2|       2|       0|       0|       0|       0|       0|
   18432|      11|  136187|  134158|  134156|       1|       0| 1133784|
   18432|       5|  195891|  195889|  195887|       2|       0| 1763070|
   18432|       9|  195585|  195568|  195566|       2|       0| 1758397|
   18432|       7|  195290|  195281|  195279|       0|       0| 1751884|
   18432|       8|  195587|  195579|  195577|       0|       0| 1754813|
   18432|      20|  195276|  195275|  195273|       0|       0| 1752216|
   18432|      11|  194983|  194980|  194978|       0|       0| 1749822|
   18432|       7|  195288|  195287|  195285|       0|       0| 1752655|
   18432|      13|  195282|  195281|  195279|       0|       0| 1752869|
   18432|      12|  194984|  194984|  194982|       1|       0| 1749589|
   18432|      17|  194978|  194974|  194972|       0|       0| 1748817|
   18432|      11|  194985|  194981|  194979|       0|       0| 1749182|
   18432|      14|  194981|  194977|  194975|       0|       0| 1749287|
   18432|      14|  194682|  194679|  194677|       0|       0| 1746847|
   18432|      11|  194983|  194980|  194978|       0|       0| 1749679|

...and the machine is perfectly responsive.  It's dropping packets
(managing to forward ~210 kpps, a little less than 2.4.27), but it's
at least working.  2.6.13-rc6 dribbles out ~33 kpps.

Simon-
