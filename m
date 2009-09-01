From: Jamie Le Tual <jamie.letual@gmail.com>
Subject: [iputils] - patch for ping to set un.echo.id to network byte order
Date: Tue, 1 Sep 2009 01:05:37 -0400
Message-ID: <ebb05fd20908312205v2c6184bfi88eff30bf0834356@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: nedev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qy0-f181.google.com ([209.85.221.181]:62429 "EHLO
	mail-qy0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750732AbZIAFFf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Sep 2009 01:05:35 -0400
Received: by qyk11 with SMTP id 11so3325558qyk.1
        for <netdev@vger.kernel.org>; Mon, 31 Aug 2009 22:05:37 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I noticed in the ping source code that the identity flag on the icmp
echo packet is set to the pid of the ping command being run. I
immediatly fired up a packet sniffer to see it, but got endian
wierdness. Looking back at the code, and comparing with ping6 and
traceroute6, I noticed that when the identity is set, its fed the
value of getpid() without running it through htons(), as is done in
traceroute6.

So this patch for the ipv4 version of ping:

diff -pu iputils-s20071127/ping_common.c iputils-jamie/ping_common.c
--- iputils-s20071127/ping_common.c	2007-11-26 19:57:27.000000000 -0500
+++ iputils-jamie/ping_common.c	2009-09-01 00:10:58.000000000 -0400
@@ -473,7 +473,7 @@ void setup(int icmp_sock)
 			*p++ = i;
 	}

-	ident = getpid() & 0xFFFF;
+	ident = htons(getpid() & 0xFFFF);

 	set_signal(SIGINT, sigexit);
 	set_signal(SIGALRM, sigexit);



seems obvious enough. I figured that htons was safe enough, since
pid_t is just an int.

Is there some reason to not send the identifier properly so it doesn't
end up bass-ackwards on the receiving end?
