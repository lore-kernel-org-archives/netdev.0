From: Paul Moore <pmoore@redhat.com>
Subject: Re: [PATCH] tcp: assign the sock correctly to an outgoing SYNACK packet
Date: Mon, 08 Apr 2013 14:12:01 -0400
Message-ID: <1725553.maWFXblPLa@sifl>
References: <20130408154519.18177.57709.stgit@localhost> <1558855.HGIqa4tJdt@sifl> <1365443267.3887.28.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: netdev@vger.kernel.org, mvadkert@redhat.com
To: Eric Dumazet <eric.dumazet@gmail.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:29066 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S935199Ab3DHSME (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 8 Apr 2013 14:12:04 -0400
In-Reply-To: <1365443267.3887.28.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Monday, April 08, 2013 10:47:47 AM Eric Dumazet wrote:
> On Mon, 2013-04-08 at 13:40 -0400, Paul Moore wrote:
> > Sort of a similar problem, but not really the same.  Also, arguably, there
> > is no real associated sock/socket for a RST so orphaning the packet makes
> > sense. In the case of a SYNACK we can, and should, associate the packet
> > with a sock/socket.
> 
> What is the intent ?

We have to do a number of painful things in SELinux because we aren't allowed 
a proper security blob (void *security) in a sk_buff.  One of those things is 
using the security blob in the originating sock as a stand-in for the packet's 
own security blob; as a result, when skb->sk is not set we have to make some 
guesses about the security attributes of packet.  We do have methods to handle 
packets without a valid sock pointer, but those are used primarily for non-
local packets (e.g. forwarded traffic) and some limited local use cases (e.g. 
TCP RST packets).

Also, don't mention skb->secmark; unfortunately that was used for something 
else and doesn't apply to this conversation.
 
> On Mon, 2013-04-08 at 10:47 -0700, Eric Dumazet wrote:
> > This kind of requirement has a huge cost, and thats why I want a hook
> > instead of a 'generic thing'
> 
> I meant " I would like ... "
> 
> We for example have security_inet_csk_clone()
> 
> We could have security_skb_owned_by(skb, sk)
>
> I probably can send a patch, it seems quite easy.

It seems a bit fragile to me, perhaps even hacky, but in some ways I guess it 
isn't anymore fragile than relying on skb->sk - as this problem demonstrates.  
My other concern is that adding this hook *correctly* is likely to touch a lot 
of files and may be a bit much so late in the 3.9 cycle, Dave, what say you?

Assuming that this is the preferred option, Eric, would you be open to 
reverting your patch for 3.9 with the assumption that I promise to add the 
hook for 3.10?  You've got my word that I'll have it done ASAP.

-- 
paul moore
security and virtualization @ redhat
