From: Max Krasnyansky <maxk@qualcomm.com>
Subject: Skb over panic on TUN device (2.6.18)
Date: Thu, 04 Oct 2007 13:58:54 -0700
Message-ID: <4705540E.40903@qualcomm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from warlock.qualcomm.com ([129.46.50.49]:33988 "EHLO
	warlock.qualcomm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759244AbXJDVLd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Oct 2007 17:11:33 -0400
Received: from ithilien.qualcomm.com (ithilien.qualcomm.com [129.46.51.59])
	by warlock.qualcomm.com (8.13.6/8.13.6/1.0) with ESMTP id l94LBW52021112
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=FAIL)
	for <netdev@vger.kernel.org>; Thu, 4 Oct 2007 14:11:32 -0700 (PDT)
Received: from totoro.qualcomm.com (totoro.qualcomm.com [129.46.61.158])
	by ithilien.qualcomm.com (8.14.1/8.12.5/1.0) with ESMTP id l94KwtPV001299
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=FAIL)
	for <netdev@vger.kernel.org>; Thu, 4 Oct 2007 13:58:55 -0700
Received: from [129.46.6.218] (m2x.qualcomm.com [129.46.6.218])
	by totoro.qualcomm.com (8.14.1/8.13.6/1.0) with ESMTP id l94Kwsqa021457
	for <netdev@vger.kernel.org>; Thu, 4 Oct 2007 13:58:55 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Folks,

I just got this panic report against 2.6.18 kernel and was wondering if some of you have
an idea of why this might happen.

The panic looks like this:

skb_over_panic: text:ffffffff880463db len:2840 put:1454 head:ffff81005df81000 data:ffff81005df81020
tail:ffff81005df81b38 end:ffff81005df81840 dev:tun0

skb_over_panic: text:ffffffff880463db len:1354 put:1314 head:ffff81007d77ee00 data:ffff81007d77ee20 
tail:ffff81007d77f36a end:ffff81007d77ee80 dev:tun0

Those are two are unrelated and happened at different times.

It's coming from this piece of code:
        if (!(skb = alloc_skb(len + align, GFP_KERNEL))) {
                tun->stats.rx_dropped++;
                return -ENOMEM;
        }

        if (align)
                skb_reserve(skb, align);
        if (memcpy_fromiovec(skb_put(skb, len), iv, len)) {
                tun->stats.rx_dropped++;
                kfree_skb(skb);
                return -EFAULT;
        }

As you can see there is not a whole lot that can go wrong with skb in there.
'align' is set to 0 for TUN devices.

First dumps looks as if skb already had no zero length right after allocation.
In the second dump skb is only 128 byte in size (end - head) even though 
we're clearly allocating and trying to write more than that. 

So, my conclusion at this point is that for whatever reason alloc_skb() returned 
busted SKB. Probably because something in the slab got corrupted.

Any other thoughts ?

Thanx
Max
