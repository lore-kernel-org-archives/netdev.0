From: trajaraman@mvista.com
Subject: [PATCH] xfrm: Added the auth and enc update support in "state update"
Date: Tue,  7 Mar 2017 17:33:13 +0530
Message-ID: <1488888193-4071-1-git-send-email-trajaraman@mvista.com>
Cc: davem@davemloft.net, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org,
        Thiruvadi rajaraman <trajaraman@mvista.com>
To: steffen.klassert@secunet.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f53.google.com ([74.125.83.53]:35379 "EHLO
        mail-pg0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752039AbdCGMMI (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 7 Mar 2017 07:12:08 -0500
Received: by mail-pg0-f53.google.com with SMTP id b129so78447952pgc.2
        for <netdev@vger.kernel.org>; Tue, 07 Mar 2017 04:11:10 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Thiruvadi rajaraman <trajaraman@mvista.com>

The "ip xfrm state update" process doesn't update the new authendication
and encryption keys as well as it doesn't return an error.

Test logs: (Default)
==========
~# ip xfrm state list
~# ip xfrm state add src fe80::/10 dst ff02::3 proto esp spi 1235 mode transport auth sha1 0xAABBCCDDEEFF0010 enc des 0xAABBCCDDEEFF0010
~# ip xfrm state list
src fe80:: dst ff02::3
        proto esp spi 0x000004d3 reqid 0 mode transport
        replay-window 0
        auth-trunc hmac(sha1) 0xaabbccddeeff0010 96
        enc cbc(des) 0xaabbccddeeff0010
        sel src ::/0 dst ::/0
~#

~# ip xfrm state update src fe80::/10 dst ff02::3 proto esp spi 1235 mode transport auth sha1 0xAABBCCDDEEFF0015 enc des 0xAABBCCDDEEFF0020
src fe80:: dst ff02::3
        proto esp spi 0x000004d3 reqid 0 mode transport
        replay-window 0
        auth-trunc hmac(sha1) 0xaabbccddeeff0010 96   ----> [ Auth key doesn't changed and remains same ]
        enc cbc(des) 0xaabbccddeeff0010               ----> [  Enc key doesn't changed and remains same ]
        sel src ::/0 dst ::/0

The issue resolved by updating the x1->aalg, x1->ealg with new keys.

Test logs: ( with fix patch )
==========
~# ip xfrm state list
~# ip xfrm state add src fe80::/10 dst ff02::3 proto esp spi 1235 mode transport auth sha1 0xAABBCCDDEEFF0010 enc des 0xAABBCCDDEEFF0010
~# ip xfrm state list
src fe80:: dst ff02::3
        proto esp spi 0x000004d3 reqid 0 mode transport
        replay-window 0
        auth-trunc hmac(sha1) 0xaabbccddeeff0010 96
        enc cbc(des) 0xaabbccddeeff0010
        sel src ::/0 dst ::/0

~# ip xfrm state update src fe80::/10 dst ff02::3 proto esp spi 1235 mode transport auth sha1 0xAABBCCDDEEFF0015 enc des 0xAABBCCDDEEFF0020
~# ip xfrm state list
src fe80:: dst ff02::3
        proto esp spi 0x000004d3 reqid 0 mode transport
        replay-window 0
        auth-trunc hmac(sha1) 0xaabbccddeeff0015 96     ----> [ Updated to new Auth key ]
        enc cbc(des) 0xaabbccddeeff0020                 ----> [ Updated to new  Enc key ]
        sel src ::/0 dst ::/0
---
 net/xfrm/xfrm_state.c | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/net/xfrm/xfrm_state.c b/net/xfrm/xfrm_state.c
index 419bf5d..1c80fc2 100644
--- a/net/xfrm/xfrm_state.c
+++ b/net/xfrm/xfrm_state.c
@@ -1388,6 +1388,10 @@ int xfrm_state_update(struct xfrm_state *x)
 		memcpy(&x1->lft, &x->lft, sizeof(x1->lft));
 		x1->km.dying = 0;

+		/* To update Authendication and Encryption keys */
+		x1->aalg = kmemdup( x->aalg, xfrm_alg_auth_len(x->aalg), GFP_KERNEL);
+		x1->ealg = kmemdup( x->ealg, xfrm_alg_len(x->ealg), GFP_KERNEL);
+
 		tasklet_hrtimer_start(&x1->mtimer, ktime_set(1, 0), HRTIMER_MODE_REL);
 		if (x1->curlft.use_time)
 			xfrm_state_check_expire(x1);
