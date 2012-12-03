From: Krzysztof Mazur <krzysiek@podlesie.net>
Subject: Re: [PATCH] atm: introduce vcc_pop_skb()
Date: Mon, 3 Dec 2012 21:11:18 +0100
Message-ID: <20121203201118.GB19460@shrek.podlesie.net>
References: <20121127173906.GA11390@shrek.podlesie.net>
 <1354039349.2534.11.camel@shinybook.infradead.org>
 <20121127182843.GA11597@shrek.podlesie.net>
 <20121128201837.GA912@shrek.podlesie.net>
 <20121128162001.3f326720@thirdoffive.cmf.nrl.navy.mil>
 <20121128214533.GA25486@shrek.podlesie.net>
 <20121128165906.05ef5e2b@thirdoffive.cmf.nrl.navy.mil>
 <20121128221040.GA24035@shrek.podlesie.net>
 <20121128223300.GA12527@shrek.podlesie.net>
 <1354540961.24281.82.camel@shinybook.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: chas williams - CONTRACTOR <chas@cmf.nrl.navy.mil>,
	davem@davemloft.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: David Woodhouse <dwmw2@infradead.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1354540961.24281.82.camel@shinybook.infradead.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Dec 03, 2012 at 01:22:41PM +0000, David Woodhouse wrote:
> On Wed, 2012-11-28 at 23:33 +0100, Krzysztof Mazur wrote:
> > 
> > Many ATM drivers store vcc in ATM_SKB(skb)->vcc and use it for
> > freeing skbs. Now they can just use atm_pop_skb() to free such
> > buffers.
> > 
> > Signed-off-by: Krzysztof Mazur <krzysiek@podlesie.net>
> 
> Note that this one didn't make it into the tree that Dave just pulled.
> 
> Not that I didn't think it was a good idea, but it was just separate
> from the other "real" fixes ??? and the tree had already grown into a big
> enough pile from your original single patch!

That patch is a preparation of separate series. The current version
(far from final version) is available at:

git://git.podlesie.net/km/linux.git atm-pop

and

http://git.podlesie.net/gitweb.cgi?p=km/linux.git;a=shortlog;h=refs/heads/atm-pop

Patch 3 and especially patch 4 are far from being ready. They are also ugly
because many ATM drivers use strange coding style and I tried to use that
style because using different style for new code would be probably be even worse.

Currently there are 4 patches:
      atm: introduce vcc_pop()
      atm: introduce vcc_pop_skb()
      atm: convert drivers to use vcc_pop*()
      atm: add missing vcc_pop*() calls in drivers

The first two introduce two helpers vcc_pop() and vcc_pop_skb(). The third
should be 1:1 conversion of vcc->pop() users to vcc_pop*() interface.
The forth patch fixes some problems I've found. In all cases the bugs
occurs in error handling code, in most cases dev_kfree_skb() is used
instead of vcc_pop(), in some cases driver just returns some error
code and skb is never freed, in two cases I removed the vcc->pop()
call in code like:

static int eni_send(struct atm_vcc *vcc,struct sk_buff *skb)
{
	[...]
	if (!skb) {
		printk(KERN_CRIT "!skb in eni_send ?\n");
		if (vcc->pop) vcc->pop(vcc,skb);
		return -EINVAL;
	}

I don't think that we should check for !skb and even if skb == NULL
it's not a good idea to call vcc->pop() because it will crash.

Current diffstat:
 drivers/atm/adummy.c     |  5 +---
 drivers/atm/ambassador.c | 34 ++++++++++++++--------------
 drivers/atm/atmtcp.c     | 15 ++++--------
 drivers/atm/eni.c        | 11 ++++-----
 drivers/atm/firestream.c | 19 ++--------------
 drivers/atm/fore200e.c   | 23 ++++---------------
 drivers/atm/he.c         | 33 ++++++---------------------
 drivers/atm/horizon.c    | 31 +++++++++----------------
 drivers/atm/idt77252.c   | 32 +++++++-------------------
 drivers/atm/iphase.c     | 59 +++++++++++++-----------------------------------
 drivers/atm/lanai.c      | 18 ++++-----------
 drivers/atm/nicstar.c    | 31 ++++++++-----------------
 drivers/atm/solos-pci.c  |  5 +---
 drivers/atm/zatm.c       | 13 ++++-------
 drivers/usb/atm/usbatm.c | 17 ++++----------
 include/linux/atmdev.h   | 16 +++++++++++++
 net/atm/common.c         | 15 ++++++++++++
 17 files changed, 128 insertions(+), 249 deletions(-)

> 
> In <20121006154606.GA25588@shrek.podlesie.net> you posted another patch:
> > I think there is another problem here. The pppoatm gets a reference
> > to atmvcc, but I don't see anything that protects against removal
> > of that vcc.
> > 
> > The vcc uses vcc->sk socket for reference counting, so sock_hold()
> > and sock_put() should be used by pppoatm.
> 
> That one I think *isn't* needed, because we have properly fixed the
> races with vcc_destroy_socket(). I just wanted to check you agree...?
> 

It was never really needed, I removed it from v3.

Thanks,

Krzysiek
