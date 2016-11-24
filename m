From: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
Subject: Re: [PATCH 12/20] net/iucv: Convert to hotplug state machine
Date: Thu, 24 Nov 2016 10:10:46 +0100
Message-ID: <20161124091046.hixy3j4ibt7xzezr@linutronix.de>
References: <20161117183541.8588-1-bigeasy@linutronix.de>
 <20161117183541.8588-13-bigeasy@linutronix.de>
 <62f8abea-093c-cac5-ffb1-7b8710aa0a91@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: linux-kernel@vger.kernel.org, rt@linutronix.de,
        "David S. Miller" <davem@davemloft.net>,
        linux-s390@vger.kernel.org, netdev@vger.kernel.org
To: Ursula Braun <ubraun@linux.vnet.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Galois.linutronix.de ([146.0.238.70]:36500 "EHLO
        Galois.linutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S934150AbcKXJKv (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 24 Nov 2016 04:10:51 -0500
Content-Disposition: inline
In-Reply-To: <62f8abea-093c-cac5-ffb1-7b8710aa0a91@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2016-11-23 19:04:16 [+0100], Ursula Braun wrote:
> Sebastian,
Hallo Ursula,

> your patch looks good to me. I run successfully some small tests with it.
> I want to suggest a small change in iucv_init() to keep the uniform technique
> of undo labels below. Do you agree?

So what you ask for is:

diff --git a/net/iucv/iucv.c b/net/iucv/iucv.c
index f0d6afc5d4a9..8f7ef167c45a 100644
--- a/net/iucv/iucv.c
+++ b/net/iucv/iucv.c
@@ -2038,16 +2038,16 @@ static int __init iucv_init(void)
 	rc = cpuhp_setup_state(CPUHP_NET_IUCV_PREPARE, "net/iucv:prepare",
 			       iucv_cpu_prepare, iucv_cpu_dead);
 	if (rc)
-		goto out_free;
+		goto out_dev;
 	rc = cpuhp_setup_state(CPUHP_AP_ONLINE_DYN, "net/iucv:online",
 			       iucv_cpu_online, iucv_cpu_down_prep);
 	if (rc < 0)
-		goto out_free;
+		goto out_prep;
 	iucv_online = rc;
 
 	rc = register_reboot_notifier(&iucv_reboot_notifier);
 	if (rc)
-		goto out_free;
+		goto out_remove_hp;
 	ASCEBC(iucv_error_no_listener, 16);
 	ASCEBC(iucv_error_no_memory, 16);
 	ASCEBC(iucv_error_pathid, 16);
@@ -2061,11 +2061,11 @@ static int __init iucv_init(void)
 
 out_reboot:
 	unregister_reboot_notifier(&iucv_reboot_notifier);
-out_free:
-	if (iucv_online)
-		cpuhp_remove_state(iucv_online);
+out_remove_hp:
+	cpuhp_remove_state(iucv_online);
+out_prep:
 	cpuhp_remove_state(CPUHP_NET_IUCV_PREPARE);
-
+out_dev:
 	root_device_unregister(iucv_root);
 out_int:
 	unregister_external_irq(EXT_IRQ_IUCV, iucv_external_interrupt);

This is your change including the removal of the `if' check in the
`out_remove' label which got renamed to `out_remove_hp'.
Of course, I agree with this change and a proper patch will follow in a
few hours if nobody objects.

> Kind regards, Ursula

Sebastian
