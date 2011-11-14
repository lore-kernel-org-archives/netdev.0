From: Neal Cardwell <ncardwell@google.com>
Subject: Re: [PATCH] tcp: fixes for DSACK-based undo of cwnd reduction during
 fast recovery
Date: Mon, 14 Nov 2011 18:03:37 -0500
Message-ID: <CADVnQyn7czRocYV3-goTtwqCDg9MBv+bTHeZ-A8R4n45LH8L=g@mail.gmail.com>
References: <1320775631-16341-1-git-send-email-ncardwell@google.com>
	<20111114.152359.1131974895743731960.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, ilpo.jarvinen@helsinki.fi,
	nanditad@google.com, ycheng@google.com, therbert@google.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f46.google.com ([209.85.213.46]:45727 "EHLO
	mail-yw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753559Ab1KNXDi convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Nov 2011 18:03:38 -0500
Received: by ywt32 with SMTP id 32so2749774ywt.19
        for <netdev@vger.kernel.org>; Mon, 14 Nov 2011 15:03:38 -0800 (PST)
In-Reply-To: <20111114.152359.1131974895743731960.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Nov 14, 2011 at 3:23 PM, David Miller <davem@davemloft.net> wro=
te:
> From: Neal Cardwell <ncardwell@google.com>
> Date: Tue, =A08 Nov 2011 13:07:11 -0500
>
>> (2) When the ACK field is below snd_una (the "old_ack" goto label),
>> process any DSACKs and try to send out more packets based on
>> newly-SACKed packets.
>
> This seems dubious.
>
> An older ACK should not have more uptodate SACK information than a ne=
wer
> ACK.
>

I grant that it is a rare corner case, but it is possible if there is
reordering and packet loss in both directions.

In fact, AFAICT the code path to handle this corner case is already
there: AFAICT we call tcp_sacktag_write_queue() in the old_ack code
path exactly because it is possible for old ACKs to carry SACK ranges
that we haven't seen yet. If this is not possible then it seems we
should remove the old_ack code path.

Let me try to lay out a specific example:

Suppose a sender sends packets 1-12, and there is lots of loss and
reordering in both directions.

Suppose the receiver sends the following ACKs with SACK blocks, in the
following order (using packet numbers rather than sequence numbers):

(1) ack 1, sack <3-4>
(2) ack 1, sack <3-4 6>
(3) ack 1, sack <3-4 6 8>
(4) ack 1, sack <3-4 6 8 10>
(5) ack 1, sack <6 8 10 12>
(6) ack 2, sack <6 8 10 12>

Note that starting at ACK (5) the receiver is limited by the fact that
TCP options can only hold 4 SACK ranges, so the SACK for 3-4 "falls
off" the SACK block set.

Now suppose the ACKs are reordered, and some are dropped, so that the
sender receives the ACKs in this order:

(6) ack 2, sack <6 8 10 12>
(1) ack 1, sack <3-4>

The arrival of (6) advances snd_una to 2. Now the question is what to
do when (1), with an ACK field below snd_una, arrives at the
sender. The existing code tags packets 3-4 as SACKed, but does not use
this newly SACK-tagged data to send out new data. This commit proposes
to use the newly SACK-tagged 3-4 to send out new data.

neal
