From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [RFC] gro: Is it ok to share a single napi from several devs ?
Date: Sat, 28 Aug 2010 12:54:06 +0200
Message-ID: <1282992846.2277.15.camel@edumazet-laptop>
References: <20100827205042.GA13844@del.dom.local>
	 <20100828001337.GA1955@gondor.apana.org.au>
	 <20100828094433.GA3110@del.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Jarek Poplawski <jarkao2@gmail.com>,
	Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:33738 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752095Ab0H1KyM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 28 Aug 2010 06:54:12 -0400
Received: by wyb35 with SMTP id 35so4672523wyb.19
        for <netdev@vger.kernel.org>; Sat, 28 Aug 2010 03:54:10 -0700 (PDT)
In-Reply-To: <20100828094433.GA3110@del.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In commit f2bde7328633269ee935d9ed96535ade15cc348f
Author: Stephen Hemminger <shemminger@vyatta.com>

    net: allow multiple dev per napi with GRO
    
    GRO assumes that there is a one-to-one relationship between NAPI
    structure and network device. Some devices like sky2 share multiple
    devices on a single interrupt so only have one NAPI handler. Rather than
    split GRO from NAPI, just have GRO assume if device changes that
    it is a different flow.
   

It was assumed a napi could be shared by several devs, but I dont really
understand, since we have an unique ->dev pointer inside "napi_struct",
this one is set once, and never change.

This pointer is currently used from napi_get_frags() [but that could be
avoided], and from netpoll_poll_lock().

The netpoll_poll_lock() case is problematic.

static inline void *netpoll_poll_lock(struct napi_struct *napi)
{
        struct net_device *dev = napi->_dev;

        if (dev && dev->npinfo) {
                spin_lock(&napi->poll_lock);

Maybe we should remove 'dev' field from napi_struct and replace it by a
npinfo pointer ?




