From: Mr Dash Four <mr.dash.four@googlemail.com>
Subject: [PATCH] iproute2: lib/utils.c bug fixes
Date: Fri, 12 Apr 2013 03:30:45 +0100
Message-ID: <516771D5.3040607@googlemail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <stephen@networkplumber.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f178.google.com ([209.85.212.178]:52248 "EHLO
	mail-wi0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751026Ab3DLCa5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Apr 2013 22:30:57 -0400
Received: by mail-wi0-f178.google.com with SMTP id hr17so153057wib.5
        for <netdev@vger.kernel.org>; Thu, 11 Apr 2013 19:30:56 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch fixes the following 3 bugs in get_u32/get_u64 functions:

  1. On 32-bit systems, get_u32 could not detect an overflow.
     get_u32(&l, "4294967296", 10) always returned 4294967295
     (ULONG_MAX on 32-bit systems).

  2. get_u64(&ll, "4294967295", 10) was returning an error where
     it shouldn't have (4294967295 is perfectly legitimate value for
     unsigned long long).

  3. get_u64 couldn't detect an overflow errors (arg > ULLONG_MAX)

Signed-off-by: Mr Dash Four <mr.dash.four@googlemail.com>
---
  lib/utils.c |    8 ++++++--
  1 file changed, 6 insertions(+), 2 deletions(-)

diff --git a/lib/utils.c b/lib/utils.c
index 5bcdbcf..aeee8f1 100644
--- a/lib/utils.c
+++ b/lib/utils.c
@@ -149,10 +149,12 @@ int get_u64(__u64 *val, const char *arg, int base)
  	unsigned long long res;
  	char *ptr;

+	errno = 0;
+
  	if (!arg || !*arg)
  		return -1;
  	res = strtoull(arg, &ptr, base);
-	if (!ptr || ptr == arg || *ptr || res == 0xFFFFFFFFULL)
+	if (!ptr || ptr == arg || *ptr || (res == ULLONG_MAX && errno == ERANGE))
   		return -1;
   	*val = res;
   	return 0;
@@ -163,10 +165,12 @@ int get_u32(__u32 *val, const char *arg, int base)
  	unsigned long res;
  	char *ptr;

+	errno = 0;
+
  	if (!arg || !*arg)
  		return -1;
  	res = strtoul(arg, &ptr, base);
-	if (!ptr || ptr == arg || *ptr || res > 0xFFFFFFFFUL)
+	if (!ptr || ptr == arg || *ptr || res > 0xFFFFFFFFUL || errno == ERANGE)
  		return -1;
  	*val = res;
  	return 0;
