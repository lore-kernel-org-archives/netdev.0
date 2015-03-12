From: Nikolay Aleksandrov <nikolay@redhat.com>
Subject: Re: [PATCH net-next 0/4] bonding work-queues, try_rtnl() & notifications
Date: Thu, 12 Mar 2015 13:09:10 +0100
Message-ID: <550181E6.2080100@redhat.com>
References: <1426139673-26995-1-git-send-email-maheshb@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: Maciej Zenczykowski <maze@google.com>,
	netdev <netdev@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>
To: Mahesh Bandewar <maheshb@google.com>,
	Jay Vosburgh <j.vosburgh@gmail.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	Veaceslav Falico <vfalico@gmail.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:40342 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754059AbbCLMJX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 12 Mar 2015 08:09:23 -0400
In-Reply-To: <1426139673-26995-1-git-send-email-maheshb@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/03/15 06:54, Mahesh Bandewar wrote:
> This patch series tries to address the issue discovered in various work-
> queues and the way these handlers deal with the RTNL. Especially for 
> notification handling. If RTNL can not be acquired, these handlers ignore
> sending notifications and just re-arm the timer. This could be very 
> problematic if the re-arm timer has larger value (e.g. in minutes).
> 
> 
> Mahesh Bandewar (4):
>   bonding: Handle notifications during work-queue processing gracefully
>   bonding: Do not ignore notifications for miimon-work-queue
>   bonding: Do not ignore notifications for AD-work-queue
>   bonding: Do not ignore notifications for ARP-work-queue
> 
>  drivers/net/bonding/bond_3ad.c  | 22 ++++++++++++---
>  drivers/net/bonding/bond_main.c | 62 ++++++++++++++++++++++++-----------------
>  include/net/bonding.h           | 22 +++++++++++++++
>  3 files changed, 77 insertions(+), 29 deletions(-)
> 

Hello Mahesh,
The current behaviour was chosen as a best-effort type because such change
could skew the monitoring/AD timers because you re-schedule every time you
cannot acquire rtnl and move their timers with 1 tick ahead which could lead 
to false link drops, state machines running late and so on.
Currently the monitoring/AD functions have priority over the notifications as in
we might miss a notification but we try not to miss a monitoring/AD event, thus I'd
suggest to solve this in a different manner. If you'd like to have the best of both
worlds i.e. not miss a monitoring event and also not miss any notifications you should
use a different strategy. One idea would be to use a new "work" which checks some
notification bits and sends various types of notifications, then the monitoring
works can just schedule it whenever they need to send notifications and can keep their
running times accurate. The new work should handle the rtnl side of things and re-schedule
itself if necessary, now that is only an idea from the top of my head I haven't checked
if it's feasible or if there isn't a better approach so I'd be open to other ideas. Also
if you do decide to go this way, you should be very careful with the order of work
cancellation in bond_close(). In fact, IIRC, this has already been done by the slave
array update that you introduced and also by the igmp resend work.

There's also a bug in bond_should_notify_peers(), as in it's not RCU safe
on its own, it's currently safe because its callers use it in RCU protected sections
but here you move it outside so it should be fixed first (take a look at how "slave" is used).

Nik
