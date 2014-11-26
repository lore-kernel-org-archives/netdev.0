From: John Fastabend <john.fastabend@gmail.com>
Subject: Re: [PATCH 0/5 net] bridge: Fix missing Netlink message validations
Date: Wed, 26 Nov 2014 09:25:49 -0800
Message-ID: <54760D1D.3070201@gmail.com>
References: <cover.1417005245.git.tgraf@suug.ch> <547606B3.3060808@gmail.com> <20141126170610.GA2399@casper.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jiri Pirko <jiri@resnulli.us>, davem@davemloft.net,
	stephen@networkplumber.org, netdev@vger.kernel.org
To: Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f50.google.com ([209.85.218.50]:41711 "EHLO
	mail-oi0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750837AbaKZR0C (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Nov 2014 12:26:02 -0500
Received: by mail-oi0-f50.google.com with SMTP id a141so2281653oig.37
        for <netdev@vger.kernel.org>; Wed, 26 Nov 2014 09:26:00 -0800 (PST)
In-Reply-To: <20141126170610.GA2399@casper.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/26/2014 09:06 AM, Thomas Graf wrote:
> On 11/26/14 at 08:58am, John Fastabend wrote:
>> On 11/26/2014 04:42 AM, Thomas Graf wrote:
>>> Adds various missing length checks in the bridging code for Netlink
>>> messages and corresponding attributes provided by user space.
>>>
>>> Thomas Graf (5):
>>>    bridge: Validate IFLA_BRIDGE_FLAGS attribute length
>>>    net: Validate IFLA_BRIDGE_MODE attribute length
>>>    net: Check for presence of IFLA_AF_SPEC
>>>    bridge: Add missing policy entry for IFLA_BRPORT_FAST_LEAVE
>>>    bridge: Sanitize IFLA_EXT_MASK for AF_BRIDGE:RTM_GETLINK
>>>
>>>   drivers/net/ethernet/emulex/benet/be_main.c   |  5 +++++
>>>   drivers/net/ethernet/intel/ixgbe/ixgbe_main.c |  5 +++++
>>>   net/bridge/br_netlink.c                       |  1 +
>>>   net/core/rtnetlink.c                          | 23 ++++++++++++++++++-----
>>>   4 files changed, 29 insertions(+), 5 deletions(-)
>>>
>>
>> +Jiri
>>
>> Looks like a miss in bond_netlink also? Seems like writing
>> a smatch or cocci check for this would be worthwhile.
>
> Thanks, I'll take a look.
>
> The cocci check is somewhat difficult as validation is often
> centralized and decoupled from actual access to implement atomic
> operations. I'll give it a try though.
>

Sounds good, if I get some time I could give it a try as well.

Also another missing one here or at least I'm not seeing it if its
there,

> --- a/net/ipv4/devinet.c
> +++ b/net/ipv4/devinet.c
> @@ -1687,8 +1687,11 @@ static int inet_set_link_af(struct net_device *dev, const struct nlattr *nla)
>                 BUG();
>
>         if (tb[IFLA_INET_CONF]) {
> -               nla_for_each_nested(a, tb[IFLA_INET_CONF], rem)
> +               nla_for_each_nested(a, tb[IFLA_INET_CONF], rem) {
> +                       if (nla_len(a) < sizeof(u32))
> +                               return -EINVAL;
>                         ipv4_devconf_set(in_dev, nla_type(a), nla_get_u32(a));
> +               }
>         }





-- 
John Fastabend         Intel Corporation
