From: Florian Fainelli <f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: changing dev->needed_headroom/needed_tailroom?
Date: Tue, 20 Aug 2013 11:00:18 +0100
Message-ID: <CAGVrzcaGV6AqLTAxpM6zMv7_C-LNxp-WNg+J47d7a9S+Ca1bDw@mail.gmail.com>
References: <1374850210.8248.59.camel@jlt4.sipsolutions.net>
 <1375433758.24371.20.camel@deadeye.wl.decadent.org.uk> <1375449082.3927.5.camel@edumazet-glaptop>
 <1375711240.8120.11.camel@jlt4.sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Ben Hutchings <bhutchings-s/n/eUQHGBpZroRs9YW3xA@public.gmane.org>,
	netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1375711240.8120.11.camel-8Nb76shvtaUJvtFkdXX2HixXY32XiHfO@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

2013/8/5 Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>:
> On Fri, 2013-08-02 at 06:11 -0700, Eric Dumazet wrote:
>> On Fri, 2013-08-02 at 10:55 +0200, Ben Hutchings wrote:
>>
>> > I don't think this is safe when the interface is running (even if
>> > carrier is off).  Some functions may read dev->needed_headroom twice and
>> > rely on getting the same value each time.
>>
>> It should be no problem. Remaining unsafe places should be fixed.
>
> Most interesting would be stack devs, which I hadn't even considered. In
> any case, since I can't completely _rely_ on it, it's an optimisation,
> the only bugs would be around the double-access and then running
> over/under the SKB or so?

As far as I could test this with an Ethernet driver which adjusted its
needed_headroom by 64 bytes whenever some hardware feature was
enabled/disabled, this expectedly broke bridge and vlans at least.
Bridge code does not use the slave ports needed_headroom values, and
VLAN devices get the parent device needed_headroom only when creating
the vlan device. The good thing is since the needed_headroom space you
need is most likely fixed for a given configuration type, you should
see a pretty "stable" corruption of your SKB head.

>
>> We already had this discussion in the past, and some patches were
>> issued. Check commit ae641949df01b85117845bec45328eab6d6fada1
>> ("net: Remove all uses of LL_ALLOCATED_SPACE")
>
> That would have addressed some of that, I guess.
>
>
> I'm asking because some of the crypto stuff we do has fairly large
> head/tailroom requirements and it seems I may need to add more. But if
> you don't have crypto, it would be much smaller, so I figured we could
> switch it.

We could probably do it via a pair of new NETDEV_* notify event to
signal new needed_headroom/tailroom values to stacked devices. Would
that be acceptable?
-- 
Florian
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
