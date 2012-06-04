From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] net: netdev_alloc_skb() use build_skb()
Date: Mon, 04 Jun 2012 19:44:50 +0200
Message-ID: <1338831890.2760.1842.camel@edumazet-glaptop>
References: <1337272404.3403.18.camel@edumazet-glaptop>
	 <20120517164016.GL14498@1wt.eu> <1337273387.3403.24.camel@edumazet-glaptop>
	 <1337276056.3403.37.camel@edumazet-glaptop>
	 <20120604123738.GA28992@redhat.com>
	 <1338815213.2760.1806.camel@edumazet-glaptop>
	 <20120604134138.GA29814@redhat.com>
	 <1338818501.2760.1821.camel@edumazet-glaptop>
	 <20120604141731.GA30226@redhat.com>
	 <1338822064.2760.1834.camel@edumazet-glaptop>
	 <20120604172030.GA32205@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Willy Tarreau <w@1wt.eu>, David Miller <davem@davemloft.net>,
	netdev@vger.kernel.org
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:52088 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754478Ab2FDRoz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Jun 2012 13:44:55 -0400
Received: by bkcji2 with SMTP id ji2so3841274bkc.19
        for <netdev@vger.kernel.org>; Mon, 04 Jun 2012 10:44:53 -0700 (PDT)
In-Reply-To: <20120604172030.GA32205@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2012-06-04 at 20:20 +0300, Michael S. Tsirkin wrote:

> I see. virtio allocates full 4K pages which works well for GSO
> but it means smaller packets would get large truesize
> wasting lots of memory.
> So maybe we should keep copying packets < 128 bytes.

Yet, but restrict the copy to bare minimum if > 128 bytes

See following commit for details (actual changelog bigger than patch
itself)

commit 56138f50d1900b0c3d8647376e37b488b23ba53d
Author: Eric Dumazet <edumazet@google.com>
Date:   Fri May 18 04:48:33 2012 +0000

    iwlwifi: dont pull too much payload in skb head
    
    As iwlwifi use fat skbs, it should not pull too much data in skb->head,
    and particularly no tcp data payload, or splice() is slower, and TCP
    coalescing is disabled. Copying payload to userland also involves at
    least two copies (part from header, part from fragment)
    
    Each layer will pull its header from the fragment as needed.
    
    (on 64bit arches, skb_tailroom(skb) at this point is 192 bytes)
    
    With this patch applied, I have a major reduction of collapsed/pruned
    TCP packets, a nice increase of TCPRcvCoalesce counter, and overall
    better Internet User experience.
    
    Small packets are still using a fragless skb, so that page can be reused
    by the driver.
    
