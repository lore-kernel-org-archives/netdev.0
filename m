From: Pavel Roskin <proski@gnu.org>
Subject: Re: [PATCH] hostap_plx: fix CIS verification
Date: Tue, 24 Oct 2006 22:12:24 -0400
Message-ID: <1161742344.29939.6.camel@dv>
References: <1161382815.5803.2.camel@dv>  <20061021011943.GC6140@jm.kir.nu>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, hostap@shmoo.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from c60.cesmail.net ([216.154.195.49]:34479 "EHLO c60.cesmail.net")
	by vger.kernel.org with ESMTP id S1422763AbWJYCMZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Oct 2006 22:12:25 -0400
To: Jouni Malinen <jkmaline@cc.hut.fi>
In-Reply-To: <20061021011943.GC6140@jm.kir.nu>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello, Jouni!

On Fri, 2006-10-20 at 18:19 -0700, Jouni Malinen wrote: 
> On Fri, Oct 20, 2006 at 06:20:15PM -0400, Pavel Roskin wrote:
> 
> > The record length for numerical manufacturer ID should be at least 4
> > bytes (two 16-bit words).  The code required 5 bytes, which would break
> > for most (if not all) cards.  Reported by ph35sm@free.fr
> 
> >  		case CISTPL_MANFID:
> > -			if (cis[pos + 1] < 5)
> > +			if (cis[pos + 1] < 4)
> 
> Hmm.. Interesting. I think this was changed from 4 to 5 due to a
> potential buffer overflow as reported by Coverity tools.. In addition, I
> think that I spent long time trying to understand why it could be a
> buffer overflow and since it was changed, likely finally figured out an
> example case.. Alas, I don't remember what exactly this was anymore.

Coverity has no means to interpret CIS.  However, it may understand
kmalloc, which allocates CIS_MAX_LEN for the CIS copy.

The value of cis[pos + 1] has no bearing on the validity of the access
to cis[pos + 5] from the point of view of a checking tool.

> It looks like the comparison of the length field to be <5 was incorrect,
> but in order to avoid re-introducing any potential buffer overflows,
> that condition could be extended to verify that pos is small enough..

pos is already checked in the beginning of the loop to be small enough,
but the check is not strong enough.  The next tuple starts at (pos +
cis[pos + 1] + 2), and we want that to be at most CIS_MAX_LEN.

That's something Coverity could have found.

So, the right fix would be:

diff --git a/drivers/net/wireless/hostap/hostap_plx.c b/drivers/net/wireless/hostap/hostap_plx.c
index b5b72db..bc81b13 100644
--- a/drivers/net/wireless/hostap/hostap_plx.c
+++ b/drivers/net/wireless/hostap/hostap_plx.c
@@ -364,7 +364,7 @@ #define CIS_MAX_LEN 256
 
 	pos = 0;
 	while (pos < CIS_MAX_LEN - 1 && cis[pos] != CISTPL_END) {
-		if (pos + cis[pos + 1] >= CIS_MAX_LEN)
+		if (pos + 2 + cis[pos + 1] > CIS_MAX_LEN)
 			goto cis_error;
 
 		switch (cis[pos]) {

I'm rewriting this with "<" because it's easier to read.  Next tuple at
exactly CIS_MEX_LEN is fine - we just stop precessing at that point.

I'm going to combine this with my previous fix and resend.

-- 
Regards,
Pavel Roskin

