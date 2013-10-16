From: jianhai luan <jianhai.luan@oracle.com>
Subject: Re: [Xen-devel] DomU's network interface will hung when Dom0 running
 32bit
Date: Thu, 17 Oct 2013 00:44:53 +0800
Message-ID: <525EC285.4000009@oracle.com>
References: <1381826609.24708.135.camel@kazak.uk.xensource.com>	<525D0C41.2080407@oracle.com>	<20131015100624.GB29436@zion.uk.xensource.com>	<525D2667.6040102@oracle.com>	<20131015125802.GR11739@zion.uk.xensource.com>	<525E41CF.7090008@oracle.com> <525E5EDF.4030904@oracle.com>	<525E8FB3.8000606@oracle.com>	<20131016134740.GG16371@zion.uk.xensource.com>	<525EAB02.9050207@oracle.com> <20131016151732.GJ16371@zion.uk.xensource.com> <525EBABB.4070906@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: xen-devel@lists.xenproject.org, annie li <annie.li@oracle.com>,
	Ian Campbell <Ian.Campbell@citrix.com>, netdev@vger.kernel.org
To: David Vrabel <david.vrabel@citrix.com>,
	Wei Liu <wei.liu2@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:33008 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760894Ab3JPQpJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Oct 2013 12:45:09 -0400
In-Reply-To: <525EBABB.4070906@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On 2013-10-17 0:11, David Vrabel wrote:
> On 16/10/13 16:17, Wei Liu wrote:
>> On Wed, Oct 16, 2013 at 11:04:34PM +0800, jianhai luan wrote:
>> [...]
>>> >From ef02403a10173896c5c102f768741d0700b8a3a2 Mon Sep 17 00:00:00 2001
>>> From: Jason Luan <jianhai.luan@oracle.com>
>>> Date: Tue, 15 Oct 2013 17:07:49 +0800
>>> Subject: [PATCH] xen-netback: pending timer only in the range [expire,
>>>   next_credit)
>>>
>>> The function time_after_eq() do correct judge in range of MAX_UNLONG/2.
>>> If net-front send lesser package, the delta between now and next_credit
>>> will out of the range and time_after_eq() will do wrong judge in result
>>> to net-front hung.  For example:
>>>      expire    next_credit    ....    next_credit+MAX_UNLONG/2    now
>>>      -----------------time increases this direction----------------->
>>>
>>> We should be add the environment which now beyond next_credit+MAX_UNLONG/2.
>>> Because the fact now mustn't before expire, time_before(now, expire) == true
>>> will show the environment.
>>>      time_after_eq(now, next_credit) || time_before (now, expire)
>>>      ==
>>>      !time_in_range_open(now, expire, next_credit)
>>>
> I would like the description improved because it's too hard to understand.
>
> How about something like:
>
> "time_after_eq() only works if the delta is < MAX_ULONG/2.
>
> If netfront sends at a very low rate, the time between subsequent calls
> to tx_credit_exceeded() may exceed MAX_ULONG/2 and the test for
> timer_after_eq() will be incorrect.  Credit will not be replenished and
> the guest may become unable to send (e.g., if prior to the long gap, all
> credit was exhausted)."

Thanks your description, i will accept it. :)
>
> But that's as far as I get because I can't see how the fix is correct.
> The time_in_range() test might still return the wrong value if now has
> advanced even further and wrapped so it is between expire and
> next_credit again.

typo, time_in_range() should be time_in_range_open().
Yes, if now have advanced even further and wrapped, it will always fall 
in [ expire, next_credit). In the range, please think two scenario:
    * No transmit limit: expire == next_credit, the range will be zero, 
replenish will always be done.
    * Transmit limit: Because guest may be consume all credit_bytes in 
very short time, other time in [expire, next_credit) will don't send any 
package. So the time which don't send package should be think about when 
we set the rate parameter.
       So if now fall in the range, the hung time should be acceptable. 
(if rate=10000M/s, the worse time will be 4s).
>
> I think the credit timeout should be always armed to expire in
> MAX_ULONG/4 jiffies (or some other large value).  If credit is exceeded,
> this timer is then adjusted to fire earlier (at next_credit as it does
> already).

Setting timer may be fixed the issue. But i don't think how to verify 
the fixed expect waiting 180 days. I verified the above patch only 
change expire's value to emulator the scenario.
>
> David

Jason.
