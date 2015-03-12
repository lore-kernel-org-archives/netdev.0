From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next 0/4] bonding work-queues, try_rtnl() &
 notifications
Date: Thu, 12 Mar 2015 07:11:06 -0700
Message-ID: <1426169466.11398.158.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1426139673-26995-1-git-send-email-maheshb@google.com>
	 <550181E6.2080100@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Mahesh Bandewar <maheshb@google.com>,
	Jay Vosburgh <j.vosburgh@gmail.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	Veaceslav Falico <vfalico@gmail.com>,
	David Miller <davem@davemloft.net>,
	Maciej Zenczykowski <maze@google.com>,
	netdev <netdev@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>
To: Nikolay Aleksandrov <nikolay@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f181.google.com ([209.85.213.181]:45370 "EHLO
	mail-ig0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753847AbbCLOLJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Mar 2015 10:11:09 -0400
Received: by igjz20 with SMTP id z20so16887345igj.4
        for <netdev@vger.kernel.org>; Thu, 12 Mar 2015 07:11:08 -0700 (PDT)
In-Reply-To: <550181E6.2080100@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2015-03-12 at 13:09 +0100, Nikolay Aleksandrov wrote:
> On 12/03/15 06:54, Mahesh Bandewar wrote:
> > This patch series tries to address the issue discovered in various work-
> > queues and the way these handlers deal with the RTNL. Especially for 
> > notification handling. If RTNL can not be acquired, these handlers ignore
> > sending notifications and just re-arm the timer. This could be very 
> > problematic if the re-arm timer has larger value (e.g. in minutes).
> > 
> > 
> > Mahesh Bandewar (4):
> >   bonding: Handle notifications during work-queue processing gracefully
> >   bonding: Do not ignore notifications for miimon-work-queue
> >   bonding: Do not ignore notifications for AD-work-queue
> >   bonding: Do not ignore notifications for ARP-work-queue
> > 
> >  drivers/net/bonding/bond_3ad.c  | 22 ++++++++++++---
> >  drivers/net/bonding/bond_main.c | 62 ++++++++++++++++++++++++-----------------
> >  include/net/bonding.h           | 22 +++++++++++++++
> >  3 files changed, 77 insertions(+), 29 deletions(-)
> > 
> 
> Hello Mahesh,
> The current behaviour was chosen as a best-effort type because such change
> could skew the monitoring/AD timers because you re-schedule every time you
> cannot acquire rtnl and move their timers with 1 tick ahead which could lead 
> to false link drops, state machines running late and so on.
> Currently the monitoring/AD functions have priority over the notifications as in
> we might miss a notification but we try not to miss a monitoring/AD event, thus I'd
> suggest to solve this in a different manner. If you'd like to have the best of both
> worlds i.e. not miss a monitoring event and also not miss any notifications you should
> use a different strategy. 


I think I disagree here.

All rtnl_trylock() call sites must be very careful about what they are
doing.

bonding is not, and we should fix this.

Mahesh fix seems very reasonable. If you need something else, please
provide your own patch.

When code is the following :

        if (!rtnl_trylock())
                 return;
        call_netdevice_notifiers(NETDEV_NOTIFY_PEERS, bond->dev);
        rtnl_unlock();

Then, one must understand what happens if at this point rtnl_trylock()
never succeeds.

Like, what happens if you remove the whole thing.

If the code is not needed, remove it, instead of having flaky behavior.



diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index c026ce9cd7b6f52f1a6bff88b9e6053b13ecebcd..958c9a46345a59daee2dbd34d859b17af94931bc 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -2167,12 +2167,6 @@ re_arm:
 	if (bond->params.miimon)
 		queue_delayed_work(bond->wq, &bond->mii_work, delay);
 
-	if (should_notify_peers) {
-		if (!rtnl_trylock())
-			return;
-		call_netdevice_notifiers(NETDEV_NOTIFY_PEERS, bond->dev);
-		rtnl_unlock();
-	}
 }
 
 static bool bond_has_this_ip(struct bonding *bond, __be32 ip)
