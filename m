From: jianhai luan <jianhai.luan@oracle.com>
Subject: Re: [Xen-devel] DomU's network interface will hung when Dom0 running
 32bit
Date: Wed, 16 Oct 2013 23:04:34 +0800
Message-ID: <525EAB02.9050207@oracle.com>
References: <20131014111958.GE11739@zion.uk.xensource.com> <525CAC21.5040202@oracle.com> <1381826609.24708.135.camel@kazak.uk.xensource.com> <525D0C41.2080407@oracle.com> <20131015100624.GB29436@zion.uk.xensource.com> <525D2667.6040102@oracle.com> <20131015125802.GR11739@zion.uk.xensource.com> <525E41CF.7090008@oracle.com> <525E5EDF.4030904@oracle.com> <525E8FB3.8000606@oracle.com> <20131016134740.GG16371@zion.uk.xensource.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------000905000708070004020703"
Cc: annie li <annie.li@oracle.com>, xen-devel@lists.xenproject.org,
	Ian Campbell <Ian.Campbell@citrix.com>, netdev@vger.kernel.org
To: Wei Liu <wei.liu2@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:43284 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751993Ab3JPPEw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Oct 2013 11:04:52 -0400
In-Reply-To: <20131016134740.GG16371@zion.uk.xensource.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------000905000708070004020703
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit


On 2013-10-16 21:47, Wei Liu wrote:
> On Wed, Oct 16, 2013 at 09:08:03PM +0800, jianhai luan wrote:
> [...]
>>>>>     expires   now   next_credit
>>>>>     ----time increases this direction--->
>>>>>
>>>>> * time_after_eq(now, next_credit) -> false
>>>>> * time_before(now, expires) -> false
>>>>>
>>>>> Then it's stuck again. You're merely narrowing the window, not fixing
>>>>> the real problem.
>>>> The above environment isn't stack again. The netback will
>>>> pending one timer to process the environment.
>>>>
>>>> The attachment program will prove if !(time_after_eq(now,
>>>> next_credit) || time_before(now, vif->credit_timeout.expires)),
>>>> now will only be placed in above environment [ expires
>>>> next_credit),  and the above environment will be processed by
>>>> timer in soon.
>>> Or check following to see what the if condition really do,
>>>
>>> ----------expires-------now-------credit----------    is the only
>>> case where we need to add a timer.
>>>
>>> Other cases like following would match the if condition above,
>>> then no timer is added.
>>> ----------expires----------credit------now------
>>> -----now-----expires----------credit----------
>>>
>>> Or we can consider the extreme condition, when the rate control
>>> does not exist, "credit_usec" is zero, and "next_credit" is equal
>>> to "expires". The above if condition would cover all conditions,
>>> and no rate control really happens. If credit_usec is not zero,
>>> the "if condition" would cover the range outside of that from
>>> expires to next_credit.
>>>
>>> Even if "now" is wrapped again into the range from "expires" to
>>> "next_credit", the "next_credit" that is set in __mod_timer is
>>> reasonable value(this can be gotten from credit_usec), and the
>>> timer would be hit soon.
>> Thanks Annie's express, my option is consistent with Annie.
>>
> OK, thanks for the explanation. I think I get the idea.
>
> In any case, could you use !time_in_range / !time_in_range_open instead
> of open coded one-liner? Though I presume one-liner open coding would
> not hurt.

I agree above the suggest. The attachment patch may be better than 
previous patch.

Jason
>
> Wei.


--------------000905000708070004020703
Content-Type: text/plain; charset=gb18030;
 name="0001-xen-netback-pending-timer-only-in-the-range-expire-n.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename*0="0001-xen-netback-pending-timer-only-in-the-range-expire-n.pa";
 filename*1="tch"

>From ef02403a10173896c5c102f768741d0700b8a3a2 Mon Sep 17 00:00:00 2001
From: Jason Luan <jianhai.luan@oracle.com>
Date: Tue, 15 Oct 2013 17:07:49 +0800
Subject: [PATCH] xen-netback: pending timer only in the range [expire,
 next_credit)

The function time_after_eq() do correct judge in range of MAX_UNLONG/2.
If net-front send lesser package, the delta between now and next_credit
will out of the range and time_after_eq() will do wrong judge in result
to net-front hung.  For example:
    expire    next_credit    ....    next_credit+MAX_UNLONG/2    now
    -----------------time increases this direction----------------->

We should be add the environment which now beyond next_credit+MAX_UNLONG/2.
Because the fact now mustn't before expire, time_before(now, expire) == true
will show the environment.
    time_after_eq(now, next_credit) || time_before (now, expire)
    ==
    !time_in_range_open(now, expire, next_credit)

Signed-off-by: Jason Luan <jianhai.luan@oracle.com>
---
 drivers/net/xen-netback/netback.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/xen-netback/netback.c b/drivers/net/xen-netback/netback.c
index f3e591c..62492f0 100644
--- a/drivers/net/xen-netback/netback.c
+++ b/drivers/net/xen-netback/netback.c
@@ -1195,7 +1195,7 @@ static bool tx_credit_exceeded(struct xenvif *vif, unsigned size)
 		return true;
 
 	/* Passed the point where we can replenish credit? */
-	if (time_after_eq(now, next_credit)) {
+	if (!time_in_range(now, vif->credit_timeout.expires, next_credit)) {
 		vif->credit_timeout.expires = now;
 		tx_add_credit(vif);
 	}
-- 
1.7.6.5


--------------000905000708070004020703--
