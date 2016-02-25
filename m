From: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Subject: Re: Sending short raw packets using sendmsg() broke
Date: Thu, 25 Feb 2016 15:49:37 -0500
Message-ID: <CAF=yD-+QPEOqsQcumy91xeLuLAww+6C5pfHys=u6zb0Xokhcfw@mail.gmail.com>
References: <alpine.DEB.2.10.1602252105250.32432@jazz.he.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Network Development <netdev@vger.kernel.org>,
	Willem de Bruijn <willemb@google.com>,
	Alan Cox <alan@linux.intel.com>
To: Heikki Hannikainen <hessu@hes.iki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f52.google.com ([209.85.215.52]:34682 "EHLO
	mail-lf0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750835AbcBYUuT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Feb 2016 15:50:19 -0500
Received: by mail-lf0-f52.google.com with SMTP id j78so41072388lfb.1
        for <netdev@vger.kernel.org>; Thu, 25 Feb 2016 12:50:18 -0800 (PST)
In-Reply-To: <alpine.DEB.2.10.1602252105250.32432@jazz.he.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> Commit 9c7077622dd9174 added a check, ll_header_truncated(), which requires
> that a packet transmitted using sendmsg() with PF_PACKET, SOCK_RAW must be
> longer than dev->hard_header_len.
>
> https://github.com/torvalds/linux/commit/9c7077622dd9174
> https://github.com/torvalds/linux/blob/master/net/packet/af_packet.c#L2329

As David already pointed out, this has been revised to allow greater
than or equal. Note that the behavior was already present for
tpacket_snd and this patch only rationalized the two paths.

>
> The bug that popped up is that an application (aprx) can no longer send
> short AX.25 packets using sendmsg(). Packets shorter than 77 bytes fail this
> check in ll_header_truncated(). With older kernels, no problem. AX.25 (and
> some other protocols) have variable-length headers (somewhere between 21 and
> 77 bytes in this case).
>
> hard_header_len is set in drivers/net/hamradio/mkiss.c to
> AX25_KISS_HEADER_LEN + AX25_MAX_HEADER_LEN + 3 which works out to be

If header length is variable and can be shorter than
AX25_MAX_HEADER_LEN then the check will still trigger.

> (1+17+7*8+3)=77.
>
> https://github.com/torvalds/linux/blob/master/drivers/net/hamradio/mkiss.c#L845
>
> I guessed that we could probably set hard_header_len to be the minimum
> length of the packet header (AX25_KISS_HEADER_LEN + AX25_HEADER_LEN + 3) to
> make things work again, but I first asked Alan Cox for an opinion, and he
> says hard_header_len is set correctly to be the worst-case maximum header
> length, and that the ll_header_truncated commit should be reverted instead,
> since it doesn't take variable-length headers into account.

hard_header_length is used in cases where we have to reserve room or
check against packets that exceed frame size, so it indeed should not
be changed to be the minimum header length in a variable header length
scenario.

In most protocols the header length is fixed, so there is no separate
field for minimal header length. If this is the only such check in the
kernel (and I haven't found another after a cursory inspection), then
perhaps an exception should be made here for this one protocol family.

> s = socket(AF_AX25, SOCK_DGRAM, 0);
>
> I didn't yet figure out why that works, maybe the sendto() of an AX25 datagram does not go through that hard_header_len check.

That is a different protocol family. The above check is limited to
sends over packets of family PF_PACKET.
