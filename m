From: Robert Olsson <Robert.Olsson@data.slu.se>
Subject: Re: [PATCH] option for large routing hash
Date: Wed, 10 Dec 2003 15:47:44 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <16343.12816.917811.588853@robur.slu.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Robert Olsson <Robert.Olsson@data.slu.se>, kuznet@ms2.inr.ac.ru,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Hello!

More thoughts and observations before doing anything else maybe we can wake 
up Alexey...

> IP: routing cache hash table of 4096 buckets, 32Kbytes
 ...
> And tot+hit gives the pps throughput 152 kpps.
 ...
> IP: routing cache hash table of 32768 buckets, 256Kbytes
 ...
> We see cache is now used as hit > tot and we get a performance jump from 
> 152 to 265 kpps.
> 

Some more experiment details. First full Internet routing table was used. 
Processor UP XEON 2.6 GHz.

With large route hash see dst cache overflow. Somewhat surprising it 
seems at first sight but as we increase to 265 kpps so we get much 
closer to max_size (265k entries). So if RCU get problems with getting
the batch job (freeing the dst entries) done. We get dst cache over-
flow. 

The RCU/sofirq stuff pop-up again (now with routing table loaded).
RCU will probable get on the agenda again as from what I heard the
netfilter folks have plans to use it.

It's also worth to notice that focusing just of getting rid of 
"dst cache overflow" can give half performance as seen here. :-)

Since have max_size, gc_elasity,  gc_thresh same. I think it's goal of 
GC that causes the difference. (rt_hash_mask). With a smaller number the
GC gets much more aggressive.

I think this is indicated in rtstat:

 size   IN: hit     tot
35320     62700   88890

Versus:

212976    212665  52703

Much more entries when we increased the bucket size. RCU can play some tricks
here as well.

Conclusions? IMO the dst cache "within it's operation range" is well behaved 
traffic is giving us very good performance and something we don't have pay
attention to. We see cache is in effect simply as hit > tot.

But when hit <= tot we have at least two cases:
1) Traffic is not well behaved. DoS.
2) Traffic is well behaved but tuning is bad.

As the actions is totally different from above cases:
w. 1. Reduce size to avoid searching. 
w. 2. Increase size so cache becomes active.

So it crucial to distinguish between the cases. Can it be done from incoming 
traffic? 


Cheers.
						--ro
