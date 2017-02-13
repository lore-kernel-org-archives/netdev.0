From: David Ahern <dsa@cumulusnetworks.com>
Subject: [PATCH iproute2 v2] ip route: Make name of protocol 0 consistent
Date: Mon, 13 Feb 2017 12:21:53 -0800
Message-ID: <1487017313-8000-1-git-send-email-dsa@cumulusnetworks.com>
Cc: David Ahern <dsa@cumulusnetworks.com>
To: netdev@vger.kernel.org, stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ot0-f179.google.com ([74.125.82.179]:32806 "EHLO
        mail-ot0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752492AbdBMUV7 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 13 Feb 2017 15:21:59 -0500
Received: by mail-ot0-f179.google.com with SMTP id 73so77641185otj.0
        for <netdev@vger.kernel.org>; Mon, 13 Feb 2017 12:21:59 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

iproute2 can inconsistently show the name of protocol 0 if a route with
a custom protocol is added. For example:
  dsa@cartman:~$ ip -6 ro ls table all | egrep 'proto none|proto unspec'
  local ::1 dev lo  table local  proto none  metric 0  pref medium
  local fe80::225:90ff:fecb:1c18 dev lo  table local  proto none  metric 0  pref medium
  local fe80::92e2:baff:fe5c:da5d dev lo  table local  proto none  metric 0  pref medium

protocol 0 is pretty printed as "none". Add a route with a custom protocol:
  dsa@cartman:~$ sudo ip -6 ro add  2001:db8:200::1/128 dev eth0 proto 123

And now display has switched from "none" to "unspec":
  dsa@cartman:~$ ip -6 ro ls table all | egrep 'proto none|proto unspec'
  local ::1 dev lo  table local  proto unspec  metric 0  pref medium
  local fe80::225:90ff:fecb:1c18 dev lo  table local  proto unspec  metric 0  pref medium
  local fe80::92e2:baff:fe5c:da5d dev lo  table local  proto unspec  metric 0  pref medium

The rt_protos file has the id to name mapping as "unspec" while
rtnl_rtprot_tab[0] has "none". The presence of a custom protocol id
triggers reading the rt_protos file and overwriting the string in
rtnl_rtprot_tab. All of this is logic from 2004 and earlier.

Update rtnl_rtprot_tab to "unspec" to match the enum value.

Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
---
v2
- update rtnl_rtprot_tab instead of rt_protos file as requested by Stephen

 lib/rt_names.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/lib/rt_names.c b/lib/rt_names.c
index 3a16d5cf9bb5..04c15ff5b15f 100644
--- a/lib/rt_names.c
+++ b/lib/rt_names.c
@@ -119,7 +119,7 @@ static void rtnl_tab_initialize(const char *file, char **tab, int size)
 }
 
 static char *rtnl_rtprot_tab[256] = {
-	[RTPROT_UNSPEC]   = "none",
+	[RTPROT_UNSPEC]   = "unspec",
 	[RTPROT_REDIRECT] = "redirect",
 	[RTPROT_KERNEL]	  = "kernel",
 	[RTPROT_BOOT]	  = "boot",
-- 
2.1.4
