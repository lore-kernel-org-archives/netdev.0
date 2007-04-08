From: Kumiko Ono <kumiko@cs.columbia.edu>
Subject: garbage of TCP sock mem in sockstat?
Date: Sat, 07 Apr 2007 23:22:36 -0400
Message-ID: <46185FFC.8020104@cs.columbia.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from cs.columbia.edu ([128.59.16.20]:53839 "EHLO cs.columbia.edu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750999AbXDHDWi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 7 Apr 2007 23:22:38 -0400
Received: from lion.cs.columbia.edu (IDENT:NKNCmYu7VFtjmQAtm8evOnrb0oSIMgvJ@lion.cs.columbia.edu [128.59.16.120])
	by cs.columbia.edu (8.12.10/8.12.10) with ESMTP id l383MaqS024322
	(version=TLSv1/SSLv3 cipher=EDH-RSA-DES-CBC3-SHA bits=168 verify=NOT)
	for <netdev@vger.kernel.org>; Sat, 7 Apr 2007 23:22:37 -0400 (EDT)
Received: from [128.59.19.158] (irtcluster06.cs.columbia.edu [128.59.19.158])
	by lion.cs.columbia.edu (8.12.9/8.12.9) with ESMTP id l383Mab9022484
	for <netdev@vger.kernel.org>; Sat, 7 Apr 2007 23:22:36 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi all,

I tried to find out why some amount of memory remains allocated for TCP 
socket buffers after an application completes to read the buffers.
Although I looked for similar topics in this ML, I couldn't find it.

While a client create hundreds of new TCP connections to a server and 
sends 512 bytes data for each connection at 1000 requests/second, I 
monitored the amount of memory allocated for TCP socket buffers in 
/proc/net/sockstat. At lower sending rate, e.g., 100 requests/second, 
this problem does not happen.

The Linux kernel is 2.6.20.

When a server calls read() for all connections, and not call send() for 
echoing messages, the sockstat shows some garbage remaining as follows:

TCP: inuse 13 orphan 0 tw 0 alloc 19 mem 0
TCP: inuse 1226 orphan 0 tw 0 alloc 1232 mem 3
TCP: inuse 2332 orphan 0 tw 0 alloc 2338 mem 3
TCP: inuse 2441 orphan 0 tw 0 alloc 2447 mem 3
TCP: inuse 3654 orphan 0 tw 0 alloc 3660 mem 6
TCP: inuse 4869 orphan 0 tw 0 alloc 4875 mem 6
TCP: inuse 5012 orphan 0 tw 0 alloc 5018 mem 6
TCP: inuse 5012 orphan 0 tw 0 alloc 5018 mem 6
TCP: inuse 5012 orphan 0 tw 0 alloc 5018 mem 6

Even after a day, the sockstat shows the same value on mem.

On the other hand, when a server calls read() and send() for echoing 
messages for all connections, the sockstat shows that all the socket 
buffers are deallocated after competing echoing as follows:

TCP: inuse 13 orphan 0 tw 0 alloc 19 mem 0
TCP: inuse 1237 orphan 0 tw 0 alloc 1243 mem 0
TCP: inuse 2461 orphan 0 tw 0 alloc 2467 mem 0
TCP: inuse 3688 orphan 0 tw 0 alloc 3694 mem 0
TCP: inuse 4912 orphan 0 tw 0 alloc 4918 mem 268
TCP: inuse 5012 orphan 0 tw 0 alloc 5018 mem 101
TCP: inuse 5012 orphan 0 tw 0 alloc 5018 mem 0

Interestingly, when a server calls send() to send 512 byte data, and 
recv() to receive 512 byte data from clients, the sockstat shows 
similarly to that of the echoing.

Could anybody tell me why the garbage in the memory for TCP socket 
buffers remains? Is this a problem on deallocation of socket buffers, or 
just on sockstat?  Or I'm missing something?


Regards,
Kumiko
