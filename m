From: David Miller <davem@davemloft.net>
Subject: Re: [RFC net-2.6.26] [IPV6] SIT: ISATAP Updates.
Date: Tue, 08 Apr 2008 03:08:41 -0700 (PDT)
Message-ID: <20080408.030841.66945263.davem@davemloft.net>
References: <20080403.113811.105715223.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, fred.l.templin@boeing.com
To: yoshfuji@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42890
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751690AbYDHKIk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Apr 2008 06:08:40 -0400
In-Reply-To: <20080403.113811.105715223.yoshfuji@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: YOSHIFUJI Hideaki / 吉藤英明 <yoshfuji@linux-ipv6.org>
Date: Thu, 03 Apr 2008 11:38:11 +0900 (JST)

> This updates ISATAP implementation in Linux kernel
> based on the update from Templin, Fred L <fred.l.templin@boeing.com>.
> 
> One big question is the "dump" support (4th commit).
> Since we cannot use copy_to_user family inside the lock,
> nasty kcalloc() is used inside the lock so far...
> 
> Patches are also available at
> 	git://git.linux-ipv6.org/gitroot/yoshfuji/linux-2.6-dev.git net-2.6.26-isatap-20080403

I think this is fine and I've pulled it into net-2.6.26

About the kcalloc() code, what you could do is add a mutex
that is held across these changes.  Use it to augment the
rwlock, not to replace it.

So you're grab it around calls to ipip6_tunnel_{link,unlink}(),
ipip6_tunnel_{add,del}_prl(), and the piece of code in
ipip6_tunnel_uninit() that sets tunnels_wc[0] to NULL.

Then you also take this mutex around the dump code, so
you don't need to do the kcalloc() stuff.

You might be tempted to hold the mutex across all of
ipip6_tunnel_uninit(), but it may not be safe to hold
it across the dev_put().  Although I cannot prove it,
it might be possible for that to end up calling back
into some of these paths.  Better safe than sorry.
:-)
