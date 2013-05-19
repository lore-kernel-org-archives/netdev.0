From: David Hauweele <david@hauweele.net>
Subject: Re: [PATCH 1/1] 6lowpan: Fix fragmentation with link-local compressed addresses
Date: Mon, 20 May 2013 00:14:48 +0200
Message-ID: <CAO+c-UW6MAK5TQrsn6NFnkvsm7QOTk+tUDM4OHGUb+E0KxvJgQ@mail.gmail.com>
References: <1368987211-19826-1-git-send-email-david@hauweele.net>
	<20130519195809.GA3237@x61s.Speedport_W_921V_1_21_000>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Alexander Smirnov <alex.bluesman.smirnov@gmail.com>,
	Dmitry Eremin-Solenikov <dbaryshkov@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	linux-zigbee-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Alexander Aring <alex.aring@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20130519195809.GA3237@x61s.Speedport_W_921V_1_21_000>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello,

There is a patch which fixes link-local address uncompression:

http://permalink.gmane.org/gmane.linux.network.zigbee.devel/1717

I came across a similar solution but didn't submit it as another patch
already existed.
This patch instead focus on fragmented packet with link-local address
compression,
which is related but a different bug.

2013/5/19 Alexander Aring <alex.aring@gmail.com>:
> Hi David,
>
> can you use a link-layer address on the current net-next kernel?
>
> I am asking because I can't use a link-layer address currently.
> Your patch doesn't help to solve my problem with link-layer addresses.
>
>
> To your patch:
>
> We get the link-layer addresses from skb not from the allocated
> frame->skb.
>
> Here is the code:
>
> _saddr = mac_cb(skb)->sa.hwaddr;
> _daddr = mac_cb(skb)->da.hwaddr;
>
> Here is skb != frame->skb so we don't need to copy it to frame->skb->cb
> because we already the link-layer addresses from skb->cb.
>
> Is there another place in the code where we get the link-layer addresses
> from allocated "frame" structure?

frame->skb is used to reassemble the 6lowpan packet when new fragments
are received.
This is the 'fragments assembling' switch at the beginning of
lowpan_process_data().
It will reassemble fragments until the packet is successfully reassembled.
Once it is, skb is replaced:

dev_kfree_skb(skb);
skb = frame->skb;
kfree(frame);

And the process continues as with other 6lowpan packets.

In particular:

_saddr = mac_cb(skb)->sa.hwaddr;
_daddr = mac_cb(skb)->da.hwaddr;

Several lines later there are:

err = lowpan_uncompress_addr(skb, &hdr.saddr, lowpan_llprefix,
lowpan_unc_llconf[tmp], skb->data);
err = lowpan_uncompress_addr(skb, &hdr.daddr, lowpan_llprefix,
lowpan_unc_llconf[tmp], skb->data);

These two lines should use _saddr/_daddr instead of skb->data, which
fixes the link-local address uncompression.
I'm able to use link-layer addresses with these two patches and it works well.

>
> Regards
> Alex

Regards,

David
