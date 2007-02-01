From: "Jouni Malinen" <jkm@devicescape.com>
Subject: Re: Hidden SSID's
Date: Thu, 1 Feb 2007 10:46:09 -0800
Message-ID: <20070201184609.GE2652@instant802.com>
References: <1169899689.25670.3.camel@localhost.localdomain> <1170019717.30318.0.camel@johannes.berg> <1170075611.2895.2.camel@localhost.localdomain> <20070130030911.GA6637@jm.kir.nu> <1170128208.3448.6.camel@localhost.localdomain> <45BECF04.3070904@lwfinger.net> <20070130050841.GC6637@jm.kir.nu> <45BEEEED.9010702@lwfinger.net> <20070130225641.GH32304@instant802.com> <45C00066.80807@lwfinger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Dan Williams <dcbw@redhat.com>,
	Johannes Berg <johannes@sipsolutions.net>,
	netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>
To: Larry Finger <larry.finger@lwfinger.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from dhost002-89.dex002.intermedia.net ([64.78.20.227]:22257 "EHLO
	dhost002-89.dex002.intermedia.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1422934AbXBASqQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Feb 2007 13:46:16 -0500
Content-Disposition: inline
In-Reply-To: <45C00066.80807@lwfinger.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Jan 30, 2007 at 08:35:18PM -0600, Larry Finger wrote:

> If one does the equivalent of 'iwlist eth1 scan essid myssid', then a probe response with
> NETWORK_EMPTY_ESSID set in the network flags will have 'myssid' returned in the SSID field of the
> returned buffer. If the input command were 'iwlist eth1 scan', then an empty SSID would be returned
> under the same circumstances. My code saves the SSID that is in the extra argument of the
> SIOCSIWSCAN call, and uses that in the SIOCGIWSCAN call.

Well, yes, but SIOCSIWSCAN and SIOCGIWSCAN calls are not in any way
linked together.. You could have two user space programs asking for a
scan of different SSID at more or less the same time and then have them
read the results with SIOCGIWSCAN. At this point, the SSID from the last
SIOCSIWSCAN would be returned for all APs that are in the scan list
without an SSID. This may not be the correct SSID and can produce quite
confusing results. I don't see this as an improvement over just removing
the "<hidden>" which will at least provide consistent results.

The proper fix for this is to use the information from the AP (Probe
Response frames) and create a local BSS list that has entries with SSID
updated from Probe Responses. If the underlying hardware/firmware does
not allow such handling, this kind of mapping of SSIDs from scan request
to scan results should probably in the hardware driver that would have
chance of mapping results from firmware to request for a given SSID. At
that point, it might be feasible to change the SSID in scan results, but
I see only problems for the case where this is done at higher layer.

> What is the method that should be used to associated with a given hidden AP?

The 802.11 stack should fill in the proper SSID data from Probe
Responses and maintain a local BSS list, i.e., the hidden APs would be
marked with proper SSID whenever Probe Responses are processed. See,
e.g., how driver/net/wireless/hostap/*.c use local->bss_list that will
be filled with information from both Beacon and Probe Response frames or
how wireless-dev.git net/d80211/ieee80211_sta.c handles updating of BSS
entry from both Beacon and Probe Response frames (i.e., do not allow
Beacon frames to replace data from Probe Response frames) in
ieee80211_rx_bss_info().

In other words, the hidden SSIDs are resolved in the BSS list based on
information from Probe Responses and user space programs will get proper
information in the scan results regardless of how the real SSID was
learned.

-- 
Jouni Malinen                                            PGP id EFC895FA
