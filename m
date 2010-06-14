From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] fragment: add fast path
Date: Mon, 14 Jun 2010 09:04:56 +0200
Message-ID: <1276499096.2478.25.camel@edumazet-laptop>
References: <1276470995-21713-1-git-send-email-xiaosuo@gmail.com>
	 <1276493743.2448.41.camel@edumazet-laptop>
	 <AANLkTimN1-uyAvpxgpno55XoyPzBptdZimz-MA-0MCWZ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	"Pekka Savola (ipv6)" <pekkas@netcore.fi>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org
To: Changli Gao <xiaosuo@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:40323 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755426Ab0FNHFA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Jun 2010 03:05:00 -0400
Received: by wyb40 with SMTP id 40so3477633wyb.19
        for <netdev@vger.kernel.org>; Mon, 14 Jun 2010 00:04:58 -0700 (PDT)
In-Reply-To: <AANLkTimN1-uyAvpxgpno55XoyPzBptdZimz-MA-0MCWZ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


> 
> Without this branch. prev needs to be initialized to zero again(of
> course, we can avoid this by moving prev = NULL in the previous
> branch). next needs an assignment, and a duplicate check if the the
> queue is empty, which is already known in the above branch. Sorry, but
> I can't see which path I slow.
> 
>         prev = NULL;
>         for (next = qp->q.fragments; next != NULL; next = next->next) {
>                 if (FRAG_CB(next)->offset >= offset)
>                         break;  /* bingo! */
>                 prev = next;
>         }
> 

Concept of 'fast path' has changed over years. It used to be cpu
instructions and cycles, its now number of memory transactions.

The only thing we need to address are the cache lines we must bring into
cpu caches, and keep code short.

These days, one cache line miss -> more than one hundred instructions
that could be done during cpu stall. cpu cycles are cheap if code
already in instruction cache.

Adding a test to avoid entering a NULL loop (no fragment is stored yet)
just bloats the code, making it larger than necessary.

You dont need the else branch :

if (prev) {
	if (FRAG_CB(prev)->offset < offset) {
		next = NULL;
		goto found;
	}
else {
	next = NULL;
	goto found;
}

Just write :

next = NULL;
if (prev && FRAG_CB(prev)->offset < offset)
	goto found;



