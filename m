From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: RFC: Proposed fix for tc linklayer calc broken after commit
 56b765b79 (htb: improved accuracy at high rates)
Date: Thu, 06 Jun 2013 07:28:06 -0700
Message-ID: <1370528885.24311.346.camel@edumazet-glaptop>
References: <20130529151330.22c5c89e@redhat.com>
	 <20130606155504.0eb6570a@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Jesper Dangaard Brouer <brouer@redhat.com>,
	Stephen Hemminger <stephen@networkplumber.org>,
	David Miller <davem@redhat.com>, j.vimal@gmail.com,
	Michal Soltys <soltys@ziu.info>,
	Mike Frysinger <vapier@gentoo.org>,
	Jussi Kivilinna <jussi.kivilinna@mbnet.fi>,
	Patrick McHardy <kaber@trash.net>,
	Jiri Pirko <jpirko@redhat.com>,
	Toke =?ISO-8859-1?Q?H=F8iland-J=F8rgensen?= <toke@toke.dk>,
	Dave Taht <dave.taht@gmail.com>, netdev@vger.kernel.org,
	bloat@lists.bufferbloat.net, Dan Siemon <dan@coverfire.com>,
	Jim Gettys <jg@freedesktop.org>,
	Steven Barth <cyrus@openwrt.org>, Felix Fietkau <nbd@nbd.name>,
	Jiri Benc <jbenc@redhat.com>
To: Jesper Dangaard Brouer <jbrouer@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f43.google.com ([209.85.220.43]:39113 "EHLO
	mail-pa0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751200Ab3FFO2I (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Jun 2013 10:28:08 -0400
Received: by mail-pa0-f43.google.com with SMTP id hz11so942531pad.30
        for <netdev@vger.kernel.org>; Thu, 06 Jun 2013 07:28:08 -0700 (PDT)
In-Reply-To: <20130606155504.0eb6570a@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2013-06-06 at 15:55 +0200, Jesper Dangaard Brouer wrote:
> Requesting comments.
> 
> So, bacically commit 56b765b79 (htb: improved accuracy at high rates),
> broke the "linklayer atm" handling.  As it didn't update the iproute tc util.
> 
> Treating this as a regression fix, this is the smallest and least
> intrusive solution I could come up with.
> 
> I'm basically restoring the "linklayer atm" handling, by using the
> __reserved field in struct tc_ratespec, to convey the chosen
> linklayer option.
> 
> 
> KERNEL patch:
> =============
> 
> [PATCH RFC] net_sched: restore "linklayer atm" handling
> 
> From: Jesper Dangaard Brouer <brouer@redhat.com>
> 
> commit 56b765b79 ("htb: improved accuracy at high rates")
> broke the "linklayer atm" handling.
> 
>  tc class add ... htb rate X ceil Y linklayer atm
> 
> This patch restores the "linklayer atm" handling, by using the
> __reserved field in struct tc_ratespec, to convey the choosen
> linklayer option.
> 
> This requires a corrosponding iproute2 tc fix, that updates this
> field.  Older tc binaries can be detected by the kernel, as the
> field would be zero.
> 
> Request-For-Comments-by: Jesper Dangaard Brouer <brouer@redhat.com>
> ---
> 
>  include/net/sch_generic.h      |    8 +++++++-
>  include/uapi/linux/pkt_sched.h |   11 ++++++++++-
>  net/sched/sch_generic.c        |    4 ++++
>  3 files changed, 21 insertions(+), 2 deletions(-)
> 
> 
> diff --git a/include/net/sch_generic.h b/include/net/sch_generic.h
> index e7f4e21..c9916b1 100644
> --- a/include/net/sch_generic.h
> +++ b/include/net/sch_generic.h
> @@ -682,13 +682,18 @@ struct psched_ratecfg {
>  	u64	rate_bps;
>  	u32	mult;
>  	u16	overhead;
> +	u8	linklayer;
>  	u8	shift;
>  };
>  
>  static inline u64 psched_l2t_ns(const struct psched_ratecfg *r,
>  				unsigned int len)
>  {
> -	return ((u64)(len + r->overhead) * r->mult) >> r->shift;
> +	u64 pkt_len = len + r->overhead;
> +
> +	if (r->linklayer == TC_LINKLAYER_ATM)
> +		pkt_len = DIV_ROUND_UP(pkt_len,48)*53;

Is this working on 32bit kernel ?

> +	return (pkt_len * r->mult) >> r->shift;
>  }

I have no idea why you include so many people on your mails.

This looks like ATM link have real rate of 48/53 of the rate.


Since we have to distribute a new tc version, why not doing

"tc ... rate rate X ceil Y linklayer atm"

->

"tc ... rate  X*48/53 Y*48/53"

It avoids hard coded values in the kernel.

Or make it use STAB if people really want to count bits/cells instead of
bytes.

Lets try to keep this overhead out of the fast path.
