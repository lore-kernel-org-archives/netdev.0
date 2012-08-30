From: Lutz Jaenicke <ljaenicke@innominate.com>
Subject: [PATCH] rtnl_wilddump_request: fix alignment issue for embedded platforms
Date: Thu, 30 Aug 2012 17:01:34 +0200
Message-ID: <1346338894-12600-1-git-send-email-ljaenicke@innominate.com>
References: <1345621133-23583-1-git-send-email-ljaenicke@innominate.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from home.innominate.com ([77.245.32.75]:53481 "EHLO
	home.innominate.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750852Ab2H3PBh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Aug 2012 11:01:37 -0400
Received: from localhost (localhost.localdomain [127.0.0.1])
	by home.innominate.com (Postfix) with ESMTP id 62EBD232C1
	for <netdev@vger.kernel.org>; Thu, 30 Aug 2012 17:01:35 +0200 (CEST)
Received: from home.innominate.com ([127.0.0.1])
	by localhost (innominate.com [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id pi8rUZNsZXnX for <netdev@vger.kernel.org>;
	Thu, 30 Aug 2012 17:01:35 +0200 (CEST)
Received: from lutz.bln.innominate.local (lutz.bln.innominate.local [10.1.0.160])
	by home.innominate.com (Postfix) with ESMTP id 31FF023049
	for <netdev@vger.kernel.org>; Thu, 30 Aug 2012 17:01:35 +0200 (CEST)
In-Reply-To: <1345621133-23583-1-git-send-email-ljaenicke@innominate.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Platforms have different alignment requirements which need to be
fulfilled by the compiler. If the structure elements are already
4 byte (NLMGS_ALIGNTO) aligned by the compiler adding an explicit
padding element (align_rta) is not allowed.
Use __attribute__ ((aligned (NLMSG_ALIGNTO))) in order to achieve
the required alignment.
Experienced on ARM (xscale) with symptom
  netlink: 12 bytes leftover after parsing attributes

Tested on:
  ARM      (32bit Big Endian)
  PowerPC  (32bit Big Endian)
  x86_64   (64bit Little Endian)
Each with different aligment requirments.

Signed-off-by: Lutz Jaenicke <ljaenicke@innominate.com>
---
 lib/libnetlink.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/lib/libnetlink.c b/lib/libnetlink.c
index 8e8c8b9..09b4277 100644
--- a/lib/libnetlink.c
+++ b/lib/libnetlink.c
@@ -94,8 +94,8 @@ int rtnl_wilddump_request(struct rtnl_handle *rth, int family, int type)
 	struct {
 		struct nlmsghdr nlh;
 		struct rtgenmsg g;
-		__u16 align_rta;	/* attribute has to be 32bit aligned */
-		struct rtattr ext_req;
+		/* attribute has to be NLMSG aligned */
+		struct rtattr ext_req __attribute__ ((aligned(NLMSG_ALIGNTO)));
 		__u32 ext_filter_mask;
 	} req;
 
-- 
1.7.2.5
