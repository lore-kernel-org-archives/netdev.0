From: Jiri Benc <jbenc@suse.cz>
Subject: Re: [PATCH 2/7] d80211: add support for SIOCSIWRATE and SIOCGIWRATE
Date: Thu, 28 Sep 2006 13:38:24 +0200
Message-ID: <20060928133824.0cb2aa78@logostar.upir.cz>
References: <44F355EE.3090607@linux.intel.com>
	<20060830171919.GC18041@instant802.com>
	<20060921184021.1fb7fa6e@logostar.upir.cz>
	<4512C4FB.5010704@linux.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Jouni Malinen <jkm@devicescape.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from styx.suse.cz ([82.119.242.94]:53422 "EHLO mail.suse.cz")
	by vger.kernel.org with ESMTP id S965362AbWI1Lib (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Sep 2006 07:38:31 -0400
To: mabbas <mabbas@linux.intel.com>
In-Reply-To: <4512C4FB.5010704@linux.intel.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 21 Sep 2006 09:59:39 -0700, mabbas wrote:
> I can not see how does it break per-STA TX rate limit, especially 
> PRISM2_HOSTAPD_SET_RATE_SETS almost doing the same thing. I am not saying
> the patch is correct I just want to know how to fix it to get it in.

As Jouni wrote, it's not useful to change the per-radio rate table. You
want to limit the rates you are using to communicate with the current AP
while not limiting other virtual interfaces. (Imagine you have the card
that is capable to associate to two APs at the same time. You don't want to
limit rates for both APs with SIOCSIWRATE.)

To do that I think the following is needed:

1. Add 'allowed_rates' field to struct sta_info. It defaults to 0xffffffff.
(Or perhaps call it 'disabled_rates' and make it default to 0.)

2. The SIOCSIWRATE handler: If the interface is not in a STA mode, return
-EOPNOTSUPP. Otherwise, modify the allowed_rates field of the sta entry
belonging to the current AP.

3. Bitmask sta->curr_rates with sta->allowed_rates (or
~sta->disabled_rates) in various places (ieee80211_ioctl_add_sta,
ieee80211_rx_mgmt_assoc_resp, ieee80211_rx_bss_info; please check for other
places).

In IBSS and AP mode setting this (per-STA, of course, which is not
supported by WE, btw.) can be useful as well but it can be done later.

 Jiri

-- 
Jiri Benc
SUSE Labs
