From: Veaceslav Falico <vfalico@redhat.com>
Subject: Re: [PATCH net] netconsole: fix NULL pointer dereference
Date: Thu, 24 Oct 2013 12:21:47 +0200
Message-ID: <20131024102147.GD16787@redhat.com>
References: <1382533489-19248-1-git-send-email-nikolay@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Cc: netdev@vger.kernel.org, davem@davemloft.net
To: Nikolay Aleksandrov <nikolay@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:8587 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754516Ab3JXKX7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 24 Oct 2013 06:23:59 -0400
Content-Disposition: inline
In-Reply-To: <1382533489-19248-1-git-send-email-nikolay@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Oct 23, 2013 at 03:04:49PM +0200, Nikolay Aleksandrov wrote:
>We need to disable the netconsole (enabled = 0) before setting nt->np.dev
>to NULL because otherwise we might still have users after the
>netpoll_cleanup() since nt->enabled is set afterwards and we can
>have a message which will result in a NULL pointer dereference.
>It is very easy to hit dereferences all over the netpoll_send_udp function
>by running the following two loops in parallel:
>while [ 1 ]; do echo 1 > enabled; echo 0 > enabled; done;
>while [ 1 ]; do echo 00:11:22:33:44:55 > remote_mac; done;
>(the second loop is to generate messages, it can be done by anything)
>
>We're safe to set nt->np.dev = NULL and nt->enabled = 0 with the spinlock
>since it's required in the write_msg() function.
>
>Signed-off-by: Nikolay Aleksandrov <nikolay@redhat.com>
>---
>Taking the spinlock seems like the cleanest way to insure there's noone
>running in parallel, but I'm open to suggestions as I'm not satisfied with
>the looks of this. I'll prepare a net-next patchset for netconsole soon to
>clean it up properly, all of these can be easily simplified.

First when I've seen 'spin_lock(); a = 1; spin_unlock()' I've thought
"WTF?", however indeed it will stop us racing with write_msg().

FWIW...

Reviewed-by: Veacelsav Falico <vfalico@redhat.com>

>
> drivers/net/netconsole.c | 8 ++++++++
> 1 file changed, 8 insertions(+)
>
>diff --git a/drivers/net/netconsole.c b/drivers/net/netconsole.c
>index adeee61..1505dcb 100644
>--- a/drivers/net/netconsole.c
>+++ b/drivers/net/netconsole.c
>@@ -310,6 +310,7 @@ static ssize_t store_enabled(struct netconsole_target *nt,
> 			     const char *buf,
> 			     size_t count)
> {
>+	unsigned long flags;
> 	int enabled;
> 	int err;
>
>@@ -342,6 +343,13 @@ static ssize_t store_enabled(struct netconsole_target *nt,
> 		printk(KERN_INFO "netconsole: network logging started\n");
>
> 	} else {	/* 0 */
>+		/* We need to disable the netconsole before cleaning it up
>+		 * otherwise we might end up in write_msg() with
>+		 * nt->np.dev == NULL and nt->enabled == 1
>+		 */
>+		spin_lock_irqsave(&target_list_lock, flags);
>+		nt->enabled = 0;
>+		spin_unlock_irqrestore(&target_list_lock, flags);
> 		netpoll_cleanup(&nt->np);
> 	}
>
>-- 
>1.8.1.4
>
>--
>To unsubscribe from this list: send the line "unsubscribe netdev" in
>the body of a message to majordomo@vger.kernel.org
>More majordomo info at  http://vger.kernel.org/majordomo-info.html
