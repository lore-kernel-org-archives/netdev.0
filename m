From: Petar Penkov <ppenkov@google.com>
Subject: [PATCH net-next RFC 0/2] Improve code coverage of syzkaller
Date: Tue,  5 Sep 2017 15:35:49 -0700
Message-ID: <20170905223551.27925-1-ppenkov@google.com>
Cc: Petar Penkov <ppenkov@google.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f43.google.com ([74.125.83.43]:38243 "EHLO
        mail-pg0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752670AbdIEWgJ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 5 Sep 2017 18:36:09 -0400
Received: by mail-pg0-f43.google.com with SMTP id v66so11801406pgb.5
        for <netdev@vger.kernel.org>; Tue, 05 Sep 2017 15:36:09 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch series is intended to improve code coverage of syzkaller on
the early receive path, specifically including flow dissector, GRO,
and GRO with frags parts of the networking stack. Syzkaller exercises
the stack through the TUN driver and this is therefore where changes
reside. Current coverage through netif_receive_skb() is limited as it
does not touch on any of the aforementioned code paths. Furthermore,
for full coverage, it is necessary to have more flexibility over the
linear and non-linear data of the skbs.

The following patches address this by providing the user(syzkaller)
with the ability to send via napi_gro_receive() and napi_gro_frags().
Additionally, syzkaller can specify how many fragments there are and
how much data per fragment there is. This is done by exploiting the
convenient structure of iovecs. Finally, this patch series adds
support for exercising the flow dissector during fuzzing.

The code path including napi_gro_receive() can be enabled via the
CONFIG_TUN_NAPI compile-time flag, and can be used by users other than
syzkaller. The remainder of the  changes in this patch series give the
user significantly more control over packets entering the kernel. To
avoid potential security vulnerabilities, hide the ability to send
custom skbs and the flow dissector code paths behind a run-time flag
IFF_NAPI_FRAGS that is advertised and accepted only if CONFIG_TUN_NAPI
is enabled.

The patch series will be followed with changes to packetdrill, where
these additions to the TUN driver are exercised and demonstrated.
This will give the ability to write regression tests for specific
parts of the early networking stack.

Patch 1/ Add NAPI struct per receive queue, enable NAPI, and use
	 napi_gro_receive() 
Patch 2/ Use NAPI skb and napi_gro_frags(), exercise flow dissector,
	 and allow custom skbs.
Petar Penkov (2):
  tun: enable NAPI for TUN/TAP driver
  tun: enable napi_gro_frags() for TUN/TAP driver

 drivers/net/Kconfig         |   8 ++
 drivers/net/tun.c           | 251 +++++++++++++++++++++++++++++++++++++++++---
 include/uapi/linux/if_tun.h |   1 +
 3 files changed, 246 insertions(+), 14 deletions(-)

-- 
2.14.1.581.gf28d330327-goog
