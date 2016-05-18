From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v2] net: sock: move ->sk_shutdown out of bitfields.
Date: Wed, 18 May 2016 06:49:04 -0700
Message-ID: <1463579344.18194.102.camel@edumazet-glaptop3.roam.corp.google.com>
References: <a070f6f7-ed85-c909-ce8b-748210402211@stressinduktion.org>
	 <1463572995-17432-1-git-send-email-aryabinin@virtuozzo.com>
	 <1463576621.18194.96.camel@edumazet-glaptop3.roam.corp.google.com>
	 <573C6ABC.3090008@virtuozzo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Rainer Weikusat <rweikusat@mobileactivedefense.com>,
	Eric Dumazet <edumazet@google.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Andrey Ryabinin <aryabinin@virtuozzo.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f195.google.com ([209.85.192.195]:36231 "EHLO
	mail-pf0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932497AbcERNtH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 May 2016 09:49:07 -0400
In-Reply-To: <573C6ABC.3090008@virtuozzo.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2016-05-18 at 16:14 +0300, Andrey Ryabinin wrote:
> 
> On 05/18/2016 04:03 PM, Eric Dumazet wrote:
> > On Wed, 2016-05-18 at 15:03 +0300, Andrey Ryabinin wrote:
> >> ->sk_shutdown bits share one bitfield with some other bits in sock struct,
> >> such as ->sk_no_check_[r,t]x, ->sk_userlocks ...
> >> sock_setsockopt() may write to these bits, while holding the socket lock.
> >>
> >> In case of AF_UNIX sockets, we change ->sk_shutdown bits while holding only
> >> unix_state_lock(). So concurrent setsockopt() and shutdown() may lead
> >> to corrupting these bits.
> >>
> >> Fix this by moving ->sk_shutdown bits out of bitfield into a separate byte.
> >> This will not change the 'struct sock' size since ->sk_shutdown moved into
> >> previously unused 16-bit hole.
> >>
> >> Signed-off-by: Andrey Ryabinin <aryabinin@virtuozzo.com>
> >> Suggested-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
> >> ---
> >>  include/net/sock.h | 4 ++--
> >>  1 file changed, 2 insertions(+), 2 deletions(-)
> >>
> >> diff --git a/include/net/sock.h b/include/net/sock.h
> >> index c9c8b19..04dc131 100644
> >> --- a/include/net/sock.h
> >> +++ b/include/net/sock.h
> >> @@ -383,8 +383,7 @@ struct sock {
> >>  	int			sk_sndbuf;
> >>  	struct sk_buff_head	sk_write_queue;
> >>  	kmemcheck_bitfield_begin(flags);
> >> -	unsigned int		sk_shutdown  : 2,
> > 
> > 
> > Please replace by a padding, so that sk_protocol is sill a byte,
> > not 8 bits spaning 2 bytes in memory.
> 
> I think, it would be better to have something like this:
> 
> 	u16 sk_type;
> 	u8 sk_protocol;
> 	kmemcheck_bitfield_begin(flags);
> 	u8			sk_no_check_tx : 1,
> 				sk_no_check_rx : 1,
> 				sk_userlocks : 4,
> 	kmemcheck_bitfield_end(flags);
> 
> 

No. This would add extra 32 bits for KMEMCHECK users.

Check kmemcheck_bitfield_begin definition.

These fields are together to fill 32 bits.
