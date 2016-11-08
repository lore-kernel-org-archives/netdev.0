From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [net-next PATCH 3/3] qdisc: catch misconfig of attaching qdisc
 to tx_queue_len zero device
Date: Tue, 8 Nov 2016 08:46:35 +0100
Message-ID: <20161108084635.02cdc293@redhat.com>
References: <20161103135534.28737.37657.stgit@firesoul>
        <20161103135611.28737.39840.stgit@firesoul>
        <CAHo-Oozk1AqqR4+9HxLYSGQOQ8Ohs0NaOx=ZV+94JCH-ftxtMw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8BIT
Cc: Linux NetDev <netdev@vger.kernel.org>, Phil Sutter <phil@nwl.cc>,
        Robert Olsson <robert@herjulf.se>,
        Jamal Hadi Salim <jhs@mojatatu.com>, brouer@redhat.com
To: Maciej =?UTF-8?B?xbtlbmN6eWtvd3NraQ==?= <zenczykowski@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:41242 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752302AbcKHHql (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 8 Nov 2016 02:46:41 -0500
In-Reply-To: <CAHo-Oozk1AqqR4+9HxLYSGQOQ8Ohs0NaOx=ZV+94JCH-ftxtMw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Mon, 7 Nov 2016 22:14:37 -0800 Maciej Żenczykowski <zenczykowski@gmail.com> wrote:

> Just FYI:
> 
> I'm tangentially aware of internal Google code that:
> - expects a bonding device running HTB with non-zero txqueuelen
> - wants to remove HTB and get a noqueue interface (the normal default
> for bonding)
> 
> The code currently removes HTB, which gets us to mq, sets txqueuelen
> to 0, adds a pfifo, removes the pfifo, which gets us to noqueue.

This clearly shows that the older userspace interface, of tx_queue_len
having double meaning, was a mess!

> After this patch this would ?possibly? break (adding pfifo, would
> change txqueuelen, so when we remove it we wouldn't end up with
> noqueue).

No, you will still end-up with "noqueue".  It is now the flag
IFF_NO_QUEUE that determine if a device gets "noqueue" when the default
qdisc is attached. The tx_queue_len no longer have any effect on
getting "noqueue".  The IFF_NO_QUEUE system removed this double meaning
of tx_queue_len.


> From what I fuzzily recall, HTB with txquelelen == 0 drops traffic
> hard, while pfifo continues to function, hence the ordering...
> 
> Obviously our code can be fixed, but I'm worried there's a more
> generic backwards compatibility problem here.

It is good you bring it up, but I don't see a backwards compatibility
problem with your usage after the patchset.
 
> (note: this is mostly about 3.11 and 4.3 and might no longer be
> relevant with 4.10... maybe the new kernel's default qdisc selection
> logic doesn't depend on txqueuelen and checks the flag instead???)

If I were you, I would now implement a validation check that reported
the problem if not getting into the expected "noqueue" state.  Then
when you eventually upgrade to a more recent kernel, you would get
alerted of improper state.

Something like:

noqueue=$(ip link show dev $DEV 2> /dev/null | grep -q "noqueue" && echo "noqueue" || echo "bad")
if [[ "$noqueue" != "noqueue" ]]; then
    echo "report-problem";
fi

-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Principal Kernel Engineer at Red Hat
  Author of http://www.iptv-analyzer.org
  LinkedIn: http://www.linkedin.com/in/brouer
