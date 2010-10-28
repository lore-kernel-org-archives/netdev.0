From: =?UTF-8?Q?Maciej_=C5=BBenczykowski?= <zenczykowski@gmail.com>
Subject: Re: [PATCH] ipv6: addrconf: clear IPv6 addresses and routes when
 losing link
Date: Thu, 28 Oct 2010 15:50:13 -0700
Message-ID: <AANLkTinQd1YSPvYbhy0hdjT-+O=8Y0oN-yPvsdRwRf6T@mail.gmail.com>
References: <AANLkTikC4pv8aOODM2pOg2bKQGL69wivcUU3f9ZziPhe@mail.gmail.com>
	<4CC78F19.9080504@hp.com>
	<AANLkTikTT5ie-R61rA9NucgGi5RBOPpXZLMYQRa_wb7j@mail.gmail.com>
	<AANLkTinA+znFn4txgq_2=njuX+eCTNJW+n_psbMYkU9d@mail.gmail.com>
	<AANLkTi=AyYrmSWDTZVWb2s+jgnyjNyHo-fkV4U+Fm45n@mail.gmail.com>
	<AANLkTim-2ghTVVEaJesMkXcRL-eCPBoHkehKF8HXhyK+@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev@vger.kernel.org, Brian Haley <brian.haley@hp.com>
To: Lorenzo Colitti <lorenzo@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:56359 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754809Ab0J1WuO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Oct 2010 18:50:14 -0400
Received: by wyf28 with SMTP id 28so2477493wyf.19
        for <netdev@vger.kernel.org>; Thu, 28 Oct 2010 15:50:13 -0700 (PDT)
In-Reply-To: <AANLkTim-2ghTVVEaJesMkXcRL-eCPBoHkehKF8HXhyK+@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> It's random, but the random interface ID is a property of the
> interface, not of the address, and thus survives interface up/down:

Interesting, that actually means a link down/up will break the
temporary address lifetimes (reset them).

# uname -a
Linux nike 2.6.34.7-61.fc13.x86_64 #1 SMP Tue Oct 19 04:06:30 UTC 2010
x86_64 x86_64 x86_64 GNU/Linux

# echo --Dump--; ip -6 addr list dev eth0 secondary; echo --Down--; ip
link set eth0 down; echo --Dump--; ip -6 addr list dev eth0 secondary;
echo --Up--; ip link set eth0 up; echo --Dump--; ip -6 addr list dev
eth0 secondary; echo --Sleep30--; sleep 30; echo --Dump--; ip -6 addr
list dev eth0 secondary; echo --Sleep60--; sleep 60; echo --Dump--; ip
-6 addr list dev eth0 secondary; echo --Done--

--Dump--
2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qlen 1000
    inet6 2620:0:1000:1301:ab:5938:64ce:ae20/64 scope global temporary dynamic
       valid_lft 604667sec preferred_lft 85667sec
--Down--
--Dump--
--Up--
--Dump--
--Sleep30--
--Dump--
2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qlen 1000
    inet6 2620:0:1000:1301:ab:5938:64ce:ae20/64 scope global temporary dynamic
       valid_lft 604775sec preferred_lft 85775sec
--Sleep60--
--Dump--
2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qlen 1000
    inet6 2620:0:1000:1301:ab:5938:64ce:ae20/64 scope global temporary dynamic
       valid_lft 604715sec preferred_lft 85715sec
--Done--

Notice that when the v6 temp address comes back (presumably after
receiving an RA) it comes back with fresh valid/preferred lifetimes,
instead of the already partially expired ones that we had before the
link went down.

I was already aware that v6 temp addresses didn't work all that well
with short RA timeouts, but it looks like the logic needs a bit more
tweaking...
