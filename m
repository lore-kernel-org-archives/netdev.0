From: John Heffner <johnwheffner@gmail.com>
Subject: Re: TCP being hoodwinked into spurious retransmissions by lack of timestamps?
Date: Mon, 3 Mar 2014 22:22:32 -0500
Message-ID: <CABrhC0=hHpZSdE5-dLqysuFn_d_VK7r1jKb0kGZF9hn1+UHjDw@mail.gmail.com>
References: <53151E55.9000503@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Netdev <netdev@vger.kernel.org>
To: Rick Jones <rick.jones2@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ve0-f178.google.com ([209.85.128.178]:53099 "EHLO
	mail-ve0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756049AbaCDDWd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Mar 2014 22:22:33 -0500
Received: by mail-ve0-f178.google.com with SMTP id jw12so1988284veb.23
        for <netdev@vger.kernel.org>; Mon, 03 Mar 2014 19:22:32 -0800 (PST)
In-Reply-To: <53151E55.9000503@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Running with such a large window scale and no timestamps (PAWS
protection) is generally not a great idea, but I don't think is part
of the issue here.

If you look where things really go wrong, the receiver is sending
anomalous SACK blocks that will trigger the SACK renege handling path.
 Reneging triggers go-back-n behavior, so we see the spurious
retransmits from there on.

The most notable bad segment is this one:
18:20:46.800063 IP 75.236.145.7.443 > 91.216.86.7.56064: Flags [.],
ack 3171368, win 32716, options [nop,nop,sack 1 {3171368:3177208}],
length 0
It contains a SACK block contiguous with the acked seqno.  There is
some other strangeness just before that, where the SACK block shrinks
then grows again.

One other thing that jumped out at me is there is no actual loss, just
reordering.

  -John

On Mon, Mar 3, 2014 at 7:29 PM, Rick Jones <rick.jones2@hp.com> wrote:
> I've been looking at some packet traces of an application looking to upload
> a Large Quantity (tm) of data to a server across the Big Bad Internet (tm).
> They've been Linux senders, and the destination while supporting SACK and
> window scaling does not support TCP timestamps. (TCP timestamp support was
> requested of the supplier of said server many many months ago now.)
>
> This destination system has been issuing RSTs at seemingly random points in
> the middle of a large fraction of the attempted transfers.  In looking at
> the traces, they all seem to be variations on the theme of what is shown by:
>
> ftp://netperf.org/retrans_question/for_netdev.png
>
> which is a passing of ftp://netperf.org/retrans_question/for_netdev.pcap
> through tcptrace -nG and zoomed-in to the end.  I've seen this with a 3.2.0
> kernel as the sender, have reports of it happening with whatever is in
> Fedora Core 20, and the traces above are from a 3.11.0 kernel as the sender.
>
> The large quantity of (likely) unnecessary retransmissions shouldn't be
> triggering a RST by the receiver, but the failures consistently show that
> and I was wondering if the (spurious) retransmissions were perhaps
> "encouraged" (so to speak) by the lack of TCP Timestamps.
>
> happy benchmarking,
>
> rick jones
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
