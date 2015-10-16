From: Jan Blunck <jblunck@infradead.org>
Subject: Re: [PATCH] ipv6: no addrconf for slave devices
Date: Fri, 16 Oct 2015 17:57:44 +0200
Message-ID: <CALe+Z02xUZEeRMBfTneJaGFH0TQFoQt9WcJ67ogbQwXEs6p8Ew@mail.gmail.com>
References: <1444990911-27458-1-git-send-email-jblunck@infradead.org>
	<20151016115457.GE2194@nanopsycho.orion>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: davem@davemloft.net, Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	jmorris@namei.org, yoshfuji@linux-ipv6.org,
	Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org,
	LKML <linux-kernel@vger.kernel.org>, fubar@us.ibm.com
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f170.google.com ([209.85.212.170]:35751 "EHLO
	mail-wi0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754033AbbJPP5q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Oct 2015 11:57:46 -0400
In-Reply-To: <20151016115457.GE2194@nanopsycho.orion>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Oct 16, 2015 at 1:54 PM, Jiri Pirko <jiri@resnulli.us> wrote:
> Fri, Oct 16, 2015 at 12:21:51PM CEST, jblunck@infradead.org wrote:
>>If a device without the IFF_SLAVE flag set (e.g. team, bridge, openvswitch
>>vport, batman) is enslaved and IPv6 is active then addrconf will be
>>initiated and a link-local address is added to the slave interface.
>>
>>This patch alters the behavior so that addrconf will only run on the master
>>device itself. This is achieved by checking the device tree instead of
>>checking for a specific flag.
>>
>>Signed-off-by: Jan Blunck <jblunck@infradead.org>
>>---
>> net/ipv6/addrconf.c | 6 +++++-
>> 1 file changed, 5 insertions(+), 1 deletion(-)
>>
>>diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
>>index 9001133..26d61f0 100644
>>--- a/net/ipv6/addrconf.c
>>+++ b/net/ipv6/addrconf.c
>>@@ -3141,8 +3141,12 @@ static int addrconf_notify(struct notifier_block *this, unsigned long event,
>>
>>       case NETDEV_UP:
>>       case NETDEV_CHANGE:
>>-              if (dev->flags & IFF_SLAVE)
>>+              /* If a master is set stop IPv6 on this interface */
>>+              if (netdev_master_upper_dev_get(dev)) {
>>+                      if (idev)
>>+                              addrconf_ifdown(dev, 1);
>
> This breaks teamd if it's using NS/NA ping link-watch on link-local addresses.
>
> What is the reason for this patch? Does it recolve any issue you are
> having?

I don't think that enslaved ports should get network layer addresses.
This is one example with a team device:

3: eth1: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast
master team0 state UP group default qlen 1000
    link/ether 52:54:00:ef:5f:a1 brd ff:ff:ff:ff:ff:ff
    inet6 fe80::5054:ff:feef:5fa1/64 scope link
       valid_lft forever preferred_lft forever
4: eth2: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast
master team0 state UP group default qlen 1000
    link/ether 52:54:00:ef:5f:a1 brd ff:ff:ff:ff:ff:ff
    inet6 fe80::5054:ff:feef:5fa1/64 scope link
       valid_lft forever preferred_lft forever
6: team0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue
state UP group default
    link/ether 52:54:00:ef:5f:a1 brd ff:ff:ff:ff:ff:ff
    inet6 fe80::5054:ff:feef:5fa1/64 scope link
       valid_lft forever preferred_lft forever

All link-layer addresses are identical due to the fact that the link
aggregation group is syncing the MAC addresses. Having the IPv6
link-local address set in this case is pretty useless. The partner
device is unable to differentiate if the port is addressed or the team
device. Even if the addrconf started before the device was enslaved
(and therefore at least one port got a different IPv6 link-local
address than the link aggregation group) the partner device usually
learns the address for the aggregated link.

For LACP the standard states that one port should only bind to at most
one aggregator. The additional IPv6 link-local address allows the port
to be used by another stack besides the aggregator. Besides that, the
distribution of any user traffic (e.g. ICMPv6) is forbidden in LACP
before the partner aggregator signals being ready. So having the
link-local traffic on the wire is clearly a violation of that.

In other cases like openvswitch the link-local address is added to the
system but it is not usable since the bridge port stays in state
UNKNOWN.

Regards,
Jan
