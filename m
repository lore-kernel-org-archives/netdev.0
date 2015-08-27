From: Scott Feldman <sfeldma@gmail.com>
Subject: Re: [patch net-next 3/6] net: add netif_is_ovs_master helper with
 IFF_OPENVSWITCH private flag
Date: Thu, 27 Aug 2015 00:51:52 -0700
Message-ID: <CAE4R7bD7SLQ9nDvrzxPGidT28O-t0YctgMbr-JU2Mwu-62aqxg@mail.gmail.com>
References: <1440606998-11072-1-git-send-email-jiri@resnulli.us>
 <1440606998-11072-4-git-send-email-jiri@resnulli.us> <CAE4R7bA5S6WcycMxWXPyOWyA-dPVs4Jy6TS2hq2176FGC8BKbg@mail.gmail.com>
 <20150827054307.GC2228@nanopsycho.orion> <CAE4R7bDokROc=9tWrS2wQ8HaYLMQVBDY5=X=p0YcxLodqfyw-A@mail.gmail.com>
 <20150827063051.GG2228@nanopsycho.orion>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Netdev <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Ido Schimmel <idosch@mellanox.com>, eladr@mellanox.com,
	"simon.horman@netronome.com" <simon.horman@netronome.com>,
	Jiri Pirko <jiri@mellanox.com>
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f173.google.com ([209.85.214.173]:34923 "EHLO
	mail-ob0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751341AbbH0HwM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Aug 2015 03:52:12 -0400
Received: by obbwr7 with SMTP id wr7so9654551obb.2
        for <netdev@vger.kernel.org>; Thu, 27 Aug 2015 00:52:12 -0700 (PDT)
In-Reply-To: <20150827063051.GG2228@nanopsycho.orion>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Aug 26, 2015 at 11:30 PM, Jiri Pirko <jiri@resnulli.us> wrote:
> Thu, Aug 27, 2015 at 08:23:13AM CEST, sfeldma@gmail.com wrote:
>>On Wed, Aug 26, 2015 at 10:43 PM, Jiri Pirko <jiri@resnulli.us> wrote:
>>> Wed, Aug 26, 2015 at 07:43:18PM CEST, sfeldma@gmail.com wrote:
>>>>On Wed, Aug 26, 2015 at 9:36 AM, Jiri Pirko <jiri@resnulli.us> wrote:
>>>>> From: Jiri Pirko <jiri@mellanox.com>

>>>>We're going to run out of priv_flags bits.  This flag doesn't seem
>>>>like something that will be checked lots of places.  How about using
>>>>rtnl_link_ops->kind to save a bit in priv_flags?
>>>>
>>>>static inline bool netif_is_ovs_master(const struct net_device *dev)
>>>>{
>>>>    return !strcmp(dev->rtnl_link_ops->kind, "openvswitch"));
>>>>}
>>>
>>> There are lot of helpers like this for other soft-devices. I think that
>>> is okay to have it this way. The thing is that sometimes you need to use
>>> thi helper in fast path and in that case, you do not want to strcmp.
>>>
>>> There is plenty of priv_flags bits for now when I killed the bonding
>>> stuff.
>>
>>Ya, but think about the bit: you (and others) used a bit in priv_flags
>>to indicate the netdev type.  Can you add an enum field to
>>rtnl_link_ops->type to indicate link type?  Then it's not a strcmp.
>>You can write your helper using strcmp first, and then later migrate
>>to using rtnl_link_ops->type.
>
>
> Also, dev can be multiple things, it can be bridge port and vlan dev at
> the same time. Flags are good for this.

priv_flags bits are three types:

1) dev attribute (IFF_XMIT_DST_RELEASE, IFF_DISABLE_NETPOLL, etc)
2) dev type (IFF_802_1Q_VLAN, IFF_EBRIDGE, etc)
3) and dev membership (IFF_BRIDGE_PORT, IFF_TEAM_PORT, etc)

Are there types 2 or 3 in any fast paths?  Type 2 can move to enum;
they're mutually exclusive.  Type 3 is the dev's master's type 2, and
since dev can have only one master, no flag is needed: just look up
master type to know if dev is bridged or ovs'ed.
