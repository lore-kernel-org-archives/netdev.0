From: Ben Greear <greearb@candelatech.com>
Subject: Re: netlink stats: Ability to get stats for a single device?
Date: Tue, 26 Oct 2010 13:29:18 -0700
Message-ID: <4CC73A1E.5050605@candelatech.com>
References: <4CC72C80.9010802@candelatech.com>	 <20101026.123811.13746869.davem@davemloft.net> <1288122986.2652.20.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:58869 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755917Ab0JZU3Y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Oct 2010 16:29:24 -0400
In-Reply-To: <1288122986.2652.20.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/26/2010 12:56 PM, Eric Dumazet wrote:
> Le mardi 26 octobre 2010 =C3=A0 12:38 -0700, David Miller a =C3=A9cri=
t :
>> From: Ben Greear<greearb@candelatech.com>
>> Date: Tue, 26 Oct 2010 12:31:12 -0700
>>
>>> Am I missing something, or do I just need to write up a patch
>>> to have netlink pay attention to the ifindex?
>>
>> Setting the ->ifi_index or IFLA_IFNAME attribute values appropriatel=
y
>> in the getlink request doesn't work?
>>
>> That should give you back, amonst other things, the rtnl_link_stats
>> for the device in the netlink response.
>> --
>
> Yep, it should be easy to change iproute2 to not ask a full dump
> in ip/ipaddress.c :
>
> if (rtnl_wilddump_request(&rth, preferred_family, RTM_GETLINK)<  0) .=
=2E.
>
> and instead use rtnl_send() or something like that, if user provided =
one
> specific interface name   (or index)
>
> ip link show dev eth0

I'm trying to craft my own netlink message...basically:

    memset(&snl, 0, sizeof(snl));
    snl.nl_family =3D AF_NETLINK;
    snl.nl_pid    =3D 0;
    snl.nl_groups =3D 0;

    memset(&buffer, 0, sizeof(buffer));
    nlh->nlmsg_type =3D msg_type;
    nlh->nlmsg_flags =3D NLM_F_MATCH|NLM_F_REQUEST;
    static unsigned int nl_seqno =3D 1;
    nlh->nlmsg_seq =3D nl_seqno++;
    nlh->nlmsg_pid =3D nl_pid;



       nlh->nlmsg_len =3D NLMSG_LENGTH(sizeof(*ifinfomsg));
       ifinfomsg =3D (struct ifinfomsg*)(NLMSG_DATA(nlh));
       ifinfomsg->ifi_family =3D AF_UNSPEC;
       ifinfomsg->ifi_type =3D IFLA_UNSPEC;
       ifinfomsg->ifi_index =3D if_index;
       ifinfomsg->ifi_flags =3D 0;
       ifinfomsg->ifi_change =3D 0xffffffff;


It's possible that I'm somehow messing this up. But, looking at the
static int rtnl_dump_ifinfo(struct sk_buff *skb, struct netlink_callbac=
k *cb)
method, I cannot see how it would bail out properly after a single dev
has been processed, either.

Thanks,
Ben

--=20
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com

