From: James Chapman <jchapman@katalix.com>
Subject: RFC: L2TPv3 implementation: some questions
Date: Wed, 11 Jun 2008 00:01:36 +0100
Message-ID: <484F07D0.5050907@katalix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from s36.avahost.net ([74.53.95.194]:41188 "EHLO s36.avahost.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751714AbYFJXBk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 10 Jun 2008 19:01:40 -0400
Received: from jchapman.plus.com ([84.92.108.75] helo=[192.168.1.10])
	by s36.avahost.net with esmtpa (Exim 4.68)
	(envelope-from <jchapman@katalix.com>)
	id 1K6CuK-0008R7-KO
	for netdev@vger.kernel.org; Tue, 10 Jun 2008 18:05:40 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I'm working on adding L2TPv3 support and would like feedback on a few 
things.

L2TP is currently implemented in one C file, drivers/net/pppol2tp.c and 
provides only L2TPv2 functionality. L2TPv2 carries only PPP, L2TPv3 
carries other types of frame, so this work splits the existing driver to 
separate L2TP from PPP code and adds new drivers for other frame types, 
sitting on top of the common L2TP core. There are now 5 modules, with 
another 3 or more to come later. Should this stuff go in a separate 
subdirectory, say, net/l2tp? This would be in line with pppoatm which 
lives in net/atm.

Are there implications of the pppol2tp module moving from drivers/net to 
net/l2tp?

For L2TPv3, the existing sockaddr_pppol2tp structure can't be used 
because some 16 bit fields are 32 bits in L2TPv3. So I've created a new 
struct sockaddr_pppol2tpv3. Is it ok that one socket family shares these 
two sockaddr structs? (I can have the kernel code derive which one to 
use using the sockaddr length param that is passed in connect() and 
getname() calls.)

In adding support for L2TP over IP, I'm implementing a new L2TPIP socket 
family for the tunnel, which is really just raw IP using IP protocol 
115. There can be only one such socket between a given IP address pair. 
The tunnel socket is how userspace sends and receives L2TP control 
frames, but it is also used by the kernel datapath for data packets. 
Using raw sockets would be possible but I think (unless I'm mistaken) 
raw sockets are always delivered all packets that match the socket's 
protocol. If support were added for raw encapsulation sockets, similar 
to the UDP encapsulation sockets which are used for L2TP over UDP, data 
frames could be consumed by an encapsulation func. However, I think this 
breaks the raw socket semantics which were intended for userspace 
protocol implementations handling both control and user data frames. In 
L2TP/IP's case, the datapath is implemented in the kernel. So is a new 
L2TPIP socket family the right way?

The patch series is already 10+ patches and it is getting increasingly 
difficult to make changes to an early patch in the series (which is 
where the change should have been done in the first place) without 
causing patch conflicts in later patches. To reduce this churn, is it 
acceptable to put such changes in incremental patches in chronological 
order as the work is done?

Thanks!

-- 
James Chapman
Katalix Systems Ltd
http://www.katalix.com
Catalysts for your Embedded Linux software development

