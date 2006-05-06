From: Ivo van Doorn <ivdoorn@gmail.com>
Subject: Dscape ieee80211: enabling/disabling the radio
Date: Sat, 6 May 2006 14:00:58 +0200
Message-ID: <200605061401.01795.IvDoorn@gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart2141649.9AmNkeybrB";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit
Cc: Jiri Benc <jbenc@suse.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wr-out-0506.google.com ([64.233.184.230]:56462 "EHLO
	wr-out-0506.google.com") by vger.kernel.org with ESMTP
	id S1750798AbWEFL7d (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 6 May 2006 07:59:33 -0400
Received: by wr-out-0506.google.com with SMTP id i12so729446wra
        for <netdev@vger.kernel.org>; Sat, 06 May 2006 04:59:33 -0700 (PDT)
To: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--nextPart2141649.9AmNkeybrB
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

Hi,

While working on the rt2x00 driver, I keep hitting against some problems with scanning.
Basicly the dscape stack handles scanning in 2 ways, through the
passive_scan() handler in the ieee80211_hw structure, and by calling
the config() handler in the ieee80211_hw stucture.

The usage of the first handler, does not give any problems at this time.
The main source of problems during scanning in rt2x00 seems to come
when the config() handler is used.

In rt2x00 the config() handler schedules all configuration changes by using a workqueue,
this is required since several configuration changes in rt2x00 need sleeping and for
USB devices all register access requires sleeping. And the config() handler is often
called from interrupt context so it complains a lot when the workqueue is not used.

This seemed fine, untill the radio_enabled field was introduced to the configuration structure.
When the radio_enable field is set, the radio must be enabled, but enabling
the radio is something that can (at least in rt2x00) fail. So scheduling the enabling of the radio
to the workqueue is not something that is desired since the stack can not be notified that the
device is not able to enable the radio.

Moving the enabling of the radio outside the workqueue function and into the config()
handler results in scheduling while atomic issues since the enabling of the radio requires
sleeping for both PCI and USB devices.

Instead of using a config field radio_enabled, wouldn't it be better to add 2 handlers
to the ieee80211_hw structure, something like enable_radio() and disable_radio()?
If these functions are called from normal context the dscape stack can still enable
and disable the radio whenever it is desired, and it is able to check the return value
to see if the request has actually succeeded.

What I am wondering about afterwards is what exactly should happen when the open()
and stop() handlers are being called? Because those are basicly intented to enable
and stop the radio as well. I checked bcm43xx to see what they do, and they don't seem
to check the radio_enabled field, so I don't know what they do besides enabling the radio.

Well this was just some stuff I have been trying to figure out while trying to solve several
rt2x00 bugs... ;)

Regards,

Ivo

--nextPart2141649.9AmNkeybrB
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.2 (GNU/Linux)

iD8DBQBEXI/9aqndE37Em0gRAlazAJ9L5hg8EYRBxlfLm0/9R0EAbrds1gCggCmI
ym+dp3hFsk5kpVQx/v8AeXc=
=X+Ex
-----END PGP SIGNATURE-----

--nextPart2141649.9AmNkeybrB--
