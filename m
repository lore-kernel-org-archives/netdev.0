From: Andi Kleen <ak@suse.de>
Subject: Re: [PATCH] tg3 : avoid an expensive divide
Date: Wed, 7 Feb 2007 11:27:42 +0100
Message-ID: <200702071127.42298.ak@suse.de>
References: <200702061536.18800@nienna> <p73ireemgwm.fsf@bingen.suse.de> <200702071056.04879.dada1@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, mchan@broadcom.com,
	netdev@vger.kernel.org
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:43211 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1161109AbXBGK14 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 7 Feb 2007 05:27:56 -0500
In-Reply-To: <200702071056.04879.dada1@cosmosbay.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


> Well, this could explain but unfortunatly I dont have this option set :
> 
> # grep OPTIMIZE .config
> # CONFIG_CC_OPTIMIZE_FOR_SIZE is not set
> 
> # gcc -v
> Using built-in specs.
> Target: x86_64-unknown-linux-gnu
> Configured with: ../gcc-4.1.1/configure --enable-languages=c,c++

Ah. Looking more closely the problem is different (sorry for the wrong
explanation earlier, it fit too well and it really happened elsewhere)

The code is 

#define TG3_RX_RCB_RING_SIZE(tp)        \
        ((tp->tg3_flags2 & TG3_FLG2_5705_PLUS) ?  512 : 1024)

...
sw_idx %= TG3_RX_RCB_RING_SIZE(tp);


The problem is that gcc doesn't rewrite the x % (cond ? const1 : const2) expression
to the more optimizable cond ? (x % const1 : x % const2). For the first it sees
a full variable division, for which div* is the best code to generate.

Your patch is probably correct or alternatively rewrite the expression 
to the optimizable form by hand.

Arguably gcc should do this by itself. Perhaps file a gcc bug about this missing optimization. 

-Andi

