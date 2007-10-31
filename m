From: Daniel Lezcano <dlezcano@fr.ibm.com>
Subject: Re: [PATCH 0/5] Make nicer CONFIG_NET_NS=n case code
Date: Wed, 31 Oct 2007 22:35:51 +0100
Message-ID: <4728F537.40407@fr.ibm.com>
References: <4728D54F.2080208@openvz.org> <20071031194924.2436843e.dada1@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Pavel Emelyanov <xemul@openvz.org>,
	David Miller <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>,
	"Eric W. Biederman" <ebiederm@xmission.com>, devel@openvz.org
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate4.uk.ibm.com ([195.212.29.137]:11779 "EHLO
	mtagate4.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753518AbXJaVi4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 31 Oct 2007 17:38:56 -0400
Received: from d06nrmr1407.portsmouth.uk.ibm.com (d06nrmr1407.portsmouth.uk.ibm.com [9.149.38.185])
	by mtagate4.uk.ibm.com (8.13.8/8.13.8) with ESMTP id l9VLcrbB140922
	for <netdev@vger.kernel.org>; Wed, 31 Oct 2007 21:38:54 GMT
Received: from d06av04.portsmouth.uk.ibm.com (d06av04.portsmouth.uk.ibm.com [9.149.37.216])
	by d06nrmr1407.portsmouth.uk.ibm.com (8.13.8/8.13.8/NCO v8.5) with ESMTP id l9VLcr2F2957384
	for <netdev@vger.kernel.org>; Wed, 31 Oct 2007 21:38:53 GMT
Received: from d06av04.portsmouth.uk.ibm.com (loopback [127.0.0.1])
	by d06av04.portsmouth.uk.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l9VLcaab002990
	for <netdev@vger.kernel.org>; Wed, 31 Oct 2007 21:38:37 GMT
In-Reply-To: <20071031194924.2436843e.dada1@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Eric Dumazet wrote:
> On Wed, 31 Oct 2007 22:19:43 +0300
> Pavel Emelyanov <xemul@openvz.org> wrote:
> 
>> Currently we have the NET_NS config option, but the only change it 
>> makes is just return ERR_PTR(-EINVAL) inside the cloning call thus
>> introducing a bunch of a dead code and making the reference counting
>> unneeded. This is not very good.
>>
>> So clean the net_namespace.c to fix this.
>>
>> I have sent a set of patches to Andrew to make similar thing for
>> other namespaces, which introduces the NAMESPACES option to turn
>> all the namespaces off at once (to make embedded people suffer
>> less). So after that stuff is in, there will be some more patches 
>> to tie all this together.
>>
>> What is to be done after this set is to make the register_pernet_xxx
>> stuff smaller. Currently this code weights approximately 500 bytes, 
>> so it worths reducing it, but I haven't found a good solution yet.
> 
> Definitly wanted here. Thank you.
> One more refcounting on each socket creation/deletion was expensive.
> 
> Maybe we can add a macro to get nd_net from a "struct net_device"
> so that every instance of
> 
> if (dev->nd_net != &init_net)
>     goto drop;
> 
> can also be optimized away if !CONFIG_NET_NS
> 
> extern inline netdev_get_ns(struct netdevice *dev)
> {
> #ifdef CONFIG_NET_NS
> 	return dev->nd_net;
> #else
> 	return &init_net;
> #endif
> }

Or something like:

#ifdef CONFIG_NET_NS
static inline int init_net_dev(struct net_device *dev)
{
	return dev->nd_net == &init_net;
}
#else
static inline int init_net_dev(struct net_device *dev)
{
	return 1;
}
#endif


By the way, this kind of test will disappear when the network namespace 
will be complete and take into account the differents protocols.
