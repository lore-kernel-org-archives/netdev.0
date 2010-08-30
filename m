From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [RFC] netpoll: Is it ok to share a single napi from several devs ?
Date: Mon, 30 Aug 2010 21:59:16 +0200
Message-ID: <1283198356.2405.8.camel@edumazet-laptop>
References: <1283107162.2297.32.camel@edumazet-laptop>
	 <20100830064231.GA7060@ff.dom.local> <20100830085721.54c8c31b@nehalam>
	 <20100830.095012.233695092.davem@davemloft.net>
	 <20100830183620.GA3079@del.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, shemminger@vyatta.com,
	herbert@gondor.apana.org.au, netdev@vger.kernel.org
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f46.google.com ([209.85.215.46]:45657 "EHLO
	mail-ew0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753901Ab0H3T7Y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Aug 2010 15:59:24 -0400
Received: by ewy23 with SMTP id 23so3435817ewy.19
        for <netdev@vger.kernel.org>; Mon, 30 Aug 2010 12:59:22 -0700 (PDT)
In-Reply-To: <20100830183620.GA3079@del.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

So everybody jumped on GRO, while my concern was more the napi->dev
thing.

I pointed to gro because the commit was about gro, but gro was fine
IMHO.

Are we sure netpoll is ok ?

If a napi is shared by several net_device, should'nt we change
netpoll_poll_lock() ?

static inline void *netpoll_poll_lock(struct napi_struct *napi)
{
        struct net_device *dev = napi->dev;

        if (dev && dev->npinfo) {
                spin_lock(&napi->poll_lock);
                napi->poll_owner = smp_processor_id();
                return napi;
        }
        return NULL;
}

---->

static inline void *netpoll_poll_lock(struct napi_struct *napi)
{
        if (atomic_read(&napi->poll_count)) {
                spin_lock(&napi->poll_lock);
                napi->poll_owner = smp_processor_id();
                return napi;
        }
        return NULL;
}



