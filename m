From: Alexander Potapenko <glider@google.com>
Subject: [PATCH] net/packet: check length in getsockopt() called with PACKET_HDRLEN
Date: Tue, 25 Apr 2017 18:51:46 +0200
Message-ID: <20170425165146.25075-1-glider@google.com>
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: dvyukov@google.com, kcc@google.com, edumazet@google.com,
        davem@davemloft.net, kuznet@ms2.inr.ac.ru
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f53.google.com ([74.125.82.53]:35045 "EHLO
        mail-wm0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1432235AbdDYQwC (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 25 Apr 2017 12:52:02 -0400
Received: by mail-wm0-f53.google.com with SMTP id w64so28267756wma.0
        for <netdev@vger.kernel.org>; Tue, 25 Apr 2017 09:51:51 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In the case getsockopt() is called with PACKET_HDRLEN and optlen < 4
|val| remains uninitialized and the syscall may behave differently
depending on its value, and even copy garbage to userspace on certain
architectures. To fix this we now return -EINVAL if optlen is too small.

This bug has been detected with KMSAN.

Signed-off-by: Alexander Potapenko <glider@google.com>

---
The previous versions of this patch were called "net/packet: initialize
val in packet_getsockopt()"

v3: - change patch summary, return -EINVAL for optlen < sizeof(int)
v2: - if len < sizeof(int), make it 0

---
 net/packet/af_packet.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
index 8489beff5c25..ea81ccf3c7d6 100644
--- a/net/packet/af_packet.c
+++ b/net/packet/af_packet.c
@@ -3836,6 +3836,8 @@ static int packet_getsockopt(struct socket *sock, int level, int optname,
 	case PACKET_HDRLEN:
 		if (len > sizeof(int))
 			len = sizeof(int);
+		if (len < sizeof(int))
+			return -EINVAL;
 		if (copy_from_user(&val, optval, len))
 			return -EFAULT;
 		switch (val) {
-- 
2.13.0.rc0.306.g87b477812d-goog
