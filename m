From: Vijay Subramanian <subramanian.vijay@gmail.com>
Subject: Re: [PATCH] pkt_sched: fq: clear time_next_packet for reused flows
Date: Sun, 27 Oct 2013 15:06:10 -0700
Message-ID: <CAGK4HS945jCtfOoa_ENhTwZQvnSRJpHdWVDyhF+wjE56bjT8Pw@mail.gmail.com>
References: <1382612508.7572.53.camel@edumazet-glaptop.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ve0-f182.google.com ([209.85.128.182]:36443 "EHLO
	mail-ve0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753963Ab3J0WGL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 27 Oct 2013 18:06:11 -0400
Received: by mail-ve0-f182.google.com with SMTP id c14so3013309vea.13
        for <netdev@vger.kernel.org>; Sun, 27 Oct 2013 15:06:10 -0700 (PDT)
In-Reply-To: <1382612508.7572.53.camel@edumazet-glaptop.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 24 October 2013 04:01, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> From: Eric Dumazet <edumazet@google.com>
>
> When a socket is freed/reallocated, we need to clear time_next_packet
> or else we can inherit a prior value and delay first packets of the
> new flow.
>
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Eric,
By the way,  it looks like fq_flow_set_throttled() uses
f->time_next_packet in an incorrect way.
It is used as key to insert the flow into the delayed rb-tree but does
not seem to check for duplicates.
This could lead to rb tree corruption. I assume it is possible for
different flows to have same f->time_next_packet.
Do we at least we need a BUG_ON(f->time_next_packet ==
aux->time_next_packet) here?


Code in fq_flow_set_throttled():
        while (*p) {
                struct fq_flow *aux;

                parent = *p;
                aux = container_of(parent, struct fq_flow, rate_node);
                if (f->time_next_packet >= aux->time_next_packet)
                        p = &parent->rb_right;
                else
                        p = &parent->rb_left;
        }
        rb_link_node(&f->rate_node, parent, p);
        rb_insert_color(&f->rate_node, &q->delayed);

Thanks!
-vijay
