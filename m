From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: Re: [PATCH v2] ipv6: fix ecmp lookup when oif is specified
Date: Mon, 24 Jun 2013 18:44:24 +0200
Message-ID: <51C87768.7090008@6wind.com>
References: <20130613.173829.683328203745717078.davem@davemloft.net> <1371198778-26099-1-git-send-email-nicolas.dichtel@6wind.com> <20130623.184018.934611809597741522.davem@davemloft.net>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f180.google.com ([209.85.212.180]:53252 "EHLO
	mail-wi0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753079Ab3FXQo1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Jun 2013 12:44:27 -0400
Received: by mail-wi0-f180.google.com with SMTP id c10so2673100wiw.7
        for <netdev@vger.kernel.org>; Mon, 24 Jun 2013 09:44:26 -0700 (PDT)
In-Reply-To: <20130623.184018.934611809597741522.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 24/06/2013 03:40, David Miller a =E9crit :
> From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
> Date: Fri, 14 Jun 2013 10:32:58 +0200
>
>> There is no reason to skip ECMP lookup when oif is specified, but th=
is implies
>> to check oif given by user when selecting another route.
>> When the new route does not match oif requirement, we simply keep th=
e initial
>> one.
>>
>> Spotted-by: dingzhi <zhi.ding@6wind.com>
>> Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
>
> IPV4 routing has elided the multipath lookup when the interface is sp=
ecified
> for nearly two decades.
>
> So two things:
>
> 1) A decision that old must have a good reason, and you must do some
>     research to figure out exactly what that reason is.
>
> 2) If ipv4 is found to be wrong too, we must bring both ipv4 and ipv6
>     into the same behavior at the same time.
In fact, routing engines are different in forwarding case:

IPv4 case:
fl4->flowi4_oif is 0 when a packet is forwarded and this value is check=
ed to=20
select or not multipath functions.

IPv6 case:
The check is done against the argument oif (not fl6->flowi6_oif) of the=
 function=20
ip6_pol_route(). And this argument is set to the input interface by=20
ip6_pol_route_input().

=46unctions call:
   - ip6_rcv_finish() -> ip6_route_input() -> ip6_route_input_lookup() =
->=20
fib6_rule_lookup() -> ip6_pol_route_input() -> ip6_pol_route()

Will you accept the patch if I remove only the check of oif argument in=
=20
ip6_pol_route() (and leave ip6_pol_route_lookup() untouched).

My goal was only to have ECMP working in the forwarding case.
