From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH RFC] net: decrease the length of backlog queue
 immediately after it's detached from sk
Date: Tue, 29 Mar 2016 22:34:03 -0700
Message-ID: <1459316043.6473.188.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1459315001-3448-1-git-send-email-yangyingliang@huawei.com>
	 <1459315520.6473.187.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net
To: Yang Yingliang <yangyingliang@huawei.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f174.google.com ([209.85.192.174]:34040 "EHLO
	mail-pf0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752143AbcC3FeI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Mar 2016 01:34:08 -0400
Received: by mail-pf0-f174.google.com with SMTP id x3so33013552pfb.1
        for <netdev@vger.kernel.org>; Tue, 29 Mar 2016 22:34:08 -0700 (PDT)
In-Reply-To: <1459315520.6473.187.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2016-03-29 at 22:25 -0700, Eric Dumazet wrote:
> On Wed, 2016-03-30 at 13:16 +0800, Yang Yingliang wrote:
> > When task A hold the sk owned in tcp_sendmsg, if lots of packets
> > arrive and the packets will be added to backlog queue. The packets
> > will be handled in release_sock called from tcp_sendmsg. When the
> > sk_backlog is removed from sk, the length will not decrease until
> > all the packets in backlog queue are handled. This may leads to the
> > new packets be dropped because the lenth is too big. So set the
> > lenth to 0 immediately after it's detached from sk.
> > 
> > Signed-off-by: Yang Yingliang <yangyingliang@huawei.com>
> > ---
> >  net/core/sock.c | 1 +
> >  1 file changed, 1 insertion(+)
> > 
> > diff --git a/net/core/sock.c b/net/core/sock.c
> > index 47fc8bb..108be05 100644
> > --- a/net/core/sock.c
> > +++ b/net/core/sock.c
> > @@ -1933,6 +1933,7 @@ static void __release_sock(struct sock *sk)
> >  
> >  	do {
> >  		sk->sk_backlog.head = sk->sk_backlog.tail = NULL;
> > +		sk->sk_backlog.len = 0;
> >  		bh_unlock_sock(sk);
> >  
> >  		do {
> 
> Certainly not.
> 
> Have you really missed the comment ?
> 
> https://git.kernel.org/cgit/linux/kernel/git/torvalds/linux.git/commit/?id=8eae939f1400326b06d0c9afe53d2a484a326871
> 
> 
> I do not believe the case you describe can happen, unless a misbehaving
> driver cooks fat skb (with skb->truesize being far more bigger than
> skb->len)
> 

And also make sure you backported
https://git.kernel.org/cgit/linux/kernel/git/torvalds/linux.git/commit/?id=da882c1f2ecadb0ed582628ec1585e36b137c0f0
