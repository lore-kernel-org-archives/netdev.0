From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH 1/3] Rough VJ Channel Implementation - vj_core.patch
Date: Fri, 28 Apr 2006 12:21:02 -0700 (PDT)
Message-ID: <20060428.122102.76435590.davem@davemloft.net>
References: <54AD0F12E08D1541B826BE97C98F99F143B020@NT-SJCA-0751.brcm.ad.broadcom.com>
	<1146212660.8029.38.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: caitlinb@broadcom.com, johnpol@2ka.mipt.ru, kelly@au1.ibm.com,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:19862
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1751189AbWD1TWM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 28 Apr 2006 15:22:12 -0400
To: rusty@rustcorp.com.au
In-Reply-To: <1146212660.8029.38.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Rusty Russell <rusty@rustcorp.com.au>
Date: Fri, 28 Apr 2006 18:24:08 +1000

> Note that the problem space AFAICT includes strange advanced routing
> setups, ingress qos and possibly others, not just netfilter.  But
> perhaps the same solutions apply, so I'll concentrate on nf.

Yes, this hasn't been mentioned explicitly yet.

The big problem is that we don't want the classifier to become
overly complex.

One scheme I'm thinking about right now is an ordered lookup
that looks like:

1) Check for established sockets, they trump everything else.

2) Check for classifier rules, ie. netfilter and packet scheduler
   stuff

3) Check for listening sockets

4) default channel

#2 is still an unsolved problem, we don't want this big complex
classifier to be required in the hardware implementations.
However, using just IP addresses and ports does not map well to
what netfilter and co. want.

> Ah, this is a different problem.  Our idea was to have a syscall which
> would check & sanitize the buffers for output.  To do this, you need the
> ability to chain buffers (a simple next entry in the header, for us).
> 
> Sanitization would copy the header into a global buffer (ie. not one
> reachable by userspace), check the flowid, and chain on the rest of the
> user buffer.  After it had sanitized the buffers, it would activate the
> NIC, which would only send out buffers which started with a kernel
> buffer.
> 
> Of course, the first step (CAP_NET_RAW-only) wouldn't need this.  And,
> if the "sanitize_and_send" syscall were PF_VJCHAN's write(), then the
> contents of the write() could actually be the header: userspace would
> never deal with chained buffers.

I am not sure any of this is anything more than overhead.

If we just pop the buffers directly into the user mmap()'d ring
buffer, headers and all, and give an offset+length pair so the
user knows where the data starts and how much data is there, it
should all just work out.  Where to put the offset+length is
just a detail.
