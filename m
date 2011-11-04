From: David Decotigny <david.decotigny@google.com>
Subject: Re: [PATCH net v2 6/8] forcedeth: Fix a race during rmmod of forcedeth
Date: Fri, 4 Nov 2011 10:22:40 -0700
Message-ID: <CAG88wWZdRZnm8QtuhWtkc0dQprDK=7+8NifvUYYtOfQE9KKBVA@mail.gmail.com>
References: <cover.1320369398.git.david.decotigny@google.com>
 <267015997eb594f2fd859acd572aa20dfc3e3e63.1320369398.git.david.decotigny@google.com>
 <1320378386.3079.56.camel@deadeye>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	Ian Campbell <ian.campbell@citrix.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Jiri Pirko <jpirko@redhat.com>, Joe Perches <joe@perches.com>,
	Szymon Janc <szymon@janc.net.pl>,
	Salman Qazi <sqazi@google.com>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1320378386.3079.56.camel@deadeye>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Ben,

Thank you for your comments. I understand this patch needs more work.
So I am going to remove it from this series for now and work on it in
isolation.

Regards,

On Thu, Nov 3, 2011 at 8:46 PM, Ben Hutchings <bhutchings@solarflare.co=
m> wrote:
> On Thu, 2011-11-03 at 18:41 -0700, David Decotigny wrote:
>> From: Salman Qazi <sqazi@google.com>
>>
>> The race was between del_timer_sync and nv_do_stats_poll called thro=
ugh
>> nv_get_ethtool_stats.
>
> I don't think so. =A0nv_close() and nv_get_ethtool_stats() are both c=
alled
> with RTNL held.
>
> Calling the timer function from nv_get_ethtool_stats is very likely p=
art
> of the problem though, so why don't you stop doing that?
>
> [...]
>> diff --git a/drivers/net/ethernet/nvidia/forcedeth.c b/drivers/net/e=
thernet/nvidia/forcedeth.c
>> index 0af12a8..7996782 100644
>> --- a/drivers/net/ethernet/nvidia/forcedeth.c
>> +++ b/drivers/net/ethernet/nvidia/forcedeth.c
>> @@ -3937,6 +3937,10 @@ static void nv_poll_controller(struct net_dev=
ice *dev)
>> =A0}
>> =A0#endif
>>
>> +/* No locking is needed as long as this is in the timer
>> + * callback. =A0However, any other callers must call this
>> + * function with np->lock held.
>> + */
>
> So long as this function is used by all of (1) the timer function (2)
> the ndo_get_stats implementation (3) the ethtool get_stats
> implementation, it can most certainly be called concurrently on multi=
ple
> processors.
>
> You could have (2) and (3) return the last polled stats and not poll =
the
> hardware themselves, but you would need to use the functions from
> <linux/u64_stats_sync.h> to avoid word-tearing on 32-bit architecture=
s.
>
>> =A0static void nv_do_stats_poll(unsigned long data)
>> =A0{
>> =A0 =A0 =A0 =A0 struct net_device *dev =3D (struct net_device *) dat=
a;
>> @@ -4589,12 +4593,17 @@ static int nv_get_sset_count(struct net_devi=
ce *dev, int sset)
>>
>> =A0static void nv_get_ethtool_stats(struct net_device *dev, struct e=
thtool_stats *estats, u64 *buffer)
>> =A0{
>> + =A0 =A0 =A0 unsigned long flags;
>> =A0 =A0 =A0 =A0 struct fe_priv *np =3D netdev_priv(dev);
>>
>> + =A0 =A0 =A0 spin_lock_irqsave(&np->lock, flags);
>> +
>> =A0 =A0 =A0 =A0 /* update stats */
>> =A0 =A0 =A0 =A0 nv_do_stats_poll((unsigned long)dev);
>>
>> =A0 =A0 =A0 =A0 memcpy(buffer, &np->estats, nv_get_sset_count(dev, E=
TH_SS_STATS)*sizeof(u64));
>> +
>> + =A0 =A0 =A0 spin_unlock_irqrestore(&np->lock, flags);
>
> This function is not called from interrupt context.
>
>> =A0}
>>
>> =A0static int nv_link_test(struct net_device *dev)
>> @@ -5189,13 +5198,13 @@ static int nv_close(struct net_device *dev)
>>
>> =A0 =A0 =A0 =A0 spin_lock_irq(&np->lock);
>> =A0 =A0 =A0 =A0 np->in_shutdown =3D 1;
>> + =A0 =A0 =A0 del_timer_sync(&np->stats_poll);
>> =A0 =A0 =A0 =A0 spin_unlock_irq(&np->lock);
>> =A0 =A0 =A0 =A0 nv_napi_disable(dev);
>> =A0 =A0 =A0 =A0 synchronize_irq(np->pci_dev->irq);
>>
>> =A0 =A0 =A0 =A0 del_timer_sync(&np->oom_kick);
>> =A0 =A0 =A0 =A0 del_timer_sync(&np->nic_poll);
>> - =A0 =A0 =A0 del_timer_sync(&np->stats_poll);
>>
>> =A0 =A0 =A0 =A0 netif_stop_queue(dev);
>> =A0 =A0 =A0 =A0 spin_lock_irq(&np->lock);
>
> I don't believe this code movement is helpful.
>
> Ben.
>
> --
> Ben Hutchings, Staff Engineer, Solarflare
> Not speaking for my employer; that's the marketing department's job.
> They asked us to note that Solarflare product names are trademarked.
>
>
