From: Patrick McHardy <kaber@trash.net>
Subject: [RFC IPROUTE 00/05]: Time cleanups
Date: Fri, 23 Jun 2006 20:06:42 +0200 (MEST)
Message-ID: <20060623180642.13183.74864.sendpatchset@localhost.localdomain>
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>,
	hadi@cyberus.ca
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:42165 "EHLO
	stinky.trash.net") by vger.kernel.org with ESMTP id S1751835AbWFWSGo
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 23 Jun 2006 14:06:44 -0400
To: hemminger@osdl.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

I'm currently adding support for ktime as clocksource to the qdisc layer and
in the course of doing that cleaned up the iproute time handling a bit to
make it easier to use a different internal clock resultion and audit for
integer overflows.

Increasing iproutes internal clock resolution is necessary for all token bucket
based schedulers to take advantage of a higher kernel clock resolution because
the kernel only does lookups and additions/subtractions, which can never result
in values that have a higher precision that those passed from userspace.

The way I imagine it we have to keep the old clock sources around for userspace
compatibility since they can't deal with the higher precision values. iproute is
changed to use nsec internally and reads the kernel clock resulution from
/proc/net/psched (third value, currently assumed to always be 10^6) to convert
it's internal resolution to that of the kernel. With ktime as clocksource the
kernel will report a resulution of 10^9. The downside is that distributors can't
enable ktime unless they want to break compatibility with old iproute versions.
Any better suggestions are welcome of course.


 tc/m_estimator.c  |    4 ++--
 tc/m_police.c     |    2 +-
 tc/q_cbq.c        |   15 ++++++++-------
 tc/q_hfsc.c       |   18 +++++++++---------
 tc/q_htb.c        |    4 ++--
 tc/q_netem.c      |   12 +++---------
 tc/q_tbf.c        |   20 ++++++++++----------
 tc/tc_cbq.c       |    8 ++++----
 tc/tc_core.c      |   31 +++++++++++++++++++++++--------
 tc/tc_core.h      |    9 +++++++--
 tc/tc_estimator.c |    2 +-
 tc/tc_red.c       |    2 +-
 tc/tc_util.c      |   33 +++++++++++++++++++--------------
 tc/tc_util.h      |    7 ++++---
 14 files changed, 94 insertions(+), 73 deletions(-)

Patrick McHardy:
      [IPROUTE]: Use tc_calc_xmittime where appropriate
      [IPROUTE]: Introduce tc_calc_xmitsize and use where appropriate
      [IPROUTE]: Introduce TIME_UNITS_PER_SEC to represent internal clock resulution
      [IPROUTE]: Replace "usec" by "time" in function names
      [IPROUTE]: Add sprint_ticks() function and use in CBQ
