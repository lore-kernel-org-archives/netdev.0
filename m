From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] net: rps: fix data stall after hotplug
Date: Fri, 20 Mar 2015 04:50:39 -0700
Message-ID: <1426852239.25985.33.camel@edumazet-glaptop2.roam.corp.google.com>
References: <b3ecb218932daa656a796cfa6e9e62b9.squirrel@www.codeaurora.org>
	 <1426801839.25985.15.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: subashab@codeaurora.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f177.google.com ([209.85.223.177]:33419 "EHLO
	mail-ie0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750977AbbCTLuh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Mar 2015 07:50:37 -0400
Received: by iecvj10 with SMTP id vj10so90579553iec.0
        for <netdev@vger.kernel.org>; Fri, 20 Mar 2015 04:50:36 -0700 (PDT)
In-Reply-To: <1426801839.25985.15.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2015-03-19 at 14:50 -0700, Eric Dumazet wrote:

> Are you seeing this race on x86 ?
> 
> If IPI are not reliable on your arch, I am guessing you should fix them.
> 
> Otherwise, even without hotplug you'll have hangs.

Please try instead this patch :

diff --git a/net/core/dev.c b/net/core/dev.c
index 5d43e010ef870a6ab92895297fe18d6e6a03593a..baa4bff9a6fbe0d77d7921865c038060cb5efffd 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -4320,9 +4320,8 @@ static void net_rps_action_and_irq_enable(struct softnet_data *sd)
 		while (remsd) {
 			struct softnet_data *next = remsd->rps_ipi_next;
 
-			if (cpu_online(remsd->cpu))
-				smp_call_function_single_async(remsd->cpu,
-							   &remsd->csd);
+			smp_call_function_single_async(remsd->cpu,
+						       &remsd->csd);
 			remsd = next;
 		}
 	} else
