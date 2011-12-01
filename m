From: Tom Herbert <therbert@google.com>
Subject: Re: [PATCH v4 06/10] e1000e: Support for byte queue limits
Date: Wed, 30 Nov 2011 17:04:38 -0800
Message-ID: <CA+mtBx-8AzEyUc3GVD+mEQoqUZeaB9hjSJonRW_SjOQaTx51mQ@mail.gmail.com>
References: <alpine.DEB.2.00.1111281819350.24413@pokey.mtv.corp.google.com>
	<20111129130137.000009ce@unknown>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: Jesse Brandeburg <jesse.brandeburg@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gx0-f174.google.com ([209.85.161.174]:57561 "EHLO
	mail-gx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753866Ab1LABEj convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Nov 2011 20:04:39 -0500
Received: by ggnr5 with SMTP id r5so1270097ggn.19
        for <netdev@vger.kernel.org>; Wed, 30 Nov 2011 17:04:38 -0800 (PST)
In-Reply-To: <20111129130137.000009ce@unknown>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> whats wrong with using total_tx_bytes or buffer_info->bytecount? =A0i=
t
> contains the "bytes on the wire" value which will be slightly larger
> than skb->len, but avoids warming the skb->len cacheline unnecessaril=
y.
>

This makes sense.  I made the changes, but the limits computed are
much higher than with using sbk->len.  I suspect there may be a bug in
GSO path.

=46or instance, in the driver at:

  bytecount =3D ((segs - 1) * skb_headlen(skb)) + skb->len;

I see cases like:

  segs=3D34, skb_header_len(skb)=3D70, skb->len=3D49298 so bytecount=3D=
51608

Which seems reasonable... but, I also see things like:

  segs=3D45, skb_header_len(skb)=3D1522, skb->len=3D65226, so bytecount=
=3D 132194
                                                      ^^^^
Which doesn't seem right at all.  I am thinking there may be a bug
setting skb->data_len improperly.

Tom
