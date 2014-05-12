From: zhuyj <zyjzyj2000@gmail.com>
Subject: icmp: account for ICMP out errors because of socket limit
Date: Mon, 12 May 2014 11:19:28 +0800
Message-ID: <53703DC0.2070204@gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------020500030407000703090906"
Cc: "Tao, Yue" <Yue.Tao@windriver.com>, zhuyj <zyjzyj2000@gmail.com>,
	linux-kernel@vger.kernel.org, netdev <netdev@vger.kernel.org>
To: eric.dumazet@gmail.com, "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------020500030407000703090906
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Hi, Eric && David

  ____           ______________
|    |         |              |
| PC |<------->| MIPS 32 core |
|____|         |______________|

When ping from a PC to a board (MIPS 32 core), because of socket limit,
ping echo will fail. But ICMP_MIB_OUTERRORS counter is not incremented.
In this case, "netstat -s" can not report these errors.

This patch will fix this problem. Now it is in the attachment. Please 
check it.

Best Regards!
Zhu Yanjun

--------------020500030407000703090906
Content-Type: text/x-patch;
 name="0001-icmp-account-for-ICMP-out-errors-because-of-socket-l.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename*0="0001-icmp-account-for-ICMP-out-errors-because-of-socket-l.pa";
 filename*1="tch"

>From af800d0f123cf9c66a9ae167baa7dc1d25d0cd1f Mon Sep 17 00:00:00 2001
From: Zhu Yanjun <Yanjun.Zhu@windriver.com>
Date: Mon, 12 May 2014 11:07:20 +0800
Subject: [PATCH 1/1] icmp: account for ICMP out errors because of socket
 limit

When icmp_xmit_lock fails because of socket limit or memory shortage,
increment ICMP_MIB_OUTERRORS counter, so that "netstat -s" can report
these errors.

netstat -s | grep "ICMP messages failed"
    0 ICMP messages failed

Signed-off-by: Zhu Yanjun <Yanjun.Zhu@windriver.com>
---
 net/ipv4/icmp.c |    4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/net/ipv4/icmp.c b/net/ipv4/icmp.c
index 0134663..9a0bd7c 100644
--- a/net/ipv4/icmp.c
+++ b/net/ipv4/icmp.c
@@ -342,8 +342,10 @@ static void icmp_reply(struct icmp_bxm *icmp_param, struct sk_buff *skb)
 		return;
 
 	sk = icmp_xmit_lock(net);
-	if (sk == NULL)
+	if (sk == NULL){
+		ICMP_INC_STATS_BH(net, ICMP_MIB_OUTERRORS);
 		return;
+	}
 	inet = inet_sk(sk);
 
 	icmp_param->data.icmph.checksum = 0;
-- 
1.7.9.5


--------------020500030407000703090906--
