From: Nikita Yushchenko <nikita.yoush@cogentembedded.com>
Subject: Re: [patch net / RFC] net: fec: increase frame size limitation to
 actually available buffer
Date: Wed, 30 Nov 2016 09:36:15 +0300
Message-ID: <dab27a3d-821c-8d07-ad98-2bdd8c442bc5@cogentembedded.com>
References: <1480444528-30054-1-git-send-email-nikita.yoush@cogentembedded.com>
 <AM4PR0401MB2260D022EC9B9E4C4333E621FF8C0@AM4PR0401MB2260.eurprd04.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: Chris Healy <cphealy@gmail.com>,
        Fabio Estevam <fabio.estevam@nxp.com>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Andy Duan <fugang.duan@nxp.com>,
        "David S. Miller" <davem@davemloft.net>,
        Troy Kisky <troy.kisky@boundarydevices.com>,
        Andrew Lunn <andrew@lunn.ch>, Eric Nelson <eric@nelint.com>,
        Philippe Reynes <tremyfr@gmail.com>,
        Johannes Berg <johannes@sipsolutions.net>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f45.google.com ([209.85.215.45]:34145 "EHLO
        mail-lf0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752857AbcK3GgT (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 30 Nov 2016 01:36:19 -0500
Received: by mail-lf0-f45.google.com with SMTP id o141so138997532lff.1
        for <netdev@vger.kernel.org>; Tue, 29 Nov 2016 22:36:18 -0800 (PST)
In-Reply-To: <AM4PR0401MB2260D022EC9B9E4C4333E621FF8C0@AM4PR0401MB2260.eurprd04.prod.outlook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> But I think it is not necessary since the driver don't support jumbo frame.

Hardcoded 1522 raises two separate issues.

(1) When DSA is in use, frames processed by FEC chip contain DSA tag and
thus can be larger than hardcoded limit of 1522. This issue is not
FEC-specific, any driver that hardcodes maximum frame size to 1522 (many
do) will have this issue if used with DSA.

Clean solution for this must take into account that difference between
MTU and max frame size is no longer known at compile time. Actually this
is the case even without DSA, due to VLANs: max frame size is (MTU + 18)
without VLANs, but (MTU + 22) with VLANs. However currently drivers tend
to ignore this and hardcode 22.  With DSA, 22 is not enough, need to add
switch-specific tag size to that.

Not yet sure how to handle this. DSA-specific API to find out tag size
could be added, but generic solution should handle all cases of dynamic
difference between MTU and max frame size, not only DSA.


(2) There is some demand to use larger frames for optimization purposes.

FEC register fields that limit frame size are 14-bit, thus allowing
frames up to (4k-1). I'm about to prepare a larger patch:
- add ndo_change_mtu handler, allowing MTU up to (4k - overhead),
- set MAX_FL / TRUNC_FL based on configured MTU,
- if necessary, do buffer reallocation with larger buffers.

Is this suitable for upstreaming?
Is there any policy related to handling larger frames?
