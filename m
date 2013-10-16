From: annie li <annie.li@oracle.com>
Subject: Re: DomU's network interface will hung when Dom0 running 32bit
Date: Wed, 16 Oct 2013 15:10:20 +0800
Message-ID: <525E3BDC.4060309@oracle.com>
References: <52590DFE.6080203@oracle.com>  <20131014111958.GE11739@zion.uk.xensource.com>  <525CAC21.5040202@oracle.com> <1381826609.24708.135.camel@kazak.uk.xensource.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: jianhai luan <jianhai.luan@oracle.com>,
	Wei Liu <wei.liu2@citrix.com>, xen-devel@lists.xenproject.org,
	netdev@vger.kernel.org
To: Ian Campbell <Ian.Campbell@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:35781 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759887Ab3JPHKa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Oct 2013 03:10:30 -0400
In-Reply-To: <1381826609.24708.135.camel@kazak.uk.xensource.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On 2013-10-15 16:43, Ian Campbell wrote:
> On Tue, 2013-10-15 at 10:44 +0800, jianhai luan wrote:
>> On 2013-10-14 19:19, Wei Liu wrote:
>>> On Sat, Oct 12, 2013 at 04:53:18PM +0800, jianhai luan wrote:
>>>> Hi Ian,
>>>>     I meet the DomU's network interface hung issue recently, and have
>>>> been working on the issue from that time. I find that DomU's network
>>>> interface, which send lesser package, will hung if Dom0 running
>>>> 32bit and DomU's up-time is very long.  I think that one jiffies
>>>> overflow bug exist in the function tx_credit_exceeded().
>>>>     I know the inline function time_after_eq(a,b) will process jiffies
>>>> overflow, but the function have one limit a should little that (b +
>>>> MAX_SIGNAL_LONG). If a large than the value, time_after_eq will
>>>> return false. The MAX_SINGNAL_LONG should be 0x7fffffff at 32-bit
>>>> machine.
>>>>     If DomU's network interface send lesser package (<0.5k/s if
>>>> jiffies=250 and credit_bytes=ULONG_MAX), jiffies will beyond out
>>>> (credit_timeout.expires + MAX_SIGNAL_LONG) and time_after_eq(now,
>>>> next_credit) will failure (should be true). So one timer which will
>>>> not be trigger in short time, and later process will be aborted when
>>>> timer_pending(&vif->credit_timeout) is true. The result will be
>>>> DomU's network interface will be hung in long time (> 40days).
>>>>     Please think about the below scenario:
>>>>     Condition:
>>>>       Dom0 running 32-bit and HZ = 1000
>>>>       vif->credit_timeout->expire = 0xffffffff, vif->remaining_credit
>>>> = 0xffffffff, vif->credit_usec=0 jiffies=0
>>>>       vif receive lesser package (DomU send lesser package). If the
>>>> value is litter than 2K/s, consume 4G(0xffffffff) will need 582.55
>>>> hours. jiffies will large than 0x7ffffff. we guess jiffies =
>>>> 0x800000ff, time_after_eq(0x800000ff, 0xffffffff) will failure, and
>>>> one time which expire is 0xfffffff will be pended into system. So
>>>> the interface will hung until jiffies recount 0xffffffff (that will
>>>> need very long time).
>>> If I'm not mistaken you meant time_after_eq(now, next_credit) in
>>> netback. How does next_credit become 0xffffffff?
>> I only assume the value is 0xfffffff, and the value of next_credit
>> isn't  point. If the delta between now and next_credit larger than
>> ULONG_MAX, time_after_eq will do wrong judge.
> So it sounds like we need a timer which is independent of the traffic
> being sent to keep credit_timeout.expires rolling over.
Resending it because of the wrong format in last email...

Is it a timer to be set as less than ULONG_MAX/2 to avoid credit_timeout.expires rolling over? But the problem is that we can not assure where jiffies start from, and this probably results into current issue again.
I assume Jason's patch fix this issue and this patch only uses __mod_timer to add a timer with next_credit when the netback fails to send out current
available credits.

Thanks
Annie


>
> Can you propose a patch?
>
> Ian.
>
>>> Wei.
>>>
>>>>     If some error exist in above explain, please help me point it out.
>>>>
>>>> Thanks,
>>>> Jason
>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
