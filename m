From: Mahesh Bandewar <maheshb@google.com>
Subject: [PATCH next v2 0/3] Multicast processing in IPvlan
Date: Wed, 29 Apr 2015 11:19:11 -0700
Message-ID: <1430331551-20199-1-git-send-email-maheshb@google.com>
Cc: Dan Willems <dcbw@redhat.com>, David Miller <davem@davemloft.net>,
	Mahesh Bandewar <maheshb@google.com>
To: netdev <netdev@vger.kernel.org>, Eric Dumazet <edumazet@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f202.google.com ([209.85.214.202]:34640 "EHLO
	mail-ob0-f202.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751081AbbD2Smh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Apr 2015 14:42:37 -0400
Received: by obbgq1 with SMTP id gq1so2170510obb.1
        for <netdev@vger.kernel.org>; Wed, 29 Apr 2015 11:42:36 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dan Willems pointed out that autoconf in IPvlan is broken because of the
way broadcast bit gets set. Since broadcast processing is a real performance
drain, the broadcast bit in multicast filter was only set when the interface
was configured with IPv4 address. In autoconf scenario, when there are
no addresses configured; this logic did not work and it wouldn't allow
DHCPv4 to work. The only way was to add protocol specific hacks to avoid
processing unnecessary broadcast burdon.

This jugglery could be avoided if these multicast / broadcast packets are taken
out of fast-path and are processed in a work-queue. This will enable us to add
broadcast bit in all multicast filters without any impact on performance of
the virtual device. This patch series just does that. This also addresses the
issue when multicast packets received are fragmented, the current code did not
handle that scenario.
 
Mahesh Bandewar (3):
  ipvlan: Defer multicast / broadcast processing to a work-queue
  ipvlan: Process fragmented multicast frames correctly
  ipvlan: Always set broadcast bit in multicast filter

 drivers/net/ipvlan/ipvlan.h      |   5 ++
 drivers/net/ipvlan/ipvlan_core.c | 145 +++++++++++++++++++++++++--------------
 drivers/net/ipvlan/ipvlan_main.c |  25 +++----
 include/net/ip.h                 |   1 +
 4 files changed, 111 insertions(+), 65 deletions(-)

-- 
2.2.0.rc0.207.ga3a616c
