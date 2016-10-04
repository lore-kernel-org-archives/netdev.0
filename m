From: Gavin Shan <gwshan@linux.vnet.ibm.com>
Subject: [PATCH v2 net-next 0/8] net/ncsi: NCSI Improvment and bug fixes
Date: Tue,  4 Oct 2016 11:25:46 +1100
Message-ID: <1475540754-31169-1-git-send-email-gwshan@linux.vnet.ibm.com>
Cc: davem@davemloft.net, joel@jms.id.au, yuvali@mellanox.com,
        benh@kernel.crashing.org, Gavin Shan <gwshan@linux.vnet.ibm.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-001b2d01.pphosted.com ([148.163.158.5]:35308 "EHLO
        mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1751399AbcJDAZ0 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 3 Oct 2016 20:25:26 -0400
Received: from pps.filterd (m0098420.ppops.net [127.0.0.1])
        by mx0b-001b2d01.pphosted.com (8.16.0.17/8.16.0.17) with SMTP id u940N0lv081894
        for <netdev@vger.kernel.org>; Mon, 3 Oct 2016 20:25:26 -0400
Received: from e23smtp01.au.ibm.com (e23smtp01.au.ibm.com [202.81.31.143])
        by mx0b-001b2d01.pphosted.com with ESMTP id 25uy9p538m-1
        (version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Mon, 03 Oct 2016 20:25:25 -0400
Received: from localhost
        by e23smtp01.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
        for <netdev@vger.kernel.org> from <gwshan@linux.vnet.ibm.com>;
        Tue, 4 Oct 2016 10:25:23 +1000
Received: from d23relay09.au.ibm.com (d23relay09.au.ibm.com [9.185.63.181])
        by d23dlp03.au.ibm.com (Postfix) with ESMTP id 4912A357805C
        for <netdev@vger.kernel.org>; Tue,  4 Oct 2016 11:25:21 +1100 (EST)
Received: from d23av01.au.ibm.com (d23av01.au.ibm.com [9.190.234.96])
        by d23relay09.au.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id u940PL8j63111190
        for <netdev@vger.kernel.org>; Tue, 4 Oct 2016 11:25:21 +1100
Received: from d23av01.au.ibm.com (localhost [127.0.0.1])
        by d23av01.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id u940PKWj031404
        for <netdev@vger.kernel.org>; Tue, 4 Oct 2016 11:25:20 +1100
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series of patches improves NCSI stack according to the comments
I received after the NCSI code was merged to 4.8.rc1:

  * PATCH[1/8] fixes the build warning caused by xchg() with ia64-linux-gcc.
    The atomic operations are removed. The NCSI's lock should be taken when
    reading or updating its state and chained state.
  * Channel ID (0x1f) is the reserved one and it cannot be valid channel ID.
    So we needn't try to probe channel whose ID is 0x1f. PATCH[2/8] and
    PATCH[3/8] are addressing this issue.
  * The request IDs are assigned in round-robin fashion, but it's broken.
    PATCH[4/8] make it work.
  * PATCH[5/8] and PATCH[6/8] reworks the channel monitoring to improve the
    code readability and its robustness.
  * PATCH[7/8] and PATCH[8/8] introduces ncsi_stop_dev() so that the network
    device can be closed and opened afterwards. No error will be seen.

Changelog
=========
v2:
  * The NCSI's lock is taken when reading or updating its state as the
    {READ,WRITE}_ONCE() isn't reliable.

Gavin Shan (8):
  net/ncsi: Avoid unused-value build warning from ia64-linux-gcc
  net/ncsi: Introduce NCSI_RESERVED_CHANNEL
  net/ncsi: Don't probe on the reserved channel ID (0x1f)
  net/ncsi: Rework request index allocation
  net/ncsi: Allow to extend NCSI request properties
  net/ncsi: Rework the channel monitoring
  net/ncsi: Introduce ncsi_stop_dev()
  net/faraday: Stop NCSI device on shutdown

 drivers/net/ethernet/faraday/ftgmac100.c |   2 +
 include/net/ncsi.h                       |   5 +
 net/ncsi/internal.h                      |  22 +++-
 net/ncsi/ncsi-aen.c                      |  37 ++++--
 net/ncsi/ncsi-cmd.c                      |   2 +-
 net/ncsi/ncsi-manage.c                   | 198 ++++++++++++++++++++-----------
 net/ncsi/ncsi-rsp.c                      |   4 +-
 7 files changed, 180 insertions(+), 90 deletions(-)

-- 
2.1.0
