From: Dan Williams <dcbw@redhat.com>
Subject: Re: proposal for new wireless configuration API
Date: Tue, 15 Aug 2006 12:29:47 -0400
Message-ID: <1155659387.3005.15.camel@localhost.localdomain>
References: <1155655728.17742.30.camel@ux156>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Jean Tourrilhes <jt@hpl.hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:19340 "EHLO mx1.redhat.com")
	by vger.kernel.org with ESMTP id S965242AbWHOQbA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Aug 2006 12:31:00 -0400
To: Johannes Berg <johannes@sipsolutions.net>
In-Reply-To: <1155655728.17742.30.camel@ux156>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2006-08-15 at 17:28 +0200, Johannes Berg wrote:
> Hi,
> 
> So I've thought about this all day long... After writing this mail I'll
> go home and hope my inbox collects some feedback ;)

We might want to take the time to fix up a few of the ambiguities of
WEXT that we've encountered over the past few years:

o Separate attributes for signal strength units; signed integer type for
dBm, unsigned integer type for RSSI.  One 8-bit var to represent both is
just too confusing for people, evidently (which is true...)

o Merge functionality ENCODE and ENCODEEXT handlers into one

o Separate attributes for channel and frequency

o Method of finding out channel <-> frequency mapping (not all drivers
support this in the SIOCGIWRANGE handler now)

Nothing big here...  but gives driver writers a much easier target to
hit, and userspace app writers an easier API to understand.

Dan

> I've arrived at the following conclusions:
>  * we want to use genetlink
>  * we need an equivalent of the old commit() call,
>    but without all the stupidity
>  * we want to do packet injection and many other advanced
>    features with it, and keep it extensible
> 
> NB: I have some code, so don't start ;)
> 
> Hence, I came up with the following system. Note that I don't use any
> private header for the netlink messages.
> 
>  - we implement a bunch of commands, for example NL80211_CMD_INJECT and
>    _SETATTR, _GETATTR[(attrnumber)] [easy with dumpit()],
>    _GETATTRGROUP, ...
> 
>  - we have a whole bunch of possible attributes:
>    NL80211_ATTR_FLAGS: flags for injecting a packet (e.g. want_notify)
>    NL80211_ATTR_IFINDEX: index of interface to use
>    (NL80211_ATTR_PHYIDX: (later) index of wiphy to configure)
>    NL80211_ATTR_ESSID,
>                 FRAGTHRESHOLD,
>                 CHANNEL,...: most of the old wext ioctls map to
>                              attributes now
>    NL80211_ATTR_FRAME: frame to inject, or received mgmt frame
> 
>  - we use a few multicast groups:
>     (a) one for management frames that are received
>     (b) one for scan results as they come available
>         (When, for example, someone requests scan results, they are
>          simply multicast to the group+the requester, if they come
>          available during operation they can also be multicast here)
> 
> Note that I haven't mentioned commit(). NL80211_CMD_GETATTRGROUP returns
> a list of attributes that make sense to set with a single _SETATTR call
> and multiple attributes.
> 
> an old sequence of
>   iwconfig eth0 essid 'lalala'
>   iwconfig eth0 channel 2
>   iwconfig eth0 commit
> would then be translated in the compat layer to a single _SETATTR
> message with the channel and essid attributes. Ultimately, we'll get rid
> of this, so a userspace tool using the netlink configuration would just
> tell the user via _GETATTRGROUP which attributes make sense to group
> together for optimal card behaviour.
> 
> As for the inject command, it looks like on the current wmgmt# interface
> for d80211 has a bunch of implicit behaviour like looking into the
> transmitted frame to see what type it is etc. I'd like to get rid of it
> and stuff the information for that into ATTR_FLAGS instead.
> 
> Oh and of course we'll have a structure somewhere that drivers and
> stacks register with the module that provides this netlink interface.
> That module will then also multiplex the commands to the drivers/stacks.
> I have that mostly figured out.
> 
> Since it will be easy to tell if a specific driver/stack implements
> old-style wext or this new API we can allow drivers with both APIs to
> coexist for a while. I won't map the new API to the old wext one of
> course, but mapping the wext API to the new one we need anyway. Hence,
> we can change the wext code to call the new API if present and the old
> one otherwise (with a big fat printk), and then slowly migrate drivers
> over. Due to the reduced commit logic, it should become simpler too,
> even for old drivers.
> 
> Anyway, comments appreciated. If we can agree on this general framework
> I'll start implementing the groundwork and some of the rest for d80211
> soon.
> 
> johannes
> -
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

