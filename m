From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] net: flush the softnet backlog in process
 context
Date: Thu, 25 Aug 2016 07:32:37 -0700
Message-ID: <1472135557.14381.130.camel@edumazet-glaptop3.roam.corp.google.com>
References: <528006070d2951617c55b94c60c5d690ff0e4fc3.1472130597.git.pabeni@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
        Eric Dumazet <edumazet@google.com>,
        Tom Herbert <tom@herbertland.com>,
        Hannes Frederic Sowa <hannes@stressinduktion.org>
To: Paolo Abeni <pabeni@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f194.google.com ([209.85.192.194]:35876 "EHLO
        mail-pf0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750933AbcHYOe1 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 25 Aug 2016 10:34:27 -0400
Received: by mail-pf0-f194.google.com with SMTP id y134so3350193pfg.3
        for <netdev@vger.kernel.org>; Thu, 25 Aug 2016 07:32:40 -0700 (PDT)
In-Reply-To: <528006070d2951617c55b94c60c5d690ff0e4fc3.1472130597.git.pabeni@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2016-08-25 at 15:58 +0200, Paolo Abeni wrote:
> Currently in process_backlog(), the process_queue dequeuing is
> performed with local IRQ disabled, to protect against
> flush_backlog(), which runs in hard IRQ context.

Acked-by: Eric Dumazet <edumazet@google.com>

> @@ -6707,7 +6735,7 @@ static void rollback_registered_many(struct list_head *head)
>  		unlist_netdevice(dev);
>  
>  		dev->reg_state = NETREG_UNREGISTERING;
> -		on_each_cpu(flush_backlog, dev, 1);
> +		flush_all_backlogs(dev);
>  	}
>  
>  	synchronize_net();

In a future patch, we could change this so that we kick
flush_all_backlogs() once for all devices, instead of one device at a
time.

We would not pass @dev anymore as a parameter and simply look at
skb->dev->reg_state to decide to remove packets from queues in
flush_backlog()

Batching matters for some guys using hundred of devices and suddenly
removing them all in one go.

Thanks.
