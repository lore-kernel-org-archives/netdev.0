From: Nicolas Pitre <nicolas.pitre@linaro.org>
Subject: Re: [PATCH 1/2] ptp_clock: allow for it to be optional
Date: Mon, 19 Sep 2016 10:10:21 -0400 (EDT)
Message-ID: <alpine.LFD.2.20.1609190942230.9311@knanqh.ubzr>
References: <1474257070-4255-1-git-send-email-nicolas.pitre@linaro.org> <1474257070-4255-2-git-send-email-nicolas.pitre@linaro.org> <20160919142553.3fb682ba@griffin>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: John Stultz <john.stultz@linaro.org>,
        Thomas Gleixner <tglx@linutronix.de>,
        Richard Cochran <richardcochran@gmail.com>,
        Josh Triplett <josh@joshtriplett.org>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Jiri Benc <jbenc@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f170.google.com ([209.85.216.170]:35220 "EHLO
        mail-qt0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1758464AbcISOKZ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 19 Sep 2016 10:10:25 -0400
Received: by mail-qt0-f170.google.com with SMTP id 93so72020845qtg.2
        for <netdev@vger.kernel.org>; Mon, 19 Sep 2016 07:10:24 -0700 (PDT)
In-Reply-To: <20160919142553.3fb682ba@griffin>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 19 Sep 2016, Jiri Benc wrote:

> On Sun, 18 Sep 2016 23:51:09 -0400, Nicolas Pitre wrote:
> > And to make it possible for PTP to be configured out, the select statement
> > in the Kconfig entry for those ethernet drivers is changed from selecting
> > PTP_1588_CLOCK to PTP_1588_CLOCK_SELECTED whose purpose is to indicate the
> > default Kconfig value for the PTP subsystem.
> 
> With this patch applied, the user is free to set a NIC driver as built
> in and PTP_1588_CLOCK as a module, right? If so, that would lead to
> non-functional PTP without any warning due to the use of IS_REACHABLE.
> That doesn't sound right. Could easily cause hours of headache to
> someone.
> 
> Or is this handled somehow?

I don't see how to remove the ability to select m for PTP_1588_CLOCK 
based on (PTP_1588_CLOCK_SELECTED = y).

What about this on top then:

diff --git a/include/linux/ptp_clock_kernel.h b/include/linux/ptp_clock_kernel.h
index 4c29eb8e53..74079b2fcf 100644
--- a/include/linux/ptp_clock_kernel.h
+++ b/include/linux/ptp_clock_kernel.h
@@ -207,7 +207,16 @@ int ptp_find_pin(struct ptp_clock *ptp,
 #else
 static inline struct ptp_clock *ptp_clock_register(struct ptp_clock_info *info,
 						   struct device *parent)
-{ return NULL; }
+{
+	if (IS_MODULE(CONFIG_PTP_1588_CLOCK)) {
+		pr_warn("%s is built-in while PTP clock subsystem is modular, "
+			"PTP clock ignored\n", KBUILD_MODNAME);
+	} else {
+		pr_warn("ignoring PTP clock from %s as PTP clock subsystem "
+			"is configured out\n", KBUILD_MODNAME);
+	}
+	return NULL;
+}
 static inline int ptp_clock_unregister(struct ptp_clock *ptp)
 { return 0; }
 static inline void ptp_clock_event(struct ptp_clock *ptp,
