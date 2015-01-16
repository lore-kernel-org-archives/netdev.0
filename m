From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH 7/9] rhashtable: Per bucket locks & deferred
 expansion/shrinking
Date: Fri, 16 Jan 2015 16:43:02 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D1CACADAF@AcuExch.aculab.com>
References: <cover.1418647641.git.tgraf@suug.ch>
 <75db38bc9313a55cf02a8c36a3376c32b691e5d9.1418647641.git.tgraf@suug.ch>
 <20150116153415.GF30132@acer.localdomain>
 <20150116155835.GA15052@casper.infradead.org>
 <20150116160354.GI30132@acer.localdomain>
 <20150116161530.GC15052@casper.infradead.org>
 <20150116163202.GJ30132@acer.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: "davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"kernel@vger.kernel.org" <kernel@vger.kernel.org>,
	"herbert@gondor.apana.org.au" <herbert@gondor.apana.org.au>,
	"paulmck@linux.vnet.ibm.com" <paulmck@linux.vnet.ibm.com>,
	"edumazet@google.com" <edumazet@google.com>,
	"john.r.fastabend@intel.com" <john.r.fastabend@intel.com>,
	"josh@joshtriplett.org" <josh@joshtriplett.org>,
	"netfilter-devel@vger.kernel.org" <netfilter-devel@vger.kernel.org>
To: 'Patrick McHardy' <kaber@trash.net>, Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out6.electric.net ([192.162.217.187]:61295 "EHLO
	smtp-out6.electric.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752775AbbAPQoo convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Jan 2015 11:44:44 -0500
In-Reply-To: <20150116163202.GJ30132@acer.localdomain>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Patrick McHardy
> On 16.01, Thomas Graf wrote:
> > On 01/16/15 at 04:03pm, Patrick McHardy wrote:
> > > On 16.01, Thomas Graf wrote:
> > > > A walker may not see insertions that occur after the walker was started
> > > > if resizing is enabled. Is that a problem for nftables?
> > >
> > > No, that would be Ok. The case I'm wondering about is:
> > >
> > > - insertion
> > > - resize starts
> > > - another insertion
> > > - walker, resize not finished yet
> >
> > Correct, walker may not see "another insertion". The window for this
> > behavior to occur is not the full resize operation, just the linking
> > period, but it may occur. The length of the window is typically
> > equal to a grace period.
> >
> > We can provide a synchronization function to block the dumper or the
> > insertion/removal until the linking is complete. The latter would
> > give the old runtime behaviour back (variable runtime of insert),
> > the blocked dumper might be preferred. What do you think?
> 
> If we have to block, the dumper if of course preferred. Taking the
> mutex should do fine I guess?
> 
> I suppose walking both tables without any races would be rather
> complicated.

The walker is unlikely to see items that get inserted early in the hash
table even without a resize.

I'd be more worried about the walker missing big blocks of entries or
getting duplicate entries during a resize.
This might be a problem if the walker is a user-process table dump,
in which case you can't assume it will finish in any finite time.

	David
