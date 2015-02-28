From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Repeatable IPv6 crash in 3.19.0-1
Date: Fri, 27 Feb 2015 16:48:53 -0800
Message-ID: <1425084533.5130.54.camel@edumazet-glaptop2.roam.corp.google.com>
References: <54F0E38C.5060203@vultr.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Brian Rak <brak@vultr.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f172.google.com ([209.85.213.172]:37438 "EHLO
	mail-ig0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750916AbbB1Asz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Feb 2015 19:48:55 -0500
Received: by igbhn18 with SMTP id hn18so4857538igb.2
        for <netdev@vger.kernel.org>; Fri, 27 Feb 2015 16:48:55 -0800 (PST)
In-Reply-To: <54F0E38C.5060203@vultr.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2015-02-27 at 16:37 -0500, Brian Rak wrote:
> I've been seeing a crash under 3.19.0 that seems to occur when I put 
> heavy traffic across a macvtap/veth interface.
> 
> We have a KVM guest attached to a veth pair using macvtap.  We're 
> routing IPv6 traffic into one end of the veth pair using some static 
> routes.  We do *not* have proxy_ndp enabled (though, we are using some 
> software to do neighbor proxying - http://priv.nu/projects/ndppd/ ).
> 
> I've been able to reproduce this pretty easily by downloading some large 
> files from the guest.  We see two traces in a row when this occurs:


Nice !

Crash is in neigh_hh_output()

-> memcpy(skb->data - HH_DATA_MOD, hh->hh_data, HH_DATA_MOD);

And there is only 14 bytes of headroom instead of 16.

Some layer did not align skb_headroom(skb) to HH_DATA_MOD for ethernet
header.

IPv4 has a paranoid section, not IPv6 :

        /* Be paranoid, rather than too clever. */
        if (unlikely(skb_headroom(skb) < hh_len && dev->header_ops)) {
                struct sk_buff *skb2;

                skb2 = skb_realloc_headroom(skb, LL_RESERVED_SPACE(dev));
                if (skb2 == NULL) {
                        kfree_skb(skb);
                        return -ENOMEM;
                }
                if (skb->sk)
                        skb_set_owner_w(skb2, skb->sk);
                consume_skb(skb);
                skb = skb2;
        }
