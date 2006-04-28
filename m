From: Rusty Russell <rusty@rustcorp.com.au>
Subject: RE: [PATCH 1/3] Rough VJ Channel Implementation - vj_core.patch
Date: Fri, 28 Apr 2006 18:24:08 +1000
Message-ID: <1146212660.8029.38.camel@localhost.localdomain>
References: <54AD0F12E08D1541B826BE97C98F99F143B020@NT-SJCA-0751.brcm.ad.broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, johnpol@2ka.mipt.ru,
	kelly@au1.ibm.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([203.10.76.45]:49829 "EHLO ozlabs.org")
	by vger.kernel.org with ESMTP id S1030327AbWD1IYv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Apr 2006 04:24:51 -0400
To: Caitlin Bestler <caitlinb@broadcom.com>
In-Reply-To: <54AD0F12E08D1541B826BE97C98F99F143B020@NT-SJCA-0751.brcm.ad.broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2006-04-27 at 14:12 -0700, Caitlin Bestler wrote:
> So the real issue is when there is an intelligent device that
> uses hardware packet classification to place the packet in
> the correct ring. We don't want to bypass packet filtering,
> but it would be terribly wasteful to reclassify the packet.
> Intelligent NICs will have packet classification capabilities
> to support RDMA and iSCSI. Those capabilities should be available
> to benefit SOCK_STREAM and SOCK_DGRAM users as well without it
> being a choice of either turning all stack control over to
> the NIC or ignorign all NIC capabilities beyound pretending
> to be a dumb Ethernet NIC.
> 
> For example, counting packets within an approved connection
> is a valid goal that the final solution should support. But
> would a simple count be sufficient, or do we truly need the
> full flexibility currently found in netfilter?

Note that the problem space AFAICT includes strange advanced routing
setups, ingress qos and possibly others, not just netfilter.  But
perhaps the same solutions apply, so I'll concentrate on nf.

If we start with a "disable direct netchannels when netfilter hooks
registered", we would inevitably refine it to "disable some netchannels
when netfilter hooks registered".  The worst case for this filtering
based on connection tracking, with its constantly changing effects as
things time out.  Hard problem.

Is it time to re-examine the Grand Unified Lookup which Dave mentions
every few years? 8)

> My assumption
> is that each input ring has a matching output ring, and that
> the output ring cannot be used to send packets that would
> not be matched by the reverse rule for the paired input ring.
> So the information that supports enforcing that rule needs
> to be stored somewhere other than the ring itself.

Ah, this is a different problem.  Our idea was to have a syscall which
would check & sanitize the buffers for output.  To do this, you need the
ability to chain buffers (a simple next entry in the header, for us).

Sanitization would copy the header into a global buffer (ie. not one
reachable by userspace), check the flowid, and chain on the rest of the
user buffer.  After it had sanitized the buffers, it would activate the
NIC, which would only send out buffers which started with a kernel
buffer.

Of course, the first step (CAP_NET_RAW-only) wouldn't need this.  And,
if the "sanitize_and_send" syscall were PF_VJCHAN's write(), then the
contents of the write() could actually be the header: userspace would
never deal with chained buffers.

Finally, it's not clear how one should sanely mix this with sendfile
etc.  Maybe you don't, and only use this for RDMA, etc.

Cheers!
Rusty.
-- 
 ccontrol: http://ozlabs.org/~rusty/ccontrol

