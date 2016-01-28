From: "Jason A. Donenfeld" <Jason@zx2c4.com>
Subject: Interesting performance characteristics of serial packet submission
Date: Thu, 28 Jan 2016 13:05:03 +0100
Message-ID: <CAHmME9odG_BcQe_-8RWDtq0G0g7DyoLdpaOCCWg_+Tq-2sHPAQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: Netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from frisell.zx2c4.com ([192.95.5.64]:34021 "EHLO frisell.zx2c4.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932900AbcA1MLp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 28 Jan 2016 07:11:45 -0500
Received: by frisell.zx2c4.com (ZX2C4 Mail Server) with ESMTP id 23d4699e
	for <netdev@vger.kernel.org>;
	Thu, 28 Jan 2016 12:04:00 +0000 (UTC)
Received: by frisell.zx2c4.com (ZX2C4 Mail Server) with ESMTPSA id 2278fad6
	TLS version=TLSv1/SSLv3 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128 verify=YES
	for <netdev@vger.kernel.org>;
	Thu, 28 Jan 2016 12:04:00 +0000 (UTC)
Received: by mail-wm0-f52.google.com with SMTP id p63so21406746wmp.1
        for <netdev@vger.kernel.org>; Thu, 28 Jan 2016 04:05:04 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello folks,

I've observed a very interesting performance characteristic. Sometimes
net_device drivers need to "do something to a packet" and then "send
it through a tunnel". This looks like:

    expensive_transformation(skb1);
    udp_tunnel_xmit_skb(skb1);
    expensive_transformation(skb2);
    udp_tunnel_xmit_skb(skb2);
    expensive_transformation(skb3);
    udp_tunnel_xmit_skb(skb3);
    expensive_transformation(skb4);
    udp_tunnel_xmit_skb(skb4);
    expensive_transformation(skb5);
    udp_tunnel_xmit_skb(skb5);

It turns out, however, that we gain significant performance increases
(300mbps on my laptop) by doing all the xmits in a row, like this:

    expensive_transformation(skb1);
    expensive_transformation(skb2);
    expensive_transformation(skb3);
    expensive_transformation(skb4);
    expensive_transformation(skb5);
    udp_tunnel_xmit_skb(skb1);
    udp_tunnel_xmit_skb(skb2);
    udp_tunnel_xmit_skb(skb3);
    udp_tunnel_xmit_skb(skb4);
    udp_tunnel_xmit_skb(skb5);

Now practically speaking, it's not that hard to implement the latter
more performant variant, as devices can simply opt in to receiving GSO
super packets, and submit them all together in bunches of GSO-split
packets. Implementation is not an issue.

But this does leave me wondering why the performance is better this way.

Possible ideas include something along the lines of NAPI polling for
tx buffers at intervals, and the more full the buffer is, the better,
as it means it won't need to do another poll examination later. But
this is just a theory, and I really have no idea. I was wondering if
anybody reads this message and thinks, "oh, duh, it's of course
because of XYZ. You should always do ABC, and you can improve things
further if you 123 too." I'd be quite interested anyhow.

Thanks,
Jason
