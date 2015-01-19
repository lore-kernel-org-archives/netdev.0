From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH 7/9] rhashtable: Per bucket locks & deferred
 expansion/shrinking
Date: Mon, 19 Jan 2015 12:58:13 +0000
Message-ID: <20150119125813.GA7672@casper.infradead.org>
References: <20150116163202.GJ30132@acer.localdomain>
 <063D6719AE5E284EB5DD2968C1650D6D1CACADAF@AcuExch.aculab.com>
 <20150116165302.GE15052@casper.infradead.org>
 <20150116183626.GS30132@acer.localdomain>
 <20150116191831.GA26730@casper.infradead.org>
 <20150116193557.GU30132@acer.localdomain>
 <20150116213605.GE20315@casper.infradead.org>
 <20150116220735.GA12614@acer.localdomain>
 <20150116233414.GF20315@casper.infradead.org>
 <20150117080255.GA3968@acer.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Laight <David.Laight@ACULAB.COM>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"herbert@gondor.apana.org.au" <herbert@gondor.apana.org.au>,
	"paulmck@linux.vnet.ibm.com" <paulmck@linux.vnet.ibm.com>,
	"edumazet@google.com" <edumazet@google.com>,
	"john.r.fastabend@intel.com" <john.r.fastabend@intel.com>,
	"josh@joshtriplett.org" <josh@joshtriplett.org>,
	"netfilter-devel@vger.kernel.org" <netfilter-devel@vger.kernel.org>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:55494 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751976AbbASM6T (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Jan 2015 07:58:19 -0500
Content-Disposition: inline
In-Reply-To: <20150117080255.GA3968@acer.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/17/15 at 08:02am, Patrick McHardy wrote:
> On 16.01, Thomas Graf wrote:
> > Resize operations should be *really* rare as well unless you start
> > with really small hash table sizes and constantly add/remove at the
> > watermark.
> 
> Which are far enough from each other that this should only happen
> in really unlucky cases.
> 
> > Re-dumping on insert/remove is a different story of course. Do you
> > care about missed insert/removals for dumps? If not we can do the
> > sequence number consistency checking for resizing only.
> 
> No, that has always been undeterministic with netlink. We want to
> dump everything that was present when the dump was started and is
> still present when it finishes. Anything else can be handled using
> notifications.

It looks like we want to provide two ways to resolve this:

1) Walker holds ht->mutex the entire time to block out resizes.
   Optionally the walker can acquire all bucket locks. Such
   scenarios would seem to benefit from either a single or a very
   small number of bucket locks.

2) Walker holds ht->mutex during individual Netlink message
   construction periods and relases it while user space reads the
   message. rhashtable provides a hook which is called when a
   resize operation is scheduled allowing for the walker code to
   bump a sequence number and notify user space that the dump is
   inconsistent, causing it to request a new dump.

I'll provide an API to achieve (2). (1) is already achieveable with
the current API.
