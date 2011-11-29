From: =?utf-8?B?Iklnb3IgTWFyYXZpxIci?= <igorm@etf.rs>
Subject: Re: [PATCH 1/1] netstamp_needed shouldn't be jump_label_key
Date: Tue, 29 Nov 2011 10:03:03 +0100
Message-ID: <fba9911084786bf04747c0350e774615.squirrel@kondor.etf.bg.ac.rs>
References: <igorm@etf.rs> <1322511796-6908-1-git-send-email-igorm@etf.rs>
    <1322511796-6908-2-git-send-email-igorm@etf.rs>
    <1322512426.2970.15.camel@edumazet-laptop>
    <1322515010.2970.24.camel@edumazet-laptop>
Reply-To: igorm@etf.rs
Mime-Version: 1.0
Content-Type: text/plain;charset=utf-8
Content-Transfer-Encoding: 8BIT
Cc: igorm@etf.rs, netdev@vger.kernel.org
To: "Eric Dumazet" <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.etf.rs ([147.91.14.170]:60895 "EHLO mx2.etf.bg.ac.rs"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753011Ab1K2JDJ convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Nov 2011 04:03:09 -0500
In-Reply-To: <1322515010.2970.24.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>
> Could you test following patch ?
>

I've just put it to compile. I'l let you know soon as it finishes compiling.

I have one proposition for your patch. To put WARN_ON before in ifdef endif,
because we don't needed if we don't have HAVE_JUMP_LABEL, and also to check it
before using jump_label_dec.

Also I have few questions :)

First - why can't we use spin_lock on jump_label?

I know that You said that is because we are using mutex_lock in
arch_jump_label_transform() or text_poke_smp(), but I don't see why couldn't
we use mutex_lock inside spin_lock.

To me using spin_lock_irqsave and spin_lock_irqrestore does sound like as most logical solution.
With that lock, we would be sure that our mutex_lock in arch_jump_label_transform() or text_poke_smp()
isn't going to be interrupted.
Please correct if I'm wrong.

Also I saw that you put calling of net_enable_timestamp outside of spin_lock_bh
Why?

BR
Igor

[PATCH 1/1] jump_label warning if_interrupt

Move warning on the top of function net_enable_timestamp,
so we would be also warn if we are going to jump_label_dec in interrupt

Signed-off-by: Igor Maravic <igorm@etf.rs>

:100644 100644 45eab03... ef23cf7... M	net/core/dev.c

diff --git a/net/core/dev.c b/net/core/dev.c
index 45eab03..ef23cf7 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -1453,6 +1453,7 @@ void net_enable_timestamp(void)
 {
 #ifdef HAVE_JUMP_LABEL
 	int deferred = atomic_xchg(&netstamp_needed_deferred, 0);
+	WARN_ON(in_interrupt());

 	if (deferred) {
 		while (--deferred)
@@ -1460,7 +1461,6 @@ void net_enable_timestamp(void)
 		return;
 	}
 #endif
-	WARN_ON(in_interrupt());
 	jump_label_inc(&netstamp_needed);
 }
 EXPORT_SYMBOL(net_enable_timestamp);
-- 
1.7.5.4
