From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH 12/20] x25: remove the BKL
Date: Thu, 27 Jan 2011 13:17:01 +0100
Message-ID: <201101271317.01502.arnd@arndb.de>
References: <1295993854-4971-1-git-send-email-arnd@arndb.de> <1295993854-4971-13-git-send-email-arnd@arndb.de> <AANLkTim=d4Tok-ri1BozZUfBFS=rofaodN8ZBA5AjKKd@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, linux-x25@vger.kernel.org,
	netdev@vger.kernel.org
To: Andrew Hendry <andrew.hendry@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.126.171]:57976 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752213Ab1A0MRK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Jan 2011 07:17:10 -0500
In-Reply-To: <AANLkTim=d4Tok-ri1BozZUfBFS=rofaodN8ZBA5AjKKd@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thursday 27 January 2011, Andrew Hendry wrote:
> Left it running and put about 3.0G through x.25, it was running fine
> until after about 20 hours.
> I was stopping the test programs and hit this.
> 
> Jan 27 20:18:34 jaunty kernel: [80403.945790] PGD 1d8b00067 PUD 1ddec3067 PMD 0

Is there no long above this about what problem was hit? There
is normally one saying things like "Bug: unable to handle ..."

Well, nevermind. It seems I could figure it out anyway:

> Jan 27 20:18:34 jaunty kernel: [80403.946083] RAX: 0000000000000080 RBX: ffff880228dbfd70 RCX: ffff880228dbfce4
> Jan 27 20:18:34 jaunty kernel: [80403.946096] RDX: 00000000fffffe00 RSI: 0000000000000000 RDI: ffff8801ba89f050
> Jan 27 20:18:34 jaunty kernel: [80403.946109] RBP: ffff880228dbfd18 R08: ffff88022aa91000 R09: 0000000000000000
> Jan 27 20:18:34 jaunty kernel: [80403.946482] R10: 0000000000000000 R11: 0000000000000000 R12: ffff8801ba89f000
> Jan 27 20:18:34 jaunty kernel: [80403.946495] R13: 0000000000000000 R14: 0000000000000000 R15: 0000000000000000
> ...
>
> If i have done it right, x25_sendmsg+0x1a7/0x530 is the skb_reserve
> which gets inlined here.
> (af_x25.c)
>         /* Build a packet */
>         SOCK_DEBUG(sk, "x25_sendmsg: sendto: building packet.\n");
> 
>         if ((msg->msg_flags & MSG_OOB) && len > 32)
>                 len = 32;
> 
>         size = len + X25_MAX_L2_LEN + X25_EXT_MIN_LEN;
> 
>         release_sock(sk);
>         skb = sock_alloc_send_skb(sk, size, noblock, &rc);
>         lock_sock(sk);
> 
>         X25_SKB_CB(skb)->flags = msg->msg_flags;


ok.

> objdump -dS show it at 2197 here.
> 
> static inline void skb_reserve(struct sk_buff *skb, int len)
> {
>         skb->data += len;
>         skb->tail += len;
>     2197:       41 83 87 b4 00 00 00    addl   $0x16,0xb4(%r15) <---
>     219e:       16
>     219f:       41 89 47 28             mov    %eax,0x28(%r15)
>     21a3:       49 8b 87 c8 00 00 00    mov    0xc8(%r15),%rax
>     21aa:       48 83 c0 16             add    $0x16,%rax
>         skb_reserve(skb, X25_MAX_L2_LEN + X25_EXT_MIN_LEN);
> 
> But im not sure where to go from there...
 
It's pretty clear that %r15 is the skb in this, and from the registers in the dump,
you can see that it's NULL. skb has just been returned from sock_alloc_send_skb,
which means that this function failed.

And indeed:

> > @@ -1148,9 +1140,10 @@ static int x25_sendmsg(struct kiocb *iocb, struct socket *sock,
> >
> >        size = len + X25_MAX_L2_LEN + X25_EXT_MIN_LEN;
> >
> > +       release_sock(sk);
> >        skb = sock_alloc_send_skb(sk, size, noblock, &rc);
> > -       if (!skb)
> > -               goto out;
> > +       lock_sock(sk);
> > +
> >        X25_SKB_CB(skb)->flags = msg->msg_flags;

I accidentally removed the error handling in my patch. No idea how that
happened, it certainly wasn't intentional. Thanks a lot for the thorough
testing and the detailed bug report!

I'll follow up with a fixed patch that puts the error path back in.

	Arnd
