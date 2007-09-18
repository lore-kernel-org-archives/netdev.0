From: lepton <ytht.net@gmail.com>
Subject: [PATCH] 2.6.22.6 NETWORKING [IPV4]: Always use source addr in skb to reply packet
Date: Tue, 18 Sep 2007 10:16:17 +0800
Message-ID: <20070918021617.GA15540@router.lepton.home>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: lkm <linux-kernel@vger.kernel.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from wa-out-1112.google.com ([209.85.146.178]:6265 "EHLO
	wa-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753404AbXIRCRM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Sep 2007 22:17:12 -0400
Received: by wa-out-1112.google.com with SMTP id v27so2246769wah
        for <netdev@vger.kernel.org>; Mon, 17 Sep 2007 19:17:11 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,
  In some situation, icmp_reply and ip_send_reply will send
  out packet with the wrong source addr, the following patch
  will fix this.

  I don't understand why we must use rt->rt_src in the current
  code, if this is a wrong fix, please correct me.

Signed-off-by: Lepton Wu <ytht.net@gmail.com>

diff -X linux-2.6.22.6/Documentation/dontdiff -pru linux-2.6.22.6/net/ipv4/icmp.c linux-2.6.22.6-lepton/net/ipv4/icmp.c
--- linux-2.6.22.6/net/ipv4/icmp.c	2007-09-14 17:41:18.000000000 +0800
+++ linux-2.6.22.6-lepton/net/ipv4/icmp.c	2007-09-18 09:57:30.000000000 +0800
@@ -382,6 +382,7 @@ static void icmp_reply(struct icmp_bxm *
 	struct ipcm_cookie ipc;
 	struct rtable *rt = (struct rtable *)skb->dst;
 	__be32 daddr;
+ 	struct iphdr *ip = ip_hdr(skb);
 
 	if (ip_options_echo(&icmp_param->replyopts, skb))
 		return;
@@ -393,7 +394,7 @@ static void icmp_reply(struct icmp_bxm *
 	icmp_out_count(icmp_param->data.icmph.type);
 
 	inet->tos = ip_hdr(skb)->tos;
-	daddr = ipc.addr = rt->rt_src;
+ 	daddr = ipc.addr = ip->saddr;
 	ipc.opt = NULL;
 	if (icmp_param->replyopts.optlen) {
 		ipc.opt = &icmp_param->replyopts;
diff -X linux-2.6.22.6/Documentation/dontdiff -pru linux-2.6.22.6/net/ipv4/ip_output.c linux-2.6.22.6-lepton/net/ipv4/ip_output.c
--- linux-2.6.22.6/net/ipv4/ip_output.c	2007-09-14 17:41:18.000000000 +0800
+++ linux-2.6.22.6-lepton/net/ipv4/ip_output.c	2007-09-18 09:57:13.000000000 +0800
@@ -1337,11 +1337,12 @@ void ip_send_reply(struct sock *sk, stru
 	struct ipcm_cookie ipc;
 	__be32 daddr;
 	struct rtable *rt = (struct rtable*)skb->dst;
+	struct iphdr *ip = ip_hdr(skb);
 
 	if (ip_options_echo(&replyopts.opt, skb))
 		return;
 
-	daddr = ipc.addr = rt->rt_src;
+	daddr = ipc.addr = ip->saddr;
 	ipc.opt = NULL;
 
 	if (replyopts.opt.optlen) {
