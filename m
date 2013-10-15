From: jianhai luan <jianhai.luan@oracle.com>
Subject: Re: DomU's network interface will hung when Dom0 running 32bit
Date: Wed, 16 Oct 2013 00:23:50 +0800
Message-ID: <525D6C16.6010705@oracle.com>
References: <525CAC21.5040202@oracle.com> <1381826609.24708.135.camel@kazak.uk.xensource.com> <525D0C41.2080407@oracle.com> <20131015100624.GB29436@zion.uk.xensource.com> <525D2667.6040102@oracle.com> <20131015125802.GR11739@zion.uk.xensource.com> <525D513B.70406@oracle.com> <20131015144910.GS11739@zion.uk.xensource.com> <1381848632.21901.42.camel@kazak.uk.xensource.com> <525D5D0E.5070107@oracle.com> <20131015160336.GT11739@zion.uk.xensource.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Ian Campbell <Ian.Campbell@citrix.com>,
	xen-devel@lists.xenproject.org, netdev@vger.kernel.org,
	ANNIE LI <annie.li@oracle.com>
To: Wei Liu <wei.liu2@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:39335 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932283Ab3JOQYH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Oct 2013 12:24:07 -0400
In-Reply-To: <20131015160336.GT11739@zion.uk.xensource.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On 2013-10-16 0:03, Wei Liu wrote:
> On Tue, Oct 15, 2013 at 11:19:42PM +0800, jianhai luan wrote:
> [...]
>>>>>> * time_after_eq(now, next_credit) -> false
>>>>>> * time_before(now, expires) -> false
>>>>> If now is placed in above environment, the result will be correct
>>>>> (Sending package will be not allowed until next_credit).
>>>> No, it is not necessarily correct. Keep in mind that "now" wraps around,
>>>> which is the issue you try to fix. You still have a window to stall your
>>>> frontend.
>>> Remember that time_after_eq is supposed to work even with wraparound
>>> occurring, so long as the two times are less than MAX_LONG/2 apart.
>> Sorry for my misunderstand explanation. I mean that
>>    * time_after_eq()/time_before_eq() fix the jiffies wraparound, so
>> please think about  jiffies in line increasing.
>>    * time_after_eq()/time_before_eq() have the range (0, MAX_LONG/2),
>> the judge will be wrong if out of the range.
>>
>> So please think about three kind environment
>>    -  expires        now        next_credit
>>       --------time increases this direction ---------->
>>
>>    -  expires        [next_credit        now next_credit+MAX_LONG/2
>>       --------time increase this direction ----------->
>>
>>    - expires        next_credit        next_credit+MAX_LONG/2 now
>>       --------time increadse this direction ---------->
>>
>> The first environment should be netfront consume all credit_byte
>> before next_credit, So we should pending one timer to calculator the
>> new credit_byte, and don't transmit until next_credit.
>>
>> the second environment should be calculator the credit_byte because
>> netfront don't consume all credit_byte before next_credit, and
>> time_after_eq() do correct judge.
>>
>> the third environment should be calculator in time because netfront
>> don't consume all credit_byte until next_credit.But time_after_eq do
>> error judge (time_after_eq(now, next_credit) is false), so the
>> remaining_byte isn't be increased.
>>
>> and I work on the third environment.  You know now >
>> next_credit+MAX_LONG/2, time_before(now, expire) should be
>> true(time_before(now, expire) is false in first environment)
> Thanks for staighten this out for me. I'm just too dumb for this, please
> be patient with me. :-)
>
> Could you prove that time_before(now, expire) is always true in third
> case? That's where my main cencern lies. Is it because msecs_to_jiffies
> always returns MAX_JIFFY_OFFSET (which is ((LONG_MAX >> 1)-1) ) at most?

I have wrong judge in third environment. If now large than expires + 
MAX_UNLONG, time_before(now, expires) will be false.
   expires    next_credit    next_credit+MAX_UNLONG/2    expires + 
MAX_UNLONG    now    next_credit+MAX_UNLONG
   --------------------------------------------------------- time 
increadse this direction  ---------------------------------->

   In the above environment, time_before(now, expires) will return 
false. But the jiffies elapsed more time and next_credit will be 
reachable in soon(time_after_eq(now, next_credit) will be true).
>
> Wei.
