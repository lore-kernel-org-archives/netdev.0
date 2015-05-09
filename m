From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH 3/6] net: Pass kern from net_proto_family.create to sk_alloc
Date: Sat, 09 May 2015 12:31:38 -0500
Message-ID: <878ucxverp.fsf@x220.int.ebiederm.org>
References: <1430988770-28907-1-git-send-email-ying.xue@windriver.com>
	<87wq0kcqlm.fsf@x220.int.ebiederm.org>
	<20150508140733.GA13325@gondor.apana.org.au>
	<87sib76kef.fsf@x220.int.ebiederm.org>
	<20150509011339.GA19116@gondor.apana.org.au>
	<87383633pu.fsf_-_@x220.int.ebiederm.org>
	<87ioc21oza.fsf_-_@x220.int.ebiederm.org>
	<1431190302.566.7.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: davem@davemloft.net, Ying Xue <ying.xue@windriver.com>,
	netdev@vger.kernel.org, cwang@twopensource.com, xemul@openvz.org,
	maxk@qti.qualcomm.com, stephen@networkplumber.org, tgraf@suug.ch,
	nicolas.dichtel@6wind.com, tom@herbertland.com,
	jchapman@katalix.com, erik.hugne@ericsson.com,
	jon.maloy@ericsson.com, horms@verge.net.au,
	Herbert Xu <herbert@gondor.apana.org.au>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out01.mta.xmission.com ([166.70.13.231]:44673 "EHLO
	out01.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750909AbbEIRgT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 9 May 2015 13:36:19 -0400
In-Reply-To: <1431190302.566.7.camel@edumazet-glaptop2.roam.corp.google.com>
	(Eric Dumazet's message of "Sat, 09 May 2015 09:51:42 -0700")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet <eric.dumazet@gmail.com> writes:

> On Fri, 2015-05-08 at 21:09 -0500, Eric W. Biederman wrote:
>> In preparation for changing how struct net is refcounted
>> on kernel sockets pass the knowledge that we are creating
>> a kernel socket from sock_create_kern through to sk_alloc.
>
> ...
>
>>  
>> diff --git a/drivers/net/tun.c b/drivers/net/tun.c
>> index 3262f3e2b8b2..1a1c4f7b3ec5 100644
>> --- a/drivers/net/tun.c
>> +++ b/drivers/net/tun.c
>> @@ -2148,7 +2148,7 @@ static int tun_chr_open(struct inode *inode, struct file * file)
>>  	DBG1(KERN_INFO, "tunX: tun_chr_open\n");
>>  
>>  	tfile = (struct tun_file *)sk_alloc(net, AF_UNSPEC, GFP_KERNEL,
>> -					    &tun_proto);
>> +					    &tun_proto, 0);
>>  	if (!tfile)
>>  		return -ENOMEM;
>>  	RCU_INIT_POINTER(tfile->tun, NULL);
> ...
>
>> index 3a4898ec8c67..d8dcf91732b0 100644
>> --- a/include/net/sock.h
>> +++ b/include/net/sock.h
>> @@ -1514,7 +1514,7 @@ static inline void unlock_sock_fast(struct sock *sk, bool slow)
>>  
>> 
>>  struct sock *sk_alloc(struct net *net, int family, gfp_t priority,
>> -		      struct proto *prot);
>> +		      struct proto *prot, int kern);
>
>
> Problem adding lot of parameters to functions, is that 0 (or false)
> means nothing when we read the code later and we have to go back to
> sk_alloc() definition to check.
>
> Sure, at the time you write the code everything is clear, but in 2 years
> we wont have the context in our heads.

Possibly.  In most cases what we are doing is passing the kern parameter
from net_proto_family.create (aka inet_create) to sk_alloc.   Which has
enough local context that unless you are debugging that particular
aspect of the code it should be fairly obviously locally what is
happening.  We are passing the parameter through to sk_alloc.

> I would use an enumeration to ease code readability maybe.
>
> enum sk_alloc_kern {
> 	SK_ALLOC_USER,
> 	SK_ALLOC_KERN,
> };

If you want to add such an enumeration to the entire call chain of
__sock_create, security_socket_create, security_post_socket_create,
net_proto_family.create and sk_alloc and the handful of protocol
specific helper functions in between feel free.

I can't think of an obviously better convention than what we are using
now, and I certainly can't think of an appropriate name.

In most cases it does not matter as this parameter is simply passed
through.

There are only a handful of places where a hard coded constant is used,
and I always used a 0 to ensure there would be no change in existing
behavior.  But I really don't think there are enough of them to matter.


For myself the main issue is fixing the mess that is creating kernel
sockets and how they deal with reference counting.  Being consistent
with existing conventions and not taking on more than I had to, to get
that done appears to be the best course.

Eric
