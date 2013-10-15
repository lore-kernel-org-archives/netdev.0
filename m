From: jianhai luan <jianhai.luan@oracle.com>
Subject: Re: DomU's network interface will hung when Dom0 running 32bit
Date: Tue, 15 Oct 2013 10:44:49 +0800
Message-ID: <525CAC21.5040202@oracle.com>
References: <52590DFE.6080203@oracle.com> <20131014111958.GE11739@zion.uk.xensource.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Ian Campbell <Ian.Campbell@citrix.com>,
	xen-devel@lists.xenproject.org, netdev@vger.kernel.org
To: Wei Liu <wei.liu2@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:46260 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755122Ab3JOCpB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Oct 2013 22:45:01 -0400
In-Reply-To: <20131014111958.GE11739@zion.uk.xensource.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On 2013-10-14 19:19, Wei Liu wrote:
> On Sat, Oct 12, 2013 at 04:53:18PM +0800, jianhai luan wrote:
>> Hi Ian,
>>    I meet the DomU's network interface hung issue recently, and have
>> been working on the issue from that time. I find that DomU's network
>> interface, which send lesser package, will hung if Dom0 running
>> 32bit and DomU's up-time is very long.  I think that one jiffies
>> overflow bug exist in the function tx_credit_exceeded().
>>    I know the inline function time_after_eq(a,b) will process jiffies
>> overflow, but the function have one limit a should little that (b +
>> MAX_SIGNAL_LONG). If a large than the value, time_after_eq will
>> return false. The MAX_SINGNAL_LONG should be 0x7fffffff at 32-bit
>> machine.
>>    If DomU's network interface send lesser package (<0.5k/s if
>> jiffies=250 and credit_bytes=ULONG_MAX), jiffies will beyond out
>> (credit_timeout.expires + MAX_SIGNAL_LONG) and time_after_eq(now,
>> next_credit) will failure (should be true). So one timer which will
>> not be trigger in short time, and later process will be aborted when
>> timer_pending(&vif->credit_timeout) is true. The result will be
>> DomU's network interface will be hung in long time (> 40days).
>>    Please think about the below scenario:
>>    Condition:
>>      Dom0 running 32-bit and HZ = 1000
>>      vif->credit_timeout->expire = 0xffffffff, vif->remaining_credit
>> = 0xffffffff, vif->credit_usec=0 jiffies=0
>>      vif receive lesser package (DomU send lesser package). If the
>> value is litter than 2K/s, consume 4G(0xffffffff) will need 582.55
>> hours. jiffies will large than 0x7ffffff. we guess jiffies =
>> 0x800000ff, time_after_eq(0x800000ff, 0xffffffff) will failure, and
>> one time which expire is 0xfffffff will be pended into system. So
>> the interface will hung until jiffies recount 0xffffffff (that will
>> need very long time).
> If I'm not mistaken you meant time_after_eq(now, next_credit) in
> netback. How does next_credit become 0xffffffff?

I only assume the value is 0xfffffff, and the value of next_credit 
isn't  point. If the delta between now and next_credit larger than 
ULONG_MAX, time_after_eq will do wrong judge.
>
> Wei.
>
>>    If some error exist in above explain, please help me point it out.
>>
>> Thanks,
>> Jason
