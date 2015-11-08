From: Phil Sutter <phil@nwl.cc>
Subject: [iproute PATCH 0/6] flush many addresses and some cleanups
Date: Sun,  8 Nov 2015 20:21:05 +0100
Message-ID: <1447010471-559-1-git-send-email-phil@nwl.cc>
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <shemming@brocade.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbit.nwl.cc ([176.31.251.142]:43849 "EHLO mail.nwl.cc"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752070AbbKHTVO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 8 Nov 2015 14:21:14 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch series aims to silence spurious error messages when flushing
an interface with many addresses assigned and provides a few cleanups
found along the way.

The original issue was a test-case adding 40k IPv4 addresses to an
interface and calling 'ip addr flush' afterwards. Initially, this
resulted in an error message:

| Failed to send flush request: Cannot assign requested address

Iproute apparently tried to remove (secondary) addresses which didn't
exist anymore since the primary one had already been removed. (This
behaviour actually depends on the promote_secondaries sysctl setting.)
Patch 1/6 makes iproute simply ignore this error, as when flushing it is
not relevant. This also allows to remove iproute's previous workaround,
which is to flush secondary addresses before primary ones (patch 2/6).

Yet, still an error message is emitted on newer kernels, as they started
to check consistency of netlink dumps (which is broken by iproute as it
alters the data while it is dumped). This error may as well be ignored,
as it's expected behaviour while flushing addresses. Though in order to
do that, libnetlink API had to be extended a bit to actually allow to
ignore certain nlmsg_flags bits. Patch 3/6 therefore extends libnetlink,
patch 4/6 then makes use of the extended functionality.

While debugging the issue, an unnecessary check has been discovered
(patch 5/6) as well as a possible simplification in iptoken.c was found
(patch 6/6).

Phil Sutter (6):
  ipaddress: make flush command more error-tolerant
  ipaddress: simplify ipaddr_flush()
  libnetlink: introduce nc_flags
  ipaddress: fix ipaddr_flush for Linux >= 3.1
  ipaddress: drop unnecessary check in ipaddr_list_flush_or_save()
  iptoken: simplify iptoken_list a bit

 include/libnetlink.h |  7 ++++++-
 ip/ipaddress.c       | 51 +++++++++------------------------------------------
 ip/iptoken.c         |  6 +-----
 lib/libnetlink.c     | 10 ++++++----
 4 files changed, 22 insertions(+), 52 deletions(-)

-- 
2.1.2
