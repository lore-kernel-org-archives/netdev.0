From: akpm@linux-foundation.org
Subject: [patch 1/4] drivers/isdn/capi/kcapi.c: Adjust error handling code involving capi_ctr_put
Date: Mon, 22 Sep 2008 14:51:01 -0700
Message-ID: <200809222151.m8MLp1S9031895@imap1.linux-foundation.org>
Cc: netdev@vger.kernel.org, akpm@linux-foundation.org, julia@diku.dk,
	davem@davemloft.net
To: kkeil@suse.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:39608 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753465AbYIVVvi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Sep 2008 17:51:38 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Julia Lawall <julia@diku.dk>

After calling capi_ctr_get, error handling code should call capi_ctr_put.

The semantic match that finds this problem is as follows:
(http://www.emn.fr/x-info/coccinelle/)

// <smpl>
@r@
expression x,E;
statement S;
position p1,p2,p3;
@@

(
if ((x = capi_ctr_get@p1(...)) == NULL || ...) S
|
x = capi_ctr_get@p1(...)
... when != x
if (x == NULL || ...) S
)
<...
if@p3 (...) { ... when != capi_ctr_put(x)
                  when != if (x) { ... capi_ctr_put(x); ...}
    return@p2 ...;
}
...>
(
return x;
|
return 0;
|
x = E
|
E = x
|
capi_ctr_put(x)
)

@exists@
position r.p1,r.p2,r.p3;
expression x;
int ret != 0;
statement S;
@@

* x = capi_ctr_get@p1(...)
  <...
* if@p3 (...)
  S
  ...>
* return@p2 \(NULL\|ret\);
// </smpl>

Signed-off-by: Julia Lawall <julia@diku.dk>
Cc: Karsten Keil <kkeil@suse.de>
Cc: "David S. Miller" <davem@davemloft.net>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 drivers/isdn/capi/kcapi.c |    4 ++++
 1 file changed, 4 insertions(+)

diff -puN drivers/isdn/capi/kcapi.c~drivers-isdn-capi-kcapic-adjust-error-handling-code-involving-capi_ctr_put drivers/isdn/capi/kcapi.c
--- a/drivers/isdn/capi/kcapi.c~drivers-isdn-capi-kcapic-adjust-error-handling-code-involving-capi_ctr_put
+++ a/drivers/isdn/capi/kcapi.c
@@ -828,15 +828,18 @@ static int old_capi_manufacturer(unsigne
 			return -ESRCH;
 		if (card->load_firmware == NULL) {
 			printk(KERN_DEBUG "kcapi: load: no load function\n");
+			capi_ctr_put(card);
 			return -ESRCH;
 		}
 
 		if (ldef.t4file.len <= 0) {
 			printk(KERN_DEBUG "kcapi: load: invalid parameter: length of t4file is %d ?\n", ldef.t4file.len);
+			capi_ctr_put(card);
 			return -EINVAL;
 		}
 		if (ldef.t4file.data == NULL) {
 			printk(KERN_DEBUG "kcapi: load: invalid parameter: dataptr is 0\n");
+			capi_ctr_put(card);
 			return -EINVAL;
 		}
 
@@ -849,6 +852,7 @@ static int old_capi_manufacturer(unsigne
 
 		if (card->cardstate != CARD_DETECTED) {
 			printk(KERN_INFO "kcapi: load: contr=%d not in detect state\n", ldef.contr);
+			capi_ctr_put(card);
 			return -EBUSY;
 		}
 		card->cardstate = CARD_LOADING;
_
