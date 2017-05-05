From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: net/key: slab-out-of-bounds in pfkey_compile_policy
Date: Fri, 5 May 2017 11:11:05 +0200
Message-ID: <20170505091105.GA9813@secunet.com>
References: <CAAeHK+xqxvEWMXS9sDNi2seUqFzJkijKJhivB8JDehpCJvBAaw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
        "David S. Miller" <davem@davemloft.net>,
        netdev <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>
To: Andrey Konovalov <andreyknvl@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([62.96.220.36]:41124 "EHLO a.mx.secunet.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753246AbdEEJLH (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 5 May 2017 05:11:07 -0400
Content-Disposition: inline
In-Reply-To: <CAAeHK+xqxvEWMXS9sDNi2seUqFzJkijKJhivB8JDehpCJvBAaw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, May 02, 2017 at 06:45:03PM +0200, Andrey Konovalov wrote:
> Hi,
> 
> I've got the following error report while fuzzing the kernel with syzkaller.
> 
> On commit d3b5d35290d729a2518af00feca867385a1b08fa (4.11).
> 
> A reproducer and .config are attached.
> 
> ==================================================================
> BUG: KASAN: slab-out-of-bounds in pfkey_compile_policy+0x8e6/0xd40 at
> addr ffff88006701f798
> Read of size 1280 by task a.out/4181


This bug was introduced twelve years ago...

This patch is based just on code review, I don't have an option to
function test this. But I see that we now exit with -EINVAL before the
memcpy that causes the slab-out-of-bounds when using your reproducer,
so it should at least fix the bug.

Subject: [PATCH RFC] af_key: Fix slab-out-of-bounds in pfkey_compile_policy.

The sadb_x_sec_len is stored in the unit 'byte divided by eight'.
So we have to multiply this value by eight before we can do
size checks. Otherwise we may get a slab-out-of-bounds when
we memcpy the user sec_ctx.

Fixes: df71837d502 ("[LSM-IPSec]: Security association restriction.")
Reported-by: Andrey Konovalov <andreyknvl@google.com>
Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
---
 net/key/af_key.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/key/af_key.c b/net/key/af_key.c
index c1950bb..512dc43 100644
--- a/net/key/af_key.c
+++ b/net/key/af_key.c
@@ -3285,7 +3285,7 @@ static struct xfrm_policy *pfkey_compile_policy(struct sock *sk, int opt,
 		p += pol->sadb_x_policy_len*8;
 		sec_ctx = (struct sadb_x_sec_ctx *)p;
 		if (len < pol->sadb_x_policy_len*8 +
-		    sec_ctx->sadb_x_sec_len) {
+		    sec_ctx->sadb_x_sec_len*8) {
 			*dir = -EINVAL;
 			goto out;
 		}
-- 
2.7.4
