From: Ben Greear <greearb@candelatech.com>
Subject: Re: [net-next] ipv6: Enable netlink notification for tentative addresses.
Date: Thu, 26 Aug 2010 11:50:24 -0700
Message-ID: <4C76B770.4030800@candelatech.com>
References: <1282760777-15381-1-git-send-email-greearb@candelatech.com> <20100825.212456.71107442.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:50958 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754587Ab0HZSu2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Aug 2010 14:50:28 -0400
In-Reply-To: <20100825.212456.71107442.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/25/2010 09:24 PM, David Miller wrote:
> From: Ben Greear<greearb@candelatech.com>
> Date: Wed, 25 Aug 2010 11:26:17 -0700
>
>> By default, netlink messages are not sent when an IPv6 address
>> is added if it is in tentative state.  This makes it harder
>> for user-space applications to know the current state of the
>> IPv6 addresses.  This patch adds an ipv6 sysctl that will
>> allow tentative address notifications to be sent.  The sysctl
>> is off by default.
>>
>> Signed-off-by: Ben Greear<greearb@candelatech.com>
>
> It's inconsistent to send two NEWADDR events for the same add.

The ipv6 code seems to send a NEWADDR message every time there
is a flag change for the IPv6 addresses.  I suppose this better
lets code that cares know the state of things.

The patch below should always send an even on add, but it will
keep all the other events.  If you really think I should
elide some of the others, I'll make the change, but I think
it might be a bad idea.

If the patch below looks ok as is, let me know and I'll
resend it as a git patch.

Thanks,
Ben

[greearb@ben-dt2 net-next-2.6]$ git diff
diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index ab70a3f..7aa7535 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -125,6 +125,7 @@ static void ipv6_regen_rndid(unsigned long data);

  static int ipv6_generate_eui64(u8 *eui, struct net_device *dev);
  static int ipv6_count_addresses(struct inet6_dev *idev);
+static void inet6_ifa_notify(int event, struct inet6_ifaddr *ifa);

  /*
   *     Configured unicast address hash table
@@ -697,9 +698,10 @@ ipv6_add_addr(struct inet6_dev *idev, const struct in6_addr *addr, int pfxlen,
  out2:
         rcu_read_unlock_bh();

-       if (likely(err == 0))
+       if (likely(err == 0)) {
                 atomic_notifier_call_chain(&inet6addr_chain, NETDEV_UP, ifa);
-       else {
+               inet6_ifa_notify(RTM_NEWADDR, ifa);
+       } else {
                 kfree(ifa);
                 ifa = ERR_PTR(err);
         }


-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com

