From: Mahesh Bandewar <maheshb@google.com>
Subject: Re: [PATCH next 1/3] ipvlan: Defer multicast / broadcast processing
 to a work-queue
Date: Thu, 23 Apr 2015 19:54:29 -0700
Message-ID: <CAF2d9jgBwgLzg3y9KDaVHmbE7_NYnHVjTPfD=Jw-yAbLGGhe7w@mail.gmail.com>
References: <1429824589-23663-1-git-send-email-maheshb@google.com> <1429835549.22254.105.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>,
	Dan Willems <dcbw@redhat.com>,
	David Miller <davem@davemloft.net>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f47.google.com ([209.85.218.47]:36754 "EHLO
	mail-oi0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753783AbbDXCyu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Apr 2015 22:54:50 -0400
Received: by oift201 with SMTP id t201so30433504oif.3
        for <netdev@vger.kernel.org>; Thu, 23 Apr 2015 19:54:49 -0700 (PDT)
In-Reply-To: <1429835549.22254.105.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Apr 23, 2015 at 5:32 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Thu, 2015-04-23 at 14:29 -0700, Mahesh Bandewar wrote:
>
>> +static void ipvlan_multicast_enqueue(struct ipvl_port *port,
>> +                                  struct sk_buff *skb)
>> +{
>> +     if (skb->protocol == htons(ETH_P_PAUSE))
>> +             return;
>
> But what happens to this packet ? It seems leaked ?
>
Hmm, will take care of it in v2.
>> +
>> +     spin_lock(&port->backlog.lock);
>> +     if (skb_queue_len(&port->backlog) < IPVLAN_QBACKLOG_LIMIT) {
>> +             __skb_queue_tail(&port->backlog, skb);
>> +             spin_unlock(&port->backlog.lock);
>> +     } else {
>> +             spin_unlock(&port->backlog.lock);
>> +             atomic_long_inc(&skb->dev->rx_dropped);
>> +             kfree_skb(skb);
>> +     }
>> +     schedule_work(&port->wq);
>
> No point calling schedule_work(&port->wq); if packet was dropped.
>
> We are under pressure, so don't add extra cpu cycles ;)
>
The only possibility of schedule_work() while doing kfree_skb() is
when the queue limit is reached. How can the queue be reduced if not
scheduled? May be I'm missing something..
>
