From: "Caitlin Bestler" <caitlinb@broadcom.com>
Subject: RE: [PATCH 1/3] Rough VJ Channel Implementation - vj_core.patch
Date: Fri, 28 Apr 2006 10:55:31 -0700
Message-ID: <54AD0F12E08D1541B826BE97C98F99F143B10A@NT-SJCA-0751.brcm.ad.broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: "David S. Miller" <davem@davemloft.net>, kelly@au1.ibm.com,
	rusty@rustcorp.com.au, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:56072 "EHLO
	mms2.broadcom.com") by vger.kernel.org with ESMTP id S1751778AbWD1SFj convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 28 Apr 2006 14:05:39 -0400
Content-class: urn:content-classes:message
To: "Evgeniy Polyakov" <johnpol@2ka.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Evgeniy Polyakov wrote:

> 
> I see your point, and respectfully disagree.
> The more complex userspace interface we create the less users
> it will have. It is completely unconvenient to read 100 bytes
> and receive only 80, since 20 were eaten by header. And what
> if we need only 20, but packet contains 100, introduce per packet
> head pointer? For purpose of benchmarking it works perfectly - read
> the whole packet, one can event touch that data to emulate real
> work, but for the real world it becomes practically unusabl.
> 

In a straight-forward user-mode library using existing interfaces the
message would be interleaved with the headers in the inbound ring.
While the inbound ring is part of user memory, it is not what the
user would process from, that would be the buffer they supplied 
in a call to read() or recvmsg(), that buffer would have to make
no allowances for interleaved headers.

Enabling zero-copy when a buffer is pre-posted is possible, but
modestly complex. Research on MPI and SDP have generally
shown that the unless the pinning overhead is eliminated somehow
that the buffers have to be quite large before zero-copy reception
becomes a benefit. vj_netchannels represent a strategy of minimizing
registration/pinning costs even if it means paying for an extra copy.
Because the extra copy is closely tied to the activation of the data
sink consumer the cost of that extra copy is greatly reduced because
it places the data in the cache immediately before the application
will in fact use the received data.

Also keep in mind that once the issues are resolved to allow the
netchannel rings to be directly visible to a user-mode client that
enhanced/specialized interfaces can easily be added in user-mode
libraries. So focusing on supporting existing conventional interfaces
is probably the best approach for the initial efforts.

