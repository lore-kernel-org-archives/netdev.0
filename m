From: "Chris Leech" <chris.leech@gmail.com>
Subject: Re: problems with e1000 and jumboframes
Date: Thu, 3 Aug 2006 13:34:12 -0700
Message-ID: <41b516cb0608031334s6e159e99tb749240f44ae608d@mail.gmail.com>
References: <44D1FEB7.2050703@arndnet.de> <20060803135925.GA28348@2ka.mipt.ru>
	 <44D20A2F.3090005@arndnet.de> <20060803150330.GB12915@2ka.mipt.ru>
	 <Pine.LNX.4.64.0608031705560.8443@bizon.gios.gov.pl>
	 <20060803151631.GA14774@2ka.mipt.ru>
	 <41b516cb0608030857h1d55820rfd4ccd0cc56dd71d@mail.gmail.com>
	 <44D22350.5070709@arndnet.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Evgeniy Polyakov" <johnpol@2ka.mipt.ru>,
	"Krzysztof Oledzki" <olel@ans.pl>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.172]:43427 "EHLO
	ug-out-1314.google.com") by vger.kernel.org with ESMTP
	id S1751320AbWHCUeQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 3 Aug 2006 16:34:16 -0400
Received: by ug-out-1314.google.com with SMTP id m3so966168ugc
        for <netdev@vger.kernel.org>; Thu, 03 Aug 2006 13:34:12 -0700 (PDT)
To: "Arnd Hannemann" <arnd@arndnet.de>
In-Reply-To: <44D22350.5070709@arndnet.de>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 8/3/06, Arnd Hannemann <arnd@arndnet.de> wrote:
> Well you say "if a single buffer per frame is going to be used". Well,
> if I understood you correctly i could set the MTU to, lets say 4000.
> Then the driver would enable the "jumbo frame bit" of the hardware, and
> allocate only a 4k rx buffer, right? (and allocate 16k, because of
> skb_shinfo)
> Now if a new 9k frame arrives the hardware will accept it regardless of
> the 2k MTU and will split it into 3x 4k rx buffers?
> Does the current driver work in this way? That would be great.
>
> Perhaps then one should change the driver in a way that the MTU can
> changed independently of the buffer size?

Yes, e1000 devices will spill over and use multiple buffers for a
single frame.  We've been trying to find a good way to use multiple
buffers to take care of these allocation problems.  The structure of
the sk_buff does not make it easy.  Or should I say that it's the
limitation that drivers are not allowed to chain together multiple
sk_buffs to represent a single frame that does not make it easy.

PCI-Express e1000 devices support a feature called header split, where
the protocol headers go into a different buffer from the payload.  We
use that today to put headers into the kmalloc() allocated skb->data
area, and payload into one or more skb->frags[] pages.  You don't ever
have multiple page allocations from the driver in this mode.

We could try and only use page allocations for older e1000 devices,
putting headers and payload into skb->frags and copying the headers
out into the skb->data area as needed for processing.  That would do
away with large allocations, but in Jesse's experiments calling
alloc_page() is slower than kmalloc(), so there can actually be a
performance hit from trying to use page allocations all the time.

It's an interesting problem.

- Chris
