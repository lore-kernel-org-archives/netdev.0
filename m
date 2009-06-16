From: David Miller <davem@davemloft.net>
Subject: Re: [GIT]: Networking
Date: Tue, 16 Jun 2009 03:35:54 -0700 (PDT)
Message-ID: <20090616.033554.102149558.davem@davemloft.net>
References: <20090616094813.GA1686@elte.hu>
	<20090616.025659.224075454.davem@davemloft.net>
	<20090616101132.GA28204@elte.hu>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: alan@lxorguk.ukuu.org.uk, torvalds@linux-foundation.org,
	akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: mingo@elte.hu, eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:41487
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753049AbZFPKfv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Jun 2009 06:35:51 -0400
In-Reply-To: <20090616101132.GA28204@elte.hu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ingo Molnar <mingo@elte.hu>
Date: Tue, 16 Jun 2009 12:11:32 +0200

> sure, here you go (i also added a stack dump, just in case it's some 
> kernel-internal socket open):
> 
>  [ifconfig:3516]: Creates X25 socket.
> 
> so plain ifconfig. Part of the ~1.5 years old net-tools-1.60-84.fc8.

Ok, ifconfig seems to open one of every socket type when it starts up.
That explains why an X25 socket is openned and then closed.

Now the question is why is the X25 socket released by a timer?  This
should only happen if some socket memory is still pending in the
socket buffers.

Wait, I know why this is triggering now.  It's Eric Dumazet's SKB
accounting optimizations.

So, I'll fix the X25 timer bug.  It's always been there, but
beforehand this deferred-via-timer x25 socket destruction path almost
never triggers.  So we never saw it.  Now it happens every time.

Eric can you sniff around and see what you think about this unforseen
(at least for me) consequence of your changes?  Socket layers that use
the current sk_wmem_alloc/sk_rmem_alloc value at destroy time to
determine if a socket can be killed immediately, or need to be killed
later via timer, will always see that dummy one byte allocation you
now put there.

Can you look into that?

Thanks.
