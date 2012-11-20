From: Rami Rosen <roszenrami@gmail.com>
Subject: Re: question about eth_header
Date: Tue, 20 Nov 2012 16:51:03 +0200
Message-ID: <CAKoUArnRnx0txGWhNWpZAFBijWmtzdOe-D7Qb62-5AvBCfgHJQ@mail.gmail.com>
References: <1353419044.16036.6.camel@lb-tlvb-dmitry>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev@vger.kernel.org
To: Dmitry Kravkov <dmitry@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qa0-f53.google.com ([209.85.216.53]:54236 "EHLO
	mail-qa0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752418Ab2KTOvF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Nov 2012 09:51:05 -0500
Received: by mail-qa0-f53.google.com with SMTP id k31so810578qat.19
        for <netdev@vger.kernel.org>; Tue, 20 Nov 2012 06:51:03 -0800 (PST)
In-Reply-To: <1353419044.16036.6.camel@lb-tlvb-dmitry>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,
I think that you should call skb_reset_mac_header()
before calling eth_hdr() and that skb_reset_mac_header() should not be
inside eth_hdr(). Following is explanation:

In the RX path, when we get a packet in the driver, what essentially
happens is that at this point, we have a pointer to
the packet buffer in skb->data, and its length in skb->len.

With ethernet packets, the driver will call eth_type_trans(); please
look at ethernet drivers code.
eth_type_trans() indeed sets the MAC header pointer by calling
skb_reset_mac_header() on the skb.

Afterwards, the eth_type_trans() will advance skb->data by
14, the size of the Ethernet header, and decrease skb->len
by calling skb_pull_inline(skb, ETH_HLEN).

In case you are wondering why the skb_reset_mac_header() is not inside
the eth_hdr(), I think that the reason is that, once
skb_reset_mac_header() on the skb was called, there are cases when we
want to make several calls eth_hdr() without each time again resetting
the mac header, for example, in the bridging code.  There is no reason
to doing it in terms of performance.

rgs,
Rami Rosen

http://ramirose.wix.com/ramirosen


On Tue, Nov 20, 2012 at 3:44 PM, Dmitry Kravkov <dmitry@broadcom.com> wrote:
> Hi,
>
> I am trying to use eth_hdr() but it looks like it doesn't point to mac
> header (mac header is present at skb->data). Shouldn't
> skb_reset_mac_header() be called inside eth_header()?
>
> Thanks.
>
>
>
>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
