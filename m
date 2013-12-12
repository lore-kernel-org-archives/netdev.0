From: Daniel Andersson Tenninge <daniel.andersson.tenninge@ericsson.com>
Subject: so_linger + shutdown() still sends a tcp fin on timeout
Date: Thu, 12 Dec 2013 16:48:13 +0000
Message-ID: <9D8F8769F710A44DA16BEA3DC7ABFF55097EE2D9@ESESSMB101.ericsson.se>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: Anders Franzen <anders.franzen@ericsson.com>
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailgw2.ericsson.se ([193.180.251.37]:42197 "EHLO
	mailgw2.ericsson.se" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751798Ab3LLRDS convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Dec 2013 12:03:18 -0500
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

There seems to be a way in the kernel to avoid TCP sockets to end up in TIME-WAIT using the SO_LINGER setsockopt. Setting linger on but with timeout set to zero cause a call to close() to send out a TCP RST instead of FIN. Apparently some (including Apache Thrift) use this for short lived connections to avoid ending up with a lot of sockets in TIME-WAIT.

However, if a call to shutdown() for both read and write (SHUT_RDWR) is made the TCP stack still closes the connection using FIN and if a subsequent call to close() is made before the connection is deleted an RST is sent. So a call to shutdown()+close() will tear down the TCP connection using FIN+RST. According to RFC1122 section 4.2.2.13 a connection can be close normally by sending a FIN or aborted by sending a RST.

See http://pastebin.com/AzCCEbjJ for an example that will cause the kernel to send the following packets:

17:41:53.627071 IP 10.0.0.1.59968 > 192.168.10.10.123: Flags [S], seq 2968732977, win 14120, options [mss 1412,sackOK,TS val 17286889 ecr 0,nop,wscale 4], length 0
17:41:53.629052 IP 192.168.10.10.123 > 10.0.0.1.59968: Flags [S.], seq 1683464704, ack 2968732978, win 14480, options [mss 1460,sackOK,TS val17277856 ecr 17286889,nop,wscale 4], length 0
17:41:53.629086 IP 10.0.0.1.59968 > 192.168.10.10.123: Flags [.], ack 1, win 883, options [nop,nop,TS val 17286890 ecr 17277856], length 0
17:41:53.629151 IP 10.0.0.1.59968 > 192.168.10.10.123: Flags [P.], seq 1:7, ack 1, win 883, options [nop,nop,TS val 17286890 ecr 17277856], length 6
17:41:53.629567 IP 10.0.0.1.59968 > 192.168.10.10.123: Flags [F.], seq 7, ack 1, win 883, options [nop,nop,TS val 17286890 ecr 17277856], length 0
17:41:53.630040 IP 10.0.0.1.59968 > 192.168.10.10.123: Flags [R.], seq 8, ack 1, win 883, options [nop,nop,TS val 17286890 ecr 17277856], length 0
17:41:53.630716 IP 192.168.10.10.123 > 10.0.0.1.59968: Flags [.], ack 7, win 905, options [nop,nop,TS val 17277856 ecr 17286890], length 0
17:41:53.630736 IP 10.0.0.1.59968 > 192.168.10.10.123: Flags [R], seq 2968732984, win 0, length 0
17:41:53.631799 IP 192.168.10.10.123 > 10.0.0.1.59968: Flags [F.], seq 1, ack 8, win 905, options [nop,nop,TS val 17277857 ecr 17286890], length 0
17:41:53.631823 IP 10.0.0.1.59968 > 192.168.10.10.123: Flags [R], seq 2968732985, win 0, length 0

Is this simply a miss in the shutdown procedure for TCP that doesn't check the linger option on the socket or are there more to it? Wouldn't it be better that a call to shutdown() checks the linger option and if set it closes with RST after timeout and a subsequent call to close only cleans up the socket if the connection already is closed.

Regards,
Daniel
