From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [patch 1/2]d80211: hardware TKIP support for ipw3945
Date: Wed, 25 Oct 2006 10:50:45 +0200
Message-ID: <1161766245.2767.17.camel@ux156>
References: <1161335976.21402.11.camel@devlinux-hong>
	 <20061023144028.629dc5d8@griffin.suse.cz> <1161607680.6617.36.camel@ux156>
	 <20061023145646.32bbd59f@griffin.suse.cz>
	 <1161678053.7083.7.camel@devlinux-hong>  <1161678908.2840.12.camel@ux156>
	 <1161679134.7258.6.camel@devlinux-hong>  <1161681021.2840.23.camel@ux156>
	 <1161764889.8668.13.camel@devlinux-hong>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Jiri Benc <jbenc@suse.cz>,
	"John W. Linville" <linville@tuxdriver.com>,
	netdev <netdev@vger.kernel.org>, Michael Buesch <mb@bu3sch.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from crystal.sipsolutions.net ([195.210.38.204]:14477 "EHLO
	sipsolutions.net") by vger.kernel.org with ESMTP id S1423104AbWJYItr
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 25 Oct 2006 04:49:47 -0400
To: Hong Liu <hong.liu@intel.com>
In-Reply-To: <1161764889.8668.13.camel@devlinux-hong>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2006-10-25 at 16:28 +0800, Hong Liu wrote:

> I'd prefer to let the stack tell the driver when there is new phase1 key
> generated.

Fine too, I guess.

> +	u8 tkip_keylen;

What do you need that for? The driver should know whether it requested a
phase 1 or phase 2 key.

> +	u8 tkip_key[16];/* generated RC4/phase1 key for hw TKIP */

Do we really have to stick this into this structure? But I'll let Jiri
figure out how to remove the structure bloat :)
 
> +	/* calculate Michael MIC for an MSDU when doing hwcrypto */
> +#define IEEE80211_HW_TKIP_INCLUDE_MMIC (1<<12)
> +	/* Do TKIP phase1 key mixing in stack to support cards only do
> +	 * phase2 key mixing when doing hwcrypto */
> +#define IEEE80211_HW_TKIP_REQ_PHASE1_KEY (1<<13)
> +	/* Do TKIP phase1 and phase2 key mixing in stack and send the generated
> +	 * per-packet RC4 key with each TX frame when doing hwcrypto */
> +#define IEEE80211_HW_TKIP_REQ_PHASE2_KEY (1<<14)

Maybe a comment indicating that you must not set both of these flags
would be good. Or (see below)

Should there be some flag indicating if the hw/firmware checked the MIC
on reception? The current code has bad assumptions there:

(from the pre-flags version)

        /* Some devices handle Michael MIC internally and do not include MIC in
         * the received packets passed up. device_strips_mic must be set
         * for such devices. The 'encryption' frame control bit is expected to
         * be still set in the IEEE 802.11 header with this option unlike with
         * the device_hides_wep configuration option.
         */
        unsigned int device_strips_mic:1;

What if the devices leaves the MIC there but indicates if it was checked?
 
> +		if (flags & IEEE80211_HW_TKIP_REQ_PHASE1_KEY) {
...
> +		} else if (flags & IEEE80211_HW_TKIP_REQ_PHASE2_KEY) {
...

if you change the order of these tests then setting both flags will be
fine.

johannes
