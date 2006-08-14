From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Subject: Re: [RFC][PATCH 2/9] deadlock prevention core
Date: Mon, 14 Aug 2006 06:40:53 +0200
Message-ID: <1155530453.5696.98.camel@twins>
References: <20060808211731.GR14627@postel.suug.ch>
	 <44DBED4C.6040604@redhat.com> <44DFA225.1020508@google.com>
	 <20060813.165540.56347790.davem@davemloft.net>
	 <44DFD262.5060106@google.com>  <20060813185309.928472f9.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Daniel Phillips <phillips@google.com>,
	David Miller <davem@davemloft.net>, riel@redhat.com,
	tgraf@suug.ch, linux-mm@kvack.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, Mike Christie <michaelc@cs.wisc.edu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from amsfep17-int.chello.nl ([213.46.243.15]:47593 "EHLO
	amsfep19-int.chello.nl") by vger.kernel.org with ESMTP
	id S1751332AbWHNEl7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 14 Aug 2006 00:41:59 -0400
To: Andrew Morton <akpm@osdl.org>
In-Reply-To: <20060813185309.928472f9.akpm@osdl.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, 2006-08-13 at 18:53 -0700, Andrew Morton wrote:
> On Sun, 13 Aug 2006 18:31:14 -0700
> Daniel Phillips <phillips@google.com> wrote:
> 
> > But to solve the whole problem
> 
> What problem?  Has anyone come up with a testcase which others can
> reproduce?

Problem:

Networked Block devices (NBD, iSCSI, AoE) can deadlock in the following
manner:
deplete normal memory because of memory pressure; deplete reserves by
writeout over network (pageout happens under PF_MEMALLOC), little to no
memory left for receiving those now crucial ACK packets.
A few packets could still fit in memory, but are quickly gobbled up by
non-crucial sockets and are left waiting on blocked user-space
processes. All memory is depleted and progress stalled forever.

(This affects swap and shared mmap)

Our Solution:

Mark some sockets with SOCK_MEMALLOC; which is essentially a promise to
never block. When under memory pressure only deliver packets to these
sockets, memory will still be used but never lost waiting on a blocked
user space process.

Also make sure the reserve is large enough so that writeout will never
be able to completely deplete it.

(It is here I still do not see Evgeniy's Network Tree Allocator work;
where is the guarantee that you do not end up with all memory lost
waiting on blocked sockets?)

Testcase:

Mount an NBD device as sole swap device and mmap > physical RAM, then
loop through touching pages only once.

My normal test setup is a p3-550 with 192M of ram with a 100Mbit card
and remote machine with a regular 7200 RPM pata drive.

I'm sure there is an iSCSI equivalent scenario, playing with iSCSI is
next on my list of things.

