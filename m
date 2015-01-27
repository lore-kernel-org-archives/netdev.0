From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCHv3 ipsec-next] xfrm: Do not parse 32bits compiled xfrm
 netlink msg on 64bits host
Date: Tue, 27 Jan 2015 11:54:16 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D1CAD3C5C@AcuExch.aculab.com>
References: <1422349230-17394-1-git-send-email-fan.du@intel.com>
 <063D6719AE5E284EB5DD2968C1650D6D1CAD3B2B@AcuExch.aculab.com>
 <20150127110413.GF1373@breakpoint.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: 'Fan Du' <fan.du@intel.com>,
	"steffen.klassert@secunet.com" <steffen.klassert@secunet.com>,
	"herbert@gondor.apana.org.au" <herbert@gondor.apana.org.au>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"fengyuleidian0615@gmail.com" <fengyuleidian0615@gmail.com>
To: 'Florian Westphal' <fw@strlen.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out4.electric.net ([192.162.216.181]:56307 "EHLO
	smtp-out4.electric.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754203AbbA0Lyb convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Jan 2015 06:54:31 -0500
In-Reply-To: <20150127110413.GF1373@breakpoint.cc>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Westphal 
> David Laight <David.Laight@ACULAB.COM> wrote:
> > From: Fan Du
> > > structure like xfrm_usersa_info or xfrm_userpolicy_info
> > > has different sizeof when compiled as 32bits and 64bits
> > > due to not appending pack attribute in their definition.
> >
> > Don't 'pack' the structure, just ensure that all the fields
> > are fixed sized and on their natural boundary.
> 
> How do you propose to do this without breaking ABI?

You may already have an ABI fubar.
Adding __packed won't make it go away.
IIRC your modified structure did have all its 64bit items
aligned on 8 byte boundaries - so the __packed wouldn't affect
the structure layout.

The problem is that you can't add that field when the ABI
only requires 4 byte alignment for 64bit items.

If you need to access a structure from (eg) an i386 application
within an amd64 kernel then you can add __attribute__((aligned(4)))
to any 64bit member to force that member to have only 4 byte aligment.
On 64bit systems that can't do misaligned transfers (eg sparc64)
that will result in two 32bit accesses for that member.
(You'll need to do it to all 64bit members if the structure
size needs to be an odd multiple of 4.)

> > Possibly add a compile-time check that the structure is
> > of the expected size.
> 
> Uh, what?

eg something based on:

typedef foo_check char[sizeof foo == 32 ? 1 : -1];

There will be a standard define for this somewhere
(and for the align attribute).

	David
