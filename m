From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH iproute2] Re: HTB accuracy for high speed
Date: Thu, 4 Jun 2009 07:50:27 +0000
Message-ID: <20090604075027.GB2683@ff.dom.local>
References: <4A2620FD.8030708@trash.net> <20090603074049.GA5254@ff.dom.local> <4A262BE7.4090807@trash.net> <20090603.215314.96383042.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: kaber@trash.net, vexwek@gmail.com, shemminger@vyatta.com,
	netdev@vger.kernel.org, devik@cdi.cz, dada1@cosmosbay.com,
	hazard@francoudi.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f213.google.com ([209.85.218.213]:58425 "EHLO
	mail-bw0-f213.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751650AbZFDHuc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Jun 2009 03:50:32 -0400
Received: by bwz9 with SMTP id 9so517212bwz.37
        for <netdev@vger.kernel.org>; Thu, 04 Jun 2009 00:50:34 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20090603.215314.96383042.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jun 03, 2009 at 09:53:14PM -0700, David Miller wrote:
> From: Patrick McHardy <kaber@trash.net>
> Date: Wed, 03 Jun 2009 09:53:11 +0200
> 
> > Jarek Poplawski wrote:
> >> On Wed, Jun 03, 2009 at 09:06:37AM +0200, Patrick McHardy wrote:
> >>> Mid-term we really need to move to 64 bit values and ns resolution,
> >>> otherwise this problem is just going to reappear as soon as someone
> >>> tries 10gbit. Not sure what the best short term fix is, I feel a bit
> >>> uneasy about changing the current factors given how close this brings
> >>> us towards overflowing.
> >> I completely agree it's on the verge of overflow, and actually would
> >> overflow for some insanely low (for today's standards) rates. So I
> >> treat it's as a temporary solution, until people start asking about
> >> more than 1 or 2Gbit. And of course we will have to move to 64 bit
> >> anyway. Or we can do it now...
> > 
> > That (now) would certainly be the best solution, but its a non-trivial
> > task since all the ABIs use 32 bit values.
> 
> We could pass in a new attribute which provides the upper-32bits
> of the value.  I'm not sure if that works in this case but it's
> an idea.

I'm not sure it could be so simple: I guess Patrick is concerned with
a new tc talking to an old kernel (otherwise a kernel should recognize
an old format). Then it would need something reasonable in 32bits.

But, I'm not even sure we need 64bit rate tables. We could
alternatively use (after checking a kernel can handle this)
simply a log to shift these values in kernel to u64:

- static inline u32 qdisc_l2t(struct qdisc_rate_table* rtab, unsigned int pktlen)
+ static inline u64 qdisc_l2t(struct qdisc_rate_table* rtab, unsigned int pktlen)
  {
	...
-        return rtab->data[slot];
+        return rtab->data[slot] << rtab->rate.rate_log;
  }

Since these overflows are for low rates, this rounding of lower bits
shouldn't matter here. So, IMHO, it's more about adding this overhead
of u64 to the kernel now.

Jarek P.
