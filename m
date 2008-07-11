From: Jim Rees <rees@umich.edu>
Subject: Autotuning and send buffer size
Date: Fri, 11 Jul 2008 11:02:08 -0400
Message-ID: <20080711150208.GA15305@citi.umich.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from citi.umich.edu ([141.211.133.111]:1424 "EHLO citi.umich.edu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752487AbYGKPCJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 11 Jul 2008 11:02:09 -0400
Received: from citi.umich.edu (barataria.citi.umich.edu [141.211.133.88])
	(using TLSv1 with cipher DHE-RSA-AES256-SHA (256/256 bits))
	(Client CN "Jim Rees", Issuer "CITI Production KCA" (verified OK))
	by citi.umich.edu (Postfix) with ESMTP id 4103E40D8
	for <netdev@vger.kernel.org>; Fri, 11 Jul 2008 11:02:08 -0400 (EDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Bill Fink and others have mentioned that tcp buffer size autotuning can
cause a 5% or so performance penalty.  I looked into this a bit, and it
appears that if you set the sender's socket buffer too big, performance
suffers.

Consider this, on a 1Gbps link with ~.1msec delay (12KB bdp):

Fixed 128KB sender socket buffer:
nuttcp -i1 -w128k pdsi5
 1115.4375 MB /  10.00 sec =  935.2707 Mbps 4 %TX 11 %RX

Fixed 8MB sender socket buffer:
nuttcp -i1 -w8m pdsi5
 1063.0625 MB /  10.10 sec =  882.7833 Mbps 4 %TX 15 %RX

Autotuned sender socket buffer:
nuttcp -i1 pdsi5
 1056.9375 MB /  10.04 sec =  883.1083 Mbps 4 %TX 15 %RX

I don't undestand how a "too big" sender buffer can hurt performance.  I
have not measured what size the sender's buffer is in the autotuning case.

Yes, I know "nuttcp -w" also sets the receiver's socket buffer size.  I
tried various upper limits on the receiver's buffer size via
net.ipv4.tcp_rmem but that doesn't seem to matter as long as it's big
enough:

nuttcp -i1 pdsi5
sender wmem_max=131071, receiver rmem_max=15728640
 1116.9375 MB /  10.01 sec =  936.4816 Mbps 3 %TX 16 %RX
sender wmem_max=15728640, receiver rmem_max=15728640
 1062.8750 MB /  10.10 sec =  882.6013 Mbps 4 %TX 15 %RX
sender wmem_max=15728640, receiver rmem_max=131071
 1060.2500 MB /  10.07 sec =  883.2847 Mbps 4 %TX 15 %RX
