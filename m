From: Andreas Henriksson <andreas@fatal.se>
Subject: [PATCH] iproute: "ip mroute show" doesn't show all output
 interfaces
Date: Mon, 23 Nov 2009 10:52:31 +0100
Message-ID: <20091123095231.GA14210@amd64.fatal.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Mark Borst <mark@borst.org>
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from proxy2.bredband.net ([195.54.101.72]:61639 "EHLO
	proxy2.bredband.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752992AbZKWJv6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Nov 2009 04:51:58 -0500
Received: from ipb2.telenor.se (195.54.127.165) by proxy2.bredband.net (7.3.140.3)
        id 4AD3E1BC011FC4D2 for netdev@vger.kernel.org; Mon, 23 Nov 2009 10:52:00 +0100
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mark Borst <mark@borst.org>

The command "ip mroute show" will only show the first Oif. 

mark@flappie:~$ ip mroute show
(192.168.1.1, 224.0.0.123)       Iif: _rename    Oifs: eth1 

mark@flappie:~$ cat /proc/net/ip_mr_cache 
Group    Origin   Iif     Pkts    Bytes    Wrong Oifs
7B0000E0 0101A8C0 2          0        0        0  0:1    1:1  

This shows 2 Oifs here. However, ipmroute.c, function read_mroute_list(), uses sscanf() with a %s mask for oiflist, which stops after the first whitespace (i.e. after Oif 0:1). The patch below fixes this to read until the newline (though I'm not sure whether this is the proper way to fix it).

After this patch:
mark@flappie:~/iproute-20090324/ip$ ./ip mroute show
(192.168.1.1, 224.0.0.123)       Iif: _rename    Oifs: eth1 eth0 


This patch originally submitted as http://bugs.debian.org/550097

Signed-off-by: Andreas Henriksson <andreas@fatal.se>

--- iproute-20090324-origdeb/ip/ipmroute.c	2009-10-07 17:21:00.000000000 +0200
+++ iproute-20090324/ip/ipmroute.c	2009-10-07 17:34:01.000000000 +0200
@@ -95,7 +95,7 @@
 		char obuf[256];
 
 		oiflist[0] = 0;
-		if (sscanf(buf, "%x%x%d%u%u%u%s", maddr.data, msrc.data, &vifi,
+		if (sscanf(buf, "%x%x%d%u%u%u%[^\n]", maddr.data, msrc.data, &vifi,
 			   &pkts, &b, &w, oiflist) < 6)
 			continue;
