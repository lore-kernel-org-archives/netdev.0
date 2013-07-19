From: "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>
Subject: Re: mod_timer: list_add corruption: WARNING: CPU: 1 PID: 0 at lib/list_debug.c:33
 __list_add+0xbe/0xd0()
Date: Sat, 20 Jul 2013 00:16:23 +0530
Message-ID: <51E9897F.5030205@linux.vnet.ibm.com>
References: <51E557C0.2060602@linux.vnet.ibm.com> <alpine.DEB.2.02.1307191323150.4089@ionos.tec.linutronix.de> <51E92769.7090106@linux.vnet.ibm.com> <alpine.DEB.2.02.1307191523050.4089@ionos.tec.linutronix.de> <1374241882.26476.5.camel@edumazet-glaptop> <alpine.DEB.2.02.1307191834460.4089@ionos.tec.linutronix.de> <1374254778.26476.18.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: Thomas Gleixner <tglx@linutronix.de>,
	Cong Wang <amwang@redhat.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Frederic Weisbecker <fweisbec@gmail.com>,
	Ingo Molnar <mingo@kernel.org>,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1374254778.26476.18.camel@edumazet-glaptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 07/19/2013 10:56 PM, Eric Dumazet wrote:
> On Fri, 2013-07-19 at 18:38 +0200, Thomas Gleixner wrote:
>> On Fri, 19 Jul 2013, Eric Dumazet wrote:
>>>
>>> I guess following should help 
>>
>> Applying the empty patch does not work very well. Could you try again
>> after the caffeine reached your brain, please ? :)
> 
> hmm, right ;)
> 

This patch fixes the issue for me - the system has been idle for more
than an hour now without any problems (earlier, i used to get the traces
within 5 minutes of idle time).

Thanks a lot for the fix!

Tested-by: Srivatsa S. Bhat <srivatsa.bhat@linux.vnet.ibm.com>

Regards,
Srivatsa S. Bhat

> diff --git a/net/bridge/br_multicast.c b/net/bridge/br_multicast.c
> index 69af490..4b99c9a 100644
> --- a/net/bridge/br_multicast.c
> +++ b/net/bridge/br_multicast.c
> @@ -619,6 +619,9 @@ rehash:
>  	mp->br = br;
>  	mp->addr = *group;
> 
> +	setup_timer(&mp->timer, br_multicast_group_expired,
> +		    (unsigned long)mp);
> +
>  	hlist_add_head_rcu(&mp->hlist[mdb->ver], &mdb->mhash[hash]);
>  	mdb->size++;
> 
> @@ -1126,7 +1129,6 @@ static int br_ip4_multicast_query(struct net_bridge *br,
>  	if (!mp)
>  		goto out;
> 
> -	setup_timer(&mp->timer, br_multicast_group_expired, (unsigned long)mp);
>  	mod_timer(&mp->timer, now + br->multicast_membership_interval);
>  	mp->timer_armed = true;
> 
> @@ -1204,7 +1206,6 @@ static int br_ip6_multicast_query(struct net_bridge *br,
>  	if (!mp)
>  		goto out;
> 
> -	setup_timer(&mp->timer, br_multicast_group_expired, (unsigned long)mp);
>  	mod_timer(&mp->timer, now + br->multicast_membership_interval);
>  	mp->timer_armed = true;
> 
