From: David Miller <davem@davemloft.net>
Subject: Re: Socket buffer sizes with autotuning
Date: Wed, 07 May 2008 18:43:11 -0700 (PDT)
Message-ID: <20080507.184311.196815718.davem@davemloft.net>
References: <d1c2719f0805071136i3414755cv6e72e7bd5a0d41ad@mail.gmail.com>
	<20080507.141835.229114942.davem@davemloft.net>
	<d1c2719f0805071837v5168cee0qa6a3d160e93adb48@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: hkchu@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:51258
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1755292AbYEHBnS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 May 2008 21:43:18 -0400
In-Reply-To: <d1c2719f0805071837v5168cee0qa6a3d160e93adb48@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Jerry Chu" <hkchu@google.com>
Date: Wed, 7 May 2008 18:37:01 -0700

> Ok, will give it a try. First i'll fix your patch to
> atomic_add()/atomic_sub() by
> skb_shinfo(skb)->gso_segs rather than always 1, in order for GSO/TSO to work.

That might not work.  gso_segs can change over time as retransmit
packets get split up due to SACKs etc.  it needs to be audited,
at the very least.

> One problem came up to my mind - it seems possible for __kfree_skb() to
> access skb_shinfo(skb)->in_flight whose tp has been freed up since only the
> original skb's on TCP's rexmit list have the owner set and socket
> held. One solution
> is for TCP to zap skb_shinfo(skb)->in_flight field when it's ready to
> free up skb.
> I can hack sock_wfree() to do this, but I don't know how to do it right.

There will be references to the socket, so this should be ok.

If it isn't we can adjust the count and zap the pointer in
skb_orphan().
