From: Jesper Dangaard Brouer <jdb@comx.dk>
Subject: Re: [PATCH] sfc: Make temperature warnings/alarms more explicit.
Date: Thu, 30 Apr 2009 10:44:59 +0200
Message-ID: <1241081099.8115.31.camel@localhost.localdomain>
References: <1240911369.10689.20.camel@localhost.localdomain>
	 <1240925799.3200.16.camel@achroite>
	 <1240929844.10689.35.camel@localhost.localdomain>
	 <1240930084.10689.39.camel@localhost.localdomain>
	 <1241054754.22157.22.camel@deadeye>
Reply-To: jdb@comx.dk
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from lanfw001a.cxnet.dk ([87.72.215.196]:41277 "EHLO
	lanfw001a.cxnet.dk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753092AbZD3IpB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Apr 2009 04:45:01 -0400
In-Reply-To: <1241054754.22157.22.camel@deadeye>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2009-04-30 at 02:25 +0100, Ben Hutchings wrote:
> On Tue, 2009-04-28 at 16:48 +0200, Jesper Dangaard Brouer wrote:
> > The sfc driver can detect different hardware failures via the
> > LM87 system.  One of the failures I have experienced is the
> > temperature alarm, but the error message didn't reveal that this
> > error was temperature related.  I had to read the code to
> > discover that.
> > 
> > I think that the temperature error should be more explicit, in
> > order to warn people before the board is permanently damaged.
> 
> You are right, but...
> 
> > diff --git a/drivers/net/sfc/boards.c b/drivers/net/sfc/boards.c
> > index 4a4c74c..b1822fe 100644
> > --- a/drivers/net/sfc/boards.c
> > +++ b/drivers/net/sfc/boards.c
> > @@ -121,8 +121,10 @@ static int efx_check_lm87(struct efx_nic *efx, unsigned mask)
> >  	if (alarms1 || alarms2) {
> >  		EFX_ERR(efx,
> >  			"LM87 detected a hardware failure (status %02x:%02x)"
> > -			"%s%s\n",
> > +			"%s%s%s\n",
> >  			alarms1, alarms2,
> > +			(alarms1 & (LM87_ALARM_TEMP_INT|LM87_ALARM_TEMP_EXT1))
> > +			 ? " high temperature" : "",
> >  			(alarms1 & LM87_ALARM_TEMP_INT) ? " INTERNAL" : "",
> >  			(alarms1 & LM87_ALARM_TEMP_EXT1) ? " EXTERNAL" : "");
> >  		return -ERANGE;
> 
> We could be more explicit still.  How about:

Yes, the "INTERNAL" and "EXTERNAL" is not very descriptive.

> 
> 		EFX_ERR(efx,
> 			"%s out of range (LM87 status %02x:%02x)\n",
> 			(alarms1 & LM87_ALARM_TEMP_INT) ? "Board temperature" :
> 			(alarms1 & LM87_ALARM_TEMP_EXT1) ? "Controller temperature :
> 			"Voltage",

Notice that both LM87_ALARM_TEMP_INT and LM87_ALARM_TEMP_EXT1 can be set
at the same time.  In that case we only print "Board temperature", is
that good enough?  (I thinks its okay, as the status will provide
developers enough info for debugging the event)

> 			alarms1, alarms2);

I would like to emphesize that its a hardware alarm, by adding "HW
alarm:" see revised patch...

-- 
Med venlig hilsen / Best regards
  Jesper Brouer
  ComX Networks A/S
  Linux Network developer
  Cand. Scient Datalog / MSc.
  Author of http://adsl-optimizer.dk
  LinkedIn: http://www.linkedin.com/in/brouer


[PATCH] sfc: Make temperature warnings/alarms more explicit.

The sfc driver can detect different hardware failures via the
LM87 system.  One of the failures I have experienced is the
temperature alarm, but the error message didn't reveal that this
error was temperature related.  I had to read the code to
discover that.

I think that the temperature error should be more explicit, in
order to warn people before the board is permanently damaged.

Signed-off-by: Jesper Dangaard Brouer <hawk@comx.dk>
---

 drivers/net/sfc/boards.c |   10 +++++-----
 1 files changed, 5 insertions(+), 5 deletions(-)


diff --git a/drivers/net/sfc/boards.c b/drivers/net/sfc/boards.c
index 4a4c74c..223866c 100644
--- a/drivers/net/sfc/boards.c
+++ b/drivers/net/sfc/boards.c
@@ -120,11 +120,11 @@ static int efx_check_lm87(struct efx_nic *efx, unsigned mask)
 	alarms2 &= mask >> 8;
 	if (alarms1 || alarms2) {
 		EFX_ERR(efx,
-			"LM87 detected a hardware failure (status %02x:%02x)"
-			"%s%s\n",
-			alarms1, alarms2,
-			(alarms1 & LM87_ALARM_TEMP_INT) ? " INTERNAL" : "",
-			(alarms1 & LM87_ALARM_TEMP_EXT1) ? " EXTERNAL" : "");
+			"HW alarm: %s out of range (LM87 status %02x:%02x)\n",
+			(alarms1 & LM87_ALARM_TEMP_INT) ? "Board temperature" :
+			(alarms1 & LM87_ALARM_TEMP_EXT1) ? "Controller temperature" :
+			 "Voltage",
+			alarms1, alarms2);
 		return -ERANGE;
 	}
 

