From: Wang Weidong <wangweidong1@huawei.com>
Subject: Re: [PATCH 0/2] sctp: fix a problem with net_namespace
Date: Mon, 10 Feb 2014 10:56:51 +0800
Message-ID: <52F83FF3.6010307@huawei.com>
References: <1390794543-1008-1-git-send-email-wangweidong1@huawei.com> <20140127114904.GA17143@hmsreliant.think-freely.org> <52E766B8.3090406@huawei.com> <20140128115757.GA5002@hmsreliant.think-freely.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: <davem@davemloft.net>, <vyasevich@gmail.com>,
	<dborkman@redhat.com>, <netdev@vger.kernel.org>
To: Neil Horman <nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga01-in.huawei.com ([119.145.14.64]:41200 "EHLO
	szxga01-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752271AbaBJC5u (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 9 Feb 2014 21:57:50 -0500
In-Reply-To: <20140128115757.GA5002@hmsreliant.think-freely.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2014/1/28 19:57, Neil Horman wrote:
> On Tue, Jan 28, 2014 at 04:13:44PM +0800, Wang Weidong wrote:
>> On 2014/1/27 19:49, Neil Horman wrote:
>>> On Mon, Jan 27, 2014 at 11:49:01AM +0800, Wang Weidong wrote:
>>>> fix a problem with net_namespace, and optimize
>>>> the sctp_sysctl_net_register.
>>>>
>>>> Wang Weidong (2):
>>>>   sctp: fix a missed .data initialization
>>>>   sctp: optimize the sctp_sysctl_net_register
>>>>
>>>>  net/sctp/sysctl.c | 17 ++++++++++-------
>>>>  1 file changed, 10 insertions(+), 7 deletions(-)
>>>>
>>>> -- 
>>>> 1.7.12
>>>>
>>>>
>>>>
>>> I don't see that either of these patches are needed.  In sctp_init_net, the
>>> sctp_hmac_alg pointer gets initalized before calling sctp_sysctl_net_register,
>>> and sctp_proc_do_hmac_alg is written to specifically expect NULL values, so this
>>> code may change behavior regarding default cookie selection.
>>>
>> Hi Neil,
>>
>> Here, I think the sctp_proc_do_hmac_alg will be called only when we change the 
>> /proc/sys/net/cookie_hmac_alg. So add the .data won't effect the default value.
>> and the data isn't equal to the "cookie_hmac_alg"?
>>
>>> This was coded so that poniters to entires in the string table could be used,
>>> rather than needing to allocate or maintain character buffers.  That said, it
>>> does look like that for loop in sctp_sysctl_register_table might compute an odd
>>> offset when cloning the table.  I think the right fix for that is likely to just
>>> move the sysctl value initalization in sctp_init_net to below the sysctl
>>> register function.
>>>
>>> Neil
>>>
>>
>> I found the problem is that:
>> I use "ip netns add netns1/netns2"
>> In any netns(netns1 or netns2 or init_net) when I change the value of the entry
>> such as "addip_enable" "max_autoclose" which after the cookie_hmac_alg (contain it),
>> and the other netns will be effected.
>>
>> In sctp_sysctl_net_register, kmemdup does cloning the table. The offset of netns1 and
>> init_net's clt_table.data is the same as two netns offset. So the for(){...} would do
>> add the offset for every clt_table.data.
>>
>> The code:
>> 	for (i = 0; table[i].data; i++)
>> 		table[i].data += (char *)(&net->sctp) - (char *)&init_net.sctp;
>>
>> And I add a pr_info into the for(){...} in sctp_sysctl_net_register and only print 7 times for each ns.
>> 7 is the index of "cookie_preserve_enable" which before the "cookie_hmac_alg". 
>>
>> As the "cookie_hmac_alg" data is NULL, so we can't add offset to the rest, and all the netns use the same
>> address of clt_table entry after the "cookie_hmac_alg".
>>
>> So I think only "move the sysctl value initalization in sctp_init_net to below the sysctl
>> register function" won't solve the problem, because the problem is at the for() {...}.
>>
> I'm sorry, you're right, the kmemdup duplicates the table, not the structure in
> which the table points to with its .data pointers.  I was looking at it
> backwards.
> 

Hi Neil,

Should I resend "sctp: fix a problem with net_namespace" series again?

>> Is there something wrong?
>>
>> The next patch is that, the sctp_net_table is for init_net, So when load the sctp module, we needn't
>> to do the cloning tables for init_net again. And I found the ipv4 do it in the same way.
>>
>> I have a doubt : how can I rmmod the sctp? only add '-f' ? If I do "rmmod -f sctp", I will get the
>> log by dmesg: "Disabling lock debugging due to kernel taint"
>>
> I don't know, sounds like a bug, check the log to see what tainted the kernel
> during removal.
> 

Here, after removal, got "Disabling lock debugging due to kernel taint", it would effect the lockdep.
When load the sctp modules, Use "cat /proc/net/sctp/sctp_dbg_objcnt", we will create a socket and ep.
So the sctp is in use.I am not sure is there any way to kill the socket and ep.

Regards
Wang

> Regards
> Neil
> 
>> Regards,
>> Wang
>>
>>
>>>
>>>
>>
>>
>>
> 
> .
> 
