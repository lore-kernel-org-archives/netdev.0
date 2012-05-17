From: Miklos Szeredi <miklos@szeredi.hu>
Subject: tcp timestamp issues with google servers
Date: Thu, 17 May 2012 11:39:27 +0200
Message-ID: <87r4ujno34.fsf@tucsk.pomaz.szeredi.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f170.google.com ([209.85.212.170]:42105 "EHLO
	mail-wi0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759448Ab2EQJiz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 May 2012 05:38:55 -0400
Received: by wibhm6 with SMTP id hm6so4224763wib.1
        for <netdev@vger.kernel.org>; Thu, 17 May 2012 02:38:54 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sometimes connection to google.com, gmail.com and other google servers
doesn't work or takes ages to connect.  When this hits it hits all
google servers at the same time and it's persistent.  It never happens
to anything other than google.  Rebooting helps.  Rarely it goes away
spontaneously.

Apparently google is sometimes replying with an invalid TSecr timestamp
value (smaller than the one sent in the last packet) and this confuses
the Linux TCP stack which either discards the packet or sends a Reset.

Network dump attached.

I found only a couple of references to this issue:

http://gotchas.livejournal.com/3028.html

http://groups.google.com/group/comp.os.linux.networking/browse_thread/thread/29f56feded11b42a

Turning tcp timestamps fixes the issue:

  sysctl -w net.ipv4.tcp_timestamps=0

Not sure why this happens only to me and a very few others.

It appears to be an issue with google TCP stack (is it a modified
stack?) but I thought about issues in my network switch (restarting it
doesn't help) or something in the ISP, but those look unlikely.

Any ideas?

Thanks,
Miklos



  1   0.000000 192.168.28.100 -> 74.125.232.226 TCP 51303 > http [SYN] Seq=0 Win=14600 Len=0 MSS=1460 SACK_PERM=1 TSV=35355050 TSER=0 WS=5
  2   0.002730 74.125.232.226 -> 192.168.28.100 TCP http > 51303 [SYN, ACK] Seq=0 Ack=1 Win=14180 Len=0 MSS=1430 SACK_PERM=1 TSV=1184565067 TSER=35325344 WS=6
  3   0.002776 192.168.28.100 -> 74.125.232.226 TCP 51303 > http [RST] Seq=1 Win=0 Len=0
  4   1.001408 192.168.28.100 -> 74.125.232.226 TCP 51303 > http [SYN] Seq=0 Win=14600 Len=0 MSS=1460 SACK_PERM=1 TSV=35356052 TSER=0 WS=5
  5   1.004136 74.125.232.226 -> 192.168.28.100 TCP [TCP Previous segment lost] http > 51303 [SYN, ACK] Seq=15638919 Ack=1 Win=14180 Len=0 MSS=1430 SACK_PERM=1 TSV=1184566068 TSER=35325344 WS=6
  6   1.411915 74.125.232.226 -> 192.168.28.100 TCP http > 51303 [SYN, ACK] Seq=15638919 Ack=1 Win=14180 Len=0 MSS=1430 SACK_PERM=1 TSV=1184566476 TSER=35325344 WS=6
  7   2.011568 74.125.232.226 -> 192.168.28.100 TCP http > 51303 [SYN, ACK] Seq=15638919 Ack=1 Win=14180 Len=0 MSS=1430 SACK_PERM=1 TSV=1184567076 TSER=35325344 WS=6
  8   3.005400 192.168.28.100 -> 74.125.232.226 TCP 51303 > http [SYN] Seq=0 Win=14600 Len=0 MSS=1460 SACK_PERM=1 TSV=35358056 TSER=0 WS=5
  9   3.007972 74.125.232.226 -> 192.168.28.100 TCP http > 51303 [SYN, ACK] Seq=15638919 Ack=1 Win=14180 Len=0 MSS=1430 SACK_PERM=1 TSV=1184568072 TSER=35325344 WS=6
 10   3.212862 74.125.232.226 -> 192.168.28.100 TCP http > 51303 [SYN, ACK] Seq=15638919 Ack=1 Win=14180 Len=0 MSS=1430 SACK_PERM=1 TSV=1184568277 TSER=35325344 WS=6
 11   5.612449 74.125.232.226 -> 192.168.28.100 TCP http > 51303 [SYN, ACK] Seq=15638919 Ack=1 Win=14180 Len=0 MSS=1430 SACK_PERM=1 TSV=1184570677 TSER=35325344 WS=6
 12   7.013405 192.168.28.100 -> 74.125.232.226 TCP 51303 > http [SYN] Seq=0 Win=14600 Len=0 MSS=1460 SACK_PERM=1 TSV=35362064 TSER=0 WS=5
 13   7.016627 74.125.232.226 -> 192.168.28.100 TCP http > 51303 [SYN, ACK] Seq=15638919 Ack=1 Win=14180 Len=0 MSS=1430 SACK_PERM=1 TSV=1184572080 TSER=35325344 WS=6
 14  10.412642 74.125.232.226 -> 192.168.28.100 TCP http > 51303 [SYN, ACK] Seq=15638919 Ack=1 Win=14180 Len=0 MSS=1430 SACK_PERM=1 TSV=1184575477 TSER=35325344 WS=6
 15  15.029547 192.168.28.100 -> 74.125.232.226 TCP 51303 > http [SYN] Seq=0 Win=14600 Len=0 MSS=1460 SACK_PERM=1 TSV=35370080 TSER=0 WS=5
 16  15.032931 74.125.232.226 -> 192.168.28.100 TCP http > 51303 [SYN, ACK] Seq=15638919 Ack=1 Win=14180 Len=0 MSS=1430 SACK_PERM=1 TSV=1184580097 TSER=35325344 WS=6
 17  31.061400 192.168.28.100 -> 74.125.232.226 TCP 51303 > http [SYN] Seq=0 Win=14600 Len=0 MSS=1460 SACK_PERM=1 TSV=35386112 TSER=0 WS=5
 18  31.064538 74.125.232.226 -> 192.168.28.100 TCP [TCP Previous segment lost] http > 51303 [SYN, ACK] Seq=485350292 Ack=1 Win=14180 Len=0 MSS=1430 SACK_PERM=1 TSV=1184596129 TSER=35325344 WS=6
 19  31.416339 74.125.232.226 -> 192.168.28.100 TCP http > 51303 [SYN, ACK] Seq=485350292 Ack=1 Win=14180 Len=0 MSS=1430 SACK_PERM=1 TSV=1184596480 TSER=35325344 WS=6
 20  32.015998 74.125.232.226 -> 192.168.28.100 TCP http > 51303 [SYN, ACK] Seq=485350292 Ack=1 Win=14180 Len=0 MSS=1430 SACK_PERM=1 TSV=1184597081 TSER=35325344 WS=6
 21  33.216276 74.125.232.226 -> 192.168.28.100 TCP http > 51303 [SYN, ACK] Seq=485350292 Ack=1 Win=14180 Len=0 MSS=1430 SACK_PERM=1 TSV=1184598281 TSER=35325344 WS=6
 22  35.616879 74.125.232.226 -> 192.168.28.100 TCP http > 51303 [SYN, ACK] Seq=485350292 Ack=1 Win=14180 Len=0 MSS=1430 SACK_PERM=1 TSV=1184600681 TSER=35325344 WS=6
 23  40.417065 74.125.232.226 -> 192.168.28.100 TCP http > 51303 [SYN, ACK] Seq=485350292 Ack=1 Win=14180 Len=0 MSS=1430 SACK_PERM=1 TSV=1184605482 TSER=35325344 WS=6
