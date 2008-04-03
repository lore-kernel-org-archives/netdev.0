From: Dmitry Butskoy <buc@odusz.so-cdu.ru>
Subject: [PATCH] reopen bug #8747 -- complete the fix
Date: Thu, 03 Apr 2008 17:11:50 +0400
Message-ID: <47F4D796.7020909@odu.neva.ru>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------020104070506050903040908"
To: yoshfuji@linux-ipv6.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail2.odu.neva.ru ([194.85.100.6]:49248 "EHLO mail2.odu.neva.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751157AbYDCNTq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 3 Apr 2008 09:19:46 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------020104070506050903040908
Content-Type: text/plain; charset=KOI8-R; format=flowed
Content-Transfer-Encoding: 7bit

Hi,

There was a bug http://bugzilla.kernel.org/show_bug.cgi?id=8747,

"MSG_ERRQUEUE messages do not pass to connected raw sockets",

which still is not fixed completely. I've made a patch (attached), 
against the 2.6.24.4 tree. The patch fixes the issue completely for me, 
I've successfully tested it with my traceroute(8) 
(http://traceroute.sf.net) implementation.

Sorry that I have not checked up the previous attempt in real tests. I 
assumed that "typo" which I had found  at that time (saddr/daddr 
swapped) is just "a typo", and things "obviously" should work then... 
Unfortunately, it seems that I am a first person who actually use 
MSG_ERRQUEUE on connected ipv6 raw sockets. It is  a reason why all last 
years nobody reported this bug.

Note, that "connected raw sockets" is a good feature for my 
traceroute(8) program, as it allows to filter all alien packets from the 
socket's input. Without this, I will receive all the incoming packets 
(i.e. all the icmp, or all the tcp and so on packets coming to my host). 
It seems to matter especially for tcp.  Tcp tracerouting becomes most 
popular now, but on the heavily loaded hosts with big tcp traffic the 
unconnected raw tcp socket will receive all such a traffic, which I 
prefer to avoid. (I cannot decrease the number of packets, by specifying 
to receive just MSG_ERRQUEUE messages. Anyway, I have to receive a 
packet from the final destination, which is not an error packet -- icmp 
echoreply, or tcp syn+ack ).


Regards,
Dmitry Butskoy
http://www.fedoraproject.org/wiki/DmitryButskoy

--------------020104070506050903040908
Content-Type: text/x-diff;
 name="ipv6-raw_socket_msg_errqueue.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="ipv6-raw_socket_msg_errqueue.patch"

diff -Nrbu ipv6/icmp.c ipv6.OK/icmp.c
--- ipv6/icmp.c	2007-10-10 00:31:38.000000000 +0400
+++ ipv6.OK/icmp.c	2008-04-03 16:31:11.000000000 +0400
@@ -584,8 +584,8 @@
 	if (!pskb_may_pull(skb, inner_offset+8))
 		return;
 
-	saddr = &ipv6_hdr(skb)->saddr;
-	daddr = &ipv6_hdr(skb)->daddr;
+	saddr = &((struct ipv6hdr *)skb->data)->saddr;
+	daddr = &((struct ipv6hdr *)skb->data)->daddr;
 
 	/* BUGGG_FUTURE: we should try to parse exthdrs in this packet.
 	   Without this we will not able f.e. to make source routed

--------------020104070506050903040908--
