From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: 3.2.8/amd64 full interrupt hangs and deadlocks under big
 network copies (page allocation failure)
Date: Tue, 10 Apr 2012 05:56:20 +0200
Message-ID: <1334030180.13293.98.camel@edumazet-glaptop>
References: <20120409.143710.879746943062854492.davem@davemloft.net>
	 <4F83316F.20504@lwfinger.net> <1333998672.3007.245.camel@edumazet-glaptop>
	 <20120409.153452.1284163346306246866.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Larry.Finger@lwfinger.net, marc@merlins.org,
	bhutchings@solarflare.com, linux-wireless@vger.kernel.org,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f44.google.com ([74.125.82.44]:47889 "EHLO
	mail-wg0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750762Ab2DJEDj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Apr 2012 00:03:39 -0400
In-Reply-To: <20120409.153452.1284163346306246866.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2012-04-09 at 15:34 -0400, David Miller wrote:
> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Mon, 09 Apr 2012 21:11:12 +0200
> 
> > I think Marc posted stack traces showing problem on transmit side.
>  ...
> > I dont really understand how it can happen, with MTU=1500
> 
> Depending upon the configuration and the driver, wireless can need
> more headroom.  For encryption an extra 8 bytes are necessary, and the
> driver may request a variable amount of extra headroom via
> ->hw.extra_tx_headroom
> 
> What wireless device are we dealing with again?

Problem seems related to tailroom needed by mac80211
(IEEE80211_ENCRYPT_TAILROOM = 18 bytes)

So we must reallocate skb->head, thats impressive nobody cares.

[ 3007.249687] ieee80211_skb_resize(skb=ffff8802329846e8) cloned=1 head_need=0 tail_need=18 skb->len=1494 ksize=4096 tailroom=0 headroom=2282
[ 3007.249693] ieee80211_skb_resize(skb=ffff8802329846e8) cloned=0 head_need=0 tail_need=0 skb->len=1526 ksize=8192 tailroom=64 headroom=2250

Ouch... skb_tailroom() seems wrong ... it seems pskb_expand_head() is really suboptimal.

It appears tcp_sendmsg() tries to fill skb completely, with no available tailroom :

                        if (skb_tailroom(skb) > 0) {
                                /* We have some space in skb head. Superb! */
                                if (copy > skb_tailroom(skb))
                                        copy = skb_tailroom(skb);
                                err = skb_add_data_nocache(sk, skb, from, copy);
                                if (err)
                                        goto do_fault;
                        } else {


Shouldnt we take into account dev->needed_tailroom ?

I'll submit a pskb_expand_head() fix asap.
