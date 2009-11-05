From: Julian Anastasov <ja@ssi.bg>
Subject: Re: test
Date: Thu, 5 Nov 2009 11:26:27 +0200 (EET)
Message-ID: <Pine.LNX.4.58.0911051119190.2761@u.domain.uli>
References: <20091104202716.GE14821@hostway.ca>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org, Wensong Zhang <wensong@linux-vs.org>
To: Simon Kirby <sim@hostway.ca>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ja.ssi.bg ([217.79.71.194]:56290 "EHLO u.domain.uli"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752396AbZKEJ0R (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 5 Nov 2009 04:26:17 -0500
In-Reply-To: <20091104202716.GE14821@hostway.ca>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


	Hello,

On Wed, 4 Nov 2009, Simon Kirby wrote:

> Hello!
> 
> I was noticing a significant amount of what seems/seemed to be
> destination lists with multiple entries with the lblcr LVS algorithm. 
> While tracking it down, I think I stumbled over a mistake.  In
> ip_vs_lblcr_full_check(), it appears the time check logic is reversed:
> 
>         for (i=0, j=tbl->rover; i<IP_VS_LBLCR_TAB_SIZE; i++) {
>                 j = (j + 1) & IP_VS_LBLCR_TAB_MASK;
> 
>                 write_lock(&svc->sched_lock);
>                 list_for_each_entry_safe(en, nxt, &tbl->bucket[j], list) {

	If 'time to expire' is after current time then continue,
i.e. current time didn't reached the limit, seems correct,
no need to patch. For better reading and to match
ip_vs_lblcr_check_expire() it can be converted to:

if (time_before(now, en->lastuse+sysctl_ip_vs_lblcr_expiration))
	continue;


>                         if (time_after(en->lastuse+sysctl_ip_vs_lblcr_expiration,
>                                        now))
>                                 continue;
>                         
>                         ip_vs_lblcr_free(en);
>                         atomic_dec(&tbl->entries);
>                 }
>                 write_unlock(&svc->sched_lock);
>         }
> 
> Shouldn't this be "time_before"?  It seems that it currently nukes all
> recently-used entries every time this function is called, which seems to
> be every 30 minutes, rather than removing the not-recently-used ones.
> 
> If my reading is correct, this patch should fix it.  Am I missing
> something?

include/linux/jiffies.h:

time_after(a,b) returns true if the time a is after time b.
#define time_before(a,b)        time_after(b,a)

Regards

--
Julian Anastasov <ja@ssi.bg>
