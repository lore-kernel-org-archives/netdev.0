From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [ROSE] [AX25] possible circular locking
Date: Tue, 18 Dec 2007 14:52:02 +0100
Message-ID: <20071218135202.GA2023@ff.dom.local>
References: <47664A0C.4060903@free.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Alexey Dobriyan <adobriyan@gmail.com>,
	Ralf Baechle DL5RB <ralf@linux-mips.org>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Bernard Pidoux F6BVP <f6bvp@free.fr>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.173]:56166 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754924AbXLRNqy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Dec 2007 08:46:54 -0500
Received: by ug-out-1314.google.com with SMTP id z38so96446ugc.16
        for <netdev@vger.kernel.org>; Tue, 18 Dec 2007 05:46:53 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <47664A0C.4060903@free.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Dec 17, 2007 at 11:06:04AM +0100, Bernard Pidoux F6BVP wrote:
> Hi,
>
>
> When I killall kissattach I can see the following message.
>
> This happens on kernel 2.6.24-rc5 already patched with the 6 previously
> patches I sent recently.
>
>
> =======================================================
> [ INFO: possible circular locking dependency detected ]
> 2.6.23.9 #1
> -------------------------------------------------------
> kissattach/2906 is trying to acquire lock:
>  (linkfail_lock){-+..}, at: [<d8bd4603>] ax25_link_failed+0x11/0x39 [ax25]
>
> but task is already holding lock:
>  (ax25_list_lock){-+..}, at: [<d8bd7c7c>] ax25_device_event+0x38/0x84
> [ax25]
>
> which lock already depends on the new lock.
>
>
> the existing dependency chain (in reverse order) is:
...

It seems, lockdep is warried about the different order here:

#1 (rose_neigh_list_lock){-+..}:
#3 (ax25_list_lock){-+..}:

#0 (linkfail_lock){-+..}:
#1 (rose_neigh_list_lock){-+..}:

#3 (ax25_list_lock){-+..}:
#0 (linkfail_lock){-+..}:

So, ax25_list_lock could be taken before and after linkfail_lock. 
I don't know if this three-thread clutch is very probable (or
possible at all), but it seems this other bug nearby reported by
Bernard ("[...] system impossible to reboot with linux-2.6.24-rc5")
could have similar source - namely ax25_list_lock held by
ax25_kill_by_device() during ax25_disconnect(). It looks like the
only place which calls ax25_disconnect() this way, so I guess, it
isn't necessary. But, since I don't know AX25 & ROSE at all, this
should be necessarily verified by somebody who knows these things.

I attach here my very experimental proposal with breaking the lock
for ax25_disconnect(), with some failsafe and debugging because of
this, but, if in this special case the lock is required for some
other reasons, then this patch should be dumped, of course.

Regards,
Jarek P.

WARNING:
not tested, not even compiled, needs some ack before testing!

---

diff -Nurp linux-2.6.24-rc5-/net/ax25/af_ax25.c linux-2.6.24-rc5+/net/ax25/af_ax25.c
--- linux-2.6.24-rc5-/net/ax25/af_ax25.c	2007-12-17 13:29:19.000000000 +0100
+++ linux-2.6.24-rc5+/net/ax25/af_ax25.c	2007-12-18 13:36:05.000000000 +0100
@@ -87,10 +87,19 @@ static void ax25_kill_by_device(struct n
 		return;
 
 	spin_lock_bh(&ax25_list_lock);
+again:
 	ax25_for_each(s, node, &ax25_list) {
 		if (s->ax25_dev == ax25_dev) {
+			struct hlist_node *nn = node->next;
+
 			s->ax25_dev = NULL;
+			spin_unlock_bh(&ax25_list_lock);
 			ax25_disconnect(s, ENETUNREACH);
+			spin_lock_bh(&ax25_list_lock);
+			if (nn != node->next) {
+				WARN_ON_ONCE(1);
+				goto again;
+			}
 		}
 	}
 	spin_unlock_bh(&ax25_list_lock);
