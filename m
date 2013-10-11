From: Seif Mazareeb <seif@marvell.com>
Subject: [PATCH 1/1] net: fix cipso packet validation when !NETLABEL
Date: Fri, 11 Oct 2013 10:58:31 -0700
Message-ID: <0DB595A2CB707F458400BE9663B6A72269C0047793@SC-VEXCH2.marvell.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "thomas.petazzoni@free-electrons.com"
	<thomas.petazzoni@free-electrons.com>,
	Dmitri Epshtein <dima@marvell.com>
To: "davem@davemloft.net" <davem@davemloft.net>,
	"paul@paul-moore.com" <paul@paul-moore.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-0016f401.pphosted.com ([67.231.156.173]:51346 "EHLO
	mx0b-0016f401.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752772Ab3JKR6i convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 11 Oct 2013 13:58:38 -0400
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When CONFIG_NETLABEL is disabled, the cipso_v4_validate() function could loop
forever in the main loop if opt[opt_iter +1] == 0, this will causing a kernel
crash in an SMP system, since the CPU executing this function will
stall /not respond to IPIs.

This problem can be reproduced by running the IP Stack Integrity Checker
(http://isic.sourceforge.net) using the following command on a Linux machine
connected to DUT:

"icmpsic -s rand -d <DUT IP address> -r 123456"
wait (1-2 min)

Signed-off-by: Seif Mazareeb <seif@marvell.com>
---
 include/net/cipso_ipv4.h | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/include/net/cipso_ipv4.h b/include/net/cipso_ipv4.h
index a7a683e..047f1f6 100644
--- a/include/net/cipso_ipv4.h
+++ b/include/net/cipso_ipv4.h
@@ -306,6 +306,10 @@ static inline int cipso_v4_validate(const struct sk_buff *skb,
                        err_offset = opt_iter + 1;
                        goto out;
                }
+
+               if (opt[opt_iter + 1] == 0)
+                       break;
+
                opt_iter += opt[opt_iter + 1];
        }

--
1.8.1.2
