From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH] 8139too: fix improper usage of workqueue
Date: Wed, 27 Aug 2008 21:26:56 +0200
Message-ID: <20080827192656.GA27499@electric-eye.fr.zoreil.com>
References: <20080827085126.29e673db@extreme>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:37756 "EHLO
	electric-eye.fr.zoreil.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753691AbYH0T07 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Aug 2008 15:26:59 -0400
Content-Disposition: inline
In-Reply-To: <20080827085126.29e673db@extreme>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Stephen Hemminger <shemminger@vyatta.com> :
> This driver was confused about how workqueue's work. It is save to
> schedule multiple times, and the flag (bitfield) was unnecessary and racy.

static void rtl8139_start_thread(struct rtl8139_private *tp)
{
        tp->twistie = 0;
        if (tp->chipset == CH_8139_K)
                tp->twistie = 1;
        else if (tp->drv_flags & HAS_LNK_CHNG)
                return;
                ^^^^^^^

        tp->have_thread = 1;

The use of the thread was dependent on RTL8129_CAPS. Now it will be
scheduled in the tx_timeout handler for RTL8139_CAPS too.

Speaking of race, the bitfield ('have_thread') is initialized through
rtl8139_open
-> rtl8139_start_thread
Do you mean that the tx_timeout handler can kick before the bitfield
is set ?

> The workqueue was never canceled either, so it is possible that the thread
> could run after driver was removes [OOPS].

The driver uses flush_scheduled_work() when the pci device is removed.

Where would the workqueue be scheduled after / during the removal ?

-- 
Ueimor
