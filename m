From: Yuval Mintz <Yuval.Mintz@qlogic.com>
Subject: RE: [PATCH v2 net] bnx2x: Fix statistics locking scheme
Date: Thu, 19 Mar 2015 07:26:25 +0000
Message-ID: <B5657A6538887040AD3A81F1008BEC63C1401F@avmb3.qlogic.org>
References: <1426688042-20315-1-git-send-email-Yuval.Mintz@qlogic.com>
 <20150318.151059.979411313448939306.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: netdev <netdev@vger.kernel.org>,
	Ariel Elior <Ariel.Elior@qlogic.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from avcashub2.qlogic.com ([198.70.193.116]:43960 "EHLO
	avcashub1.qlogic.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1750940AbbCSH01 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Mar 2015 03:26:27 -0400
In-Reply-To: <20150318.151059.979411313448939306.davem@davemloft.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> > +int bnx2x_stats_safe_exec(struct bnx2x *bp,
> > +			  void (func_to_exec)(void *cookie),
> > +			  void *cookie)
>  ...
> > +	if (bp->stats_pending) {
> > +		BNX2X_ERR("Failed to wait for stats pending to clear\n");
> > +		return -EBUSY;
> 
> Buggy, this returns with the stats_lock still held.

Ouch; You're right - I'll fix it.

> 
> In my humble opinion, you are putting very little care and effort into this bug fix.

Well, we've put quite a bit in the logic behind it; But you're probably right
About the effort put into v2.

> Also I disagree with your timeout logic.
> 
> I suspect that the real reason these timeouts are present, is that the locking
> hierarchy is uncertain.
> 
> Nothing really should create the situation those trylocks seem to be dealing
> with.

Actually, you're probably right in the assumption - I have a feeling that due to
the races in the previous implementation, there was lack of confidence in the
general process.
According to my current analysis there shouldn't be any real need for the limit
on time, since there are no limitless loops taking place while the locks are being
held [at most, HW/FW is asserted and nothing happens; But it still should take
only a couple of mili-seconds].
The only reason I've left this was to leave the implementation close as I can to
original [which used that locking mechanism] given that it's intended to `net'.
Do you prefer I simply switch over into using a regular mutex?
