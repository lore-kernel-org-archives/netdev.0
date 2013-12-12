From: Olof Johansson <olof@lixom.net>
Subject: Re: [PATCH v2 0/5] net: macb updates
Date: Wed, 11 Dec 2013 23:00:16 -0800
Message-ID: <CAOesGMjcmeiBfc=EOvWazebg-9vnMuQtRC0aeHJy7Q=02RdRPA@mail.gmail.com>
References: <1386720443-24100-1-git-send-email-soren.brinkmann@xilinx.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Nicolas Ferre <nicolas.ferre@atmel.com>,
	David Miller <davem@davemloft.net>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Network Development <netdev@vger.kernel.org>,
	Michal Simek <michal.simek@xilinx.com>
To: Soren Brinkmann <soren.brinkmann@xilinx.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f170.google.com ([209.85.216.170]:49457 "EHLO
	mail-qc0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751364Ab3LLHAR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Dec 2013 02:00:17 -0500
Received: by mail-qc0-f170.google.com with SMTP id x13so6053295qcv.29
        for <netdev@vger.kernel.org>; Wed, 11 Dec 2013 23:00:17 -0800 (PST)
In-Reply-To: <1386720443-24100-1-git-send-email-soren.brinkmann@xilinx.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Soren,

On Tue, Dec 10, 2013 at 4:07 PM, Soren Brinkmann
<soren.brinkmann@xilinx.com> wrote:

> Soren Brinkmann (5):
>   net: macb: Adjust tx_clk when link speed changes

This patch causes build issues on some at91 platforms, namely
at91sam9263 that lacks programmable clocks. So it doesn't implement
clk_set_rate() and clk_round_rate().

I don't know if there's any reasonable config option to check for
(that wouldn't add at91-specific stuff to the driver which we don't
want). So I suspect the best way would be to implement dummy versions
for at91 when CONFIG_AT91_PROGRAMMABLE_CLOCKS isn't set.

Nicolas, you OK with that? It'd be something like the below
(copy-paste, whitespace damage, just RFC):

diff --git a/arch/arm/mach-at91/clock.c b/arch/arm/mach-at91/clock.c
index 6b2630a..17c52a7 100644
--- a/arch/arm/mach-at91/clock.c
+++ b/arch/arm/mach-at91/clock.c
@@ -459,6 +459,22 @@ static void __init init_programmable_clock(struct clk *clk)
        clk->rate_hz = parent->rate_hz / pmc_prescaler_divider(pckr);
 }

+#else  /* CONFIG_AT91_PROGRAMMABLE_CLOCKS */
+
+int clk_set_rate(struct clk *clk, unsigned long rate)
+{
+       if (rate == clk_get_rate(clk))
+               return 0;
+
+       return -EINVAL;
+}
+
+long clk_round_rate(struct clk *clk, unsigned long rate)
+{
+       /* There's really nothing sane to return here. */
+       return clk_get_rate(clk);
+}
+
 #endif /* CONFIG_AT91_PROGRAMMABLE_CLOCKS */
