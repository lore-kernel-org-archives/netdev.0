From: Swapnil Nagarkar <snagarka@redhat.com>
Subject: [PATCH 1/1] iproute2: wrong error when label is more than 15 chars
Date: Wed, 26 Mar 2014 16:09:48 +0530
Message-ID: <1395830388-13874-1-git-send-email-snagarka@redhat.com>
Cc: psabata@redhat.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:58629 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751054AbaCZKjw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 26 Mar 2014 06:39:52 -0400
Received: from int-mx13.intmail.prod.int.phx2.redhat.com (int-mx13.intmail.prod.int.phx2.redhat.com [10.5.11.26])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id s2QAdpqG001459
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <netdev@vger.kernel.org>; Wed, 26 Mar 2014 06:39:52 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The string for "label" option in "ip" command does not take more than 15 chanracters.
Gives error "RTNETLINK answers: Numerical result out of range".
$ ip addr add 10.65.X.X/23 dev em1:1 label em1:123456789012
RTNETLINK answers: Numerical result out of range
$ ip addr add 10.65.X.X/23 dev em1:1 label em1:12345678901

Adding check for maximum length of interface name and proper error
message.

After patch output:-
$ ./ip addr replace 192.168.50.4 dev em1:123 label em1:123456789012
Error: argument "em1:123456789012" is wrong: invalid label value.

Signed-off-by: Swapnil Nagarkar <snagarka@redhat.com>
---
 ip/ipaddress.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/ip/ipaddress.c b/ip/ipaddress.c
index 14d1720..b74517d 100644
--- a/ip/ipaddress.c
+++ b/ip/ipaddress.c
@@ -1358,6 +1358,8 @@ static int ipaddr_modify(int cmd, int flags, int argc, char **argv)
 		} else if (strcmp(*argv, "label") == 0) {
 			NEXT_ARG();
 			l = *argv;
+			if (strlen(l) >= IFNAMSIZ)
+				invarg("invalid label value.", *argv);
 			addattr_l(&req.n, sizeof(req), IFA_LABEL, l, strlen(l)+1);
 		} else if (matches(*argv, "valid_lft") == 0) {
 			if (valid_lftp)
-- 
1.8.5.3
