From: Pavel Roskin <proski@gnu.org>
Subject: Re: Please make CONFIG_CFG80211 harder to enable
Date: Sun, 10 Dec 2006 03:12:02 -0500
Message-ID: <20061210031202.6rgqw4go8ck48kks@webmail.spamcop.net>
References: <1165654123.2816.29.camel@portland.localdomain>
	<20061209160640.GA3365@tuxdriver.com>
	<87hcw49rg8.fsf@briny.internal.ondioline.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: "John W. Linville" <linville@tuxdriver.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailgate.cesmail.net ([216.154.195.36]:51072 "HELO
	mailgate.cesmail.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1760496AbWLJIME (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 10 Dec 2006 03:12:04 -0500
To: Paul Collins <paul@briny.ondioline.org>
In-Reply-To: <87hcw49rg8.fsf@briny.internal.ondioline.org>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Quoting Paul Collins <paul@briny.ondioline.org>:

> >> Driver developers should know that if they enable CONFIG_CFG80211 they
> >> won't be able to debug their drivers effectifely; they'll have to fix
> >> cfg80211 first.
> >
> > Perhaps you could be more specific?  I'm sending this to you from a
> > box booted on the current (~1 week old) wireless-dev kernel using a
> > WEXT-configured ipw2200 device.
> >
> > What problems are you experiencing?  CFG80211 shouldn't interfere w/
> > WEXT if a driver doesn't support it.

Sorry, it looks like the evil setting is actually CONFIG_CFG80211_WEXT_COMPAT.
I should have checked it better.  Please look for the code around the
cfg80211_wext_ioctl call in dev_ioctl(), net/core/dev.c.

The logic now is to try the compatibility code first.  I think it's wrong, at
least for now.  I think the compatibility code should only be invoked if the
native WE support failed for the request.  Or maybe if the cfg80211 support is
present for the driver.

> I think I hit this too when I started playing with wireless-dev a week
> or so ago.  I had CFG80211 enabled and iwconfig reported "wireless
> extensions not supported" with orinoco, bcm43xx and bcm43xx-d80211.

Yes.  And I could trace "iwgetid -m ath0" to cfg80211_wx_get_mode() in
net/wireless/wext-compat.c, which returns -ENOSYS unconditionally.  ath0 is
from current MadWifi.

Both in-tree and outside drivers are affected (orinoco and hostap from the tree,
MadWifi outside the tree).  DadWifi also failed to respond to iwconfig, although
its author says that Wireless Tools should be used for now.

Both the latest beta of Wireless Tools and its alpha version with Netlink
support fail to work.  wpa_supplicant with the wext driver also fails.  But
MadWifi could associate (as evidenced by working dhclient) if there was a
strong open AP around.  Also, scanning using wlanconfig worked, which shows
that the ioctls to network interfaces are not generally hosed, just those used
by Wireless Extensions.

--
Regards,
Pavel Roskin
