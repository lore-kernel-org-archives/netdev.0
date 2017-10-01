From: Yulia Kartseva <hex@fb.com>
Subject: [PATCH v2 iproute2] tc: fix ipv6 filter selector attribute for some prefix lengths
Date: Sat, 30 Sep 2017 20:18:40 -0700
Message-ID: <20171001031840.1252538-1-hex@fb.com>
References: <20170927092634.0870468d@shemminger-XPS-13-9360>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <yulia.kartseva@gmail.com>, <hex@fb.com>
To: <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:39344 "EHLO
        mx0b-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1750929AbdJADVI (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 30 Sep 2017 23:21:08 -0400
Received: from pps.filterd (m0109331.ppops.net [127.0.0.1])
        by mx0a-00082601.pphosted.com (8.16.0.21/8.16.0.21) with SMTP id v913IoTv001440
        for <netdev@vger.kernel.org>; Sat, 30 Sep 2017 20:21:07 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
        by mx0a-00082601.pphosted.com with ESMTP id 2da93esmqk-3
        (version=TLSv1 cipher=ECDHE-RSA-AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Sat, 30 Sep 2017 20:21:07 -0700
In-Reply-To: <20170927092634.0870468d@shemminger-XPS-13-9360>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Wrong TCA_U32_SEL attribute packing if prefixLen AND 0x1f equals 0x1f.
These are  /31, /63, /95 and /127 prefix lengths.

Example:
ip6 dst face:b00f::/31
filter parent b: protocol ipv6 pref 2307 u32
filter parent b: protocol ipv6 pref 2307 u32 fh 800: ht divisor 1
filter parent b: protocol ipv6 pref 2307 u32 fh 800::800 order 2048
key ht 800 bkt 0
  match faceb00f/ffffffff at 24

v2: previous patch was made with a wrong repo

Signed-off-by: Yulia Kartseva <hex@fb.com>
---
 tc/f_u32.c | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/tc/f_u32.c b/tc/f_u32.c
index 5815be9..14b9588 100644
--- a/tc/f_u32.c
+++ b/tc/f_u32.c
@@ -385,8 +385,7 @@ static int parse_ip6_addr(int *argc_p, char ***argv_p,
 
 	plen = addr.bitlen;
 	for (i = 0; i < plen; i += 32) {
-		/* if (((i + 31) & ~0x1F) <= plen) { */
-		if (i + 31 <= plen) {
+		if (i + 31 < plen) {
 			res = pack_key(sel, addr.data[i / 32],
 				       0xFFFFFFFF, off + 4 * (i / 32), offmask);
 			if (res < 0)
-- 
2.9.5
