From: David Howells <dhowells@redhat.com>
Subject: Re: [RFC] myri10ge: small rx_done refactoring
Date: Thu, 24 Mar 2011 17:29:06 +0000
Message-ID: <25658.1300987746@redhat.com>
References: <20110324155937.GA6041@redhat.com> <20110323124939.GA7834@redhat.com> <20110323083357.457f10aa@nehalam> <20110324081621.GA5508@redhat.com> <20110324081539.47ad0972@nehalam>
Cc: dhowells@redhat.com, Stephen Hemminger <shemminger@vyatta.com>,
	netdev@vger.kernel.org, Andrew Gallatin <gallatin@myri.com>,
	Brice Goglin <brice@myri.com>
To: Stanislaw Gruszka <sgruszka@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:34925 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750748Ab1CXR3V (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 24 Mar 2011 13:29:21 -0400
In-Reply-To: <20110324155937.GA6041@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Stanislaw Gruszka <sgruszka@redhat.com> wrote:

> David, can you confirm that Staphen is correct?

Stephen is correct.  The compiler is perfectly at liberty to merge the two
loads if the value being read is not marked volatile.

If you stick a barrier() in there between the reads, then I think the compiler
will be required to emit two load instructions.  However, the _CPU_ is then
entitled to merge them.

If you don't want the CPU to merge them, you have to use smp_rmb() or smp_mb()
between.

However, the compiler is also allowed to re-read the variable (ie. emit two
load instructions) if it would otherwise have to save the value on the stack
to free up a register, unless the pointed to value is marked volatile.

If you want to ensure that the value is read once only, then you need to use
ACCESS_ONCE() or stick a read/full barrier of some degree after the read.

Note the use of a barrier implies a partial ordering between two memory
accesses in the same instruction stream.  If you can't say which two memory
memory accesses you want to order, you probably shouldn't be using a barrier.

David
