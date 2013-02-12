From: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>
Subject: [PATCH 0/2] tcp: fix problems when tcp_fin_timeout is greater than
 60
Date: Tue, 12 Feb 2013 21:49:44 +0900
Message-ID: <1360673384.10638.10.camel@ubuntu-vm-makita>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from tama50.ecl.ntt.co.jp ([129.60.39.147]:54113 "EHLO
	tama50.ecl.ntt.co.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932967Ab3BLMtv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Feb 2013 07:49:51 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi all,

I found a strange behavior of FIN_WAIT2 timer when tcp_fin_timeout is greater
than 60. 

When it is between 60 and 120, if the socket is closed, FIN_WAIT2 keepalive
timer of (tcp_fin_timeout - 60) seconds long starts. After it expires, timewait
timer of (tcp_fin_timeout - 60) seconds long starts again. This takes total time
of (tcp_fin_timeout - 60) * 2 seconds to disappear the FIN_WAIT2 socket, which
is shorter than tcp_fin_timeout.

# sysctl -w net.ipv4.tcp_fin_timeout=63
net.ipv4.tcp_fin_timeout = 63
# while :; do netstat -anot | grep 54321 | grep FIN_WAIT2; sleep 1; done
tcp        0      0 127.0.0.1:43034         127.0.0.1:54321         FIN_WAIT2   keepalive (2.62/0/0)
tcp        0      0 127.0.0.1:43034         127.0.0.1:54321         FIN_WAIT2   keepalive (1.59/0/0)
tcp        0      0 127.0.0.1:43034         127.0.0.1:54321         FIN_WAIT2   keepalive (0.56/0/0)
tcp        0      0 127.0.0.1:43034         127.0.0.1:54321         FIN_WAIT2   timewait (2.61/0/0)
tcp        0      0 127.0.0.1:43034         127.0.0.1:54321         FIN_WAIT2   timewait (1.59/0/0)
tcp        0      0 127.0.0.1:43034         127.0.0.1:54321         FIN_WAIT2   timewait (0.56/0/0)

When it is greater than 120, although timewait timer appears to start from
(tcp_fin_timeout - 60), it expires after 60 seconds elapse in practice.

# sysctl -w net.ipv4.tcp_fin_timeout=150
net.ipv4.tcp_fin_timeout = 150
# while :; do netstat -anot | grep 54321 | grep FIN_WAIT2; sleep 1; done
tcp        0      0 127.0.0.1:43036         127.0.0.1:54321         FIN_WAIT2   keepalive (90.00/0/0)
tcp        0      0 127.0.0.1:43036         127.0.0.1:54321         FIN_WAIT2   keepalive (88.97/0/0)
tcp        0      0 127.0.0.1:43036         127.0.0.1:54321         FIN_WAIT2   keepalive (87.95/0/0)
...
tcp        0      0 127.0.0.1:43036         127.0.0.1:54321         FIN_WAIT2   keepalive (2.76/0/0)
tcp        0      0 127.0.0.1:43036         127.0.0.1:54321         FIN_WAIT2   keepalive (1.73/0/0)
tcp        0      0 127.0.0.1:43036         127.0.0.1:54321         FIN_WAIT2   keepalive (0.70/0/0)
tcp        0      0 127.0.0.1:43036         127.0.0.1:54321         FIN_WAIT2   timewait (89.68/0/0)
tcp        0      0 127.0.0.1:43036         127.0.0.1:54321         FIN_WAIT2   timewait (88.66/0/0)
tcp        0      0 127.0.0.1:43036         127.0.0.1:54321         FIN_WAIT2   timewait (87.63/0/0)
...
tcp        0      0 127.0.0.1:43036         127.0.0.1:54321         FIN_WAIT2   timewait (32.21/0/0)
tcp        0      0 127.0.0.1:43036         127.0.0.1:54321         FIN_WAIT2   timewait (31.18/0/0)
tcp        0      0 127.0.0.1:43036         127.0.0.1:54321         FIN_WAIT2   timewait (30.16/0/0)
(no more messages)

This seems to have been so for many years, but I think this behavior is not
desirable because it is confusing and does not match the documents.

Besides, it is also confusing that netstat shows keepalive timer first, and then
shows timewait timer, even though it is necessary to limit resources for the
orphaned socket.

I made patches that fix these problems.

Toshiaki Makita
