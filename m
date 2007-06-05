From: Eric Dumazet <dada1@cosmosbay.com>
Subject: [BUG] UDP : bind() checks are not complete
Date: Tue, 5 Jun 2007 19:15:36 +0200
Message-ID: <20070605191536.cc9a4719.dada1@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pfx2.jmh.fr ([194.153.89.55]:45171 "EHLO pfx2.jmh.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754878AbXFERPi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 5 Jun 2007 13:15:38 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David

I discovered one big problem with UDP binding in 2.6.22-rc4 :

Consider you have eth0 with addr 192.168.0.1

Consider one UDP socket was bound to 192.168.0.1:32769. It will be stored on a slot != 1

Another UDP socket is created and binded to (0.0.0.0:0)

__udp_lib_get_port() is called with snum=0 and ANY_ADDR

We try to find a hash chain with the lowest count of sockets.

If we find an empty chain (slot=1 result=32769 for example), we consider we finished our checks.

This not true since last udp lookups changes. 

If we allow the new socket to get port 32769, and source address of
outgoing message is set to 192.168.0.1, then answers 
(incoming messages to 192.168.0.1:32769) will go to first socket, because 

We really should check no socket is bound to XXX.XXX.XXX.XXX:32769. With current hashing, 
it means checking all slots in udptable[] :(

Our choices are :

1) Drop all thoses patches and re-think them for 2.6.23 eventually
2) Add the extra check for ANY_ADDR sockets and perform a full scan

What do you think ?
