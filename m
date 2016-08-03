From: Phil Sutter <phil@nwl.cc>
Subject: Re: [PATCH 2/3] sctp_diag: export timer value only if it is active
Date: Wed, 3 Aug 2016 21:28:13 +0200
Message-ID: <20160803192813.GE17974@orbyte.nwl.cc>
References: <1469811580-32429-1-git-send-email-phil@nwl.cc>
 <1469811580-32429-3-git-send-email-phil@nwl.cc>
 <20160729205113.GA2954@localhost.localdomain>
 <CADvbK_dWaMFz2f8GdavXuhyfiCxRmkT_8n9yHHNwSA3y_73WoA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>,
	David Miller <davem@davemloft.net>,
	network dev <netdev@vger.kernel.org>
To: Xin Long <lucien.xin@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbyte.nwl.cc ([151.80.46.58]:50986 "EHLO mail.nwl.cc"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752810AbcHCT2a (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 3 Aug 2016 15:28:30 -0400
Content-Disposition: inline
In-Reply-To: <CADvbK_dWaMFz2f8GdavXuhyfiCxRmkT_8n9yHHNwSA3y_73WoA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

On Sat, Jul 30, 2016 at 09:25:42PM +0800, Xin Long wrote:
[...]
> Now for the transport's info,  we only choose primary_path to dump.
> It means we should fix this by getting the left time to expire from
> primary transport t->T3_rtx_timer. like:
> 
>         r->idiag_expires = jiffies_to_msecs(
> -               asoc->timeouts[SCTP_EVENT_TIMEOUT_T3_RTX] - jiffies);
> +               asoc->peer.primary_path->T3_rtx_timer.expires - jiffies);
> 
> but yes, need to check with timer_pending firstly.

I have changed the code to this:

| struct timer_list *t3_rtx = &asoc->peer.primary_path->T3_rtx_timer;
| 
| [...]
| 
| if (timer_pending(t3_rtx)) {
| 	r->idiag_timer = SCTP_EVENT_TIMEOUT_T3_RTX;
| 	r->idiag_retrans = asoc->rtx_data_chunks;
| 	r->idiag_expires = jiffies_to_msecs(t3_rtx->expires - jiffies);
| }

And I'm still getting what appears to be negative values sometimes. Here
are some of the common values in hex when busy looping sctp_diag
requests:

0
7530
1000000
3000000
6000000
14000000
94000000
ed690000
ffffea00

While I wonder a bit about the zero, the last two seem to be unsigned
underruns. Do I still have to check for 't3_rtx->expires > jiffies' or
am I missing something?

Thanks, Phil
