From: lepton <ytht.net@gmail.com>
Subject: [PATCH RESEND] 2.6.22.6 networking [ipv4]: fix wrong destination when reply packetes
Date: Fri, 21 Sep 2007 10:23:35 +0800
Message-ID: <20070921022335.GA2849@router.lepton.home>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: lkm <linux-kernel@vger.kernel.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rv-out-0910.google.com ([209.85.198.187]:10041 "EHLO
	rv-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752042AbXIUCYe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Sep 2007 22:24:34 -0400
Received: by rv-out-0910.google.com with SMTP id k20so662263rvb
        for <netdev@vger.kernel.org>; Thu, 20 Sep 2007 19:24:33 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,
  This is a resend of this patch with more details. I'd
  like it can be accepted this time.
  The problem: In icmp_reply and ip_send_reply function, 
  we now use rt->rt_src as destination to send out packets.
  For packets received in loopback device, this is wrong 
  sometimes.
  Here is an example (NOTE: eth0 address is set to 10.10.10.1/24):

  #tcpdump -n -i lo icmp &
  [1] 3155
  ...

  # hping3 --icmp --spoof 10.10.10.3 10.10.10.1
  ...
  09:53:49.508449 IP 10.10.10.3 > 10.10.10.1: icmp 8: echo request seq 0
  09:53:49.508482 IP 10.10.10.1 > 10.10.10.1: icmp 8: echo reply seq 0
  09:53:50.525560 IP 10.10.10.3 > 10.10.10.1: icmp 8: echo request seq 256
  09:53:50.525589 IP 10.10.10.1 > 10.10.10.1: icmp 8: echo reply seq 256

  The same thing will happend for tcp:

  # hping3 --syn --destport 1234 --spoof 10.10.10.3 10.10.10.1
  (NOTE: there is no service to listen on port 1234)
  ...
  10:02:59.395715 IP 10.10.10.3.2787 > 10.10.10.1.1234: S
  72057069:72057069(0) win 512 <mss 1414>
  10:02:59.395746 IP 10.10.10.1.1234 > 10.10.10.1.2787: R 0:0(0) ack
  72057070 win 0

  As you can see, all destination address is wrong.
  This problem comes from the fact that the route selection for packetes 
travle on loopback device only happend once. When we send out packets
from loopback device, the skb->dst is assigned in ip_route_output. It 
won't be reassinged in packetes recveive path. So the rt->rt_src don't 
equal to ip_hdr(skb)->saddr.
  I don't know why we must use rt->rt_src as destionation address. at least 
  for icmp reply packets, I thin we should use ip_hdr(skb)->saddr as 
  destionation address. this is according to RFC792:
   ...
   Addresses

      The address of the source in an echo message will be the
      destination of the echo reply message.  To form an echo reply
      message, the source and destination addresses are simply reversed,
      the type code changed to 0, and the checksum recomputed.
  
  A possible fix is to do ip_route_input in ip_rcv_finish for packtes 
  received in loopback device. But I think just to use ip_hdr(skb)->saddr 
  instead of rt->rt_src as destination to reply packetes is a more simple fix.
 
  Thanks Kenan Kalajdzic <kalajdzic@gmail.com> for help me with more details
  about this problem.
  
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


