From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH] flow-dissector: Fix alignment issue in
 __skb_flow_get_ports
Date: Fri, 10 Oct 2014 14:57:35 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D174C858B@AcuExch.aculab.com>
References: <20141009.201248.1210454965155680255.davem@davemloft.net>
	<20141010035840.21428.359.stgit@ahduyck-workstation.home>
 <20141010.004708.1975127853551765914.davem@davemloft.net>
 <5437F072.5060502@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "'alexander.h.duyck@redhat.com'" <alexander.h.duyck@redhat.com>,
	"David Miller" <davem@davemloft.net>,
	"alexander.duyck@gmail.com" <alexander.duyck@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:37793 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1752017AbaJJO7S convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Oct 2014 10:59:18 -0400
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 15196-01 for <netdev@vger.kernel.org>;
 Fri, 10 Oct 2014 15:59:07 +0100 (BST)
In-Reply-To: <5437F072.5060502@redhat.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck
> On 10/09/2014 09:47 PM, David Miller wrote:
> > From: alexander.duyck@gmail.com
> > Date: Thu, 09 Oct 2014 21:03:28 -0700
> >
> >> From: Alexander Duyck <alexander.h.duyck@redhat.com>
> >>
> >> This patch addresses a kernel unaligned access bug seen on a sparc64 system
> >> with an igb adapter.  Specifically the __skb_flow_get_ports was returning a
> >> be32 pointer which was then having the value directly returned.
> >>
> >> In order to keep the handling of the ports consistent with how we were
> >> handling the IPv4 and IPv6 addresses I have instead replaced the assignment
> >> with a memcpy to the flow key ports value.  This way it should stay a
> >> memcpy on systems that cannot handle unaligned access, and will likely be
> >> converted to a 32b assignment on the systems that can support it.
> >>
> >> Reported-by: David S. Miller <davem@davemloft.net>
> >> Signed-off-by: Alexander Duyck <alexander.h.duyck@redhat.com>
> > Guess what the compiler will output for the memcpy()....
> >
> > 	*(u32 *)dest = *(u32 *)src;
> >
> > Using memcpy() is never a valid way to avoid misaligned loads and
> > stores.
> 
> If needed we could convert ports to a __be16 I suppose.

You would have to cast it somewhere where the compiler cannot
tell what the original type was.
This usually means you have to call a non-static function, which
might have to be in a different compilation unit.

...
> That is what I get for trying to come up with a fix at the end of the
> day.  Although it does leave me scratching my head why the IPv4 and IPv6
> addresses were not causing unaligned accesses or were they triggering
> them as well?

I think there is code to copy the IP and TCP headers to aligned memory
before they are parsed.

...
> 
> The problem is the igb / ixgbe / fm10k hardware doesn't have a means of
> inserting padding from its side...

Shoot the hardware engineers.

You aren't going to get the performance you expect from a 10Ge card
unless the rx buffers are 'correctly' aligned.

	David
