From: Andrew Morton <akpm@osdl.org>
Subject: Re: [Bugme-new] [Bug 6530] New: MAINLINE
Date: Wed, 10 May 2006 02:33:57 -0700
Message-ID: <20060510023357.0d1260ee.akpm@osdl.org>
References: <200605100920.k4A9KC91018259@fire-2.osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Paul Mackerras <paulus@samba.org>,
	xeb@mail.ru
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:35544 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S964877AbWEJJg5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 May 2006 05:36:57 -0400
To: bugme-daemon@bugzilla.kernel.org
In-Reply-To: <200605100920.k4A9KC91018259@fire-2.osdl.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

bugme-daemon@bugzilla.kernel.org wrote:
>
> http://bugzilla.kernel.org/show_bug.cgi?id=6530
> 
>            Summary: MAINLINE
>     Kernel Version: 2.6.16
>             Status: NEW
>           Severity: normal
>              Owner: jgarzik@pobox.com
>          Submitter: xeb@mail.ru
> 
> 
> Most recent kernel where this bug did not occur:
> Distribution:  gentoo 2005.1
> Hardware Environment: i386 (Intel(R) Celeron(R) M processor         1.40GHz), RAM 256M
> Software Environment:
> Problem Description:
> Hello.
> I tried to setup pptp (pptpd) service on my linux box, but it don't work correctly.
> Problem: traffic freezes when sending large amount of data.
> 
> I find lack in ppp_async.c. 
> 
> 	/* try to push more stuff out */
> 	if (test_bit(XMIT_WAKEUP, &ap->xmit_flags) && ppp_async_push(ap))
> 		ppp_output_wakeup(&ap->chan);
> ---->> I added this lines and pptpd starts work.
> 	else
> 	{
> 	    if (test_bit(XMIT_FULL, &ap->xmit_flags))
> 		ppp_asynctty_wakeup(ap->tty);
> 	}
> 

hm, a PPP fix.  We seem to need some of those lately.

Paul, does this look sane?


From: <xeb@mail.ru>

Adapted from  http://bugzilla.kernel.org/show_bug.cgi?id=6530

Reschedule the async Tx tasklet if the transmit queue was full.

Cc: Paul Mackerras <paulus@samba.org>
Signed-off-by: Andrew Morton <akpm@osdl.org>
---

 drivers/net/ppp_async.c |    2 ++
 1 files changed, 2 insertions(+)

diff -puN drivers/net/ppp_async.c~ppp_async-hang-fix drivers/net/ppp_async.c
--- devel/drivers/net/ppp_async.c~ppp_async-hang-fix	2006-05-10 02:28:15.000000000 -0700
+++ devel-akpm/drivers/net/ppp_async.c	2006-05-10 02:28:53.000000000 -0700
@@ -516,6 +516,8 @@ static void ppp_async_process(unsigned l
 	/* try to push more stuff out */
 	if (test_bit(XMIT_WAKEUP, &ap->xmit_flags) && ppp_async_push(ap))
 		ppp_output_wakeup(&ap->chan);
+	else if (test_bit(XMIT_FULL, &ap->xmit_flags))
+		ppp_asynctty_wakeup(ap->tty);
 }
 
 /*
_

