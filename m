From: Prashant Sreedharan <prashant@broadcom.com>
Subject: Re: Question regarding {G,S}CHANNELS API
Date: Thu, 7 Jan 2016 13:24:24 -0800
Message-ID: <1452201864.13470.27.camel@prashant>
References: <20160107154324.4081743c@jkicinski-Precision-T1700>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Michael Chan <mchan@broadcom.com>,
	"Amit Kumar Salecha" <amit.salecha@qlogic.com>,
	Ben Hutchings <ben@decadent.org.uk>, <siva.kallam@broadcom.com>
To: Jakub Kicinski <jakub.kicinski@netronome.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gw2-out.broadcom.com ([216.31.210.63]:18972 "EHLO
	mail-gw2-out.broadcom.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752040AbcAGVra (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Jan 2016 16:47:30 -0500
In-Reply-To: <20160107154324.4081743c@jkicinski-Precision-T1700>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2016-01-07 at 15:43 +0000, Jakub Kicinski wrote:
> Hi!
> 
> I'm trying to understand how number of "separate" rx/tx vs combined
> channels should be configured.  I'd like to express asymmetric but
> mostly combined queue configuration (i.e. min(rx, tx) is combined the
> rest is separate).  Since default number of RX queues is just 8 it is
> tempting to allocate 8 RX queues but num_online_cpus() TX queues.  Does
> this configuration make sense?  What should ethtool -l report?
> 
> I had a look through the drivers and it seems that most of them fall
> nicely into the all combined and all separate categories. Two
> exceptions I found are bnxt_en (recent Michael's changes) and tg3.
> bnxt_en can switch between combined and separate mode.  tg3 is more
> interesting, it uses separate rx/tx parameters but combines first
> min(rx, tx) of the queues as I would like to.

It does not combine it takes the max(rx, tx)
u32 irq_cnt = max(tp->rxq_cnt, tp->txq_cnt);

> 
> The problem is if I hijack the "separate" rx/tx queues parameters like
> tg3 does there is no way for the user to express that (s)he truly wants
> them separate.  Also it seems that tg3 goes against the ethtool manual
> which states:
> >  rx N   Changes the number of channels with only receive queues.
> >  tx N   Changes the number of channels with only transmit queues.
> Which indicates that if user wants 8 rx, 12 tx and combining (s)he
> should do:
>   ethtool -L ethX combined 8 tx 4

there is no combined option only separate tx/rx option is supported by
tg3 driver. And at max only 4 RX, 4 TX rings are supported by the tg3
family of chips in non-iov mode.

Each status block (which is similar to completion ring) supports 1 RX or
1 TX or both. So at max there are 4 status blocks plus 1 additional
status block for async events. And each status block is assigned a irq.
