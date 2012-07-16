From: Rick Jones <rick.jones2@hp.com>
Subject: Re: [PATCH] mlx4_en: map entire pages to increase throughput
Date: Mon, 16 Jul 2012 10:27:57 -0700
Message-ID: <50044F1D.6000703@hp.com>
References: <1342458113-10384-1-git-send-email-cascardo@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"yevgenyp@mellanox.co.il" <yevgenyp@mellanox.co.il>,
	"ogerlitz@mellanox.com" <ogerlitz@mellanox.com>,
	"amirv@mellanox.com" <amirv@mellanox.com>,
	"brking@linux.vnet.ibm.com" <brking@linux.vnet.ibm.com>,
	"leitao@linux.vnet.ibm.com" <leitao@linux.vnet.ibm.com>,
	"klebers@linux.vnet.ibm.com" <klebers@linux.vnet.ibm.com>
To: Thadeu Lima de Souza Cascardo <cascardo@linux.vnet.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g4t0014.houston.hp.com ([15.201.24.17]:44341 "EHLO
	g4t0014.houston.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753180Ab2GPR2D (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Jul 2012 13:28:03 -0400
In-Reply-To: <1342458113-10384-1-git-send-email-cascardo@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/16/2012 10:01 AM, Thadeu Lima de Souza Cascardo wrote:
> In its receive path, mlx4_en driver maps each page chunk that it pushes
> to the hardware and unmaps it when pushing it up the stack. This limits
> throughput to about 3Gbps on a Power7 8-core machine.

That seems rather extraordinarily low - Power7 is supposed to be a 
rather high performance CPU.  The last time I noticed O(3Gbit/s) on 10G 
for bulk transfer was before the advent of LRO/GRO - that was in the x86 
space though.  Is mapping really that expensive with Power7?


> One solution is to map the entire allocated page at once. However, this
> requires that we keep track of every page fragment we give to a
> descriptor. We also need to work with the discipline that all fragments will
> be released (in the sense that it will not be reused by the driver
> anymore) in the order they are allocated to the driver.
>
> This requires that we don't reuse any fragments, every single one of
> them must be reallocated. We do that by releasing all the fragments that
> are processed and only after finished processing the descriptors, we
> start the refill.
>
> We also must somehow guarantee that we either refill all fragments in a
> descriptor or none at all, without resorting to giving up a page
> fragment that we would have already given. Otherwise, we would break the
> discipline of only releasing the fragments in the order they were
> allocated.
>
> This has passed page allocation fault injections (restricted to the
> driver by using required-start and required-end) and device hotplug
> while 16 TCP streams were able to deliver more than 9Gbps.

What is the effect on packet-per-second performance?  (eg aggregate, 
burst-mode netperf TCP_RR with TCP_NODELAY set or perhaps UDP_RR)

rick jones
