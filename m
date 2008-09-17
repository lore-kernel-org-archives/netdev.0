From: Jouni Malinen <j@w1.fi>
Subject: Re: [GIT]: Networking (WEXT events and 64/32 compat)
Date: Wed, 17 Sep 2008 12:11:28 -0700
Message-ID: <20080917191128.GA23239@hostap.isc.org>
References: <48C5E2FC.4090304@atheros.com> <20080908.194627.169864643.davem@davemloft.net> <20080909025525.GB25148@hostap.isc.org> <20080908.204323.04156464.davem@davemloft.net> <20080909040525.GA26151@hostap.isc.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, jouni.malinen@atheros.com,
	alex.williamson@hp.com, torvalds@linux-foundation.org,
	akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Jouni Malinen <j@w1.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hostap.isc.org ([149.20.54.63]:54300 "EHLO hostap.isc.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752648AbYIQTWl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 17 Sep 2008 15:22:41 -0400
Content-Disposition: inline
In-Reply-To: <20080909040525.GA26151@hostap.isc.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Sep 08, 2008 at 09:05:25PM -0700, Jouni Malinen wrote:
> OK. Interesting point here is that the old code was using IWEVCUSTOM
> which is defined as having header_type IW_HEADER_TYPE_POINT and so are
> the new IWEVASSOCREQIE and IWEVASSOCRESPIE. The only difference is in
> max_tokens specifying different maximum length for the data. Maybe the
> old code was also broken, but wpa_supplicant handled the bogus data
> without causing problems (text parsing failing instead of some
> parameters being set based on bogus binary data).

I was able to test this with a 64/32-bit setup and confirmed that both
IWEVCUSTOM and the new IWEVASSOCREQIE/IWEVASSOCRESPIE are indeed failing
when using 32-bit binary in userspace (and work with 64-bit). The length
field is parsed incorrectly for all these events.

wpa_supplicant has code for rejecting IWEVCUSTOM events that have too
large a value in the length field. However, same validation is not done
for IWEVASSOCREQIE/IWEVASSOCRESPIE (i.e., wpa_supplicant relies on
kernel providing the correct value for the length field). As the end
result, the new IWEVASSOCREQIE/IWEVASSOCRESPIE events will trigger a
segmentation fault in wpa_supplicant when the buffer is being read way
beyond its end.

I'll make wpa_supplicant validate the length field for all WEXT events
to avoid the crash. This was enough to make association work with the
reverted mac80211 patch since the values from these association info
events are not critical for many use cases.

Since we cannot fix the kernel code to handle the WEXT events for all
cases (e.g., 64-bit kernel and mix of 32-bit and 64-bit userspace
apps), I could consider adding a workaround in wpa_supplicant to handle
the 64-bit data being received in 32-bit app.. However, that would not
fix problems for anyone using older versions of wpa_supplicant.

Would it be acceptable to ever enable use of IWEVASSOCREQIE /
IWEVSSOCRESPIE in kernel if the workaround were available in new
wpa_supplicant versions? Or should we try to add a new WEXT event
type that uses fixed size for the length field and then replace the old
IWEVCUSTOM with the new type since IWEVCUSTOM does not work with
64/32-bit case (wpa_supplicant just knows how to avoid processing that
bogus event data)?

-- 
Jouni Malinen                                            PGP id EFC895FA
