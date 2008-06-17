From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: netlink circular locking dependency
Date: Tue, 17 Jun 2008 08:49:36 +0000
Message-ID: <20080617084936.GA4202@ff.dom.local>
References: <20080616213417.GA14988@ami.dom.local> <4856DF91.30606@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Marcel Holtmann <marcel@holtmann.org>, netdev@vger.kernel.org,
	Ingo Molnar <mingo@elte.hu>, Thomas Graf <tgraf@suug.ch>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from an-out-0708.google.com ([209.85.132.250]:59555 "EHLO
	an-out-0708.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754078AbYFQIpX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Jun 2008 04:45:23 -0400
Received: by an-out-0708.google.com with SMTP id d40so1287228and.103
        for <netdev@vger.kernel.org>; Tue, 17 Jun 2008 01:45:22 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <4856DF91.30606@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jun 16, 2008 at 11:48:01PM +0200, Patrick McHardy wrote:
> Jarek Poplawski wrote:
>> Marcel Holtmann wrote, On 06/14/2008 02:35 PM:
>> ...
>>   
>>> =======================================================
>>> [ INFO: possible circular locking dependency detected ]
>>> 2.6.26-rc2 #5
>>> -------------------------------------------------------
>>> hcid/4136 is trying to acquire lock:
>>>  (genl_mutex){--..}, at: [<c0000000002ace4c>] .ctrl_dumpfamily+0x74/0x174
>>>
>>> but task is already holding lock:
>>>  (nlk->cb_mutex){--..}, at: [<c0000000002a766c>] .netlink_dump+0x58/0x27c
>>>
>>> which lock already depends on the new lock.
>>>     
>> ...
>>
>> Hi,
>>
>> IMHO it looks like a real lockup threat. Probably it needs something
>> better, but for now here is my simplistic patch proposal for testing.
>>   
> So we have:
>
> genl_rcv()            : take genl_mutex
> genl_rcv_msg()        : call netlink_dump_start() while holding genl_mutex
> netlink_dump_start(),
> netlink_dump()        : take nlk->cb_mutex
> ctrl_dumpfamily()     : try to detect this case and not take genl_mutex a
>                        second time
>
> netlink_rcv()         : call netlink_dump
> netlink_dump          : take nlk->cb_mutex
> ctrl_dumpfamily()     : take genl_mutex
>
> which is a real bug.

Right. Probably there is also another variant:

#1
genl_rcv()            : take genl_mutex
genl_rcv_msg()        : call netlink_dump_start() while holding genl_mutex
netlink_dump_start()  : mutex_unlock nlk->cb_mutex

#2
netlink_rcv()         : call netlink_dump
netlink_dump          : take nlk->cb_mutex
ctrl_dumpfamily()     : 1st run without genl_mutex

#1
netlink_dump()        : take nlk->cb_mutex
ctrl_dumpfamily()     : > 1st run: take genl_mutex 2nd time?!

>
> It seems the best fix is to use genl_mutex for the netlink cb_mutex,
> drop genl_mutex before calling netlink_dump_start and don't take it
> in ctrl_dumpfamily, relying completely on af_netlink.c for dump
> locking. Unfortunately this creates a race since the ops passed to
> netlink_dump_start are also protect by the mutex, so this patch
> is just for testing whether it fixes the warning.
>
> On second though - that race seems to be present already since
> the ops can be unregistered and the module unloaded while a dump
> is in progress.

Yes, very interesting. I guess there will be some followup...

Regards,
Jarek P.


> diff --git a/net/netlink/genetlink.c b/net/netlink/genetlink.c
> index f5aa23c..3e1191c 100644
> --- a/net/netlink/genetlink.c
> +++ b/net/netlink/genetlink.c
> @@ -444,8 +444,11 @@ static int genl_rcv_msg(struct sk_buff *skb, struct nlmsghdr *nlh)
>  		if (ops->dumpit == NULL)
>  			return -EOPNOTSUPP;
>  
> -		return netlink_dump_start(genl_sock, skb, nlh,
> -					  ops->dumpit, ops->done);
> +		genl_unlock();
> +		err = netlink_dump_start(genl_sock, skb, nlh,
> +					 ops->dumpit, ops->done);
> +		genl_lock();
> +		return err;
>  	}
>  
>  	if (ops->doit == NULL)
> @@ -603,9 +606,6 @@ static int ctrl_dumpfamily(struct sk_buff *skb, struct netlink_callback *cb)
>  	int chains_to_skip = cb->args[0];
>  	int fams_to_skip = cb->args[1];
>  
> -	if (chains_to_skip != 0)
> -		genl_lock();
> -
>  	for (i = 0; i < GENL_FAM_TAB_SIZE; i++) {
>  		if (i < chains_to_skip)
>  			continue;
> @@ -623,9 +623,6 @@ static int ctrl_dumpfamily(struct sk_buff *skb, struct netlink_callback *cb)
>  	}
>  
>  errout:
> -	if (chains_to_skip != 0)
> -		genl_unlock();
> -
>  	cb->args[0] = i;
>  	cb->args[1] = n;
>  
> @@ -770,7 +767,7 @@ static int __init genl_init(void)
>  
>  	/* we'll bump the group number right afterwards */
>  	genl_sock = netlink_kernel_create(&init_net, NETLINK_GENERIC, 0,
> -					  genl_rcv, NULL, THIS_MODULE);
> +					  genl_rcv, &genl_mutex, THIS_MODULE);
>  	if (genl_sock == NULL)
>  		panic("GENL: Cannot initialize generic netlink\n");
>  

