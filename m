From: Jeff Garzik <jeff@garzik.org>
Subject: Re: RFR: New e1000 driver (e1000new), was: Re: e1000: backport ich9
 support from 7.5.5 ?
Date: Fri, 06 Jul 2007 15:07:36 -0400
Message-ID: <468E92F8.7010501@garzik.org>
References: <1183138159.17243.16.camel@blaa>	<20070629175006.GB3917@falooley.org>	<468571C6.3090305@garzik.org>	<46857C08.4030303@intel.com> <20070629150350.414553d4.akpm@linux-foundation.org> <4685838D.9080108@garzik.org> <468594B7.6070309@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>,
	Jason Lunz <lunz@reflexsecurity.com>,
	Mark McLoughlin <markmc@redhat.com>,
	e1000-devel@lists.sourceforge.net,
	Arjan van de Ven <arjan@linux.intel.com>,
	"Ronciak, John" <john.ronciak@intel.com>
To: "Kok, Auke" <auke-jan.h.kok@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:58365 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1762234AbXGFTHn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 6 Jul 2007 15:07:43 -0400
In-Reply-To: <468594B7.6070309@intel.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

OK, just looked through the driver.  I think its structured inside-out 
from what it should be.

Comments:

* is a clear improvement from current e1000

* The multitude of tiny, fine-grained operations for MAC, NVM, PHY, etc. 
is a signal that organization is backwards.  You should be creating 
hardware-specific high level operations (PHY layer hooks, net_device 
hooks, interrupt handler) that call out to more-generic functions when 
necessary.  Doing so eliminates the need to create a new hook for every 
little twirl in the code path.

In the long run, a driver is easier to maintain if you can easily follow 
the code path for a particular hardware generation.  Creating 
e1001_8257x_do_this_thing(), which calls more generic code as needed, is 
easier to review and doesn't require all sorts of indirection through APIs.

Doing so also means that many workarounds for older hardware "disappear" 
from the most-travelled code paths over time.  The 64k boundary check 
found in e1000new is an easy example of something that really shouldn't 
pollute newer code at all [yes, even though it reduces to 'return 1' for 
most].

* The multitude of files makes it difficult to review.  Much easier in 
one file, or a small few.

* bitfields

* check for PCI DMA mapping failure

* atomic_t irq_sem is reinventing the wheel (and too heavy for you 
needs, too?).  You might as well use a lock or mutex or whatnot at that 
point, since you are using a locked instruction.  tg3 might also have 
some hints in this regard.

* like I noted in the last email, the quickest path to upstream is to 
start SMALL.  Create the smallest working driver, review it heavily, get 
it upstream.  Add all hardware&features after that.


