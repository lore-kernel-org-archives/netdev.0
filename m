From: =?utf-8?B?Iklnb3IgTWFyYXZpxIci?= <igorm@etf.rs>
Subject: Re: [PATCH 1/1] netstamp_needed shouldn't be jump_label_key
Date: Tue, 29 Nov 2011 10:48:54 +0100
Message-ID: <88caa73892721f74b81e72c1ff1a0be3.squirrel@kondor.etf.bg.ac.rs>
References: <igorm@etf.rs> <1322511796-6908-1-git-send-email-igorm@etf.rs>
    <1322511796-6908-2-git-send-email-igorm@etf.rs>
    <1322512426.2970.15.camel@edumazet-laptop>
    <1322515010.2970.24.camel@edumazet-laptop>
    <fba9911084786bf04747c0350e774615.squirrel@kondor.etf.bg.ac.rs>
    <1322559093.2970.102.camel@edumazet-laptop>
Reply-To: igorm@etf.rs
Mime-Version: 1.0
Content-Type: text/plain;charset=utf-8
Content-Transfer-Encoding: 8BIT
Cc: igorm@etf.rs, netdev@vger.kernel.org
To: "Eric Dumazet" <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.etf.rs ([147.91.14.169]:39073 "EHLO mx1.etf.bg.ac.rs"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753289Ab1K2JtB convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Nov 2011 04:49:01 -0500
In-Reply-To: <1322559093.2970.102.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> Its better to have coverage of the test, even on machines with no
> HAVE_JUMP_LABEL.
>
> So move the test before the
> #ifdef HAVE_JUMP_LABEL
>

Here is it.

PS. Tested the patch - it works.

[PATCH 1/1] Warning if_interrupt is true

Move warning on the top of function net_enable_timestamp,
so we would be also warn if we are going to use jump_label_dec in interrupt

Signed-off-by: Igor Maravic <igorm@etf.rs>

:100644 100644 45eab03... d358088... M	net/core/dev.c

diff --git a/net/core/dev.c b/net/core/dev.c
index 45eab03..d358088 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -1451,16 +1451,18 @@ static atomic_t netstamp_needed_deferred;

 void net_enable_timestamp(void)
 {
+	WARN_ON(in_interrupt());
 #ifdef HAVE_JUMP_LABEL
-	int deferred = atomic_xchg(&netstamp_needed_deferred, 0);
-
-	if (deferred) {
-		while (--deferred)
-			jump_label_dec(&netstamp_needed);
-		return;
+	{
+		int deferred = atomic_xchg(&netstamp_needed_deferred, 0);
+
+		if (deferred) {
+			while (--deferred)
+				jump_label_dec(&netstamp_needed);
+			return;
+		}
 	}
 #endif
-	WARN_ON(in_interrupt());
 	jump_label_inc(&netstamp_needed);
 }
 EXPORT_SYMBOL(net_enable_timestamp);
-- 
1.7.5.4
