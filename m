From: David Ahern <dsa@cumulusnetworks.com>
Subject: [PATCH net] lwtunnel: valid encap attr check should return 0 when lwtunnel is disabled
Date: Wed,  8 Feb 2017 09:29:00 -0800
Message-ID: <1486574940-6513-1-git-send-email-dsa@cumulusnetworks.com>
Cc: pupilla@libero.it, David Ahern <dsa@cumulusnetworks.com>
To: netdev@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f47.google.com ([74.125.83.47]:34878 "EHLO
        mail-pg0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932926AbdBHR3G (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 8 Feb 2017 12:29:06 -0500
Received: by mail-pg0-f47.google.com with SMTP id 194so50606672pgd.2
        for <netdev@vger.kernel.org>; Wed, 08 Feb 2017 09:29:05 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

An error was reported upgrading to 4.9.8:
    root@Typhoon:~# ip route add default table 210 nexthop dev eth0 via 10.68.64.1
    weight 1 nexthop dev eth0 via 10.68.64.2 weight 1
    RTNETLINK answers: Operation not supported

The problem occurs when CONFIG_LWTUNNEL is not enabled and a multipath
route is submitted.

The point of lwtunnel_valid_encap_type_attr is catch modules that
need to be loaded before any references are taken with rntl held. With
CONFIG_LWTUNNEL disabled, there will be no modules to load so the
lwtunnel_valid_encap_type_attr stub should just return 0.

Fixes: 9ed59592e3e3 ("lwtunnel: fix autoload of lwt modules")
Reported-by: pupilla@libero.it
Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
---
 include/net/lwtunnel.h | 5 ++++-
 1 file changed, 4 insertions(+), 1 deletion(-)

diff --git a/include/net/lwtunnel.h b/include/net/lwtunnel.h
index 73dd87647460..0388b9c5f5e2 100644
--- a/include/net/lwtunnel.h
+++ b/include/net/lwtunnel.h
@@ -178,7 +178,10 @@ static inline int lwtunnel_valid_encap_type(u16 encap_type)
 }
 static inline int lwtunnel_valid_encap_type_attr(struct nlattr *attr, int len)
 {
-	return -EOPNOTSUPP;
+	/* return 0 since we are not walking attr looking for
+	 * RTA_ENCAP_TYPE attribute on nexthops.
+	 */
+	return 0;
 }
 
 static inline int lwtunnel_build_state(struct net_device *dev, u16 encap_type,
-- 
2.1.4
