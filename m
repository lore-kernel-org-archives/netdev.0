From: Simon Kirby <sim@netnation.com>
Subject: Re: Route cache performance under stress
Date: Mon, 9 Jun 2003 15:19:11 -0700
Sender: linux-net-owner@vger.kernel.org
Message-ID: <20030609221911.GF11509@netnation.com>
References: <20030609082718.GG20613@netnation.com> <004f01c32ebe$b4bd88d0$4a00000a@badass>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "'David S. Miller'" <davem@redhat.com>, hadi@shell.cyberus.ca,
	fw@deneb.enyo.de, netdev@oss.sgi.com, linux-net@vger.kernel.org
Return-path: <linux-net-owner@vger.kernel.org>
To: CIT/Paul <xerox@foonet.net>
Content-Disposition: inline
In-Reply-To: <004f01c32ebe$b4bd88d0$4a00000a@badass>
List-Id: netdev.vger.kernel.org

On Mon, Jun 09, 2003 at 03:38:30PM -0400, CIT/Paul wrote:

> gc_elasticity:1
> gc_interval:600
> gc_min_interval:1
> gc_thresh:60000
> gc_timeout:15
> max_delay:10
> max_size:512000

^^^ EEP, no!  Even the default of 65536 is too big.  No wonder you have
no CPU left.  This should never be bigger than 65536 (unless the hash is
increased), but even then it should be set smaller and the GC interval
should be fixed.  With a table that large, it's going to be walking the
buckets all of the time.

> I've tried other settings, secret-interval 1 which seems to 'flush' the
> cache every second or 60 seconds as I have it here..

That's only for permutating the hash table to avoid remote hash exploits. 
Ideally, you don't want anything clearing the route cache except for the
regular garbage collection (where the gc_elasticity controls how much of
it gets nuked).

> If I have secret interval set to 1 the GC never runs because the cache
> never gets > my gc thresh..  I've also tried this with
> Gc_thresh 2000 and more aggressive settings (timeout 5, interval 10)..
> Also tried with max_size 16000 but juno pegs the route cache
> And I get massive amounts of dst_cache_overflow messages .. 

Try setting gc_min_interval to 0 and gc_elasticity to 4 (so that it
doesn't entirely nuke it all the time, but so that it runs fairly often
and prunes quite a bit).  gc_min_interval:0 will actually make it clear
as it allocates, if I remember correctly.

> This is 'normal' traffic on the router (using the rtstat program)

> 
> ./rts -i 1
>  size   IN: hit     tot    mc no_rt bcast madst masrc  OUT: hit     tot
> mc GC: tot ignored goal_miss ovrf
> 59272     26954    1826     0     0     0     0     0         6       0
> 0       0       0         0    0

Yes, your route cache is way too large for the hash.

Ours looks like this:

[sroot@r2:/root]# rtstat -i 1
 size   IN: hit     tot    mc no_rt bcast madst masrc  OUT: hit     tot     mc
870721946     16394    1013     8     4     4     0     0        38      12      0
870722937     16278    1007     8     0    10     0     0        32       6      0
870723935     16362     999     5     0     6     0     0        34       8      0
870725083     16483    1158     1     0     0     0     2        26       6      0
870726047     16634     974     0     0     4     0     0        42       0      0
870726168     14315    2338    13    10     8     0     0        34      44      2
870726168     14683    1383     0     8     2     0     0        30      12      2
870726864     16172    1155     0     6     2     0     0        28       4      0
870728079     17842    1234     0     0     0     0     0        28      12      0
870729106     17545    1036     2     0     2     0     0        30       6      0

...Hmm, the size is a bit off there.  I'm not sure what that's all about. 
Did you have to hack on rtstat.c at all?  Alternative:

[sroot@r2:/root]# while (1)
[sroot@r2:(while)]# sleep 1
[sroot@r2:(while)]# ip -o route show cache | wc -l
[sroot@r2:(while)]# end
   8064
   8706
   9299
   9939
  10277
  10857
  11426
  11731
  12328
  12796
  13096
  13623
   1139
   2712
   4233
    561
   2468
   3948
   5075
   5459
   6114
   6768
   7502
   7815
   8303
   8969
   9602
  10090
  10566
  11194
  11765
  11987
  12678
  12920
  13563
  14136
  14693
   2336
   3652
   4814
   5954
   6449
   6741
   7412
   8036

....Hmm, even that is growing a bit large.  Pfft.  I guess we were doing
less traffic last time I checked this. :)

Maybe you have a bit more traffic than us in normal operation and it's
growing faster because of that.  Still, with a gc_elasticity of 1 it
should be clearing it out very quickly.

...Though I just tried that, and it's not.  In fact, the gc_elasticity
doesn't seem to be making much of a difference at all.  The only thing
that seems to really change it is if I set gc_min_interval to 0:

[sroot@r2:/proc/sys/net/ipv4/route]# echo 0 > gc_min_interval
[sroot@r2:/proc/sys/net/ipv4/route]# while ( 1 )
[sroot@r2:(while)]# sleep 1
[sroot@r2:(while)]# ip -o route show cache | wc -l
[sroot@r2:(while)]# end
   9674
   9547
   9678
   9525
   9625
   9544
   9385
    497
   2579
   3820
   4083
   4099
   4068
   4054
   4089
   4095
   4137
   4072
   4071
   4137
   2141
   3414
   4044
   2487
   3759
   4047
   4085
   4092
   4156
   4089
   4008
    475
   2497
   3729
   4146
   4085
   4116

It seems to regulate it after it gets cleared the first time.  If I set
gc_elasticity to 1 it seems to bounce around a lot more -- 4 is much
smoother.  It didn't seem to make a difference with gc_min_interval set
to 1, though... hmmm.  We've been running normally with gc_min_interval
set to 1, but it looks like the BGP table updates have kept the cache
from growing too large.

> Check what happens when I load up juno..

Yeah... Juno's just going to hit it harder and show the problems with it
having to walk through such large hash buckets.  How big is your routing
table on this box?  Is it running BGP?

> slammed at 100% by the ksoftirqds.  This is using e1000 with interrups
> limited to ~ 4000/second (ITR), no NAPI.. NAPI messes it up big time and
> drops more packets than without :>

Hmm, that's weird.  It works quite well here on a single CPU box with
tg3 cards.

Simon-
