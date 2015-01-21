From: Ezequiel Garcia <ezequiel.garcia@free-electrons.com>
Subject: Re: [PATCH 2/2] net: mv643xx_eth: Fix highmem support in non-TSO
 egress path
Date: Wed, 21 Jan 2015 20:34:30 -0300
Message-ID: <54C03786.2060101@free-electrons.com>
References: <1421844850-30886-1-git-send-email-ezequiel.garcia@free-electrons.com> <1421844850-30886-3-git-send-email-ezequiel.garcia@free-electrons.com> <20150121174049.GW26493@n2100.arm.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>,
	B38611@freescale.com, fabio.estevam@freescale.com
To: Russell King - ARM Linux <linux@arm.linux.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from down.free-electrons.com ([37.187.137.238]:40189 "EHLO
	mail.free-electrons.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752886AbbAUXgh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Jan 2015 18:36:37 -0500
In-Reply-To: <20150121174049.GW26493@n2100.arm.linux.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/21/2015 02:40 PM, Russell King - ARM Linux wrote:
> On Wed, Jan 21, 2015 at 09:54:10AM -0300, Ezequiel Garcia wrote:
>> Commit 69ad0dd7af22b61d9e0e68e56b6290121618b0fb
>> Author: Ezequiel Garcia <ezequiel.garcia@free-electrons.com>
>> Date:   Mon May 19 13:59:59 2014 -0300
>>
>>     net: mv643xx_eth: Use dma_map_single() to map the skb fragments
>>
>> caused a nasty regression by removing the support for highmem skb
>> fragments. By using page_address() to get the address of a fragment'=
s
>> page, we are assuming a lowmem page. However, such assumption is inc=
orrect,
>> as fragments can be in highmem pages, resulting in very nasty issues=
=2E
>>
>> This commit fixes this by using the skb_frag_dma_map() helper,
>> which takes care of mapping the skb fragment properly.
>=20
> This seems fine, so:
>=20

I have just realised that the non-TSO and the TSO paths must work
simultaneously (we don't know which path an egress skb will take).

So, with these patches, the unmapping is done using dma_unmap_page() wh=
ich
is only correct if the skb took the non-TSO paths. In other words,
these fixes are wrong (although I have no idea the effect of
using dma_unmap_page on a mapping done with dma_map_single).

And the problem is that in the TSO path, the linear and the non-linear
fragments use the same kind of descriptors, so we can't distinguish
them in the cleanup, and can't decide if _single or _page should be use=
d.

Any ideas?

I guess we could keep track in some data structure of the type of mappi=
ng
on each descriptor. Or alternatively, avoid highmem fragments altogethe=
r
by mapping to a lowmem page.

I'll try to come up with some more patches following the first idea.

Sorry for the crappiness,
--=20
Ezequiel Garc=EDa, Free Electrons
Embedded Linux, Kernel and Android Engineering
http://free-electrons.com
