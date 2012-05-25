From: Earl Chew <echew@ixiacom.com>
Subject: Inadvertently sending a Christmas Tree TCP packet
Date: Fri, 25 May 2012 11:30:34 -0700
Message-ID: <4FBFCFCA.2090501@ixiacom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from am1ehsobe001.messaging.microsoft.com ([213.199.154.204]:25017
	"EHLO am1outboundpool.messaging.microsoft.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750864Ab2EYSam (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 May 2012 14:30:42 -0400
Received: from mail11-am1 (localhost [127.0.0.1])	by mail11-am1-R.bigfish.com
 (Postfix) with ESMTP id 5CDFD34025D	for <netdev@vger.kernel.org>; Fri, 25 May
 2012 18:30:28 +0000 (UTC)
Received: from AM1EHSMHS005.bigfish.com (unknown [10.3.201.242])	by
 mail11-am1.bigfish.com (Postfix) with ESMTP id 0DE82E0048	for
 <netdev@vger.kernel.org>; Fri, 25 May 2012 18:30:27 +0000 (UTC)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Does anyone have a reference to any discussions or patches that address this issue ?

Running a userspace daemon on a rather old 2.6.18 system can inadvertently cause a TCP
packet containing flags FIN, PSH, ACK and URG (see packet 16237) which can cause the receiver
(not Linux in this case) to become confused:

16220	111.075627	10.64.33.43	10.128.163.100	TCP	59253 > exec [SYN] Seq=0 Win=65535 Len=0 MSS=1460 WS=2
16222	0.203210	10.128.163.100	10.64.33.43	TCP	exec > 59253 [SYN, ACK] Seq=0 Ack=1 Win=5840 Len=0 MSS=1250 WS=7
16223	0.000032	10.64.33.43	10.128.163.100	TCP	59253 > exec [ACK] Seq=1 Ack=1 Win=65532 Len=0
16224	0.000215	10.64.33.43	10.128.163.100	TCP	59253 > exec [PSH, ACK] Seq=1 Ack=1 Win=65532 Len=6
16225	0.202465	10.128.163.100	10.64.33.43	TCP	exec > 59253 [ACK] Seq=1 Ack=7 Win=5888 Len=0
16229	0.209383	10.64.33.43	10.128.163.100	TCP	59253 > exec [PSH, ACK] Seq=7 Ack=1 Win=65532 Len=9
16231	0.202573	10.128.163.100	10.64.33.43	TCP	exec > 59253 [ACK] Seq=1 Ack=16 Win=5888 Len=0
16232	0.000024	10.64.33.43	10.128.163.100	TCP	59253 > exec [PSH, ACK] Seq=16 Ack=1 Win=65532 Len=14
16233	0.202618	10.128.163.100	10.64.33.43	TCP	exec > 59253 [ACK] Seq=1 Ack=30 Win=5888 Len=0
16234	0.012718	10.128.163.100	10.64.33.43	TCP	exec > 59253 [PSH, ACK] Seq=1 Ack=30 Win=5888 Len=1
16235	0.101229	10.128.163.100	10.64.33.43	TCP	exec > 59253 [PSH, ACK] Seq=2 Ack=30 Win=5888 Len=29
16236	0.000032	10.64.33.43	10.128.163.100	TCP	59253 > exec [ACK] Seq=30 Ack=31 Win=65504 Len=0
16237	0.000319	10.128.163.100	10.64.33.43	TCP	exec > 59253 [FIN, PSH, ACK, URG] Seq=31 Ack=30 Win=5888 Urg=1 Len=1
16240	1.114085	10.128.163.100	10.64.33.43	TCP	[TCP Retransmission] exec > 59253 [FIN, PSH, ACK, URG] Seq=31 Ack=30 Win=5888 Urg=1 Len=1


The receiver has become confused, and the so the Linux sender retransmits at packet 16240, and continues retransmitting.
In this case, the application code at the receiver is blocked indefinitely trying to read a socket that seemingly
has (URG) data and yet at the same time doesn't have any more data (FIN).

Perhaps the making of a DOS attack ?


Earl
