From: David Ahern <dsa@cumulusnetworks.com>
Subject: [PATCH iproute2] ss: Fix support for device filter by index
Date: Fri, 15 Jul 2016 15:41:35 -0700
Message-ID: <1468622495-24968-1-git-send-email-dsa@cumulusnetworks.com>
Cc: stephen@networkplumber.org, David Ahern <dsa@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f44.google.com ([209.85.220.44]:34408 "EHLO
	mail-pa0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751684AbcGOWlp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Jul 2016 18:41:45 -0400
Received: by mail-pa0-f44.google.com with SMTP id fi15so42863809pac.1
        for <netdev@vger.kernel.org>; Fri, 15 Jul 2016 15:41:45 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Support was recently added for device filters. The intent was to allow
the device to be specified by name or index, and using the if%u format
(dev == if5) or the simpler and more intuitive index alone (dev == 5).
The latter case is broken since the index is not saved to the filter
after the strtoul conversion. Further, the tmp variable used for the
conversion shadows another variable used in the function. Fix both.

With this change all 3 variants work as expected:
$ ss -t 'dev == 62'
State   Recv-Q Send-Q         Local Address:Port    Peer Address:Port
ESTAB       0      224         10.0.1.3%mgmt:ssh   192.168.0.50:58442

$ ss -t 'dev == mgmt'
State   Recv-Q Send-Q         Local Address:Port    Peer Address:Port
ESTAB       0      224         10.0.1.3%mgmt:ssh   192.168.0.50:58442

$ ss -t 'dev == if62'
State   Recv-Q Send-Q         Local Address:Port    Peer Address:Port
ESTAB       0      36          10.0.1.3%mgmt:ssh   192.168.0.50:58442

Fixes: 2d2932125616 ("ss: Add support to filter on device")
Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
---
No changes since last version. Applies cleanly to master branch.

 misc/ss.c | 8 +++++---
 1 file changed, 5 insertions(+), 3 deletions(-)

diff --git a/misc/ss.c b/misc/ss.c
index a0f9c6b9623c..abece96c0946 100644
--- a/misc/ss.c
+++ b/misc/ss.c
@@ -1435,11 +1435,13 @@ void *parse_devcond(char *name)
 	a.iface = xll_name_to_index(name);
 	if (a.iface == 0) {
 		char *end;
-		unsigned long res;
+		unsigned long n;
 
-		res = strtoul(name, &end, 0);
-		if (!end || end == name || *end || res > UINT_MAX)
+		n = strtoul(name, &end, 0);
+		if (!end || end == name || *end || n > UINT_MAX)
 			return NULL;
+
+		a.iface = n;
 	}
 
 	res = malloc(sizeof(*res));
-- 
2.1.4
