From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3] packet: fix use after free race in send path when
 dev is released
Date: Thu, 21 Nov 2013 13:18:04 -0500 (EST)
Message-ID: <20131121.131804.553779665697649670.davem@davemloft.net>
References: <1385049058-1946-1-git-send-email-dborkman@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, noureddine@aristanetworks.com,
	greearb@candelatech.com, eric.dumazet@gmail.com
To: dborkman@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:43495 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752640Ab3KUSSG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Nov 2013 13:18:06 -0500
In-Reply-To: <1385049058-1946-1-git-send-email-dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Borkmann <dborkman@redhat.com>
Date: Thu, 21 Nov 2013 16:50:58 +0100

> Salam reported a use after free bug in PF_PACKET that occurs when
> we're sending out frames on a socket bound device and suddenly the
> net device is being unregistered. It appears that commit 827d9780
> introduced a possible race condition between {t,}packet_snd() and
> packet_notifier(). In the case of a bound socket, packet_notifier()
> can drop the last reference to the net_device and {t,}packet_snd()
> might end up suddenly sending a packet over a freed net_device.
> 
> To avoid reverting 827d9780 and thus introducing a performance
> regression compared to the current state of things, we decided to
> hold a cached RCU protected pointer to the net device and maintain
> it on write side via bind spin_lock protected register_prot_hook()
> and __unregister_prot_hook() calls.
> 
> In {t,}packet_snd() path, we access this pointer under rcu_read_lock
> through packet_cached_dev_get() that holds reference to the device
> to prevent it from being freed through packet_notifier() while
> we're in send path. This is okay to do as dev_put()/dev_hold() are
> per-cpu counters, so this should not be a performance issue. Also,
> the code simplifies a bit as we don't need need_rls_dev anymore.
> 
> Fixes: 827d978037d7 ("af-packet: Use existing netdev reference for bound sockets.")
> Reported-by: Salam Noureddine <noureddine@aristanetworks.com>
> Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
> Signed-off-by: Salam Noureddine <noureddine@aristanetworks.com>

Applied and queued up for -stable, thanks.
