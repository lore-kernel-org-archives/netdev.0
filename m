From: "Yuval Mintz" <yuvalmin@broadcom.com>
Subject: RE: [net PATCH v2 1/7] bnx2x: Avoid sending multiple statistics
 queries
Date: Thu, 13 Sep 2012 20:34:57 +0000
Message-ID: <979A8436335E3744ADCD3A9F2A2B68A504B81E31@SJEXCHMB10.corp.ad.broadcom.com>
References: <1347374054-16730-1-git-send-email-yuvalmin@broadcom.com>
 <1347374054-16730-2-git-send-email-yuvalmin@broadcom.com>
 <20120913.161711.2180618409918407558.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Dmitry Kravkov" <dmitry@broadcom.com>,
	"Eilon Greenstein" <eilong@broadcom.com>
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:4909 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755508Ab2IMUf1 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Sep 2012 16:35:27 -0400
In-Reply-To: <20120913.161711.2180618409918407558.davem@davemloft.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> > This patch prevents the sending of an additional instance of statistics
> query
> > while the previous query hasn't completed.
> >
> This change results in no change in behavior as far as I can tell.
> 
> > -	if (bnx2x_storm_stats_update(bp) && (bp->stats_pending++ == 3)) {
> > -		BNX2X_ERR("storm stats were not updated for 3 times\n");
> > -		bnx2x_panic();
> > +	if (bnx2x_storm_stats_update(bp)) {
> > +		if (bp->stats_pending++ == 3) {
> > +			BNX2X_ERR("storm stats were not updated for 3
> times\n");
> > +			bnx2x_panic();
> > +		}

But you're missing the 'return;' statement at the end.

> 
> There is no difference between:
> 
> 	if (A && B) {
> 		C;
> 	}
> 
> and:
> 
> 	if (A) {
> 		if (B) {
> 			C;
> 		}
> 	}

But there is a difference between:
If (A && B) {
	C;
	D;
}

And:
if (A) {
	if (B) {
		C;
	}
	D;
}

The point of this patch was not to change the condition of the print & panic but rather to guarantee that
if bnx2x_storm_stats_update failed, no more ramrods will be posted, as the function will return 
(regardless of stats_pending value).

Sorry it wasn't clearer in the patch.
