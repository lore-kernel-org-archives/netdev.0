From: Petar Penkov <peterpenkov96@gmail.com>
Subject: [PATCH,v2,net-next 0/2] Improve code coverage of syzkaller
Date: Thu, 21 Sep 2017 19:17:13 -0700
Message-ID: <20170922021715.2618-1-peterpenkov96@gmail.com>
Cc: Petar Penkov <peterpenkov96@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f65.google.com ([74.125.83.65]:36741 "EHLO
        mail-pg0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751653AbdIVCRT (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 21 Sep 2017 22:17:19 -0400
Received: by mail-pg0-f65.google.com with SMTP id d8so4408060pgt.3
        for <netdev@vger.kernel.org>; Thu, 21 Sep 2017 19:17:19 -0700 (PDT)
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
IFF_NAPI flag.  The remainder of the changes in this patch series give
the user significantly more control over packets entering the kernel.
To avoid potential security vulnerabilities, hide the ability to send
custom skbs and the flow dissector code paths behind a
capable(CAP_NET_ADMIN) check to require special user privileges.

Changes since v1:
Patch 1/ Remove compile-time CONFIG_TUN_NAPI flag and replace it by a
	 run-time IFF_NAPI flag that can be set via TUN_SET_IFF.
Patch 2/ Push IFF_NAPI_FRAGS to 0x0020 to accommodate for IFF_NAPI,
	 Require capable(CAP_NET_ADMIN) to set IFF_NAPI_FRAGS.

Petar Penkov (2):
  tun: enable NAPI for TUN/TAP driver
  tun: enable napi_gro_frags() for TUN/TAP driver

 drivers/net/tun.c           | 258 ++++++++++++++++++++++++++++++++++++++++----
 include/uapi/linux/if_tun.h |   2 +
 2 files changed, 242 insertions(+), 18 deletions(-)

-- 
2.11.0
