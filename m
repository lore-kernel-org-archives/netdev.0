From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [Patch] net: allow calling rtmsg_ifinfo() in atomic
Date: Tue, 14 Aug 2012 19:40:51 +0100
Message-ID: <1344969651.2690.6.camel@bwh-desktop.uk.solarflarecom.com>
References: <1344940096-5548-1-git-send-email-amwang@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, "David S. Miller" <davem@davemloft.net>,
	John Fastabend <john.r.fastabend@intel.com>,
	Greg Rose <gregory.v.rose@intel.com>,
	Thomas Graf <tgraf@suug.ch>, Eric Dumazet <edumazet@google.com>
To: Cong Wang <amwang@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:62164 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1757066Ab2HNSk6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Aug 2012 14:40:58 -0400
In-Reply-To: <1344940096-5548-1-git-send-email-amwang@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2012-08-14 at 18:28 +0800, Cong Wang wrote:
> (Against net tree.)
> 
> When running 'systemctl restart network.service', I got the following
> warning:
> 
>  [ 1123.199677] 
>  [ 1123.310275] ===============================
>  [ 1123.442202] [ INFO: suspicious RCU usage. ]
>  [ 1123.558207] 3.6.0-rc1+ #109 Not tainted
>  [ 1123.665204] -------------------------------
>  [ 1123.768254] include/linux/rcupdate.h:430 Illegal context switch in RCU read-side critical section!
>  [ 1123.992320] 
>  [ 1123.992320] other info that might help us debug this:
>  [ 1123.992320] 
>  [ 1124.307382] 
>  [ 1124.307382] rcu_scheduler_active = 1, debug_locks = 0
>  [ 1124.522220] 2 locks held by sysctl/5710:
>  [ 1124.648364]  #0:  (rtnl_mutex){+.+.+.}, at: [<ffffffff81768498>] rtnl_trylock+0x15/0x17
>  [ 1124.882211]  #1:  (rcu_read_lock){.+.+.+}, at: [<ffffffff81871df8>] rcu_lock_acquire+0x0/0x29
[...]
> This is due to that we call rtmsg_ifinfo() with RCU read lock held,
> and because rtmsg_ifinfo() may block, this is invalid.
>
> This patch fixes it by allowing callees to specify GFP when
> calling it. In this case, netdev_features_change() calls it
> with GFP_ATOMIC.
[...]

This is not the right fix; netdev notifiers *should* be able to assume
they are called with only the RTNL lock held.  Anyway,
addrconf_forward_change() is called with the RTNL lock held so there is
no need for it to use RCU-protected iteration.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
