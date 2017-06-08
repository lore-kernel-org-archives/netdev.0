From: Arnd Bergmann <arnd@arndb.de>
Subject: [PATCH] ila_xlat: add missing hash secret initialization
Date: Thu,  8 Jun 2017 09:54:24 +0200
Message-ID: <20170608075448.2076975-1-arnd@arndb.de>
Cc: Arnd Bergmann <arnd@arndb.de>,
        "David S. Miller" <davem@davemloft.net>,
        Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
        James Morris <jmorris@namei.org>,
        Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
        Patrick McHardy <kaber@trash.net>,
        stephen hemminger <stephen@networkplumber.org>,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Tom Herbert <tom@herbertland.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

While discussing the possible merits of clang warning about unused initialized
functions, I found one function that was clearly meant to be called but
never actually is.

__ila_hash_secret_init() initializes the hash value for the ila locator,
apparently this is intended to prevent hash collision attacks, but this ends
up being a read-only zero constant since there is no caller. I could find
no indication of why it was never called, the earliest patch submission
for the module already was like this. If my interpretation is right, we
certainly want to backport the patch to stable kernels as well.

I considered adding it to the ila_xlat_init callback, but for best effect
the random data is read as late as possible, just before it is first used.
The underlying net_get_random_once() is already highly optimized to avoid
overhead when called frequently.

Fixes: 7f00feaf1076 ("ila: Add generic ILA translation facility")
Cc: stable@vger.kernel.org
Link: https://www.spinics.net/lists/kernel/msg2527243.html
Signed-off-by: Arnd Bergmann <arnd@arndb.de>
---
 net/ipv6/ila/ila_xlat.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/net/ipv6/ila/ila_xlat.c b/net/ipv6/ila/ila_xlat.c
index 2fd5ca151dcf..77f7f8c7d93d 100644
--- a/net/ipv6/ila/ila_xlat.c
+++ b/net/ipv6/ila/ila_xlat.c
@@ -62,6 +62,7 @@ static inline u32 ila_locator_hash(struct ila_locator loc)
 {
 	u32 *v = (u32 *)loc.v32;
 
+	__ila_hash_secret_init();
 	return jhash_2words(v[0], v[1], hashrnd);
 }
 
-- 
2.9.0
