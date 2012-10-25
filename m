From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: Re: [PATCH iproute2 2/2] ip: remove NLM_F_EXCL in case of ECMPv6
 routes
Date: Thu, 25 Oct 2012 18:48:07 +0200
Message-ID: <50896D47.7030500@6wind.com>
References: <20121023.023910.80461258323920266.davem@davemloft.net> <1350996176-4000-1-git-send-email-nicolas.dichtel@6wind.com> <1350996176-4000-2-git-send-email-nicolas.dichtel@6wind.com> <20121025090628.25e484d1@nehalam.linuxnetplumber.net> <508966E1.2050205@6wind.com> <20121025092526.5bb0a7ca@nehalam.linuxnetplumber.net>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, joe@perches.com, bernat@luffy.cx,
	eric.dumazet@gmail.com, yoshfuji@linux-ipv6.org,
	davem@davemloft.net
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f46.google.com ([74.125.83.46]:63426 "EHLO
	mail-ee0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757202Ab2JYQsL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Oct 2012 12:48:11 -0400
Received: by mail-ee0-f46.google.com with SMTP id b15so705217eek.19
        for <netdev@vger.kernel.org>; Thu, 25 Oct 2012 09:48:10 -0700 (PDT)
In-Reply-To: <20121025092526.5bb0a7ca@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 25/10/2012 18:25, Stephen Hemminger a =E9crit :
> On Thu, 25 Oct 2012 18:20:49 +0200
> Nicolas Dichtel <nicolas.dichtel@6wind.com> wrote:
>
>> Le 25/10/2012 18:06, Stephen Hemminger a =E9crit :
>>> On Tue, 23 Oct 2012 14:42:56 +0200
>>> Nicolas Dichtel <nicolas.dichtel@6wind.com> wrote:
>>>
>>>> ECMPv6 routes are added each one after the other by the kernel, so=
 we should
>>>> avoid to set the flag NLM_F_EXCL.
>>>>
>>>> Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
>>>> ---
>>>>    ip/iproute.c | 5 ++++-
>>>>    1 file changed, 4 insertions(+), 1 deletion(-)
>>>>
>>>> diff --git a/ip/iproute.c b/ip/iproute.c
>>>> index c60156f..799a70e 100644
>>>> --- a/ip/iproute.c
>>>> +++ b/ip/iproute.c
>>>> @@ -694,8 +694,11 @@ int parse_nexthops(struct nlmsghdr *n, struct=
 rtmsg *r, int argc, char **argv)
>>>>    		rtnh =3D RTNH_NEXT(rtnh);
>>>>    	}
>>>>
>>>> -	if (rta->rta_len > RTA_LENGTH(0))
>>>> +	if (rta->rta_len > RTA_LENGTH(0)) {
>>>>    		addattr_l(n, 1024, RTA_MULTIPATH, RTA_DATA(rta), RTA_PAYLOAD(=
rta));
>>>> +		if (r->rtm_family =3D=3D AF_INET6)
>>>> +			n->nlmsg_flags &=3D ~NLM_F_EXCL;
>>>> +	}
>>>>    	return 0;
>>>>    }
>>>>
>>>
>>> Shouldn't this be true for multipath IPv4 as well?
>>>
>> In IPv4, the message is treating in one shot, because all nexthops a=
re added in
>> the route. In IPv6, each nexthop is added like a single route and th=
en they are
>> linked together.
>
> So it is a fundamental design flaw in how either v4 or v6 was impleme=
nted in
> the kernel?
>
The way to manage route is just different. Maybe a patch in the kernel =
is more=20
appropriate:

 From b4979c97f33bc41a0fa095751bfcc05de074afec Mon Sep 17 00:00:00 2001
=46rom: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Date: Thu, 25 Oct 2012 18:45:47 +0200
Subject: [PATCH] ipv6/multipath: remove flag NLM_F_EXCL after the first
  nexthop

fib6_add_rt2node() will reject the nexthop if this flag is set, so
we perform the check only for the first nexthop.

Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
---
  net/ipv6/route.c | 6 ++++++
  1 file changed, 6 insertions(+)

diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index c42650c..9c7b5d8 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -2449,6 +2449,12 @@ beginning:
  				goto beginning;
  			}
  		}
+		/* Because each route is added like a single route we remove
+		 * this flag after the first nexthop (if there is a collision,
+		 * we have already fail to add the first nexthop:
+		 * fib6_add_rt2node() has reject it).
+		 */
+		cfg->fc_nlinfo.nlh->nlmsg_flags &=3D ~NLM_F_EXCL;
  		rtnh =3D rtnh_next(rtnh, &remaining);
  	}

--=20
1.7.12
