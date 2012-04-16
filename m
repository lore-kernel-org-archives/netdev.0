From: Denys Fedoryshchenko <denys@visp.net.lb>
Subject: Re: SV: Netlink, route monitoring, =?UTF-8?Q?RTM=5FDELROUTE=20not?=
 =?UTF-8?Q?=20issued=20for=20ppp=20peer=20address=2E=20Bug=20or=20feature?=
 =?UTF-8?Q?=3F?=
Date: Mon, 16 Apr 2012 13:37:14 +0300
Message-ID: <3db49d4a58321a5e185cd67335a60c81@visp.net.lb>
References: <8986ed37b55c756ecdeec0315f73e63a@visp.net.lb>
 <023e01cd197d$a9faba40$fdf02ec0$@no>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <netdev@vger.kernel.org>
To: Stian Skjelstad <stian@nixia.no>, <eric.dumazet@gmail.com>,
	<stephen.hemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hosting.visp.net.lb ([194.146.153.11]:41213 "EHLO
	hosting.visp.net.lb" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752693Ab2DPKh1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Apr 2012 06:37:27 -0400
In-Reply-To: <023e01cd197d$a9faba40$fdf02ec0$@no>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

After digging the code, i came to conclusion:
fib_del_ifaddr, will check if deleted address are exist as prefsrc or=20
interface are shut down, they will do fi->fib_flags |=3D RTNH_F_DEAD;
Then fib_flush -> fib_table_flush -> trie_flush_leaf -> trie_flush_list=
=20
will delete such routes.
But trie_flush_list won't notify over netlink that route are deleted.

So the only solution is to fetch first, then keep full routing table in=
=20
userspace also, and keep tracking if local addresses deleted, and do th=
e=20
same in userspace and check for prefsrc...

Maybe it should be fixed? E.g. netlink message sent when any route are=20
deleted, even over the flush

On 2012-04-13 16:59, Stian Skjelstad wrote:
> I've seen the same issue, and got no response so far to that very
> same question. Have you tested this on older kernels? I have worked
> around this issue by testing my local copy of routing entries that=20
> use
> 'via'. If they are not routable when after the RTM_DELROUTE event, I
> autoremove them from my local copy.
>
> Stian Skjelstad
>
> -----Opprinnelig melding-----
> Fra: netdev-owner@vger.kernel.org
> [mailto:netdev-owner@vger.kernel.org] P=C3=A5 vegne av Denys=20
> Fedoryshchenko
> Sendt: 13. april 2012 14:11
> Til: netdev@vger.kernel.org
> Emne: Netlink, route monitoring, RTM_DELROUTE not issued for ppp peer
> address. Bug or feature?
>
> Hi
>
> I am trying to implement my own routing daemon, and using
> RTMGRP_IPV4_ROUTE to monitor routes.
> I notice, that on PPPoE, when interface disappearing, RTM_DELROUTE
> will be sent to listener only for local address, but nothing about
> peer address attached to this interface.
>
> CBSS_PPPoE ~ # ifconfig ppp0
> ppp0      Link encap:Point-to-Point Protocol
>            inet addr:172.16.146.1  P-t-P:172.16.146.10
> Mask:255.255.255.255
>            UP POINTOPOINT RUNNING NOARP MULTICAST  MTU:1200  Metric:1
>            RX packets:40439 errors:0 dropped:0 overruns:0 frame:0
>            TX packets:63211 errors:0 dropped:0 overruns:0 carrier:0
>            collisions:0 txqueuelen:3
>            RX bytes:3584507 (3.4 MiB)  TX bytes:47180929 (44.9 MiB)
>
> CBSS_PPPoE ~ # pppkill tek234@visp.net.lb  (this is killing pppd
> process for ppp0 interface)
>
> ip monitor route will show only RTM_DELROUTE for RTN_LOCAL, but
> nothing about RTN_UNICAST for 172.16.146.10.
> "Deleted local 172.16.146.1 dev ppp0  table local  proto kernel
> scope host  src 172.16.146.1"
> My program also receive same.
>
> Is it a bug, that no RTM_DELROUTE issued for peer ip address? Or
> should i monitor also RTMGRP_IPV4_IFADDR for link disappearance?
>
> Thanks for help!
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org More majordomo=20
> info
> at  http://vger.kernel.org/majordomo-info.html
>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
