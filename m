From: Thadeu Lima de Souza Cascardo <cascardo@linux.vnet.ibm.com>
Subject: Re: [PATCH] mlx4_en: map entire pages to increase throughput
Date: Mon, 16 Jul 2012 16:06:12 -0300
Message-ID: <20120716190611.GA1023@oc1711230544.ibm.com>
References: <1342458113-10384-1-git-send-email-cascardo@linux.vnet.ibm.com>
 <50044F1D.6000703@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"yevgenyp@mellanox.co.il" <yevgenyp@mellanox.co.il>,
	"ogerlitz@mellanox.com" <ogerlitz@mellanox.com>,
	"amirv@mellanox.com" <amirv@mellanox.com>,
	"brking@linux.vnet.ibm.com" <brking@linux.vnet.ibm.com>,
	"leitao@linux.vnet.ibm.com" <leitao@linux.vnet.ibm.com>,
	"klebers@linux.vnet.ibm.com" <klebers@linux.vnet.ibm.com>,
	linuxppc-dev@lists.ozlabs.org, anton@samba.org
To: Rick Jones <rick.jones2@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e24smtp03.br.ibm.com ([32.104.18.24]:41333 "EHLO
	e24smtp03.br.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754200Ab2GPTGX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Jul 2012 15:06:23 -0400
Received: from /spool/local
	by e24smtp03.br.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <cascardo@linux.vnet.ibm.com>;
	Mon, 16 Jul 2012 16:06:20 -0300
Received: from d24relay03.br.ibm.com (d24relay03.br.ibm.com [9.13.184.25])
	by d24dlp01.br.ibm.com (Postfix) with ESMTP id B01A53520050
	for <netdev@vger.kernel.org>; Mon, 16 Jul 2012 15:06:14 -0400 (EDT)
Received: from d24av04.br.ibm.com (d24av04.br.ibm.com [9.8.31.97])
	by d24relay03.br.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q6GJ5Wtp22937818
	for <netdev@vger.kernel.org>; Mon, 16 Jul 2012 16:05:32 -0300
Received: from d24av04.br.ibm.com (loopback [127.0.0.1])
	by d24av04.br.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q6GH641Y001527
	for <netdev@vger.kernel.org>; Mon, 16 Jul 2012 14:06:05 -0300
Content-Disposition: inline
In-Reply-To: <50044F1D.6000703@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jul 16, 2012 at 10:27:57AM -0700, Rick Jones wrote:
> On 07/16/2012 10:01 AM, Thadeu Lima de Souza Cascardo wrote:
> >In its receive path, mlx4_en driver maps each page chunk that it pushes
> >to the hardware and unmaps it when pushing it up the stack. This limits
> >throughput to about 3Gbps on a Power7 8-core machine.
> 
> That seems rather extraordinarily low - Power7 is supposed to be a
> rather high performance CPU.  The last time I noticed O(3Gbit/s) on
> 10G for bulk transfer was before the advent of LRO/GRO - that was in
> the x86 space though.  Is mapping really that expensive with Power7?
> 

Copying linuxppc-dev and Anton here. But I can tell you that we have
lock contention when doing the mapping on the same adapter (map table
per device). Anton has sent some patches that improves that *a lot*.

However, for 1500 MTU, mlx4_en was doing two unmaps and two maps per
packet. The problem is not the CPU power needed to do the mappings, but
that we find the lock contention and end up with the CPUs more than 30%
of the time spent on spin locking.

> 
> >One solution is to map the entire allocated page at once. However, this
> >requires that we keep track of every page fragment we give to a
> >descriptor. We also need to work with the discipline that all fragments will
> >be released (in the sense that it will not be reused by the driver
> >anymore) in the order they are allocated to the driver.
> >
> >This requires that we don't reuse any fragments, every single one of
> >them must be reallocated. We do that by releasing all the fragments that
> >are processed and only after finished processing the descriptors, we
> >start the refill.
> >
> >We also must somehow guarantee that we either refill all fragments in a
> >descriptor or none at all, without resorting to giving up a page
> >fragment that we would have already given. Otherwise, we would break the
> >discipline of only releasing the fragments in the order they were
> >allocated.
> >
> >This has passed page allocation fault injections (restricted to the
> >driver by using required-start and required-end) and device hotplug
> >while 16 TCP streams were able to deliver more than 9Gbps.
> 
> What is the effect on packet-per-second performance?  (eg aggregate,
> burst-mode netperf TCP_RR with TCP_NODELAY set or perhaps UDP_RR)
> 

I used uperf with TCP_NODELAY and 16 threads sending from another
machine 64000-sized writes for 60 seconds.

I get 5898op/s (3.02Gb/s) without the patch against 18022ops/s
(9.23Gb/s) with the patch.

Best regards.
Cascardo.


> rick jones
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
