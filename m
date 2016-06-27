From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] tcp: md5: do not use stack storage in crypto
 operations
Date: Mon, 27 Jun 2016 17:22:41 +0200
Message-ID: <1467040961.6850.155.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1466828771.6850.124.camel@edumazet-glaptop3.roam.corp.google.com>
	 <1466829439.6850.126.camel@edumazet-glaptop3.roam.corp.google.com>
	 <1466870975.6850.139.camel@edumazet-glaptop3.roam.corp.google.com>
	 <20160627.105158.605041440961301398.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: luto@amacapital.net, herbert@gondor.apana.org.au,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f65.google.com ([74.125.82.65]:36488 "EHLO
	mail-wm0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751982AbcF0PWt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Jun 2016 11:22:49 -0400
Received: by mail-wm0-f65.google.com with SMTP id c82so25489342wme.3
        for <netdev@vger.kernel.org>; Mon, 27 Jun 2016 08:22:48 -0700 (PDT)
In-Reply-To: <20160627.105158.605041440961301398.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2016-06-27 at 10:51 -0400, David Miller wrote:
> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Sat, 25 Jun 2016 18:09:35 +0200
> 
> > From: Eric Dumazet <edumazet@google.com>
> > 
> > Some arches have virtually mapped kernel stacks, or will soon have.
> > 
> > tcp_md5_hash_header() uses an automatic variable to copy tcp header
> > before mangling th->check and calling crypto function, which might
> > be problematic on such arches.
> > 
> > So use percpu storage as we already do for the pseudo header,
> > and reduce number of crypto functions calls, as these headers
> > are ridiculously small.
> > 
> > Signed-off-by: Eric Dumazet <edumazet@google.com>
> > Reported-by: Andy Lutomirski <luto@amacapital.net>
> > ---
> > I am not sure the md5 crypto functions have a problem with data backed
> > in virtually mapped stacks, but this patch seems to remove the doubt.
> 
> In a non-SMP build this storage will be in the kernel image itself.
> 
> And this violates the crypto layer's requirements.
> 
> It has to be memory taken from the page allocator or kmalloc.  So
> before vmalloc'd stacks, the current code is perfectly fine.  And
> with vmalloc'd stacks this patch trades one bug for another.

OK, so lets simply use kmalloc() allocated storage instead of percpu.
