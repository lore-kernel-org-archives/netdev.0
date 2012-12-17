From: Rick Jones <rick.jones2@hp.com>
Subject: Whence a description of how to enable TCP FASTOPEN in a net-next
 kernel?
Date: Mon, 17 Dec 2012 13:27:06 -0800
Message-ID: <50CF8E2A.5020201@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from g1t0029.austin.hp.com ([15.216.28.36]:23304 "EHLO
	g1t0029.austin.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751180Ab2LQV1I (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Dec 2012 16:27:08 -0500
Received: from g1t0039.austin.hp.com (g1t0039.austin.hp.com [16.236.32.45])
	by g1t0029.austin.hp.com (Postfix) with ESMTP id DAA1F38157
	for <netdev@vger.kernel.org>; Mon, 17 Dec 2012 21:27:07 +0000 (UTC)
Received: from [16.103.148.51] (tardy.usa.hp.com [16.103.148.51])
	by g1t0039.austin.hp.com (Postfix) with ESMTP id AB23234062
	for <netdev@vger.kernel.org>; Mon, 17 Dec 2012 21:27:07 +0000 (UTC)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Is there a writeup describing the steps needed to enable TCP_FASTOPEN in 
a net-next kernel? (pulled earlier today)

I am looking to debug netperf's support for enabling the feature and I 
want to make sure I've enabled things correctly in the kernel.  Thusfar 
I've set the tcp_fastopen sysctl to one, and I see the "client" side of 
netperf making the appropriate sendto() call, and I see what appears to 
be the correct setsockopt being set on the server side, but my tcpdump 
traces of the traffic flowing over loopback in my test setup, while 
showing the client including the experimental option, do not show the 
server side responding:

13:10:23.870202 IP localhost.5923 > localhost.54363: Flags [S], seq 
935361110, win 43690, options [mss 65495,sackOK,TS val 889762 ecr 
0,nop,wscale 7,Unknown Option 254f989], length 0
13:10:23.870214 IP localhost.54363 > localhost.5923: Flags [S.], seq 
4210640362, ack 935361111, win 43690, options [mss 65495,sackOK,TS val 
889762 ecr 889762,nop,wscale 7], length 0

The netserver side strace snippet:

3861  socket(PF_INET, SOCK_STREAM, IPPROTO_TCP) = 8
3861  getsockopt(8, SOL_SOCKET, SO_SNDBUF, [16384], [4]) = 0
3861  getsockopt(8, SOL_SOCKET, SO_RCVBUF, [87380], [4]) = 0
3861  setsockopt(8, SOL_SOCKET, SO_REUSEADDR, [1], 4) = 0
3861  bind(8, {sa_family=AF_INET, sin_port=htons(0), 
sin_addr=inet_addr("0.0.0.0")}, 16) = 0
3861  setsockopt(8, SOL_TCP, 0x17 /* TCP_??? */, [5], 4) = 0
3861  listen(8, 5)                      = 0
...
3861  accept(8, {sa_family=AF_INET, sin_port=htons(5923), 
sin_addr=inet_addr("127.0.0.1")}, [16]) = 9
3861  recvfrom(9, "n", 1, 0, NULL, NULL) = 1
3861  sendto(9, "n", 1, 0, NULL, 0)     = 1
3861  getsockopt(9, SOL_SOCKET, SO_RCVBUF, [262030], [4]) = 0
3861  getsockopt(9, SOL_SOCKET, SO_SNDBUF, [663750], [4]) = 0
3861  close(9)                          = 0

lather, rinse, repeat the accept sequence off that listen endpoint.

happy benchmarking,

rick jones
