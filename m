From: Mathias Krause <minipli@googlemail.com>
Subject: [PATCH net] packet: fix heap info leak in PACKET_DIAG_MCLIST sock_diag interface
Date: Sun, 10 Apr 2016 12:52:28 +0200
Message-ID: <1460285548-832-1-git-send-email-minipli@googlemail.com>
Cc: netdev@vger.kernel.org,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Pavel Emelyanov <xemul@parallels.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f68.google.com ([74.125.82.68]:32794 "EHLO
	mail-wm0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752285AbcDJKxC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 10 Apr 2016 06:53:02 -0400
Received: by mail-wm0-f68.google.com with SMTP id y144so14771401wmd.0
        for <netdev@vger.kernel.org>; Sun, 10 Apr 2016 03:53:02 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Because we miss to wipe the remainder of i->addr[] in packet_mc_add(),
pdiag_put_mclist() leaks uninitialized heap bytes via the
PACKET_DIAG_MCLIST netlink attribute.

Fix this by explicitly memset(0)ing the remaining bytes in i->addr[].

Fixes: eea68e2f1a00 ("packet: Report socket mclist info via diag module")
Signed-off-by: Mathias Krause <minipli@googlemail.com>
Cc: Eric W. Biederman <ebiederm@xmission.com>
Cc: Pavel Emelyanov <xemul@parallels.com>
---
The bug itself precedes commit eea68e2f1a00 but the list wasn't exposed
to userland before the introduction of the packet_diag interface.
Therefore the "Fixes:" line on that commit.

 net/packet/af_packet.c |    1 +
 1 file changed, 1 insertion(+)

diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
index 992396aa635c..86a408cf38d5 100644
--- a/net/packet/af_packet.c
+++ b/net/packet/af_packet.c
@@ -3441,6 +3441,7 @@ static int packet_mc_add(struct sock *sk, struct packet_mreq_max *mreq)
 	i->ifindex = mreq->mr_ifindex;
 	i->alen = mreq->mr_alen;
 	memcpy(i->addr, mreq->mr_address, i->alen);
+	memset(i->addr + i->alen, 0, sizeof(i->addr) - i->alen);
 	i->count = 1;
 	i->next = po->mclist;
 	po->mclist = i;
-- 
1.7.10.4
