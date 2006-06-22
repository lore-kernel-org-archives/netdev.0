From: Jiri Benc <jbenc@suse.cz>
Subject: Re: [PATCH, RFT] bcm43xx: AccessPoint mode
Date: Thu, 22 Jun 2006 17:30:13 +0200
Message-ID: <20060622173013.28e61873@griffin.suse.cz>
References: <200606191107.34602.mb@bu3sch.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: bcm43xx-dev@lists.berlios.de, netdev@vger.kernel.org,
	"Alexander Tsvyashchenko" <lists@ndl.kiev.ua>,
	"Francois Barre" <francois.barre@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from styx.suse.cz ([82.119.242.94]:25017 "EHLO mail.suse.cz")
	by vger.kernel.org with ESMTP id S932475AbWFVPaR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Jun 2006 11:30:17 -0400
To: Michael Buesch <mb@bu3sch.de>
In-Reply-To: <200606191107.34602.mb@bu3sch.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 19 Jun 2006 11:07:34 +0200, Michael Buesch wrote:
> Well, it does not work 100%, but at least it's very promising.
> We are able to create a bssid and correctly send beacon frames out.

Great work! I was even able to ping. (Tried only open system
authentication for now, it seems it works quite well.)

> Please give it a testrun.
> Final note about hostapd:
> "hostapd snapshot 0.5-2006-06-10" seems to "work" in the sense
> that it is able to bring up the device.
> "hostapd snapshot 0.5-2006-06-11" seems to fail.

0.5-2006-06-19 works with the patch.

> Important notes from Alexander Tsvyashchenko's initial mail follow:
> [...]
> Although my previous patch to hostapd to make it interoperable with
> bcm43xx & dscape has been merged already in their CVS version, due to
> the subsequent changes in dscape stack current hostapd is again
> incompartible :-( So, to test this patch, the patch to hostapd should be
> applied.

Or, if you don't want to patch hostapd (untested, but should work):

iwpriv wlan0 param 1046 1
ip link set wmgmt0 name wmaster0ap
hostapd /path/to/hostapd.conf
iwpriv wlan0 param 1046 0

> I used hostapd snapshot 0.5-2006-06-10, patch for it is attached.
> The patch is very hacky and requires tricky way to bring everything up,
> but as dscape stack is changed quite constantly, I just do not want to
> waste time fixing it in "proper" way only to find a week later that
> dscape handling of master interface was changed completely once more and
> everything is broken again ;-)

Hopefully we will convert the whole hostapd<->stack communication to
netlink in some near future ;-)

> 2) Insert modules (80211, rate_control and bcm43xx-d80211)

modprobe bcm43xx-d80211 is enough, other modules will load
automatically.

> 4) "ifconfig wlan0 up" (this should be done by hostapd actually, but
> its operation with current dscape stack seems to be broken)

hostapd tries to open (put to 'up' state) wmgmt0 earlier than wlan0,
which is not possible. It should open wlan0 first; even more, opening of
wmgmt0 is not necessary as it will be opened automatically when wlan0 is
opened.

> 6) "iwconfig wlan0 essid <your-SSID-name>" (this also should not be
> required, but current combination of hostapd + dscape doesn't seem to
> generate config_interface callback when setting beacon, so this is
> required just to force call of config_interface).

The stack currently has very limited support for cards with "beacon
templates". ieee80211_beacon_get function is not designed in a way it is
used in bcm43xx. Although this seems to be easy to fix now, we will run
into other problems later (with TIM elements mainly).

I need to look how PS mode works in bcm chipsets to find a correct
solution for this. Do you have any ideas?

Thanks,

 Jiri

-- 
Jiri Benc
SUSE Labs
