From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH 3/3] netlink: Lock out table resizes while dumping
 Netlink sockets
Date: Wed, 21 Jan 2015 10:36:48 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D1CACFFEA@AcuExch.aculab.com>
References: <cover.1421759056.git.tgraf@suug.ch>
 <e164edeacaeffee43be64d4ed6a5b5e7e8923bd1.1421759056.git.tgraf@suug.ch>
 <20150120143154.GR14883@acer.localdomain>
 <20150120145551.GH20315@casper.infradead.org>
 <20150120152149.GA3012@acer.localdomain>
 <20150120153556.GJ20315@casper.infradead.org>
 <20150121050819.GA23062@gondor.apana.org.au>
 <20150121093722.GM20315@casper.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: Patrick McHardy <kaber@trash.net>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"paulmck@linux.vnet.ibm.com" <paulmck@linux.vnet.ibm.com>,
	"ying.xue@windriver.com" <ying.xue@windriver.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"netfilter-devel@vger.kernel.org" <netfilter-devel@vger.kernel.org>
To: 'Thomas Graf' <tgraf@suug.ch>,
	Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20150121093722.GM20315@casper.infradead.org>
Content-Language: en-US
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Thomas Graf
> On 01/21/15 at 04:08pm, Herbert Xu wrote:
...
> > Essentially I need a bit to indicate an entry in the bucket chain
> > should be skipped, either because it has just been removed or that
> > it is a walker entry (see xfrm_state_walk).
> >
> > The way it'll work then is exactly the same as xfrm_state_walk,
> > except that the linked list is broken up into individual buckets.
> >
> > Of course we'll still need to postpone resizes (and rehashes which
> > is what my work is about) during a walk but I think that's a fair
> > price to pay.
> 
> If I understand this correctly we also need to block out parallel
> walkers and we need to start taking bucket locks while walking to
> modify the walker mark bit in peace.

Running 'walker | grep foo | less' really shouldn't stop any activity,
including further requests by the same person to dump the same table in a
different window.
I would also expect the above request to be able to continue correctly
when restarted hours later (unless something unusual - like a resize -
happens).

Suppressing 'table shrink' because you think a walker might be active
if probably a good idea, and just requires a timestamp of the last
walk action.

Thought...
It is possible to break walking only on hash chain boundaries?
At least in the case where the response buffer is large enough
for a full 'chain' of entries.

Also what happens if there is a page fault on any userpage?
You don't want to be holding a mutex.

	David


