From: Michael Wu <flamingice@sourmilk.net>
Subject: Re: lockdep rt2500usb report
Date: Sat, 26 Aug 2006 22:14:20 -0700
Message-ID: <200608262214.26827.flamingice@sourmilk.net>
References: <44DC4110.6080300@sipsolutions.net>
Mime-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart1842440.laW9JdTzWv";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit
Cc: Ivo van Doorn <ivdoorn@gmail.com>, netdev <netdev@vger.kernel.org>,
	Jiri Benc <jbenc@suse.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from server8.tchmachines.com ([216.180.241.250]:27539 "EHLO
	server8.tchmachines.com") by vger.kernel.org with ESMTP
	id S1751252AbWH0FOk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 27 Aug 2006 01:14:40 -0400
To: Johannes Berg <johannes@sipsolutions.net>
In-Reply-To: <44DC4110.6080300@sipsolutions.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--nextPart1842440.laW9JdTzWv
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

On Friday 11 August 2006 01:34, Johannes Berg wrote:
> This is running wireless-dev from yesterday. All I did was plug in a
> rt2500usb device into a usb port on a freshly booted system. I have a
> feeling that this is could be one of the problems reported earlier with
> the d80211 stack, but I haven't mastered the art of picking through
> these traces yet... What's swapper doing in there?
>
Ok, so it looks like dev_activate (called by dev_open) grabs queue_lock, th=
en=20
calls another function (dev_watchdog_up) which grabs xmit_lock. However, at=
=20
that point, the device is up enough that someone who wants to try=20
transmitting, can transmit (I think). If they're unlucky enough to transmit=
=20
after the queue_lock is grabbed but before xmit_lock, we get a deadlock.

This seems avoidable either by setting carrier_off before calling dev_open,=
=20
and turning it back on at a safe point (on association?), or simply refusin=
g=20
to transmit until it is reasonable to do so. (a similar thing was done in=20
adm8211: call netif_stop_queue and return 1 if we're not ready to tx yet in=
=20
order to hold skbs until association, where netif_wake_queue would be=20
called.)

=2DMichael Wu

--nextPart1842440.laW9JdTzWv
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.2 (GNU/Linux)

iD8DBQBE8SoyT3Oqt9AH4aERAodWAJ934Qunvh048C1eMvopyZ7Ev3lPyQCgzsel
n529pdOUmAqRZvIFCnmDuHg=
=EmpT
-----END PGP SIGNATURE-----

--nextPart1842440.laW9JdTzWv--
