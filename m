From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: Machine Check Exception Re: NetDev! Please help!
Date: Tue, 23 Sep 2008 09:25:04 +0000
Message-ID: <20080923092504.GB4692@ff.dom.local>
References: <48D4F85C.8090709@bigtelecom.ru> <200809202111.01256.denys@visp.net.lb> <48D67239.9040006@gmail.com> <48D7385D.40107@bigtelecom.ru> <20080922065339.GA4399@ff.dom.local> <48D76813.9000603@bigtelecom.ru> <20080922112452.GB5314@ff.dom.local> <48D79709.80400@bigtelecom.ru> <20080922172349.GA2545@ami.dom.local> <48D89E0C.9040407@bigtelecom.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Denys Fedoryshchenko <denys@visp.net.lb>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Badalian Vyacheslav <slavon@bigtelecom.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.153]:10763 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750806AbYIWJZL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Sep 2008 05:25:11 -0400
Received: by fg-out-1718.google.com with SMTP id 19so1669084fgg.17
        for <netdev@vger.kernel.org>; Tue, 23 Sep 2008 02:25:09 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <48D89E0C.9040407@bigtelecom.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Sep 23, 2008 at 11:43:08AM +0400, Badalian Vyacheslav wrote:
> Hello
> 
> I stop eth1 and eth0 and run "emegre portage" and get exception. Now i
> think its not problem in network part.
> 
> I miss situation in 2.6.27 about multiqueue and traffic shaper because i
> was have many work and was can't read all netdev list =(
> As i understand 2.6.27-rc have support multiqueue, but how it will work
> with HTB/SFQ?
> Is tc rules must have in 2.6.27 one root queue (and all queue go to this
> tree) or need to do many qdiscs and settings it to device queues (i was
> read some about queue2band)?
> If it is simple for you - can  you sort describe this part of changes?

There are two main cases:

1) The default qdiscs (created while activating a new net device):
depending on a driver (most drivers are still uniqueue), there are
created independent pfifo_fast_qdiscs for each supported tx queue;
if a driver doesn't change this, packets are directed to them
automatically, according to some hash function, which tries to
separate different flows. This should be the fastest solution because
there are separate qdisc and transmit locks, which could be taken by
different cpus at the same time.

2) Non-default qdiscs (any qdiscs added with tc): there is only one
root qdisc (with its tree) as before, dequeued to all tx queues (if
available). Since there is only one qdisc lock, and additional flag
preventing other processes to run the qdisc at the same time, there
is not so much advantage of SMP, except on tx locking. All previous
tc configs should work without changes (except sch_prio and sch_rr
used for multiqueuing, replaced by sch_multiq and act_skbedit now).
Probably in some cases adding sch_multiq to a tree for separating
qdisc queues per tx queues could be useful.

Cheers,
Jarek P.
