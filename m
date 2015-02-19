From: Steve Glendinning <steve@shawell.net>
Subject: smsc95xx truesize badness
Date: Thu, 19 Feb 2015 18:58:41 +0000
Message-ID: <CAKh2mn7w8fpSYJQqwxwOiAgzKm_5dtzY_uXG7WK7uO9CXSOTrw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: popcorn mix <popcornmix@gmail.com>, eric.dumazet@gmail.com
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f53.google.com ([74.125.82.53]:41934 "EHLO
	mail-wg0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752371AbbBSS6m (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Feb 2015 13:58:42 -0500
Received: by mail-wg0-f53.google.com with SMTP id a1so8976893wgh.12
        for <netdev@vger.kernel.org>; Thu, 19 Feb 2015 10:58:41 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi all,

It seems smsc95xx is doing bad things with truesize in our receive loop.

Simplified loop with some bits removed for clarity (handles the
possible case of receiving multiple frames in one USB transaction):


while (skb->len > 0) {

    /* last frame in this batch */
    if (skb->len == size) {
        skb_trim(skb, skb->len - 4); /* remove fcs */
        skb->truesize = size + sizeof(struct sk_buff);
        return 1;
    }

    ax_skb = skb_clone(skb, GFP_ATOMIC);
    if (unlikely(!ax_skb)) {
        netdev_warn(dev->net, "Error allocating skb\n");
        return 0;
    }

    ax_skb->len = size;
    ax_skb->data = packet;
    skb_set_tail_pointer(ax_skb, size);
    skb_trim(ax_skb, ax_skb->len - 4); /* remove fcs */
    ax_skb->truesize = size + sizeof(struct sk_buff);

    usbnet_skb_return(dev, ax_skb);
}


This is triggering warnings for many Raspberry Pi users due to Eric's
patch to catch truesize offenders.  It's a fair cop.

Before I submit a patch to remove these two truesize lines, I believe
it's safe to just do so but can anyone confirm if removing them will
have any adverse impact?

Thanks!
-- 
Steve Glendinning
