From: "David Laight" <David.Laight@ACULAB.COM>
Subject: RE: [PATCH] l2tp: synchronise u64 stats writer callsites
Date: Thu, 21 Jun 2012 16:18:12 +0100
Message-ID: <AE90C24D6B3A694183C094C60CF0A2F6026B6F5D@saturn3.aculab.com>
References: <1340291054-16077-1-git-send-email-tparkin@katalix.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "James Chapman" <jchapman@katalix.com>
To: "Tom Parkin" <tparkin@katalix.com>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:49507 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1759320Ab2FUPT3 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Jun 2012 11:19:29 -0400
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 27664-03 for <netdev@vger.kernel.org>;
 Thu, 21 Jun 2012 16:19:22 +0100 (BST)
Content-class: urn:content-classes:message
In-Reply-To: <1340291054-16077-1-git-send-email-tparkin@katalix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

 
> Subject: [PATCH] l2tp: synchronise u64 stats writer callsites
> 
> Fix statistics update race in l2tp_core.  As described in
> include/linux/u64_stats_sync.h, it is necessary for the writers of
> u64 statistics to ensure mutual exclusion to the seqcount for
> statistics synchronisation.  Failure to do so may result in a
> missed seqcount update, leaving readers blocking forever.
...
> +			spin_lock_bh(&sstats->writelock);
>  			u64_stats_update_begin(&sstats->syncp);
>  			sstats->rx_oos_packets++;
>  			u64_stats_update_end(&sstats->syncp);
> +			spin_unlock_bh(&sstats->writelock);

The purpose of the u64_stats_update_begin/end is to
perform lockless writes of the stats.
If you need to lock them (because multiple threads can
be writing to stats covered by the same 'syncp' at the
same time) then the reader might as well use the same lock.

Otherwise split the 'syncp' such that only one update
can be happening (for each sync).

	David
