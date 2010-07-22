From: Mahesh Kelkar <maheshkelkar@gmail.com>
Subject: Re: With disable_ipv6 set to 1 on an interface, ff00:/8 and fe80::/64
	are still added on device UP
Date: Thu, 22 Jul 2010 10:03:03 -0400
Message-ID: <AANLkTimdY9vKMZAhUUrkB3k-Cx3enaQdT6VKB5KMQZ5_@mail.gmail.com>
References: <AANLkTinHkaL49MS9agf525GRhWXSWIvVmn-Qz33Hcg6Y@mail.gmail.com>
	<4C460856.5090701@hp.com>
	<20100720.134851.09735512.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>
To: Brian Haley <brian.haley@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:48963 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754855Ab0GVODI convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Jul 2010 10:03:08 -0400
Received: by wwj40 with SMTP id 40so3471089wwj.1
        for <netdev@vger.kernel.org>; Thu, 22 Jul 2010 07:03:03 -0700 (PDT)
In-Reply-To: <20100720.134851.09735512.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Brian,

Overall the patch seem to work.

On one occasion I saw an error when it tried get rtnl_trylock() in
"addrconf_disable_ipv6" in addrconf.c. I am investigating into it. If
you could think of anything, please let me know.

I also came across another odd behavior (unrelated to disable_ipv6 but
related to multicast & link local route):
A. configure unicast Ipv6 address (say 123:2:3:4:5:6:7:8/64) on an
interface. (link-local will be assigned when interface comes up)
B. Bring the interface down (ip link set eth0 down),

you will get following set of netlink notifications (ip monitor all):
1. Deleted - unicast address connected route (123:2:3:4::/64)
2. Deleted - link local (fe80::/64) route
3. Deleted - multicast (ff00::/8) route
4. Deleted - unicast address (123:2:3:4:5:6:7:8/64)
5. Deleted - link local address

C. re-configure the unicast Ipv6 address (say 123:2:3:4:5:6:7:8/64) on
the interface. (link-local will NOT be assigned as interface is down)

You wil see following netlink notifications:
6. Added - unicast address (123:2:3:4:5:6:7:8/64)
7. Added - unicast address connected route (123:2:3:4::/64)
8. Added - multicast (ff00::/8) route
9. Added - link local (fe80::/64) route
etc.

I am not sure why #7, #8 & #9 occured. It doesn't happen in case of
IPv4. The routes show up when interface reaches up state. Perhaps my
kernel is old and that could be reason for this beahvior.

BTW I am using 2.6.21 with following cherry-picked disable_ipv6 patches=
:
- ipv6: Add disable_ipv6 sysctl to disable IPv6 operaion on specific
interface(commit:778d80be52699596bf70e0eb0761cf5e1e46088d)
- ipv6: Plug sk_buff leak in ipv6_rcv (net/ipv6/ip6_input.c) (commit:
71f6f6dfdf7c7a67462386d9ea05c1095a89c555)
- IPv6: Add 'autoconf' and 'disable_ipv6' module parameters (ONLY
interface specific behavior)

Thanks very much for your help.
Mahesh

On Tue, Jul 20, 2010 at 4:48 PM, David Miller <davem@davemloft.net> wro=
te:
> From: Brian Haley <brian.haley@hp.com>
> Date: Tue, 20 Jul 2010 16:34:30 -0400
>
>> I believe the easiest way to fix this is the following patch, can
>> you please test it?
> =A0...
>> If the interface has IPv6 disabled, don't add a multicast or
>> link-local route since we won't be adding a link-local address.
>>
>> Reported-by: Mahesh Kelkar <maheshkelkar@gmail.com>
>> Signed-off-by: Brian Haley <brian.haley@hp.com>
>
> This looks good to me, let me know when it has been tested.
>
