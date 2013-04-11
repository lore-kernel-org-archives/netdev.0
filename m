From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC PATCH] udp: don't rereference dst_entry dev pointer on rcv
Date: Thu, 11 Apr 2013 15:26:33 -0700
Message-ID: <1365719193.3887.190.camel@edumazet-glaptop>
References: <1362695800-8633-1-git-send-email-tparkin@katalix.com>
	 <1362695800-8633-2-git-send-email-tparkin@katalix.com>
	 <1362696444.15793.220.camel@edumazet-glaptop>
	 <20130307.181527.390191009324148471.davem@davemloft.net>
	 <20130313232743.GA3686@raven> <1363223884.29475.0.camel@edumazet-glaptop>
	 <20130314144550.GB2512@raven> <1363273531.29475.21.camel@edumazet-glaptop>
	 <1363274946.29475.24.camel@edumazet-glaptop>
	 <1365697961.3887.176.camel@edumazet-glaptop>
	 <1365702804.3887.180.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Tom Parkin <tparkin@katalix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ia0-f174.google.com ([209.85.210.174]:46425 "EHLO
	mail-ia0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753007Ab3DKW0g (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Apr 2013 18:26:36 -0400
Received: by mail-ia0-f174.google.com with SMTP id r13so1853945iar.5
        for <netdev@vger.kernel.org>; Thu, 11 Apr 2013 15:26:36 -0700 (PDT)
In-Reply-To: <1365702804.3887.180.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2013-04-11 at 10:53 -0700, Eric Dumazet wrote:
> On Thu, 2013-04-11 at 09:32 -0700, Eric Dumazet wrote:
> 
> > Short update : I do not understand yet why this patch is not working.
> > 
> > Normally, the reassembled packet should get the dst from the last skb
> > (the one completing the packet)...
> > 
> > I have to make more experiments.
> 
> OK I think I've nailed it, please try following patch (I tried it on
> net-next, but it should apply on previous kernels)

By the way I am ashamed by commit 64f3b9e203bd068550
(net: ip_expire() must revalidate route)

Reading its changelog now, I understand I should have fixed this the
way we did today...

:(

    Commit 4a94445c9a5c (net: Use ip_route_input_noref() in input path)
    added a bug in IP defragmentation handling, in case timeout is fired.
    
    When a frame is defragmented, we use last skb dst field when building
    final skb. Its dst is valid, since we are in rcu read section.
    
    But if a timeout occurs, we take first queued fragment to build one ICMP
    TIME EXCEEDED message. Problem is all queued skb have weak dst pointers,
    since we escaped RCU critical section after their queueing. icmp_send()
    might dereference a now freed (and possibly reused) part of memory.
    
    Calling skb_dst_drop() and ip_route_input_noref() to revalidate route is
    the only possible choice.
