From: Patrick McHardy <kaber@trash.net>
Subject: [IPROUTE 00/05]: Time cleanups
Date: Wed, 10 Jan 2007 11:01:43 +0100 (MET)
Message-ID: <20070110100143.29356.98344.sendpatchset@localhost.localdomain>
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:63775 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S964812AbXAJKBp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Jan 2007 05:01:45 -0500
To: shemminger@osdl.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

These patches clean up the tc time handling a bit, with the goal of making
it easier to audit for integer overflows when increasing the internal clock
resolution, which is necessary for all token bucket based schedulers to take
advantage of a higher kernel clock resolution (ktime) because the kernel only
does lookups and additions/subtractions, which can never result in values that
have a higher precision that those passed from userspace.

The way I imagine it we have to keep (at least on of) the old clock sources
around for userspace compatibility since they can't deal with the higher
precision values. iproute is changed to use nsec internally and reads the
kernel clock resulution from /proc/net/psched (third value, currently assumed
to always be 10^6) to convert it's internal resolution to that of the kernel.
With ktime as clocksource the kernel will report a resulution of 10^9. The
downside is that distributors can't enable ktime unless they want to break
compatibility with old iproute versions, but I can't see a way around this.


 tc/m_estimator.c  |    4 ++--
 tc/m_police.c     |    2 +-
 tc/q_cbq.c        |   15 ++++++++-------
 tc/q_hfsc.c       |   18 +++++++++---------
 tc/q_htb.c        |    4 ++--
 tc/q_netem.c      |   12 +++---------
 tc/q_tbf.c        |   20 ++++++++++----------
 tc/tc_cbq.c       |    8 ++++----
 tc/tc_core.c      |   35 +++++++++++++++++++++++++----------
 tc/tc_core.h      |   11 ++++++++---
 tc/tc_estimator.c |    2 +-
 tc/tc_red.c       |    2 +-
 tc/tc_util.c      |   33 +++++++++++++++++++--------------
 tc/tc_util.h      |    7 ++++---
 14 files changed, 97 insertions(+), 76 deletions(-)

Patrick McHardy:
      [IPROUTE]: Use tc_calc_xmittime where appropriate
      [IPROUTE]: Introduce tc_calc_xmitsize and use where appropriate
      [IPROUTE]: Introduce TIME_UNITS_PER_SEC to represent internal clock resolution
      [IPROUTE]: Replace "usec" by "time" in function names
      [IPROUTE]: Add sprint_ticks() function and use in CBQ
