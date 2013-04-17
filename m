From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: oops in udpv6_sendmsg
Date: Wed, 17 Apr 2013 09:05:51 -0700
Message-ID: <1366214751.3205.29.camel@edumazet-glaptop>
References: <20130329184006.GA23893@redhat.com>
	 <1364582958.5113.49.camel@edumazet-glaptop>
	 <1364865839.5113.165.camel@edumazet-glaptop>
	 <20130417010213.GA9027@redhat.com>
	 <1366164132.3205.21.camel@edumazet-glaptop>
	 <20130417141138.GA17648@redhat.com>
	 <1366208856.3205.23.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Dave Jones <davej@redhat.com>, David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f49.google.com ([209.85.220.49]:64979 "EHLO
	mail-pa0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965236Ab3DQQFy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Apr 2013 12:05:54 -0400
Received: by mail-pa0-f49.google.com with SMTP id kp14so990167pab.8
        for <netdev@vger.kernel.org>; Wed, 17 Apr 2013 09:05:54 -0700 (PDT)
In-Reply-To: <1366208856.3205.23.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2013-04-17 at 07:27 -0700, Eric Dumazet wrote:
> On Wed, 2013-04-17 at 10:11 -0400, Dave Jones wrote:
> > On Tue, Apr 16, 2013 at 07:02:12PM -0700, Eric Dumazet wrote:
> 
> > good news is that with some changes, I was able to make current
> > trinity reproduce this in seconds rather than hours..
> > 
> > ./trinity -q -l off -n -c sendmsg -c connect 
> > 
> > on current tree seems to reliably trigger it for me.
> 
> Good new indeed, I got a crash in 2 seconds
> 
> (have to reproduce it because I lost the console output)
> 
> 

Hmm, sk_dst_get() assumes dst are always freed after RCU grace period,
but it seems not the case with IPv6.

We should atomically set dst->__refcnt to -1 before RCU grace period and
final destruction, then sk_dst_get should do something like :

rcu_read_lock();
dst = rcu_dereference(sk->sk_dst_cache); 
if (dst && !atomic_add_unless(&dst->__refcnt, 1, -1))
	dst = NULL;
rcu_read_unlock();

Ie we should not increment dst->__refcnt if the dst is in dismantle
phase.
