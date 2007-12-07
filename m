From: Paul Moore <paul.moore@hp.com>
Subject: IPsec replay sequence number overflow behavior? (RFC4303 section 3.3.3)
Date: Fri, 7 Dec 2007 11:04:22 -0500
Message-ID: <200712071104.22560.paul.moore@hp.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Joy Latten <latten@us.ibm.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from g4t0017.houston.hp.com ([15.201.24.20]:48973 "EHLO
	g4t0017.houston.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755313AbXLGQE1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Dec 2007 11:04:27 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello all,

As part of the IPv6 "gap analysis" that the Linux Foundation is currently 
doing I've been looking at the IPsec auditing requirements as defined in 
RFC4303 and I came across some odd behavior regarding SA sequence number 
overflows ...

RFC4303 states the following:

   3.3.3.  Sequence Number Generation

   The sender's counter is initialized to 0 when an SA is established.
   The sender increments the sequence number (or ESN) counter for this
   SA and inserts the low-order 32 bits of the value into the Sequence
   Number field.  Thus, the first packet sent using a given SA will
   contain a sequence number of 1.

   If anti-replay is enabled (the default), the sender checks to ensure
   that the counter has not cycled before inserting the new value in the
   Sequence Number field.  In other words, the sender MUST NOT send a
   packet on an SA if doing so would cause the sequence number to cycle.
   An attempt to transmit a packet that would result in sequence number
   overflow is an auditable event.  The audit log entry for this event
   SHOULD include the SPI value, current date/time, Source Address,
   Destination Address, and (in IPv6) the cleartext Flow ID.

The related code in net/xfrm/xfrm_output.c:xfrm_output() looks like this:

   if (x->type->flags & XFRM_TYPE_REPLAY_PROT) {
           XFRM_SKB_CB(skb)->seq = ++x->replay.oseq;
           if (xfrm_aevent_is_on())
                   xfrm_replay_notify(x, XFRM_REPLAY_UPDATE);
   }

Which doesn't appear to take into account sequence number overflow at all.  
Granted, it does send notifications to userspace but it doesn't do anything 
to prevent the packet from being sent if the sequence number wraps.  I'm 
still a few years behind in my IPsec specifications so I could be missing 
something here (extended sequence numbers spring to mind and the kernel's 
curious mixing of 32bit and 64bit types for SA sequence number counters) but 
at first glance this appears to be a bug ... yes/no?

If it is a bug, I think the basic fix should be pretty simple, changing the 
above xfrm_output() code to the following:

   if (x->type->flags & XFRM_TYPE_REPLAY_PROT) {
           XFRM_SKB_CB(skb)->seq = ++x->replay.oseq;
+          if (x->replay.oseq == 0)
+                  goto error;
           if (xfrm_aevent_is_on())
                   xfrm_replay_notify(x, XFRM_REPLAY_UPDATE);
   }

-- 
paul moore
linux security @ hp
