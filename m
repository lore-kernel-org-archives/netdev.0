From: Daniel Lezcano <dlezcano@fr.ibm.com>
Subject: Re: [Devel] [PATCH 1/5] net: Modify all rtnetlink methods to only
 work	in the initial namespace
Date: Wed, 10 Oct 2007 16:05:26 +0200
Message-ID: <470CDC26.6010608@fr.ibm.com>
References: <m1myv69tfu.fsf@ebiederm.dsl.xmission.com> <470CC6F6.60706@sw.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Eric W. Biederman" <ebiederm@xmission.com>,
	netdev@vger.kernel.org, Pavel Emelianov <xemul@sw.ru>,
	Linux Containers <containers@lists.osdl.org>,
	David Miller <davem@davemloft.net>
To: "Denis V. Lunev" <den@sw.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate7.de.ibm.com ([195.212.29.156]:62957 "EHLO
	mtagate7.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751857AbXJJOLs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Oct 2007 10:11:48 -0400
Received: from d12nrmr1607.megacenter.de.ibm.com (d12nrmr1607.megacenter.de.ibm.com [9.149.167.49])
	by mtagate7.de.ibm.com (8.13.8/8.13.8) with ESMTP id l9AEBlpa463698
	for <netdev@vger.kernel.org>; Wed, 10 Oct 2007 14:11:47 GMT
Received: from d12av02.megacenter.de.ibm.com (d12av02.megacenter.de.ibm.com [9.149.165.228])
	by d12nrmr1607.megacenter.de.ibm.com (8.13.8/8.13.8/NCO v8.5) with ESMTP id l9AEBlrQ2298070
	for <netdev@vger.kernel.org>; Wed, 10 Oct 2007 16:11:47 +0200
Received: from d12av02.megacenter.de.ibm.com (loopback [127.0.0.1])
	by d12av02.megacenter.de.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l9AEBkI0011288
	for <netdev@vger.kernel.org>; Wed, 10 Oct 2007 16:11:47 +0200
In-Reply-To: <470CC6F6.60706@sw.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Denis V. Lunev wrote:
> Eric W. Biederman wrote:
>> Before I can enable rtnetlink to work in all network namespaces
>> I need to be certain that something won't break.  So this
>> patch deliberately disables all of the rtnletlink methods in everything
>> except the initial network namespace.  After the methods have been
>> audited this extra check can be disabled.
>>
> [...]
>>  static int br_dump_ifinfo(struct sk_buff *skb, struct netlink_callback *cb)
>>  {
>> +	struct net *net = skb->sk->sk_net;
>>  	struct net_device *dev;
>>  	int idx;
>>  
> 
> I've read some code today greping 'init_net.loopback_dev' and found
> interesting non-trivial for me issue.
> 
> Network namespace is extracted from the packet in two different ways in
> TCP. This is a socket for outgoing path and a device for incoming.
> Though, there are some places called uniformly both from incoming and
> outgoing path.
> 
> Typical example is netfilters. They are called uniformly all around the
> code. The prototype is the following:
> 
> static unsigned int reject6_target(struct sk_buff **pskb,
>                            const struct net_device *in,
>                            const struct net_device *out,
>                            unsigned int hooknum,
>                            const struct xt_target *target,
>                            const void *targinfo);
> 

Thanks Denis for auditing the code.

As far as I see, struct net_device *in is NULL for outgoing traffic and 
struct net_device *out is NULL for ingress traffic. Except for the 
FORWARD rules where both are filled. If we are following network 
namespace semantic, we should not have two network devices belonging to 
two differents namespaces, right ?
In this case, the following line of code should be sufficient to 
retrieve the network namespace, no ?

struct net *net = in?in->nd_net:out->nd_net;

> So, we are bound to the following options:
> - perform additional non-uniform hacks around to place 'struct net' into
>   other and other structures like xt_target
> - add 7th parameter here and over
> - introduce an skb_net field in the 'struct sk_buff' making all code
>   uniform, at least when we have an skb
> 
> I think that this is not the last place with such a parameter list and
> we should make a decision at this point when the code in not mainline yet.
> 
> As far as I understand, netfilters are not touched by the Eric and we
> can face some non-trivial problems there.

In Eric's git tree:
http://git.kernel.org/?p=linux/kernel/git/ebiederm/linux-2.6-netns.git

There are some modifications concerning 
net/ipv4/netfiler/iptable_filter.c and at the ipt_hook function, there is:

struct net *net = (in?in:out)->nd_net;

> So, if my point about uniformity is valid, this patchset looks wrong and
> should be re-worked :(

As Eric said, we want to build the network namespace step by step, 
taking care of not breaking the init network namespace.

If you want to make iptables per namespace or catch problems before the 
code goes to Dave's tree, IMHO it will be more convenient to post to 
containers@ the patches against netns49, where the modifications will be 
in a network namespace big picture.

Regards.

   -- Daniel

