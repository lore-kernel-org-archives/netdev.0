From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [patch 1/2]d80211: hardware TKIP support for ipw3945
Date: Thu, 16 Nov 2006 10:52:42 +0100
Message-ID: <1163670762.2763.19.camel@ux156>
References: <1161335976.21402.11.camel@devlinux-hong>
	 <20061023144028.629dc5d8@griffin.suse.cz> <1161607680.6617.36.camel@ux156>
	 <20061023145646.32bbd59f@griffin.suse.cz>
	 <1161678053.7083.7.camel@devlinux-hong>  <1161678908.2840.12.camel@ux156>
	 <1161679134.7258.6.camel@devlinux-hong>  <1161681021.2840.23.camel@ux156>
	 <1161764889.8668.13.camel@devlinux-hong>  <1161766245.2767.17.camel@ux156>
	 <1163470978.7789.31.camel@devlinux-hong>  <1163607901.2705.53.camel@ux156>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Jiri Benc <jbenc@suse.cz>,
	"John W. Linville" <linville@tuxdriver.com>,
	netdev <netdev@vger.kernel.org>, Michael Buesch <mb@bu3sch.de>,
	"James P. Ketrenos" <ipw2100-admin@linux.intel.com>,
	Simon Barber <simon@devicescape.com>,
	Jouni Malinen <jkm@devicescape.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from crystal.sipsolutions.net ([195.210.38.204]:1702 "EHLO
	sipsolutions.net") by vger.kernel.org with ESMTP id S1422847AbWKPJvm
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 16 Nov 2006 04:51:42 -0500
To: Hong Liu <hong.liu@intel.com>
In-Reply-To: <1163607901.2705.53.camel@ux156>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2006-11-15 at 17:25 +0100, Johannes Berg wrote:

> Instead of putting all this into the stack, however, I think we could
> make those drivers that require it do the bookkeeping and export
> ieee80211_tkip_gen_phase1key and ieee80211_tkip_gen_rc4key for their
> use. Maybe that's too much against Jiri's doctrine of "be easy on
> drivers" though :)

Thought about this a bit more.

I think we should simplify the stack code by making it have *only* the
distinction between between hardware and software crypto (on a per-key
basis).

This would entail getting rid of the flags

  IEEE80211_HW_TKIP_INCLUDE_MMIC
  IEEE80211_HW_TKIP_REQ_PHASE1_KEY
  IEEE80211_HW_TKIP_REQ_PHASE2_KEY

and possibly

  IEEE80211_HW_NO_TKIP_WMM_HWACCEL


Instead, I would like to provide "library" functions to do these tasks
and let drivers use them when they are necessary.

This should simplify and streamline code in the stack by getting rid of
all the tests for these flags and associated code.

My reasoning for this is that
 1) it doesn't break Jiri's doctrine of making things easy for drivers
    because, well, simple drivers just use sw crypto
 2) since drivers will always hard-code these flags it actually makes
    the code more efficient -- no testing of flags required, just
    function calls we'd be making elsewhere after testing flags
 3) instead of drivers hard-coding the flag setting they hardcode
    (yes, in a few more lines) the crypto they need

I think putting the code into the driver vs. the stack is a trade-off we
should make because it makes things more efficient.

Could you live with a patch to do this and adjust ipw3945 accordingly?

For ipw3945 it would be just an addition of a call to
ieee80211_tkip_gen_rc4key() as it lives in the stack after this patch,
and for bcm43xx it would be similar to the code you added within 
"else if (flags & IEEE80211_HW_TKIP_REQ_PHASE1_KEY) {"

As for IEEE80211_HW_NO_TKIP_WMM_HWACCEL, we would have to tell the
hw->set_key routine if WME is enabled for the STA associated with the
key. I'm not yet sure how to do this best, plus the flag isn't actually
checked in the TX path but only the key setting path so...

Basically, I think we have too much knowledge of hardware quirks in the
stack. I'll be submitting a patch for this item later today.

johannes
