From: Tom Herbert <therbert@google.com>
Subject: Re: [PATCH] Software receive packet steering
Date: Wed, 22 Apr 2009 08:46:13 -0700
Message-ID: <65634d660904220846h3bbd35a7n5269f6d23db6cea4@mail.gmail.com>
References: <49ED967B.4070105@cosmosbay.com> <20090421084636.198b181e@nehalam>
	 <65634d660904211152l6c17aa6dpf7e626474acfe499@mail.gmail.com>
	 <20090422.022120.211323498.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: shemminger@vyatta.com, dada1@cosmosbay.com, andi@firstfloor.org,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([216.239.33.17]:9891 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752449AbZDVPqT convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Apr 2009 11:46:19 -0400
Received: from spaceape8.eur.corp.google.com (spaceape8.eur.corp.google.com [172.28.16.142])
	by smtp-out.google.com with ESMTP id n3MFkGjl005503
	for <netdev@vger.kernel.org>; Wed, 22 Apr 2009 16:46:16 +0100
Received: from wf-out-1314.google.com (wfc25.prod.google.com [10.142.3.25])
	by spaceape8.eur.corp.google.com with ESMTP id n3MFkD4w009097
	for <netdev@vger.kernel.org>; Wed, 22 Apr 2009 08:46:14 -0700
Received: by wf-out-1314.google.com with SMTP id 25so32214wfc.22
        for <netdev@vger.kernel.org>; Wed, 22 Apr 2009 08:46:13 -0700 (PDT)
In-Reply-To: <20090422.022120.211323498.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>
> There are some things I've been brainstorming about.
>
> One thought I keep coming back to is the hack the block layer
> is using right now. =A0It remembers which CPU a block I/O request
> comes in on, and it makes sure the completion runs on that
> cpu too.
>
> We could remember the cpu that the last socket level operation
> occurred upon, and use that as a target for packets. =A0This requires=
 a
> bit of work.
>
> First we'd need some kind of pre-demux at netif_receive_skb()
> time to look up the cpu target, and reference this blob from
> the socket somehow, and keep it uptodate at various specific
> locations (read/write/poll, whatever...).
>
> Or we could pre-demux the real socket. =A0That could be exciting.
>

We are doing the pre-demux, and it works well.  The additional benefit
is that the hash result or the the sk itself could be cached in the
skb for the upper layer protocol.

One caveat though is that if the device provides a hash, ie. Toeplitz,
we really want to use that in the CPU look-up to avoid the cache miss
on the header.  We considered using the Toeplitz hash as the inet
hash, but it's incredibly expensive to do in software being about 20x
slower than inet_ehashfn is best we could do.  Our (naive) solution is
to maintain a big array of CPU indices where we write the CPU ids from
recvmsg and sendmsg, and then read it using the hash provided on
incoming packets.  This is lockless and allows very fast operations,
but doesn't take collisions into account (probably allows a slim
possibility of thrashing a connection between CPUs).  The other option
we considered was maintaining a secondary cnx lookup table based on
Toeplitz hash, but that seemed to be rather involved.

> But then we come back to the cpu number changing issue. =A0There is a
> cool way to handle this, because it seems that we can just keep
> queueing to the previous cpu and it can check the socket cpu cookie.
> If that changes, the old target can push the rest of it's queue to
> that cpu and then update the cpu target blob.
>
> Anyways, just some ideas.
>
Thanks for your thoughts.
