From: arno@natisbad.org (Arnaud Ebalard)
Subject: Re: [BUG,REGRESSION?] 3.11.6+,3.12: GbE iface rate drops to few KB/s
Date: Wed, 20 Nov 2013 22:28:50 +0100
Message-ID: <87txf692zx.fsf@natisbad.org>
References: <87vbzxd473.fsf@natisbad.org> <20131113072257.GB10591@1wt.eu>
	<20131117141940.GA18569@1wt.eu>
	<1384710098.8604.58.camel@edumazet-glaptop2.roam.corp.google.com>
	<87li0kkhzx.fsf@natisbad.org>
	<1384869194.8604.92.camel@edumazet-glaptop2.roam.corp.google.com>
	<20131119174323.GH913@1wt.eu>
	<1384885910.8604.110.camel@edumazet-glaptop2.roam.corp.google.com>
	<20131119184121.GN913@1wt.eu> <874n780wzc.fsf@natisbad.org>
	<20131120191145.GP8581@1wt.eu>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Thomas Petazzoni <thomas.petazzoni@free-electrons.com>,
	Florian Fainelli <f.fainelli@gmail.com>,
	simon.guinot@sequanux.org, netdev@vger.kernel.org,
	edumazet@google.com, Cong Wang <xiyou.wangcong@gmail.com>,
	linux-arm-kernel@lists.infradead.org
To: Willy Tarreau <w@1wt.eu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp3-g21.free.fr ([212.27.42.3]:59380 "EHLO smtp3-g21.free.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755282Ab3KTV3X (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 20 Nov 2013 16:29:23 -0500
Received: from smtp.natisbad.org (unknown [81.57.185.249])
	by smtp3-g21.free.fr (Postfix) with ESMTP id AA00CA62AB
	for <netdev@vger.kernel.org>; Wed, 20 Nov 2013 22:29:11 +0100 (CET)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

Willy Tarreau <w@1wt.eu> writes:

> From d1a00e593841223c7d871007b1e1fc528afe8e4d Mon Sep 17 00:00:00 2001
> From: Willy Tarreau <w@1wt.eu>
> Date: Wed, 20 Nov 2013 19:47:11 +0100
> Subject: EXP: net: mvneta: try to flush Tx descriptor queue upon Rx
>  interrupts
>
> Right now the mvneta driver doesn't handle Tx IRQ, and solely relies on a
> timer to flush Tx descriptors. This causes jerky output traffic with bursts
> and pauses, making it difficult to reach line rate with very few streams.
> This patch tries to improve the situation which is complicated by the lack
> of public datasheet from Marvell. The workaround consists in trying to flush
> pending buffers during the Rx polling. The idea is that for symmetric TCP
> traffic, ACKs received in response to the packets sent will trigger the Rx
> interrupt and will anticipate the flushing of the descriptors.
>
> The results are quite good, a single TCP stream is now capable of saturating
> a gigabit.
>
> This is only a workaround, it doesn't address asymmetric traffic nor datagram
> based traffic.
>
> Signed-off-by: Willy Tarreau <w@1wt.eu>
> ---
>  drivers/net/ethernet/marvell/mvneta.c | 20 ++++++++++++++++++++
>  1 file changed, 20 insertions(+)
>
> diff --git a/drivers/net/ethernet/marvell/mvneta.c b/drivers/net/ethernet/marvell/mvneta.c
> index 5aed8ed..59e1c86 100644
> --- a/drivers/net/ethernet/marvell/mvneta.c
> +++ b/drivers/net/ethernet/marvell/mvneta.c
> @@ -2013,6 +2013,26 @@ static int mvneta_poll(struct napi_struct *napi, int budget)
>  	}
>  
>  	pp->cause_rx_tx = cause_rx_tx;
> +
> +	/* Try to flush pending Tx buffers if any */
> +	if (test_bit(MVNETA_F_TX_DONE_TIMER_BIT, &pp->flags)) {
> +		int tx_todo = 0;
> +
> +		mvneta_tx_done_gbe(pp,
> +	                           (((1 << txq_number) - 1) &
> +	                           MVNETA_CAUSE_TXQ_SENT_DESC_ALL_MASK),
> +	                           &tx_todo);
> +
> +		if (tx_todo > 0) {
> +			mod_timer(&pp->tx_done_timer,
> +			          jiffies + msecs_to_jiffies(MVNETA_TX_DONE_TIMER_PERIOD));
> +		}
> +		else {
> +			clear_bit(MVNETA_F_TX_DONE_TIMER_BIT, &pp->flags);
> +			del_timer(&pp->tx_done_timer);
> +		}
> +	}
> +
>  	return rx_done;
>  }

With current Linus tree (head being b4789b8e: aacraid: prevent invalid
pointer dereference), as a baseline here is what I get:

 w/ tcp_wmem left w/ default values (4096 16384 4071360)

  via netperf (TCP_MAERTS/TCP_STREAM): 151.13 / 935.50 Mbits/s
  via wget against apache: 15.4 MB/s
  via wget against nginx: 104 MB/s
 
 w/ tcp_wmem set to 4096 16384 262144:

  via netperf (TCP_MAERTS/TCP_STREAM): 919.89 / 935.50 Mbits/s
  via wget against apache: 63.3 MB/s
  via wget against nginx: 104 MB/s
 
With your patch on top of it (and tcp_wmem kept at its default value):

 via netperf: 939.16 / 935.44 Mbits/s
 via wget against apache: 65.9 MB/s (top reports 69.5 sy, 30.1 si
                                     and 72% CPU for apache2)
 via wget against nginx: 106 MB/s


With your patch and MVNETA_TX_DONE_TIMER_PERIOD set to 1 instead of 10
(still w/ and tcp_wmem kept at its default value):

 via netperf: 939.12 / 935.84 Mbits/s
 via wget against apache: 63.7 MB/s
 via wget against nginx: 108 MB/s

So:

 - First, Eric's patch sitting in Linus tree does fix the regression
   I had on 3.11.7 and early 3.12 (15.4 MB/s vs 256KB/s).

 - As can be seen in the results of first test, Eric's patch still
   requires some additional tweaking of tcp_wmem to get netperf and
   apache somewhat happy w/ perfectible drivers (63.3 MB/s instead of
   15.4MB/s by setting max tcp send buffer space to 256KB for apache).

 - For unknown reasons, nginx manages to provide a 104MB/s download rate
   even with a tcp_wmem set to default and no specific patch of mvneta.

 - Now, Willy's patch seems to makes netperf happy (link saturated from
   server to client), w/o tweaking tcp_wmem.

 - Again with Willy's patch I guess the "limitations" of the platform
   (1.2GHz CPU w/ 512MB of RAM) somehow prevent Apache to saturate the
   link. All I can say is that the same test some months ago on a 1.6GHz
   ARMv5TE (kirkwood 88f6282) w/ 256MB of RAM gave me 108MB/s. I do not
   know if it is some apache regression, some mvneta vs mv63xx_eth
   difference or some CPU frequency issue but having netperf and  nginx
   happy make me wonder about Apache.

 - Willy, setting MVNETA_TX_DONE_TIMER_PERIOD to 1 instead of 10 w/ your
   patch does not improve the already good value I get w/ your patch.


In the end if you iterate on your work to push a version of your patch
upstream, I'll be happy to test it. And thanks for the time you already
spent!

Cheers,

a+
