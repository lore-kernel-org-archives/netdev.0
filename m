From: Michael Ma <make0818@gmail.com>
Subject: Corrupted SKB
Date: Mon, 17 Apr 2017 17:39:55 -0700
Message-ID: <CAAmHdhx14ZH3ftE2SovFZfy8ZfOCEgsyqqcSbGPHqg87Wc+5SQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: Linux Kernel Network Developers <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f51.google.com ([209.85.218.51]:34943 "EHLO
        mail-oi0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753768AbdDRAj5 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 17 Apr 2017 20:39:57 -0400
Received: by mail-oi0-f51.google.com with SMTP id j201so7459324oih.2
        for <netdev@vger.kernel.org>; Mon, 17 Apr 2017 17:39:56 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi -

We've implemented a "glue" qdisc similar to mqprio which can associate
one qdisc to multiple txqs as the root qdisc. Reference count of the
child qdiscs have been adjusted properly in this case so that it
represents the number of txqs it has been attached to. However when
sending packets we saw the skb from dequeue_skb() corrupted with the
following call stack:

    [exception RIP: netif_skb_features+51]
    RIP: ffffffff815292b3  RSP: ffff8817f6987940  RFLAGS: 00010246

 #9 [ffff8817f6987968] validate_xmit_skb at ffffffff815294aa
#10 [ffff8817f69879a0] validate_xmit_skb at ffffffff8152a0d9
#11 [ffff8817f69879b0] __qdisc_run at ffffffff8154a193
#12 [ffff8817f6987a00] dev_queue_xmit at ffffffff81529e03

It looks like the skb has already been released since its dev pointer
field is invalid.

Any clue on how this can be investigated further? My current thought
is to add some instrumentation to the place where skb is released and
analyze whether there is any race condition happening there. However
by looking through the existing code I think the case where one root
qdisc is associated with multiple txqs already exists (when mqprio is
not used) so not sure why it won't work when we group txqs and assign
each group a root qdisc. Any insight on this issue would be much
appreciated!

Thanks,
Michael
