From: Rick Jones <rick.jones2@hp.com>
Subject: Re: [RFC PATCH net-next 4/4 V4] try to fix performance regression
Date: Thu, 13 Dec 2012 10:25:47 -0800
Message-ID: <50CA1DAB.5050000@hp.com>
References: <117a10f9575d95d6a9ea4602ea7376e2b6d5ccd1.1355320533.git.wpan@redhat.com> <5e333588f6cb48cc3464b2263dcaa734b952e4c1.1355320534.git.wpan@redhat.com> <AE90C24D6B3A694183C094C60CF0A2F6026B70ED@saturn3.aculab.com> <50C9E0A0.2040409@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Laight <David.Laight@ACULAB.COM>, davem@davemloft.net,
	brutus@google.com, netdev@vger.kernel.org
To: Weiping Pan <wpan@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g6t0185.atlanta.hp.com ([15.193.32.62]:39184 "EHLO
	g6t0185.atlanta.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755115Ab2LMSZw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Dec 2012 13:25:52 -0500
In-Reply-To: <50C9E0A0.2040409@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/13/2012 06:05 AM, Weiping Pan wrote:
> But if I just run normal tcp loopback for each message size, then the
> performance is stable.
> [root@intel-s3e3432-01 ~]# cat base.sh
> for s in 1 2 4 8 16 32 64 128 256 512 1024 2048 4096 8192 16384 32768
> 65536 131072 262144 524288 1048576
> do
> netperf -i -2,10 -I 95,20 -- -m $s -M $s | tail -n1
> done

The -i option goes max,min iterations:

http://www.netperf.org/svn/netperf2/trunk/doc/netperf.html#index-g_t_002di_002c-Global-28

and src/netsh.c will apply some silent clipping to that:


     case 'i':
       /* set the iterations min and max for confidence intervals */
       break_args(optarg,arg1,arg2);
       if (arg1[0]) {
	iteration_max = convert(arg1);
       }
       if (arg2[0] ) {
	iteration_min = convert(arg2);
       }
       /* if the iteration_max is < iteration_min make iteration_max
	 equal iteration_min */
       if (iteration_max < iteration_min) iteration_max = iteration_min;
       /* limit minimum to 3 iterations */
       if (iteration_max < 3) iteration_max = 3;
       if (iteration_min < 3) iteration_min = 3;
       /* limit maximum to 30 iterations */
       if (iteration_max > 30) iteration_max = 30;
       if (iteration_min > 30) iteration_min = 30;
       if (confidence_level == 0) confidence_level = 99;
       if (interval == 0.0) interval = 0.05; /* five percent */
       break;

So, what will happen with your netperf command line above is it will set 
iteration max to 10 iterations and it will always run 10 iterations 
since min will equal max.  If you want it to possibly terminate sooner 
upon hitting the confidence intervals you would want to go with -i 10,3. 
  That will have netperf always run at least three and no more than 10 
iterations.

If I'm not mistaken, the use of the "| tail -n 1" there will cause the 
"classic" confidence intervals not met warning to be tossed (unless I 
suppose it is actually going to stderr?).

If you use the "omni" tests directly rather than via "migration" you 
will no longer get warnings about not hitting the confidence interval, 
but you can have netperf emit the confidence level it actually achieved 
as well as the number of iterations it took to get there.  You would use 
the omni output selection to do that.

http://www.netperf.org/svn/netperf2/trunk/doc/netperf.html#Omni-Output-Selection


These may have been mentioned before...

Judging from that command line you have the potential variability of the 
socket buffer auto-tuning.  Does AF_UNIX do the same sort of auto 
tuning?  It may be desirable to add some test-specific -s and -S options 
to have a fixed socket buffer size.

Since the MTU for loopback is ~16K, the send sizes below that will 
probably have differing interactions with the Nagle algorithm. 
Particularly as I suspect the timing will differ between friends and no 
friends.

I would guess the most "consistent" comparison with AF_UNIX would be 
when Nagle is disabled for the TCP_STREAM tests.  That would be a 
test-specific -D option.

Perhaps a more "stable" way to compare friends, no-friends and unix 
would be to use the _RR tests.  That will be a more direct, less-prone 
to other heuristics measure of path-length differences - both in the 
reported transactions per second and in any CPU utilization/service 
demand if you enable that via -c.  I'm not sure it would be necessary to 
take the request/response size out beyond a couple KB.  Take it out to 
the MB level and you will probably return to the question of auto-tuning 
of the socket buffer sizes.

happy benchmarking,

rick jones
