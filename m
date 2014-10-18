From: Vinson Lee <vlee@twopensource.com>
Subject: [stable request <= 3.11] net/mlx4_en: Fix BlueFlame race
Date: Sat, 18 Oct 2014 14:14:51 -0700
Message-ID: <CAHTgTXVn1479XCoh1-j=Xghtad3zA-hf0za5r_AyoaKuKeFZ2g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>,
	Amir Vadai <amirv@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Jack Morgenstein <jackm@dev.mellanox.co.il>,
	Eugenia Emantayev <eugenia@mellanox.com>,
	Matan Barak <matanb@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f182.google.com ([209.85.216.182]:41165 "EHLO
	mail-qc0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750807AbaJRVOw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 18 Oct 2014 17:14:52 -0400
Received: by mail-qc0-f182.google.com with SMTP id i17so2143488qcy.13
        for <netdev@vger.kernel.org>; Sat, 18 Oct 2014 14:14:51 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi.

Please consider backporting upstream commit
2d4b646613d6b12175b017aca18113945af1faf3 "net/mlx4_en: Fix BlueFlame
race" to stable kernels <= 3.11.

commit 2d4b646613d6b12175b017aca18113945af1faf3
Author: Eugenia Emantayev <eugenia@mellanox.com>
Date:   Thu Jul 25 19:21:23 2013 +0300

    net/mlx4_en: Fix BlueFlame race

    Fix a race between BlueFlame flow and stamping in post send flow.
    Example:
        SW: Build WQE 0 on the TX buffer, except the ownership bit
        SW: Set ownership for WQE 0 on the TX buffer
        SW: Ring doorbell for WQE 0
        SW: Build WQE 1 on the TX buffer, except the ownership bit
        SW: Set ownership for WQE 1 on the TX buffer
        HW: Read WQE 0 and then WQE 1, before doorbell was rung/BF was
done for WQE 1
        HW: Produce CQEs for WQE 0 and WQE 1
        SW: Process the CQEs, and stamp WQE 0 and WQE 1 accordingly
(on the TX buffer)
        SW: Copy WQE 1 from the TX buffer to the BF register - ALREADY STAMPED!
        HW: CQE error with index 0xFFFF  - the BF WQE's control
segment is STAMPED,
                so the BF index is 0xFFFF. Error: Invalid Opcode.
    As a result QP enters the error state and no traffic can be sent.

    Solution:
    When stamping - do not stamp last completed wqe.

    Signed-off-by: Eugenia Emantayev <eugenia@mellanox.com>
    Signed-off-by: Amir Vadai <amirv@mellanox.com>
    Signed-off-by: David S. Miller <davem@davemloft.net>

This patch fixes Mellanox network card packet send failures on Linux
kernel 3.10.

Tested-by: Chris Suttles <csuttles@twitter.com>
Tested-by: David Mackey <tdmackey@twitter.com>
Tested-by: Matthew Mullins <mmullins@twopensource.com>
Tested-by: Vinson Lee <vlee@twitter.com>

Cheers,
Vinson
