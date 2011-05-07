From: Ben Greear <greearb@candelatech.com>
Subject: Re: Scalability of interface creation and deletion
Date: Sat, 07 May 2011 09:23:13 -0700
Message-ID: <4DC571F1.2020108@candelatech.com>
References: <891B02256A0667292521A4BF@Ximines.local>	 <1304770926.2821.1157.camel@edumazet-laptop>	 <0F4A638C2A523577CDBC295E@Ximines.local> <1304783684.9216.2.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Alex Bligh <alex@alex.org.uk>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:38777 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755745Ab1EGQXZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 7 May 2011 12:23:25 -0400
In-Reply-To: <1304783684.9216.2.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/07/2011 08:54 AM, Eric Dumazet wrote:
> Le samedi 07 mai 2011 =C3=A0 16:26 +0100, Alex Bligh a =C3=A9crit :
>> Well, I patched it (patch attached for what it's worth) and it made
>> no difference in this case. I would suggest however that it might
>> be the right think to do anyway.
>>
>
> As I said, this code should not be entered in normal situations.
>
> You are not the first to suggest a change, but it wont help you at al=
l.
>
>
>
>
>> On the current 8 core box I am testing, I see 280ms per interface
>> delete **even with only 10 interfaces**. I see 260ms with one
>> interface. I know doing lots of rcu sync stuff can be slow, but
>> 260ms to remove one veth pair sounds like more than rcu sync going
>> on. It sounds like a sleep (though I may not have found the
>> right one). I see no CPU load.
>>
>> Equally, with one interface (remember I'm doing this in unshare -n
>> so there is only a loopback interface there), this bit surely
>> can't be sysfs.
>>
>
> synchronize_rcu() calls are not consuming cpu, they just _wait_
> rcu grace period.
>
> I suggest you read Documentation/RCU files if you really want to :)
>
> If you want to check how expensive it is, its quite easy:
> add a trace in synchronize_net()
>
> diff --git a/net/core/dev.c b/net/core/dev.c
> index 856b6ee..70f3c46 100644
> --- a/net/core/dev.c
> +++ b/net/core/dev.c
> @@ -5915,8 +5915,10 @@ EXPORT_SYMBOL(free_netdev);
>    */
>   void synchronize_net(void)
>   {
> +	pr_err("begin synchronize_net()\n");
>   	might_sleep();
>   	synchronize_rcu();
> +	pr_err("end synchronize_net()\n");
>   }
>   EXPORT_SYMBOL(synchronize_net);

I wonder if it would be worth having a 'delete me soon'
method to delete interfaces that would not block on the
RCU code.

The controlling programs could use netlink messages to
know exactly when an interface was truly gone.

That should allow some batching in the sync-net logic
too, if user-space code deletes 1000 interfaces very
quickly, for instance...

Thanks,
Ben

>
>
>
>
>
>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html


--=20
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
