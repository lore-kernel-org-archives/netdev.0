From: Matthew Daley <mattjd@gmail.com>
Subject: [PATCH 1/3] x25: Validate incoming call user data lengths
Date: Sat, 15 Oct 2011 00:45:03 -0400
Message-ID: <1318653905-13716-2-git-send-email-mattjd@gmail.com>
References: <1318653905-13716-1-git-send-email-mattjd@gmail.com>
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Andrew Hendry <andrew.hendry@gmail.com>,
	Matthew Daley <mattjd@gmail.com>, stable <stable@kernel.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iy0-f174.google.com ([209.85.210.174]:64092 "EHLO
	mail-iy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751142Ab1JOEpQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 15 Oct 2011 00:45:16 -0400
Received: by mail-iy0-f174.google.com with SMTP id k3so3418201iae.19
        for <netdev@vger.kernel.org>; Fri, 14 Oct 2011 21:45:16 -0700 (PDT)
In-Reply-To: <1318653905-13716-1-git-send-email-mattjd@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

X.25 call user data is being copied in its entirety from incoming messages
without consideration to the size of the destination buffers, leading to
possible buffer overflows. Validate incoming call user data lengths before
these copies are performed.

It appears this issue was noticed some time ago, however nothing seemed to
come of it: see http://www.spinics.net/lists/linux-x25/msg00043.html and
commit 8db09f26f912f7c90c764806e804b558da520d4f.

Signed-off-by: Matthew Daley <mattjd@gmail.com>
Acked-by: Eric Dumazet <eric.dumazet@gmail.com>
Tested-by: Andrew Hendry <andrew.hendry@gmail.com>
Cc: stable <stable@kernel.org>
---
 net/x25/af_x25.c |    6 ++++++
 net/x25/x25_in.c |    3 +++
 2 files changed, 9 insertions(+), 0 deletions(-)

diff --git a/net/x25/af_x25.c b/net/x25/af_x25.c
index d306154..a4bd172 100644
--- a/net/x25/af_x25.c
+++ b/net/x25/af_x25.c
@@ -959,6 +959,12 @@ int x25_rx_call_request(struct sk_buff *skb, struct x25_neigh *nb,
 	skb_pull(skb,len);
 
 	/*
+	 *	Ensure that the amount of call user data is valid.
+	 */
+	if (skb->len > X25_MAX_CUD_LEN)
+		goto out_clear_request;
+
+	/*
 	 *	Find a listener for the particular address/cud pair.
 	 */
 	sk = x25_find_listener(&source_addr,skb);
diff --git a/net/x25/x25_in.c b/net/x25/x25_in.c
index 0b073b5..63488fd 100644
--- a/net/x25/x25_in.c
+++ b/net/x25/x25_in.c
@@ -127,6 +127,9 @@ static int x25_state1_machine(struct sock *sk, struct sk_buff *skb, int frametyp
 		 *	Copy any Call User Data.
 		 */
 		if (skb->len > 0) {
+			if (skb->len > X25_MAX_CUD_LEN)
+				goto out_clear;
+
 			skb_copy_from_linear_data(skb,
 						  x25->calluserdata.cuddata,
 						  skb->len);
-- 
1.7.2.5
