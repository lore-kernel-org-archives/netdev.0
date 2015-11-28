From: wangyufen <wangyufen@huawei.com>
Subject: Re: Issue with /proc/sys/net/ipv4/tcp_mem
Date: Sat, 28 Nov 2015 16:13:08 +0800
Message-ID: <56596214.5050003@huawei.com>
References: <561B7F98.1040809@huawei.com>
 <87io6coxg1.fsf@x220.int.ebiederm.org>
 <1444700679.21657.11.camel@edumazet-glaptop2.roam.corp.google.com>
 <87twpvmk57.fsf@x220.int.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, Hanjun Guo <guohanjun@huawei.com>,
	Dingtianhong <dingtianhong@huawei.com>,
	Dianfang Zhang <zhangdianfang@huawei.com>,
	Xinwei Hu <huxinwei@huawei.com>
To: "Eric W. Biederman" <ebiederm@xmission.com>,
	Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga01-in.huawei.com ([58.251.152.64]:45989 "EHLO
	szxga01-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750743AbbK1INq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 28 Nov 2015 03:13:46 -0500
In-Reply-To: <87twpvmk57.fsf@x220.int.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2015/10/13 13:07, Eric W. Biederman wrote:
> Eric Dumazet <eric.dumazet@gmail.com> writes:
> 
>> On Mon, 2015-10-12 at 11:37 -0500, Eric W. Biederman wrote:
>>> wangyufen <wangyufen@huawei.com> writes:
>>>
>>>> Hi,
>>>>
>>>> I tried on linux-4.1:
>>>>     linux:~# cat /proc/sys/net/ipv4/tcp_mem 
>>>>     8388608	12582912	16777216
>>>>     linux:~# echo 1234 >/proc/sys/net/ipv4/tcp_mem 
>>>>     -bash: echo: write error: Invalid argument
>>>>     linux:~# cat /proc/sys/net/ipv4/tcp_mem 
>>>>     1234	12582912	16777216
>>>>
>>>> the echo operation got error, but value already written to tcp_mem.
>>>>
>>>> I checked, patch f594d63199688ad568fb caused the issue.
>>>
>>>
>>> If your problem is that you can not write a single value and instead
>>> have to write all three values I don't know what to tell you.  I don't
>>> see how that could have ever worked.
>>>
>>> Certainly the commit you pointed at did not change that behavior.
>>
>> I would not be so sure.
>> Above commit added a regression for partial writes.
>> If a write() returns an error like EINVAL, we expect no change occurred.
>>
>> Prior code was calling proc_doulongvec_minmax() using a temporary array,
>> and updated tcp_mem[0 .. 2] only of proc_doulongvec_minmax() returned 0
>>
>>        ret = proc_doulongvec_minmax(&tmp, write, buffer, lenp, ppos);
>>        if (ret)
>>                return ret;
>> #ifdef CONFIG_MEMCG_KMEM
>> 	// deleted for clarity
>> #endif
>>
>>        net->ipv4.sysctl_tcp_mem[0] = vec[0];
>>        net->ipv4.sysctl_tcp_mem[1] = vec[1];
>>        net->ipv4.sysctl_tcp_mem[2] = vec[2];
>>
>>        return 0;
>>
>> We could argue it is a bug in proc_doulongvec_minmax().
>> This helper probably should allocate a temp buffer,
>> as we have the same issue with udp_mem[].
> 
> Point.  We do store the value on partial writes when before we did not.
> 
> That is weird.  Clearly someone noticed.  I agree this is a confusing
> corner case in proc_doulongvec_minmax that it may be worth addressing.
> 

I think maybe we can fix the confusing corner with that patch:

---
 kernel/sysctl.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/kernel/sysctl.c b/kernel/sysctl.c
index c3eee4c..e3ee4be 100644
--- a/kernel/sysctl.c
+++ b/kernel/sysctl.c
@@ -2318,6 +2318,8 @@ static int __do_proc_doulongvec_minmax(void *data, struct ctl_table *table, int
                        bool neg;

                        left -= proc_skip_spaces(&kbuf);
+                        if (!left)
+                                break;

                        err = proc_get_long(&kbuf, &left, &val, &neg,
                                             proc_wspace_sep,
-- 
2.5.0

~         

The patch makes __do_proc_doulongvec_minmax works the same as __do_proc_dointvec, 
but I'm not sure this change will not break something.

thanks,
Wang 

> Does this cause a regression in a real application?   I definitely would
> like to know what in the world a real application is doing that causes
> it to break with this difference in behavior before doing anything,
> because I am dense enough not to see how an application could
> meaningfully care about this difference in behavior.
> 
> Eric
> 
> 
> 
