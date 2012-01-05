From: Mihai Maruseac <mihai.maruseac@gmail.com>
Subject: Re: [PATCH] ipv6/addrconf: speedup /proc/net/if_inet6 filling
Date: Thu, 5 Jan 2012 16:07:33 +0200
Message-ID: <CAOMsUM+wJm0YiTZpAVh+4GYJdDKFmSCqZek_ykaYuvHYXx5MFw@mail.gmail.com>
References: <1325669495-5626-1-git-send-email-mmaruseac@ixiacom.com>
 <20120104082200.437df26a@nehalam.linuxnetplumber.net> <CAOMsUMKp_7w2+0bBTFbQk3HKpobJQd8b2vi6_zTTzGjtZ_+OMA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, eric.dumazet@gmail.com, kuznet@ms2.inr.ac.ru,
	jmorris@namei.org, yoshfuji@linux-ipv6.org, kaber@trash.net,
	netdev@vger.kernel.org, Mihai Maruseac <mmaruseac@ixiacom.com>,
	Daniel Baluta <dbaluta@ixiacom.com>
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gx0-f174.google.com ([209.85.161.174]:54740 "EHLO
	mail-gx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932294Ab2AEOHy convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Jan 2012 09:07:54 -0500
Received: by ggdk6 with SMTP id k6so187629ggd.19
        for <netdev@vger.kernel.org>; Thu, 05 Jan 2012 06:07:53 -0800 (PST)
In-Reply-To: <CAOMsUMKp_7w2+0bBTFbQk3HKpobJQd8b2vi6_zTTzGjtZ_+OMA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jan 4, 2012 at 7:03 PM, Mihai Maruseac <mihai.maruseac@gmail.co=
m> wrote:
> On Wed, Jan 4, 2012 at 6:22 PM, Stephen Hemminger <shemminger@vyatta.=
com> wrote:
>> On Wed, =A04 Jan 2012 11:31:35 +0200
>> Mihai Maruseac <mihai.maruseac@gmail.com> wrote:
>>
>>> This ensures a linear behaviour when filling /proc/net/if_inet6 thu=
s making
>>> ifconfig run really fast on IPv6 only addresses. In fact, with this=
 patch and
>>> the IPv4 one sent a while ago, ifconfig will run in linear time reg=
ardless of
>>> address type.
>>>
>>> IPv4 related patch: f04565ddf52e401880f8ba51de0dff8ba51c99fd
>>> =A0 =A0 =A0 =A0dev: use name hash for dev_seq_ops
>>> =A0 =A0 =A0 =A0...
>>>
>>> Some statistics (running ifconfig > /dev/null on a different setup)=
:
>>>
>>> iface count / IPv6 no-patch time / IPv6 patched time / IPv4 time
>>> ----------------------------------------------------------------
>>> =A0 =A0 =A0 6250 =A0| =A0 =A0 =A0 0.23 s =A0 =A0 =A0 | =A0 =A0 =A00=
=2E13 s =A0 =A0 =A0 | =A00.11 s
>>> =A0 =A0 =A012500 =A0| =A0 =A0 =A0 0.62 s =A0 =A0 =A0 | =A0 =A0 =A00=
=2E28 s =A0 =A0 =A0 | =A00.22 s
>>> =A0 =A0 =A025000 =A0| =A0 =A0 =A0 2.91 s =A0 =A0 =A0 | =A0 =A0 =A00=
=2E57 s =A0 =A0 =A0 | =A00.46 s
>>> =A0 =A0 =A050000 =A0| =A0 =A0 =A011.37 s =A0 =A0 =A0 | =A0 =A0 =A01=
=2E21 s =A0 =A0 =A0 | =A00.94 s
>>> =A0 =A0 128000 =A0| =A0 =A0 =A086.78 s =A0 =A0 =A0 | =A0 =A0 =A03.0=
5 s =A0 =A0 =A0 | =A02.54 s
>>>
>>> Signed-off-by: Mihai Maruseac <mmaruseac@ixiacom.com>
>>> Cc: Daniel Baluta <dbaluta@ixiacom.com>
>>> ---
>>> =A0net/ipv6/addrconf.c | =A0 43 ++++++++++++++++++++++++++++-------=
--------
>>> =A01 files changed, 28 insertions(+), 15 deletions(-)
>>>
>>
>>
>> What about netlink? Also ifconfig is really considered deprecated,
>> especially for ipv6 usage.
>
> Yes, ifconfig is deprecated but the /proc/net/if_inet6 file can be
> used in a lot of bash scripts and this was what we wanted to optimize=
=2E
>
> We tried to look at the netlink sockets used in iproute2 but there
> seems to be no way to improve the performance there. We used 3 pair o=
f
> eyes for this before giving up.
>
> I'll come back with statistics from ip a s in at most 24 hours, I
> cannot test right now.


Here are the statistics comparing ip a s with ifconfig, as promised:

* for IPv6:

iface count / ifconfig /   ip a s
----------------------------------------------
 =A0 =A0 =A0 6250 =A0|  0.13 s  | =A0   1.23 s
=A0 =A0 =A012500 =A0|  0.28 s  | =A0   5.03 s
=A0 =A0 =A025000 =A0|  0.57 s  | =A0 20.17 s
=A0 =A0 =A050000 =A0|  1.21 s  | =A0 87.25 s
 =A0 128000 =A0|  3.05 s  | =A0968.12 s

* for IPv4:

iface count / ifconfig /   ip a s
----------------------------------------------
 =A0 =A0 =A0 6250 =A0|  0.11 s  | =A0   0.61 s
=A0 =A0 =A012500 =A0|  0.22 s  | =A0   2.49 s
=A0 =A0 =A025000 =A0|  0.46 s  | =A0 10.12 s
=A0 =A0 =A050000 =A0|  0.94 s  | =A0 40.36 s
 =A0 128000 =A0|  2.54 s  | =A0293.14 s

It seems that an optimisation for the ip case is required. We have a
quadratic behaviour here too.

Thanks,
Mihai
