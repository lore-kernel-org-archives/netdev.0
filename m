From: Michal Kubecek <mkubecek@suse.cz>
Subject: [PATCH iproute2] ip xfrm: use correct key length for netlink message
Date: Fri, 29 Sep 2017 13:41:05 +0200 (CEST)
Message-ID: <20170929114105.2D971A0F6B@unicorn.suse.cz>
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:36488 "EHLO mx1.suse.de"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751091AbdI2LlH (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 29 Sep 2017 07:41:07 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When SA is added manually using "ip xfrm state add", xfrm_state_modify()
uses alg_key_len field of struct xfrm_algo for the length of key passed to
kernel in the netlink message. However alg_key_len is bit length of the key
while we need byte length here. This is usually harmless as kernel ignores
the excess data but when the bit length of the key exceeds 512
(XFRM_ALGO_KEY_BUF_SIZE), it can result in buffer overflow.

We can simply divide by 8 here as the only place setting alg_key_len is in
xfrm_algo_parse() where it is always set to a multiple of 8 (and there are
already multiple places using "algo->alg_key_len / 8").

Signed-off-by: Michal Kubecek <mkubecek@suse.cz>
---
 ip/xfrm_state.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/ip/xfrm_state.c b/ip/xfrm_state.c
index 4483fb8f71d2..99fdec2325ec 100644
--- a/ip/xfrm_state.c
+++ b/ip/xfrm_state.c
@@ -539,7 +539,7 @@ static int xfrm_state_modify(int cmd, unsigned int flags, int argc, char **argv)
 
 				xfrm_algo_parse((void *)&alg, type, name, key,
 						buf, sizeof(alg.buf));
-				len += alg.u.alg.alg_key_len;
+				len += alg.u.alg.alg_key_len / 8;
 
 				addattr_l(&req.n, sizeof(req.buf), type,
 					  (void *)&alg, len);
-- 
2.14.2
