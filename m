From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] netconsole: fix deadlock when removing net driver that
 netconsole is using (v2)
Date: Fri, 22 Apr 2011 11:40:33 -0700 (PDT)
Message-ID: <20110422.114033.104072820.davem@davemloft.net>
References: <1303481216-10348-1-git-send-email-nhorman@tuxdriver.com>
	<1303495859-12279-1-git-send-email-nhorman@tuxdriver.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: nhorman@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:58669
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754858Ab1DVSlH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Apr 2011 14:41:07 -0400
In-Reply-To: <1303495859-12279-1-git-send-email-nhorman@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Neil Horman <nhorman@tuxdriver.com>
Date: Fri, 22 Apr 2011 14:10:59 -0400

> @@ -683,9 +684,16 @@ static int netconsole_netdev_event(struct notifier_block *this,
>  				 * rtnl_lock already held
>  				 */
>  				if (nt->np.dev) {
> +					spin_unlock_irqrestore(
> +							      &target_list_lock,
> +							      flags);
>  					__netpoll_cleanup(&nt->np);
> +					spin_lock_irqsave(&target_list_lock,
> +							  flags);
>  					dev_put(nt->np.dev);
>  					nt->np.dev = NULL;
> +					netconsole_target_put(nt);
> +					goto restart;

If you drop the lock here, another cpu can put the device and set it
to NULL.

In which case you'll double release when you regrab the lock here.

Too bad you can't NULL out the device before dropping the lock,
because that way would be able to ensure you'd be the only releaser.

But that won't work because __netpoll_cleanup() wants the device
pointer to be set.

Hmmm...
