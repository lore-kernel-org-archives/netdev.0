From: Sasha Levin <sasha.levin@oracle.com>
Subject: Re: net, ipv6: out of bounds access in secret_stable
Date: Mon, 21 Dec 2015 08:17:20 -0500
Message-ID: <5677FBE0.8080104@oracle.com>
References: <5674AF3B.6030903@oracle.com>
 <CAHA+R7MRM3io3uAzJmjFBNj6-MtKJ67kxKqiH8TZM-jjJvzmcg@mail.gmail.com>
 <5677BF37.1080500@stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	LKML <linux-kernel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Cong Wang <cwang@twopensource.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:41822 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751134AbbLUNRa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Dec 2015 08:17:30 -0500
In-Reply-To: <5677BF37.1080500@stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/21/2015 03:58 AM, Hannes Frederic Sowa wrote:
> On 19.12.2015 21:50, Cong Wang wrote:
>> On Fri, Dec 18, 2015 at 5:13 PM, Sasha Levin <sasha.levin@oracle.com> wrote:
>>> Hi Hannes,
>>>
>>> I've hit the following out of bounds access while fuzzing on the latest -next kernel.
>>>
>>> This code was added in 3d1bec9932 ("ipv6: introduce secret_stable to ipv6_devconf").
>>>
>>> [  459.553655] BUG: KASAN: stack-out-of-bounds in strlen+0x58/0x90 at addr ffff8802ab0efb0e
>>> [  459.554953] Read of size 1 by task trinity-c91/22576
>>> [  459.555805] page:ffffea000aac3bc0 count:0 mapcount:0 mapping:          (null) index:0x0
>>> [  459.556899] flags: 0x26fffff80000000()
>>> [  459.557521] page dumped because: kasan: bad access detected
>>> [  459.558320] CPU: 7 PID: 22576 Comm: trinity-c91 Not tainted 4.4.0-rc5-next-20151218-sasha-00021-gaba8d84-dirty #2750
>>> [  459.559809]  0000000000000000 00000000549d0aa3 ffff8802ab0ef860 ffffffffa1042384
>>> [  459.561036]  0000000041b58ab3 ffffffffac667cdb ffffffffa10422d9 ffff8802ab0ef848
>>> [  459.562245]  ffffffff9f6a417e 00000000549d0aa3 ffff8802ab0efb0e ffff8802ab0efb0e
>>> [  459.563429] Call Trace:
>>> [  459.563831] dump_stack (lib/dump_stack.c:52)
>>> [  459.564623] ? _atomic_dec_and_lock (lib/dump_stack.c:27)
>>> [  459.565628] ? __dump_page (mm/debug.c:126)
>>> [  459.566538] kasan_report_error (include/linux/kasan.h:28 mm/kasan/report.c:170 mm/kasan/report.c:237)
>>> [  459.570997] __asan_report_load1_noabort (mm/kasan/report.c:277)
>>> [  459.572119] ? check_preemption_disabled (lib/smp_processor_id.c:39)
>>> [  459.573731] ? strlen (lib/string.c:481 (discriminator 1))
>>> [  459.574646] strlen (lib/string.c:481 (discriminator 1))
>>> [  459.575485] proc_dostring (kernel/sysctl.c:1825 kernel/sysctl.c:1906)
>>> [  459.576445] ? alloc_debug_processing (mm/slub.c:1054)
>>> [  459.577523] addrconf_sysctl_stable_secret (net/ipv6/addrconf.c:5395)
>>
>> Looks like we don't initialize the array on stack for write case.
>> At least other callers always initialize the data for both read
>> and write.
>>
>> Please try the attached patch.
> 
> Your patch is right. I am surprised you need to initialize the buffer
> passed down to proc_dostring so that strlen can correctly operate on it,
> but f4aacea2f5d1a5 ("sysctl: allow for strict write position handling")
> explains why. Can you submit formally?
> 
> Acked-by: Hannes Frederic Sowa <hannes@stressinduktion.org>

And that seems to fix the issue here as well.


Thanks,
Sasha
