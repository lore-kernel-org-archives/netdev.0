From: Matthew Daley <mattjd@gmail.com>
Subject: [PATCH] x25: Validate incoming call user data lengths
Date: Tue, 4 Oct 2011 14:00:20 +0000
Message-ID: <CA+nUz_J73agjPQPqdbTraUPLyv39sqQ4kvZTmrZrFXLW1faqwg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Andrew Hendry <andrew.hendry@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gy0-f174.google.com ([209.85.160.174]:61943 "EHLO
	mail-gy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757286Ab1JDOAV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Oct 2011 10:00:21 -0400
Received: by gyg10 with SMTP id 10so491644gyg.19
        for <netdev@vger.kernel.org>; Tue, 04 Oct 2011 07:00:21 -0700 (PDT)
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
Cc: Eric Dumazet <eric.dumazet@gmail.com>
Cc: Andrew Hendry <andrew.hendry@gmail.com>
Cc: stable <stable@kernel.org>
---
Hopefully this is acceptable; I thought someone with greater knowledge of
X.25 might step in :) It should take into account Andrew's suggestion to
move af_x25.c's check to before the call acception.

 net/x25/af_x25.c |    6 ++++++
 net/x25/x25_in.c |    3 +++
 2 files changed, 9 insertions(+), 0 deletions(-)

diff --git a/net/x25/af_x25.c b/net/x25/af_x25.c
index d306154..a4bd172 100644
--- a/net/x25/af_x25.c
+++ b/net/x25/af_x25.c
@@ -959,6 +959,12 @@ int x25_rx_call_request(struct sk_buff *skb,
struct x25_neigh *nb,
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
@@ -127,6 +127,9 @@ static int x25_state1_machine(struct sock *sk,
struct sk_buff *skb, int frametyp
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
