From: Ingo Molnar <mingo@elte.hu>
Subject: Re: kerneloops.org report for the week
Date: Mon, 29 Jun 2009 05:18:04 +0200
Message-ID: <20090629031804.GA6764@elte.hu>
References: <20090628091055.12a4fb9e@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, torvalds@linux-foundation.org,
	akpm@linux-foundation.org, netdev@vger.kernel.org, x86@kernel.org
To: Arjan van de Ven <arjan@infradead.org>,
	Thomas Gleixner <tglx@linutronix.de>,
	Yinghai Lu <yinghai@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.mail.elte.hu ([157.181.151.9]:59834 "EHLO mx2.mail.elte.hu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751763AbZF2DSg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 28 Jun 2009 23:18:36 -0400
Content-Disposition: inline
In-Reply-To: <20090628091055.12a4fb9e@infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


* Arjan van de Ven <arjan@infradead.org> wrote:

> Few "highlights" this week
> * mem_cgroup_add_lru_list (rank 2) is a high rising issue;
>   it's list corruption, question is why this is new
> * rank 13 (memcmp in the raid code) is also new
> * the warning in get_free_pages that has been discussed on lkml is dropping
>   from the ranks again
> 
> 
> This week, a total of 15273 oopses and warnings have been reported,
> compared to 13384 reports in the previous week.
> 
> 
> Rank 2: mem_cgroup_add_lru_list (warn)
> 	Reported 1554 times (1622 total reports)
> 	List corruption in the VM code
> 	This oops was last seen in version 2.6.30-git19, and first seen in 2.6.29.
> 	More info: http://www.kerneloops.org/searchweek.php?search=mem_cgroup_add_lru_list

At least one list corruption bug was fixed by:

   cb4cbcf: mm: fix incorrect page removal from LRU

> Rank 3: getnstimeofday (warning)
> 	Reported 1319 times (4893 total reports)
> 	[suspend resume] getnstimeofday() is called before timekeeping is resumed
> 	This oops was last seen in version 2.6.30, and first seen in 2.6.24.
> 	More info: http://www.kerneloops.org/searchweek.php?search=getnstimeofday

Probably caused by some buggy driver callback?

> Rank 7: hres_timers_resume (warning)
> 	Reported 763 times (2368 total reports)
> 	[suspend resume] hres_timers_resume() is incorrectly called with interrupts on
> 	This warning was last seen in version 2.6.30, and first seen in 2.6.24.7.
> 	More info: http://www.kerneloops.org/searchweek.php?search=hres_timers_resume

This is probably a driver incorrectly enabling irqs in a resume 
callback. This should be easier and more specific to debug with the 
lockdep based annotation i suggested for the suspend code in various 
`mails.

> Rank 8: generic_get_mtrr (warning)
> 	Reported 544 times (2061 total reports)
> 	BIOS bug where the MTRRs are not set up correctly
> 	This warning was last seen in version 2.6.30, and first seen in 2.6.25.3.
> 	More info: http://www.kerneloops.org/searchweek.php?search=generic_get_mtrr

I think this calls for enabling the x86 MTRR sanitizer by default - 
500 out of 15000 reports suggests a significant proportion of Linux 
systems is affected by MTRR setup problems.

I.e. we should change:

config MTRR_SANITIZER_ENABLE_DEFAULT
        int "MTRR cleanup enable value (0-1)"
        range 0 1
        default "0"

To 'default "1"'. Any objections?

If the MTRR sanitizer is enabled then i think the above warning in 
generic_get_mtrr() should never trigger.

	Ingo
