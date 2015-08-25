From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v4 net-next] r8169: Add values missing in @get_stats64
 from HW counters
Date: Tue, 25 Aug 2015 14:15:40 -0700 (PDT)
Message-ID: <20150825.141540.472110106537790402.davem@davemloft.net>
References: <1439888664-28620-1-git-send-email-vinschen@redhat.com>
	<1440413559-9354-1-git-send-email-vinschen@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, hayeswang@realtek.com,
	romieu@fr.zoreil.com, ivecera@redhat.com, nic_swsd@realtek.com
To: vinschen@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:59713 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752420AbbHYVPl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Aug 2015 17:15:41 -0400
In-Reply-To: <1440413559-9354-1-git-send-email-vinschen@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Corinna Vinschen <vinschen@redhat.com>
Date: Mon, 24 Aug 2015 12:52:39 +0200

> The r8169 driver collects statistical information returned by
> @get_stats64 by counting them in the driver itself, even though many
> (but not all) of the values are already collected by tally counters
> (TCs) in the NIC.  Some of these TC values are not returned by
> @get_stats64.  Especially the received multicast packages are missing
> from /proc/net/dev.
> 
> Rectify this by fetching the TCs and returning them from
> rtl8169_get_stats64.
> 
> The counters collected in the driver obviously disappear as soon as the
> driver is unloaded so after a driver is loaded the counters always start
> at 0. The TCs on the other hand are only reset by a power cycle.  Without
> further considerations the values collected by the driver would not match
> up against the TC values.
> 
> This patch introduces a new function rtl8169_reset_counters which
> resets the TCs.  Also, since rtl8169_reset_counters shares most of
> its code with rtl8169_update_counters, refactor the shared code into
> two new functions  rtl8169_map_counters and rtl8169_unmap_counters.
> 
> Unfortunately chip versions prior to RTL_GIGA_MAC_VER_19 don't allow
> to reset the TCs programatically.  Therefore introduce an addition to
> the rtl8169_private struct and a function rtl8169_init_counter_offsets
> to store the TCs at first rtl_open.  Use these values as offsets in
> rtl8169_get_stats64.  Propagate a failure to reset *and* update the
> counters up to rtl_open and emit a warning message, if so.
> 
> Signed-off-by: Corinna Vinschen <vinschen@redhat.com>

Your counter offsets should be read at probe time, not open time.

Bringing the interface is brought down/up should not reset the
counters.  Look at how the software counters behave in such a
situation.
