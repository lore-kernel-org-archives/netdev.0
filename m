From: Alexey Perevalov <a.perevalov@samsung.com>
Subject: Re: [RFC PATCH v3] cgroup: net_cls: traffic counter based on
 classification control cgroup
Date: Mon, 14 Jan 2013 15:25:36 +0400
Message-ID: <50F3EB30.1020506@samsung.com>
References: <50F04502.9090902@samsung.com> <50F3BD26.6090903@monom.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: cgroups@vger.kernel.org, Glauber Costa <glommer@parallels.com>,
	Kyungmin Park <kyungmin.park@samsung.com>,
	netdev@vger.kernel.org
To: Daniel Wagner <wagi@monom.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailout3.w1.samsung.com ([210.118.77.13]:58510 "EHLO
	mailout3.w1.samsung.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756212Ab3ANLZk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Jan 2013 06:25:40 -0500
In-reply-to: <50F3BD26.6090903@monom.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Daniel,

On 01/14/2013 12:09 PM, Daniel Wagner wrote:
> Hi Alexey,
>
> On 11.01.2013 17:59, Alexey Perevalov wrote:
>> I'm sorry for previous email with attachments.
>
> It seems something went wrong with the patch, e.g. indention is wrong 
> and also I see '^M$' line endings. I assume you are sending your 
> patches through an exchange server which is likely not to work.
Your right I'm behind MS Exchange server. I'll find the way to send 
normal patch without modification. Can you accept attachments?
>
>> I would like to represent next version of patch I sent before
>> cgroup: "net_cls: traffic counter based on classification control 
>> cgroup"
>>
>> The main idea is the same as was. It keeping counter in control groups,
>> but now uses atomic instead resource_counters.
>
> +#if IS_ENABLED(CONFIG_NET_CLS_COUNTER)
> + if (copied > 0)
> + count_cls_rcv(current, copied, ifindex);
> +#endif
> +
> release_sock(sk);
> return copied;
>
> Normally, distros will enable most config flags. Maybe you could use
> a jump label to reduce the cost for the users which have 
> CONFIG_NET_CLS_COUNTER enabled and do not use it?
Do your mean one big macro instead of #if #endif. I don't like #if 
#endif in this place too. For example skb_update_prio implemented in 
such way.
Or your mean function callback which will be invoked in case of net_cls 
loaded? This variant is more flexible. I agree.
>
>> I have a performance measurement for this patch. It was done by lmbench
>> on physical machine.
>> Results are not so representative for 20 tests and some numbers are real
>> weird.
>
> Could you explain in the commit message how your patch is designed? I 
> see you are using a RB tree. What's the purpose of it?
The main purpose - it's ability to count network traffic per 
application, application groups and application threads. Without huge 
overhead in user space. Also keep information about involved network 
interface.
For example:
ChatOn application
     consumed 100Mb on netinterface0 and 10Mb on netinterface1.

Why it wasn't done on the netfilter layer. Because of patent threat and 
big overhead for resolving incoming traffic. At the netfilter layer we 
know only source address, and destination address/port. And we need to 
make huge work to know to whom it addressed, even we use assumption like 
this, destination address for incoming is the same as source address for 
outgoing, but it true only for TCP.

In this patch I used already prepared buffer (size of buffer) which 
ready in tcp_recvmsg, tcp_read_sock,... functions. For outgoing traffic 
I count on the post routing (network interface already defined). But 
before netprio changing priority, I didn't test such case.
And here on the post routing in dev_queue_xmit there is no valid current 
thread. To find appropriate cgroup by classid and increase counter in it 
I use RB tree.

>
>> Daniel Wagner wrote what he is doing something similar, but using
>> namespaces.
>
> I am trying a different approach on this problem using iptables. I am 
> playing around with a few patches which allow to install a iptables rule
> which matches on the security context, e.g.
>
> iptables -t mangle -A OUTPUT -m secmark --secctx \
> unconfined_u:unconfined_r:foo_t:s0-s0:c0.c1023 -j MARK --set-mark 1
>
> So far it looks promising, but as I me previous networking experience 
> is, that something will not work eventually.
>
>> Proposed by me approach is used in upcoming Tizen release, but little
>> bit different version.
>
> Thanks,
> Daniel
>
>
BR,
Alexey Perevalov
