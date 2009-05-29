From: Antonio Almeida <vexwek@gmail.com>
Subject: Re: [PATCH iproute2] Re: HTB accuracy for high speed
Date: Fri, 29 May 2009 18:02:39 +0100
Message-ID: <298f5c050905291002j468aa6e6j9a28252507717660@mail.gmail.com>
References: <20090517201528.GA8552@ami.dom.local>
	 <20090518065629.GA6006@ff.dom.local>
	 <298f5c050905180954m791c14eaxe1f4b2c92f952a2f@mail.gmail.com>
	 <298f5c050905181016w552b283q2bb2ec508433525a@mail.gmail.com>
	 <20090521085116.GC2892@ami.dom.local>
	 <298f5c050905221042t45017c5q8bc967d13c9b81cb@mail.gmail.com>
	 <20090523073201.GA2766@ami.dom.local>
	 <298f5c050905281113o10393c61ye3c0539d2b6efa20@mail.gmail.com>
	 <20090528211258.GA3658@ami.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@vyatta.com>, netdev@vger.kernel.org,
	kaber@trash.net, davem@davemloft.net, devik@cdi.cz,
	Eric Dumazet <dada1@cosmosbay.com>,
	Vladimir Ivashchenko <hazard@francoudi.com>
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from an-out-0708.google.com ([209.85.132.241]:4534 "EHLO
	an-out-0708.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754983AbZE2RCi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 May 2009 13:02:38 -0400
Received: by an-out-0708.google.com with SMTP id d40so12673611and.1
        for <netdev@vger.kernel.org>; Fri, 29 May 2009 10:02:40 -0700 (PDT)
In-Reply-To: <20090528211258.GA3658@ami.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, May 28, 2009 at 10:12 PM, Jarek Poplawski wrote:
> Yes, but according to my assessment there should be "only" 50Mbit
> difference for this rate/packet size. Anyway, could you try a testing
> patch below, which should add some granularity to this rate table?
>
> Thanks,
> Jarek P.
> ---
>
>  include/net/pkt_sched.h |    4 ++--
>  1 files changed, 2 insertions(+), 2 deletions(-)
>
> diff --git a/include/net/pkt_sched.h b/include/net/pkt_sched.h
> index e37fe31..f0faf03 100644
> --- a/include/net/pkt_sched.h
> +++ b/include/net/pkt_sched.h
> @@ -42,8 +42,8 @@ typedef u64   psched_time_t;
>  typedef long   psched_tdiff_t;
>
>  /* Avoid doing 64 bit divide by 1000 */
> -#define PSCHED_US2NS(x)                        ((s64)(x) << 10)
> -#define PSCHED_NS2US(x)                        ((x) >> 10)
> +#define PSCHED_US2NS(x)                        ((s64)(x) << 6)
> +#define PSCHED_NS2US(x)                        ((x) >> 6)
>
>  #define PSCHED_TICKS_PER_SEC           PSCHED_NS2US(NSEC_PER_SEC)
>  #define PSCHED_PASTPERFECT             0

It's better! This patch gives more accuracy to HTB. Here some values:
Note that these are boundary values, so, e.g., any HTB configuration
between 377000Kbit and 400000Kbit would fall in the same step - close
to 397977Kbit.
This test was made over the same conditions: generating 950Mbit/s of
unidirectional tcp traffic of 800 bytes packets long.

leaf class ceil	leaf class sent rate (tc -s values)
376000Kbit	375379Kbit
--
377000Kbit	397977Kbit
400000Kbit	397973Kbit
--
401000Kbit	425199Kbit
426000Kbit	425199Kbit
--
427000Kbit	456389Kbit
457000Kbit	456409Kbit
--
458000Kbit	490111Kbit
492000Kbit	490138Kbit
--
493000Kbit	531957Kbit
533000Kbit	532078Kbit
--
534000Kbit	581835Kbit
581000Kbit	581820Kbit
--
582000Kbit	637809Kbit
640000Kbit	637709Kbit
--
641000Kbit	710526Kbit
711000Kbit	710553Kbit
--
712000Kbit	795921Kbit
800000Kbit	795901Kbit
--
801000Kbit	912706Kbit
914000Kbit	912782Kbit
--
915000Kbit	--


Here more values for a HTB ceil configuration of 555Mbit/s changing packet size:

800 bytes:
class htb 1:108 parent 1:10 leaf 108: prio 7 quantum 1514 rate
555000Kbit ceil 555000Kbit burst 70901b/8 mpu 0b overhead 0b cburst
70901b/8 mpu 0b overhead 0b level 0
 Sent 18731000768 bytes 23531408 pkt (dropped 15715520, overlimits 0 requeues 0)
 rate 581832Kbit 91368pps backlog 0b 110p requeues 0
 lended: 23531298 borrowed: 0 giants: 0
 tokens: -16091 ctokens: -16091


850 bytes:
class htb 1:108 parent 1:10 leaf 108: prio 7 quantum 1514 rate
555000Kbit ceil 555000Kbit burst 70901b/8 mpu 0b overhead 0b cburst
70901b/8 mpu 0b overhead 0b level 0
 Sent 30556163150 bytes 37645600 pkt (dropped 25746491, overlimits 0 requeues 0)
 rate 565509Kbit 83556pps backlog 0b 15p requeues 0
 lended: 37645585 borrowed: 0 giants: 0
 tokens: -16010 ctokens: -16010


950 bytes	
class htb 1:108 parent 1:10 leaf 108: prio 7 quantum 1514 rate
555000Kbit ceil 555000Kbit burst 70901b/8 mpu 0b overhead 0b cburst
70901b/8 mpu 0b overhead 0b level 0
 Sent 51363059854 bytes 60954074 pkt (dropped 40474346, overlimits 0 requeues 0)
 rate 598925Kbit 83555pps backlog 0b 112p requeues 0
 lended: 60953962 borrowed: 0 giants: 0
 tokens: 12446 ctokens: 12446

I'm using
# tc -V
tc utility, iproute2-ss090115

and keeping tso and gso off:
# ethtool -k eth0
Offload parameters for eth0:
rx-checksumming: on
tx-checksumming: on
scatter-gather: on
tcp segmentation offload: off
udp fragmentation offload: off
generic segmentation offload: off

# ethtool -k eth1
Offload parameters for eth1:
rx-checksumming: on
tx-checksumming: on
scatter-gather: on
tcp segmentation offload: off
udp fragmentation offload: off
generic segmentation offload: off
