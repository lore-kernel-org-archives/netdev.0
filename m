From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH next 1/3] ipvlan: Defer multicast / broadcast processing
 to a work-queue
Date: Thu, 23 Apr 2015 20:04:06 -0700
Message-ID: <1429844646.22254.113.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1429824589-23663-1-git-send-email-maheshb@google.com>
	 <1429835549.22254.105.camel@edumazet-glaptop2.roam.corp.google.com>
	 <CAF2d9jgBwgLzg3y9KDaVHmbE7_NYnHVjTPfD=Jw-yAbLGGhe7w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>,
	Dan Willems <dcbw@redhat.com>,
	David Miller <davem@davemloft.net>
To: Mahesh Bandewar <maheshb@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f176.google.com ([209.85.223.176]:36732 "EHLO
	mail-ie0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753880AbbDXDEI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Apr 2015 23:04:08 -0400
Received: by iebrs15 with SMTP id rs15so75215027ieb.3
        for <netdev@vger.kernel.org>; Thu, 23 Apr 2015 20:04:08 -0700 (PDT)
In-Reply-To: <CAF2d9jgBwgLzg3y9KDaVHmbE7_NYnHVjTPfD=Jw-yAbLGGhe7w@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2015-04-23 at 19:54 -0700, Mahesh Bandewar wrote:

> The only possibility of schedule_work() while doing kfree_skb() is
> when the queue limit is reached. How can the queue be reduced if not
> scheduled? May be I'm missing something..


What is the point calling schedule_work() if you queued no packet at
this round ? 

Do you really think it will expedite the queue drain ?

Just write instead :


     spin_lock(&port->backlog.lock);
     if (skb_queue_len(&port->backlog) < IPVLAN_QBACKLOG_LIMIT) {
             __skb_queue_tail(&port->backlog, skb);
             spin_unlock(&port->backlog.lock);
     	     schedule_work(&port->wq);
     } else {
             spin_unlock(&port->backlog.lock);
             atomic_long_inc(&skb->dev->rx_dropped);
             kfree_skb(skb);
     }
