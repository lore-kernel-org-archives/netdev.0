From: Denys Fedoryshchenko <nuclearcat@nuclearcat.com>
Subject: Re: nft 2.0, NULL pointer dereference in 3.14.1
Date: Sun, 04 May 2014 20:32:53 +0300
Message-ID: <7d7f07a02290042f1b4fc4eec7c94b02@visp.net.lb>
References: <52ee4b86089383eb7ae8d2bed17e6f8b@visp.net.lb>
 <3a97c044d7e99dc4bd3d6b8d36d79a01@visp.net.lb>
 <20140504113357.GA3953@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
 format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kaber@trash.net, kadlec@blackhole.kfki.hu
To: Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hosting.visp.net.lb ([194.146.153.11]:51585 "EHLO
	hosting.visp.net.lb" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752701AbaEDRc4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 4 May 2014 13:32:56 -0400
Received: from hosting.visp.net.lb (localhost [127.0.0.1])
	by hosting.visp.net.lb (Postfix) with ESMTP id 629CB4808C2
	for <netdev@vger.kernel.org>; Sun,  4 May 2014 20:32:54 +0300 (EEST)
In-Reply-To: <20140504113357.GA3953@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi

Thanks, understood about RFC and Signed-off-by. Next time will do that.
I was not sure i have correct idea what is happening in code, so maybe 
patch was totally incorrect.

On 2014-05-04 14:33, Pablo Neira Ayuso wrote:
> On Sun, May 04, 2014 at 10:25:58AM +0300, Denys Fedoryshchenko wrote:
>> Hi
>> 
>> I bit more debugging and found that problem is happening at:
>> 
>> >sock = netlink_lookup(sock_net(ssk), ssk->sk_protocol, portid);
>> 
>> ssk is NULL
>> 
>> After checking, i noticed in nfnetlink.c
>> nfnetlink_rcv_batch() function
>> 
>> We have
>> nskb->sk = oskb->sk;
>> skb = nskb;
>> 
>> I am matching condition
>> ss = rcu_dereference_protected(table[subsys_id].subsys,
>>        lockdep_is_held(&table[subsys_id].mutex));
>> if (!ss) {
>> 
>> And then
>> nfnl_unlock(subsys_id);
>> kfree_skb(nskb);
>> return netlink_ack(skb, nlh, -EOPNOTSUPP);
>> 
>> If i am not wrong, nskb same pointer as skb, so we are giving
>> netlink_ack freed pointer?
>> Is it "use after free()" ?
> 
> Right, this is an embarrasing use after free when no nf_tables support
> has been selected / modules are not available.
> 
>> If yes, then it seems attached patch fixing my issue. Please let me
>> know, if it is ok and i should submit it.
> 
> I'm going to take this, but please next time use git format-patch and
> include your Signed-off-by tag. If you feel the patch is not complete
> in some aspect or that you may be missing anything, just include the
> RFC tag in the subject.
> 
> Thanks Denys!
