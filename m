From: Tom Herbert <therbert@google.com>
Subject: Re: [PATCH RFC]: soreuseport: Bind multiple sockets to same port
Date: Mon, 19 Apr 2010 08:38:18 -0700
Message-ID: <m2z65634d661004190838hd16ab01dpa074ce6aeb3572e8@mail.gmail.com>
References: <alpine.DEB.1.00.1004182321480.1822@pokey.mtv.corp.google.com>
	 <1271662103.16881.7300.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([216.239.44.51]:13272 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751853Ab0DSPiY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Apr 2010 11:38:24 -0400
Received: from hpaq13.eem.corp.google.com (hpaq13.eem.corp.google.com [10.3.21.13])
	by smtp-out.google.com with ESMTP id o3JFcLUP023204
	for <netdev@vger.kernel.org>; Mon, 19 Apr 2010 08:38:23 -0700
Received: from pvg16 (pvg16.prod.google.com [10.241.210.144])
	by hpaq13.eem.corp.google.com with ESMTP id o3JFcJNK010219
	for <netdev@vger.kernel.org>; Mon, 19 Apr 2010 17:38:20 +0200
Received: by pvg16 with SMTP id 16so3173697pvg.12
        for <netdev@vger.kernel.org>; Mon, 19 Apr 2010 08:38:19 -0700 (PDT)
In-Reply-To: <1271662103.16881.7300.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> High perf DNS server on such machine would have 16 threads, and probably
> 64 threads in two years.
>
> I understand you want 16 UDP sockets to avoid lock contention, but
> __udp4_lib_lookup() becomes a nightmare (It may already be ...)
>
Calling it a nightmare be be a little strong.  It is true that this
could create long chains that need to be walked, but this might be
done with good cache locality of the structures.  In any case, the
lock contention seems to overshadow the cost of this; we were able to
increase max number of DNS queries/sec by about 60% (I will try to
publish some numbers this week).

> My idea was to add a cpu lookup key.
>
> thread0 would use a new setsockopt() option to bind a socket to a
> virtual cpu0. Then do its normal bind( port=53)
>
I agree that CPU awareness is desirable, but I'm really hesitant to
resort to pinning; this can become pretty tangled on a shared server
running a bunch of different applications-- would be nice if the
kernel can just figure out the right thing to do :-)

> ...
>
> threadN would use a new setsockopt() option to bind a socket to a
> virtual cpuN. Then do its normal bind( port=53)
>
> Each thread then do its normal worker loop.
>
> Then, when receiving a frame on cpuN, we would automatically select the
> right socket because its score is higher than others.
>
>
> Another possibility would be to extend socket structure to be able to
> have a dynamically sized queues/locks.
>
>
>
>
