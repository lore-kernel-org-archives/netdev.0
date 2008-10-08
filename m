From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: Possible regression in HTB
Date: Wed, 8 Oct 2008 12:04:05 +0000
Message-ID: <20081008120405.GA10425@ff.dom.local>
References: <48EB5A92.6010704@trash.net> <20081007220022.GA2664@ami.dom.local> <20081008002153.GL12021@verge.net.au> <48EBFF5E.1090902@trash.net> <48EC0190.7040804@trash.net> <48EC6286.1030202@cdi.cz> <20081008085325.GF4174@ff.dom.local> <48EC8FDD.5030507@cdi.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Patrick McHardy <kaber@trash.net>,
	Simon Horman <horms@verge.net.au>, netdev@vger.kernel.org,
	David Miller <davem@davemloft.net>
To: Martin Devera <devik@cdi.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ey-out-2122.google.com ([74.125.78.24]:9634 "EHLO
	ey-out-2122.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750821AbYJHMEN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Oct 2008 08:04:13 -0400
Received: by ey-out-2122.google.com with SMTP id 6so1214845eyi.37
        for <netdev@vger.kernel.org>; Wed, 08 Oct 2008 05:04:11 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <48EC8FDD.5030507@cdi.cz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Oct 08, 2008 at 12:47:57PM +0200, Martin Devera wrote:
...
>>> Thus, from qdisc point, it is not good to keep a packet for
>>> more time out of the qdisc.
>>
>> Sure, the question is how much it's useful against associated
>> code complications and additional cpu usage.
>
> honestly, I'm not familiar with the new code. Can you tell me
> in short what is gso_skb and where the skb goes now if not requeued ?

I hope I don't mislead you too much: gso_skb is actually a list of
skbs after dividing a previous skb in dev_gso_segment() in
dev_hard_start_xmit(), which because of some device/driver error
gets back to qdisc_run()/ qdisc_restart(). It's stored as q->gso_skb
and tried for next xmits before any new dequeuing until sending.

And currently, "normal" skbs are treated exactly the same (so not
returned to the qdisc tree). There is still possible internal use of
old ->requeue() functions between qdiscs for some strange cases, but
it will be probably replaced too with storing to the q->requeue lists
(one level deep). So both these cases could be treated as: an skb is
out of the qdiscs, one foot in the driver's door (probably because of
some errors - otherwise driver should stop the queue earlier).

This is supposed to simplify the code, especially error handling,
especially wrt. multiqueuing.

Cheers,
Jarek P.
