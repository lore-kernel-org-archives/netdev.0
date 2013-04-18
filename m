From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] tcp: introduce TCPSpuriousRtxHostQueues SNMP
 counter
Date: Thu, 18 Apr 2013 09:52:51 -0700
Message-ID: <1366303971.3205.62.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, Yuchung Cheng <ycheng@google.com>,
	Neal Cardwell <ncardwell@google.com>,
	Tom Herbert <therbert@google.com>,
	Willem de Bruijn <willemb@google.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f174.google.com ([209.85.192.174]:64833 "EHLO
	mail-pd0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S936298Ab3DRQwx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Apr 2013 12:52:53 -0400
Received: by mail-pd0-f174.google.com with SMTP id p12so1684921pdj.19
        for <netdev@vger.kernel.org>; Thu, 18 Apr 2013 09:52:53 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

Host queues (Qdisc + NIC) can hold packets so long that TCP can
eventually retransmit a packet before the first transmit even left
the host.

Its not clear right now if we could avoid this in the first place :

- We could arm RTO timer not at the time we enqueue packets, but
  at the time we TX complete them (tcp_wfree())

- Cancel the sending of the new copy of the packet if prior one
  is still in queue.

This patch adds instrumentation so that we can at least see how
often this problem happens.

TCPSpuriousRtxHostQueues SNMP counter is incremented every time
we detect the fast clone is not yet freed in tcp_transmit_skb()

Signed-off-by: Eric Dumazet <edumazet@google.com>
Cc: Yuchung Cheng <ycheng@google.com>
Cc: Neal Cardwell <ncardwell@google.com>
Cc: Tom Herbert <therbert@google.com>
Cc: Willem de Bruijn <willemb@google.com>
---
Google-Bug-Id: 8584703

 include/uapi/linux/snmp.h |    1 +
 net/ipv4/proc.c           |    1 +
 net/ipv4/tcp_output.c     |    7 +++++++
 3 files changed, 9 insertions(+)

diff --git a/include/uapi/linux/snmp.h b/include/uapi/linux/snmp.h
index e00013a..fefdec91 100644
--- a/include/uapi/linux/snmp.h
+++ b/include/uapi/linux/snmp.h
@@ -247,6 +247,7 @@ enum
 	LINUX_MIB_TCPFASTOPENPASSIVEFAIL,	/* TCPFastOpenPassiveFail */
 	LINUX_MIB_TCPFASTOPENLISTENOVERFLOW,	/* TCPFastOpenListenOverflow */
 	LINUX_MIB_TCPFASTOPENCOOKIEREQD,	/* TCPFastOpenCookieReqd */
+	LINUX_MIB_TCPSPURIOUS_RTX_HOSTQUEUES, /* TCPSpuriousRtxHostQueues */
 	__LINUX_MIB_MAX
 };
 
diff --git a/net/ipv4/proc.c b/net/ipv4/proc.c
index b6f2ea1..6da51d5 100644
--- a/net/ipv4/proc.c
+++ b/net/ipv4/proc.c
@@ -269,6 +269,7 @@ static const struct snmp_mib snmp4_net_list[] = {
 	SNMP_MIB_ITEM("TCPFastOpenPassiveFail", LINUX_MIB_TCPFASTOPENPASSIVEFAIL),
 	SNMP_MIB_ITEM("TCPFastOpenListenOverflow", LINUX_MIB_TCPFASTOPENLISTENOVERFLOW),
 	SNMP_MIB_ITEM("TCPFastOpenCookieReqd", LINUX_MIB_TCPFASTOPENCOOKIEREQD),
+	SNMP_MIB_ITEM("TCPSpuriousRtxHostQueues", LINUX_MIB_TCPSPURIOUS_RTX_HOSTQUEUES),
 	SNMP_MIB_SENTINEL
 };
 
diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index d126943..1dc9ccc 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -846,6 +846,13 @@ static int tcp_transmit_skb(struct sock *sk, struct sk_buff *skb, int clone_it,
 		__net_timestamp(skb);
 
 	if (likely(clone_it)) {
+		const struct sk_buff *fclone = skb + 1;
+
+		if (unlikely(skb->fclone == SKB_FCLONE_ORIG &&
+			     fclone->fclone == SKB_FCLONE_CLONE))
+			NET_INC_STATS_BH(sock_net(sk),
+					 LINUX_MIB_TCPSPURIOUS_RTX_HOSTQUEUES);
+
 		if (unlikely(skb_cloned(skb)))
 			skb = pskb_copy(skb, gfp_mask);
 		else
