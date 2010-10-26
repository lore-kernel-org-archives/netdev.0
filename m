From: Jesse Gross <jesse@nicira.com>
Subject: Re: [PATCH net-next-2.6] net: Fix some corner cases in dev_can_checksum()
Date: Mon, 25 Oct 2010 17:21:08 -0700
Message-ID: <AANLkTi=PiB_oCvaFzQpUNhgV8qsn9d-jy_ejGdbOTzQe@mail.gmail.com>
References: <1287618974-4714-1-git-send-email-jesse@nicira.com>
	<1287618974-4714-5-git-send-email-jesse@nicira.com>
	<1287675008.2235.8.camel@achroite.uk.solarflarecom.com>
	<AANLkTi=6erj4L7mwH4j1h+urPrc2PQu2xg7xTHkiM0A5@mail.gmail.com>
	<1287756739.2316.11.camel@achroite.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:49846 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751848Ab0JZAVJ convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Oct 2010 20:21:09 -0400
Received: by wyf28 with SMTP id 28so4016957wyf.19
        for <netdev@vger.kernel.org>; Mon, 25 Oct 2010 17:21:08 -0700 (PDT)
In-Reply-To: <1287756739.2316.11.camel@achroite.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Oct 22, 2010 at 7:12 AM, Ben Hutchings
<bhutchings@solarflare.com> wrote:
> dev_can_checksum() incorrectly returns true in these cases:
>
> 1. The skb has both out-of-band and in-band VLAN tags and the device
> =A0 supports checksum offload for the encapsulated protocol but only =
with
> =A0 one layer of encapsulation.
> 2. The skb has a VLAN tag and the device supports generic checksummin=
g
> =A0 but not in conjunction with VLAN encapsulation.
>
> Rearrange the VLAN tag checks to avoid these.
>
> Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>

If we assume that cards cannot handle offloading for double tagged
packets, which is obviously the most conservative approach, we
probably also need to change the checks for TSO/SG.  There's no issue
with extracting the protocol from the right header but we might assume
that the card can handle double tag offloading when it can't.  For
both TSO/SG we check if there is either an in-band tag or out-of-band
tag and use dev->vlan_features if that is the case.  Maybe we need to
handle it in software if it is double tagged.

On the other hand, I don't know whether it's true that cards can't
handle offloading for packets tagged in both manners.  I suppose that
it depends on where the offloading and tagging are in the pipeline.
=46or example, when it comes to SG I doubt that the cards care about
vlan tags much at all.
