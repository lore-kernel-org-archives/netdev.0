From: William Tu <u9012063@gmail.com>
Subject: [PATCH net] samples/bpf: fix bpf tunnel cleanup
Date: Mon, 31 Jul 2017 14:40:50 -0700
Message-ID: <1501537250-26371-1-git-send-email-u9012063@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f65.google.com ([74.125.82.65]:33017 "EHLO
        mail-wm0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751655AbdGaVlD (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 31 Jul 2017 17:41:03 -0400
Received: by mail-wm0-f65.google.com with SMTP id q189so426628wmd.0
        for <netdev@vger.kernel.org>; Mon, 31 Jul 2017 14:41:02 -0700 (PDT)
Received: from sc9-mailhost1.vmware.com ([208.91.1.34])
        by smtp.gmail.com with ESMTPSA id j23sm15220454ede.18.2017.07.31.14.41.00
        for <netdev@vger.kernel.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 31 Jul 2017 14:41:01 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

test_tunnel_bpf.sh fails to remove the vxlan11 tunnel device, causing the
next geneve tunnelling test case fails.  In addition, the geneve reserved bit
in tcbpf2_kern.c should be zero, according to the RFC.

Signed-off-by: William Tu <u9012063@gmail.com>
---
 samples/bpf/tcbpf2_kern.c      | 4 ++--
 samples/bpf/test_tunnel_bpf.sh | 1 +
 2 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/samples/bpf/tcbpf2_kern.c b/samples/bpf/tcbpf2_kern.c
index 9c823a609e75..270edcc149a1 100644
--- a/samples/bpf/tcbpf2_kern.c
+++ b/samples/bpf/tcbpf2_kern.c
@@ -147,9 +147,9 @@ int _geneve_set_tunnel(struct __sk_buff *skb)
 	__builtin_memset(&gopt, 0x0, sizeof(gopt));
 	gopt.opt_class = 0x102; /* Open Virtual Networking (OVN) */
 	gopt.type = 0x08;
-	gopt.r1 = 1;
+	gopt.r1 = 0;
 	gopt.r2 = 0;
-	gopt.r3 = 1;
+	gopt.r3 = 0;
 	gopt.length = 2; /* 4-byte multiple */
 	*(int *) &gopt.opt_data = 0xdeadbeef;
 
diff --git a/samples/bpf/test_tunnel_bpf.sh b/samples/bpf/test_tunnel_bpf.sh
index 1ff634f187b7..a70d2ea90313 100755
--- a/samples/bpf/test_tunnel_bpf.sh
+++ b/samples/bpf/test_tunnel_bpf.sh
@@ -149,6 +149,7 @@ function cleanup {
 	ip link del veth1
 	ip link del ipip11
 	ip link del gretap11
+	ip link del vxlan11
 	ip link del geneve11
 	pkill tcpdump
 	pkill cat
-- 
2.7.4
