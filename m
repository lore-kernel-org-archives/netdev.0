From: Jamal Hadi Salim <hadi@cyberus.ca>
Subject: Re: [PATCH 2/3] [VLAN]: Update iif when receiving via VLAN device
Date: Sat, 08 Jul 2006 10:14:35 -0400
Message-ID: <1152368076.5272.39.camel@jzny2>
References: <1151697554.5270.241.camel@jzny2>
	 <20060630203034.GN14627@postel.suug.ch>
	 <20060630.133348.68039806.davem@davemloft.net>
	 <1151700884.5270.278.camel@jzny2> <20060630211043.GO14627@postel.suug.ch>
	 <1151703097.5270.307.camel@jzny2> <20060630234512.GR14627@postel.suug.ch>
	 <1151722785.5093.51.camel@jzny2> <20060701112833.GS14627@postel.suug.ch>
	 <1151760901.5093.141.camel@jzny2>  <20060708105451.GG14627@postel.suug.ch>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: kaber@trash.net, netdev@vger.kernel.org,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx02.cybersurf.com ([209.197.145.105]:1175 "EHLO
	mx02.cybersurf.com") by vger.kernel.org with ESMTP id S964844AbWGHOOj
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 8 Jul 2006 10:14:39 -0400
Received: from mail.cyberus.ca ([209.197.145.21])
	by mx02.cybersurf.com with esmtp (Exim 4.30)
	id 1FzDZy-0000I0-27
	for netdev@vger.kernel.org; Sat, 08 Jul 2006 10:14:42 -0400
To: Thomas Graf <tgraf@suug.ch>
In-Reply-To: <20060708105451.GG14627@postel.suug.ch>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, 2006-08-07 at 12:54 +0200, Thomas Graf wrote:
> * jamal <hadi@cyberus.ca> 2006-07-01 09:35


> It's pretty clear actually, given eth0->ifb0->ifb1 it would look
> like:
> 
> dev_queue_xmit(eth0)
>   tcf_mirred -> ifb0
> dev_queue_xmit(ifb0)
>   tcf_mirred -> ifb1
> dev_queue_xmit(ifb1)
>   ifb_xmit(ifb1)
>   <QUEUE> /* Here we queue the packet for the first time and
>              release the stack of tx locks acquired on the
> 	     way. TC_FROM was never reset up here so this can't
> 	     possibly prevent any tx deadlocks. However, the
> 	     !from check is effective later on ... */
>   ri_tasklet(ifb1)
> dev_queue_xmit(ifb0)
>   ifb_xmit(ifb0) /* classification disabled */
>     /* Drop due to !from with input_dev = ifb1 which is
>        good as it prevents to loop the packet back to
>        ifb1 again which I refered to earlier */
> 
> Is this how it was intented?
> 

yes, indeed. This is one class pathalogical case that was/will be caught
by testing; hence the speacial casing. IOW, this will have a "break"
because of the queue. 
There are other such as loop to self (nasty for say egress eth0->eth0),
which i proposed that Herberts qdisc_is_running patch may resolve (I
need to test).

> I tried to stay out of A->B->A for now since that's currently
> broken due to mirred unless the deadlock is intentional, f.e.
> when setting up eth0->ifb0->eth0 like this:
>
> ip link set ifb0 up
> tc qdisc add dev ifb0 parent root handle 1: prio
> tc qdisc add dev eth0 parent root handle 1: prio
> tc filter add dev eth0 parent 1: protocol ip prio 10 u32
>           match ip protocol 1 0xff flowid 1:1
> 	  action mirred egress redirect dev ifb0
> tc filter add dev ifb0 parent 1: protocol ip prio 10 u32
>           match ip protocol 1 0xff flowid 1:1
> 	  action mirred egress redirect dev eth0
> 

I dont know if i tested for the above specific setup. I have to look at
my testcases when i get the opportunity.
The problem is:
There is no easy way to detect such a deadlock. I think it reduces to
the same case as eth0->eth0, i.e:

tc qdisc add dev eth0 root handle 1: prio
tc filter add dev eth0 parent 1: protocol ip prio 10 u32 \
match u32 0 0 flowid 1:1 \
action mirred egress redirect dev eth0


I have a dated  patch to mirred (may not apply cleanly) that i believe
will fix this specific one. Try to see if it also fixes this case you
have.
I do not want to submit this patch because i have a feeling there is a
lot more sophisticated way to do this. I would like to test Herberts
changes first. If you have time maybe you can try Daves 2.6.18 tree.


> This is assuming that no tx deadlock happens of course. I
> did try this out just to make sure, the machine just hung.
> I can't see any code trying to prevent this but this is
> another discussion as ifb is not involved in this, I think
> it's purely a problem of mirred.

Its the second pathological case tx deadlock essentially and mirred
could help - it is not the mirred lock really if the attached patch
fixes it, but i could be wrong.

cheers,
jamal

PS:- My responses will have some latency due to accessibility

