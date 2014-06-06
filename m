From: Dmitry Popov <ixaphire@qrator.net>
Subject: [PATCH iproute2] fix ip tunnel for vti tunnels with ikey
Date: Sat, 7 Jun 2014 00:33:49 +0400
Message-ID: <20140607003349.d8b0fd526cb6403437c88c33@qrator.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: ixaphire@qrator.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f52.google.com ([209.85.215.52]:38880 "EHLO
	mail-la0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751856AbaFFUdy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Jun 2014 16:33:54 -0400
Received: by mail-la0-f52.google.com with SMTP id s18so1806907lam.25
        for <netdev@vger.kernel.org>; Fri, 06 Jun 2014 13:33:52 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Consider the following command:

ip tunnel add mode vti remote 12.0.0.1 local 12.0.0.3 ikey 15

i_flags will be GRE_KEY|VTI_ISVTI. So, in order to distinguish between ipip and
vti we have to check just VTI_ISVTI bit, not the equality of i_flags and 
VTI_ISVTI.

Signed-off-by: Dmitry Popov <ixaphire@qrator.net>
---
 ip/iptunnel.c | 18 +++++++++---------
 1 file changed, 9 insertions(+), 9 deletions(-)

diff --git a/ip/iptunnel.c b/ip/iptunnel.c
index 9ae8847..4d0fc21 100644
--- a/ip/iptunnel.c
+++ b/ip/iptunnel.c
@@ -287,10 +287,10 @@ static int do_add(int cmd, int argc, char **argv)
 
 	switch (p.iph.protocol) {
 	case IPPROTO_IPIP:
-		if (p.i_flags != VTI_ISVTI)
-			return tnl_add_ioctl(cmd, "tunl0", p.name, &p);
-		else
+		if (p.i_flags & VTI_ISVTI)
 			return tnl_add_ioctl(cmd, "ip_vti0", p.name, &p);
+		else
+			return tnl_add_ioctl(cmd, "tunl0", p.name, &p);
 	case IPPROTO_GRE:
 		return tnl_add_ioctl(cmd, "gre0", p.name, &p);
 	case IPPROTO_IPV6:
@@ -311,10 +311,10 @@ static int do_del(int argc, char **argv)
 
 	switch (p.iph.protocol) {
 	case IPPROTO_IPIP:
-		if (p.i_flags != VTI_ISVTI)
-			return tnl_del_ioctl("tunl0", p.name, &p);
-		else
+		if (p.i_flags & VTI_ISVTI)
 			return tnl_del_ioctl("ip_vti0", p.name, &p);
+		else
+			return tnl_del_ioctl("tunl0", p.name, &p);
 	case IPPROTO_GRE:
 		return tnl_del_ioctl("gre0", p.name, &p);
 	case IPPROTO_IPV6:
@@ -503,10 +503,10 @@ static int do_show(int argc, char **argv)
 
 	switch (p.iph.protocol) {
 	case IPPROTO_IPIP:
-		if (p.i_flags != VTI_ISVTI)
-			err = tnl_get_ioctl(p.name[0] ? p.name : "tunl0", &p);
-		else
+		if (p.i_flags & VTI_ISVTI)
 			err = tnl_get_ioctl(p.name[0] ? p.name : "ip_vti0", &p);
+		else
+			err = tnl_get_ioctl(p.name[0] ? p.name : "tunl0", &p);
 		break;
 	case IPPROTO_GRE:
 		err = tnl_get_ioctl(p.name[0] ? p.name : "gre0", &p);
