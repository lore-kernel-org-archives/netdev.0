From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: Re: wireless vs. network namespaces (part II)
Date: Sat, 27 Sep 2008 18:39:54 -0700
Message-ID: <m1r675aw0l.fsf@frodo.ebiederm.org>
References: <1222509685.3798.59.camel@johannes.berg>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-wireless <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Jouni Malinen <j@w1.fi>
To: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1222509685.3798.59.camel-YfaajirXv214zXjbi5bjpg@public.gmane.org> (Johannes Berg's message
	of "Sat, 27 Sep 2008 12:01:25 +0200")
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org> writes:

> Eric,
>
> You wrote, over a year ago:
>
>> 2) Advanced routing.  Where someone is doing some weird thing like 
>>    testing sending packets and receiving them on the same machine.
>
> and I was just thinking of doing exactly that :)

Sounds like a fun way to test the wireless stack.
Have both a client and an access point on the same box talking
to each other ;)

> When looking into it, though, I noticed that you can generate some
> breakage with wireless and network namespaces: you can move a wireless
> netdev to a different namespace and then things will break down because
> we internally use init_net to find it.

> What I'd like to do in wireless is not allow moving netdevs between
> namespaces, but rather move entire hardware devices between namespaces,
> I see little value and great pain in trying to support virtual
> interfaces from a single physical device showing up in different
> namespaces, but I do see value in binding a physical device (wiphy) to a
> namespace.

At the moment I don't understand the distinction very well.  Why do we
have both a wireless master device and a wireless device that we
actually use?

In the wired ethernet world there is a lot of value in moving just
a vlan interface or just one mac address with mac vlan into a network
namespace.  Allowing full speed access to the hardware that can do
just about anything while functionally restricting what user space
can do with the hardware.

> As far as I understand, to disallow moving them, I should set the
> NETIF_F_NETNS_LOCAL flag on all devices, although that is sort of a
> misnomer then because I'd be using it to indicate 'cannot switch
> namespace'. 

In this case yes.   It is designed for devices like the loo back
device and other virtual devices that we use for creating virtual
devices.  Although the recent support for creating new network
devices with netlink removes much of the need for the second use case.

It was also designed to handle the case if we do find a network
device that just can't handle being moved between network namespaces.

> To really support this though, it seems we need to
>  * put the wiphy list into struct net (this is currently a simple
>    list_head, no fancy hashing)

Reasonable.

>  * give each struct wiphy a backpointer to the struct net, like netdev
>    in the netdev struct

Reasonable

>  * ensure that all netdevs created for this wiphy will have the right
>    netns.
>
> The latter part I'm unsure on, alloc_netdev_mq seems to always use
> init_net so I can't put them into the right namespace to start with, but
> because they're all "in there together" I can't allow switching
> namespaces either.. Ideas?

alloc_netdev_mq doesn't register the device, so it is a matter of simply
changing the network device pointer after allocation and before registration.

We do this by default when we dynamically create network devices using
netlink.  see rtnl_create_link for an example.

Eric

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
