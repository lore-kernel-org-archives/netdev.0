From: Krzysztof Halasa <khc@pm.waw.pl>
Subject: Re: [PATCH] NET: fix kernel panic from no dev->hard_header_len space
Date: Tue, 01 Aug 2006 03:04:28 +0200
Message-ID: <m3fyghz2oz.fsf@defiant.localdomain>
References: <20060730.153004.45876935.davem@davemloft.net>
	<20060731153948.GB17540@ms2.inr.ac.ru>
	<m3r701zgku.fsf@defiant.localdomain>
	<20060731.132324.65197403.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: kuznet@ms2.inr.ac.ru, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from khc.piap.pl ([195.187.100.11]:57281 "EHLO khc.piap.pl")
	by vger.kernel.org with ESMTP id S1751550AbWHABEb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 31 Jul 2006 21:04:31 -0400
To: David Miller <davem@davemloft.net>
In-Reply-To: <20060731.132324.65197403.davem@davemloft.net> (David Miller's message of "Mon, 31 Jul 2006 13:23:24 -0700 (PDT)")
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller <davem@davemloft.net> writes:

> Krzysztof, which device driver exactly creates this problem
> in the first place?

I have a report (not sure but I think it's that) with hdlc_fr (Frame
Relay).

Grepping through the tree there might be problems with:
- net/8021q/vlan.c (probably not with normal Ethernet, but there is
  a code path which could potentially be a problem with
  NETIF_F_HW_VLAN_TX)
- net/atm/clip.c
- net/appletalk/*
- drivers/net/gianfar.c
- drivers/net/wan/lapbether.c
- drivers/s390/net/netiucv.c will not oops but merely drop the packet
  and print a warning.

and possibly others, I haven't checked the whole tree.
Some (not all) of them might be false positives, though.

Fortunately most of the time skb comes with preallocated header space
(that common skb_reserve(2) I think) and thus the reports aren't
frequent (personally I have never seen that).

> If you have headers to prepend for your device, why do you set the
> header building function to NULL? :-)

hdlc_fr: logical PVC devices have no headers (plain IPv4 etc. as seen
by tcpdump), but they append FR headers (4 or 10 bytes long) just
before passing the skb to physical device.
-- 
Krzysztof Halasa
