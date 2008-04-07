From: Dmitry Butskoy <buc@odusz.so-cdu.ru>
Subject: [PATCH] for reopen bug #8747 -- complete the fix
Date: Mon, 07 Apr 2008 16:11:44 +0400
Message-ID: <47FA0F80.2080701@odu.neva.ru>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------030105000506000108020905"
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail2.odu.neva.ru ([194.85.100.6]:57642 "EHLO mail2.odu.neva.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757433AbYDGMLq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 7 Apr 2008 08:11:46 -0400
Received: from buc.odu.neva.ru (buc.odu.neva.ru [194.85.100.33])
	by mail2.odu.neva.ru (Postfix) with ESMTP id CFE3878011
	for <netdev@vger.kernel.org>; Mon,  7 Apr 2008 16:11:44 +0400 (MSD)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------030105000506000108020905
Content-Type: text/plain; charset=KOI8-R; format=flowed
Content-Transfer-Encoding: 7bit

There was a bug #8747, http://bugzilla.kernel.org/show_bug.cgi?id=8747,

"MSG_ERRQUEUE messages do not pass to connected raw sockets",

which still is not fixed, due to absence of proper tests.


I've made an additional patch (attached), against the 2.6.24.4 tree. The 
patch fixes the issue completely for me. Tested.

Sorry that I have not checked up the previous attempt in real tests. I
assumed that the "typo" which I had found at that time (saddr/daddr
swapped) is just "a typo", and things "obviously" should work then...
Unfortunately, it seems that I am a first person who actually use
MSG_ERRQUEUE on connected ipv6 raw sockets. It is a reason why all the 
last years nobody reported this bug.

Note, that "connected raw sockets" is a good feature for new
traceroute(8) implementation for Linux 
(http://traceroute.sourceforge.net), included now into Fedora and other 
distros. This feature allows to filter all alien packets from the 
socket's input. Without this, the program will receive all the incoming 
raw packets (for the "icmp" and "tcp" tracerouting methods, which use 
raw sockets).

Because of that wrong assumption, I've implemented a check, whether the 
kernel version is more than 2.6.22.2, and if so, allow raw ipv6 sockets 
to connect. But since 2.6.22.2, the issue still not fixed, and now any 
combination of "traceroute >= 2.0.8" and "kernel >= 2.6.22.2" leads to 
impossibility to do "icmp" and "tcp" tracerouting for IPv6. :(

Now I have to ship an update for traceroute. If the bug can be fixed in 
the nearest future (note the patch is too simple), I'll just change the 
version to check. If not, I'll be compelled to drop the raw sockets 
connection for a while.


Regards,
Dmitry Butskoy
http://www.fedoraproject.org/wiki/DmitryButskoy
An upstream maintainer of http://traceroute.sourceforge.net


--------------030105000506000108020905
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


--------------030105000506000108020905--
