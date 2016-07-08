From: Paul Jakma <paul@jakma.org>
Subject: RE: [PATCH] net: Fragment large datagrams even when IP_HDRINCL is
 set.
Date: Fri, 8 Jul 2016 13:55:11 +0100 (BST)
Message-ID: <alpine.LFD.2.20.1607081340430.26593@stoner.jakma.org>
References: <1464013425-31129-1-git-send-email-alan.davey@metaswitch.com> <20160531.113913.1477085966766110028.davem@davemloft.net> <BN3PR0201MB1059316BEC3EC7F6CBF2F0E4F95E0@BN3PR0201MB1059.namprd02.prod.outlook.com> <20160608.102558.903056863834035706.davem@davemloft.net>
 <BN3PR0201MB10599C7780CBC6EB4BC2894DF9550@BN3PR0201MB1059.namprd02.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII; format=flowed
Cc: David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"kuznet@ms2.inr.ac.ru" <kuznet@ms2.inr.ac.ru>,
	"jmorris@namei.org" <jmorris@namei.org>,
	"yoshfuji@linux-ipv6.org" <yoshfuji@linux-ipv6.org>,
	"kaber@trash.net" <kaber@trash.net>
To: Alan Davey <Alan.Davey@metaswitch.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f66.google.com ([74.125.82.66]:36489 "EHLO
	mail-wm0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754894AbcGHMzQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Jul 2016 08:55:16 -0400
Received: by mail-wm0-f66.google.com with SMTP id x83so5565474wma.3
        for <netdev@vger.kernel.org>; Fri, 08 Jul 2016 05:55:15 -0700 (PDT)
In-Reply-To: <BN3PR0201MB10599C7780CBC6EB4BC2894DF9550@BN3PR0201MB1059.namprd02.prod.outlook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 15 Jun 2016, Alan Davey wrote:

> The only case that would break is that where an application relies on 
> the existing (documented as a bug) feature of getting an EMSGSIZE 
> return code in the case of an over-sized packet.  Applications that 
> perform their own fragmentation would be unaffected.

If this doesn't break existing applications that are doing fragmentation 
in userspace on raw sockets (e.g. Quagga ospfd), that's better.

As per previous email, I'd love to be able to get rid of that code and 
have the kernel do it for me. However, I also don't want to have to do 
anything other non-trivial to that code either. :)

The issue for us is, how would we know on any given host whether the 
kernel will do the fragmentation or whether ospfd has to do it? We need 
to be able to probe for that capability, surely?

I guess "send an oversized packet and see if we get EMSGSIZE comes back 
or not" could be one way, though the 'man 7 raw' man page ony my system 
says that is returned on raw socket if the /IP/ max size (64 KiB) is 
exceeded - it doesn't say anything about that being returned if output 
MTU is exceeded. Also, that implies a failed packet send on startup on 
older kernels and having to rejiggle the packet we've constructed to 
retry.

Some kind of "I want kernel to do the fragmentation" sockopt, that was 
guaranteed to error with ENOPROTOOPT on non-implementing kernels, that 
we could try set when creating the socket, would seem simpler/nicer from 
my POV of my corner of user-space.

?

regards,
-- 
Paul Jakma | paul@jakma.org | @pjakma | Key ID: 0xD86BF79464A2FF6A
Fortune:
It would be nice to be sure of anything the way some people are of everything.
