From: Fan Du <fan.du@windriver.com>
Subject: [PATCHv3 net-next 3/3] xfrm: Add file to document IPsec corner case
Date: Mon, 16 Dec 2013 18:47:50 +0800
Message-ID: <1387190870-32506-4-git-send-email-fan.du@windriver.com>
References: <1387190870-32506-1-git-send-email-fan.du@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <davem@davemloft.net>, <netdev@vger.kernel.org>
To: <steffen.klassert@secunet.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail1.windriver.com ([147.11.146.13]:35961 "EHLO
	mail1.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752609Ab3LPKr4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Dec 2013 05:47:56 -0500
In-Reply-To: <1387190870-32506-1-git-send-email-fan.du@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Create Documentation/networking/ipsec.txt to document IPsec
corner issues and other info, which will be useful when user
deploying IPsec.

Signed-off-by: Fan Du <fan.du@windriver.com>
---
 Documentation/networking/ipsec.txt |   38 ++++++++++++++++++++++++++++++++++++
 1 file changed, 38 insertions(+)
 create mode 100644 Documentation/networking/ipsec.txt

diff --git a/Documentation/networking/ipsec.txt b/Documentation/networking/ipsec.txt
new file mode 100644
index 0000000..8dbc08b
--- /dev/null
+++ b/Documentation/networking/ipsec.txt
@@ -0,0 +1,38 @@
+
+Here documents known IPsec corner cases which need to be keep in mind when
+deploy various IPsec configuration in real world production environment.
+
+1. IPcomp: Small IP packet won't get compressed at sender, and failed on
+	   policy check on receiver.
+
+Quote from RFC3173:
+2.2. Non-Expansion Policy
+
+   If the total size of a compressed payload and the IPComp header, as
+   defined in section 3, is not smaller than the size of the original
+   payload, the IP datagram MUST be sent in the original non-compressed
+   form.  To clarify: If an IP datagram is sent non-compressed, no
+
+   IPComp header is added to the datagram.  This policy ensures saving
+   the decompression processing cycles and avoiding incurring IP
+   datagram fragmentation when the expanded datagram is larger than the
+   MTU.
+
+   Small IP datagrams are likely to expand as a result of compression.
+   Therefore, a numeric threshold should be applied before compression,
+   where IP datagrams of size smaller than the threshold are sent in the
+   original form without attempting compression.  The numeric threshold
+   is implementation dependent.
+
+Current IPComp implementation is indeed by the book, while as in practice
+when sending non-compressed packet to the peer(whether or not packet len
+is smaller than the threshold or the compressed len is large than original
+packet len), the packet is dropped when checking the policy as this packet
+matches the selector but not coming from any XFRM layer, i.e., with no
+security path. Such naked packet will not eventually make it to upper layer.
+The result is much more wired to the user when ping peer with different
+payload length.
+
+One workaround is try to set "level use" for each policy if user observed
+above scenario. The consequence of doing so is small packet(uncompressed)
+will skip policy checking on receiver side.
-- 
1.7.9.5
