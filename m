From: john <john@potentialcash.com>
Subject: bug in tcp/ip stack
Date: Sun, 22 Jul 2007 21:24:21 +0300
Message-ID: <46A3A0D5.6030909@potentialcash.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.potentialcash.com ([213.180.119.146]:60454 "EHLO
	mail.potentialcash.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758910AbXGVSdh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 22 Jul 2007 14:33:37 -0400
Received: from [10.1.0.10] (unknown [10.1.0.10])
	(using TLSv1 with cipher DHE-RSA-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mail.potentialcash.com (Postfix) with ESMTP id 7825A238C6
	for <netdev@vger.kernel.org>; Sun, 22 Jul 2007 21:21:41 +0300 (EEST)
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

I tracked down something that appears to be a small bug in networking code.
The way in witch i can reproduce it a complex one but it works 100%, so 
here comes the details:

I noticed strange packets on my fw coming from mail server with RST/ACK 
flags set coming from source port with no one listening on it and no 
connection attempts made to them from outside.
There are few messages on forums describing same problem and calling 
them alien ACK/RST packets.

Postfix mail server gives this behavior if for some reason client resets 
connection but some packets from client arrives after the RST, the serer 
box responds with RST and then with RST/ACK (with the wrong source port 
number).

Here is packet dump

1    0.000000    10.0.0.254    10.0.0.68    TCP    50000 > smtp [SYN] 
Seq=0 Len=0
2    0.001036    10.0.0.68    10.0.0.254    TCP    smtp > 50000 [SYN, 
ACK] Seq=0 Ack=1 Win=5840 Len=0 MSS=1460
3    0.001096    10.0.0.254    10.0.0.68    TCP    50000 > smtp [ACK] 
Seq=1 Ack=1 Win=1500 Len=0
4    0.001125    10.0.0.254    10.0.0.68    SMTP    Command: EHLO localhost
5    0.001150    10.0.0.254    10.0.0.68    TCP    50000 > smtp [RST] 
Seq=17 Len=0
6    0.001175    10.0.0.254    10.0.0.68    TCP    50000 > smtp [FIN, 
ACK] Seq=17 Ack=1 Win=1500 Len=0
7    0.001251    10.0.0.68    10.0.0.254    TCP    smtp > 50000 [ACK] 
Seq=1 Ack=17 Win=5840 Len=0
8    0.001284    10.0.0.68    10.0.0.254    TCP    smtp > 50000 [RST] 
Seq=1 Len=0
!!!9    0.218427    10.0.0.68    10.0.0.254    TCP    32768 > 50000 
[RST, ACK] Seq=0 Ack=0 Win=5840 Len=0

It is not the postfix bug, it is present in current 2.6.x and 2.4.x 
kernel versions but not in the 2.2.x tree, so after investigation i 
found it was introduced in 2.4.0-test9-pre3 back in year 2000 and 
survived for 7 years WOW :)


Whole 2.4.0-test9-pre3 diff is pretty big, but i managed to find lines 
responsible for this,
they are located in include/net/tcp.h

in function tcp_enter_cwr

if (sk->prev && !(sk->userlocks&SOCK_BINDPORT_LOCK))
                      tcp_put_port(sk);



It is not a big problem but under some setups the fw's conntrack table 
can get filled pretty quickly,  because wrong port number changes every 
time.

Can, you please check this out?

Evalds
