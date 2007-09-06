From: Randy Dunlap <randy.dunlap@oracle.com>
Subject: Re: [PATCH][MIPS][7/7] AR7: ethernet
Date: Thu, 6 Sep 2007 16:04:57 -0700
Message-ID: <20070906160457.8cb0cc1b.randy.dunlap@oracle.com>
References: <200708201704.11529.technoboy85@gmail.com>
	<200709061734.11170.technoboy85@gmail.com>
	<20070906153025.7cb71cb1.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Matteo Croce <technoboy85@gmail.com>, linux-mips@linux-mips.org,
	ejka@imfi.kspu.ru, jgarzik@pobox.com, netdev@vger.kernel.org,
	davem@davemloft.net, kuznet@ms2.inr.ac.ru, pekkas@netcore.fi,
	jmorris@namei.org, yoshfuji@linux-ipv6.org, kaber@coreworks.de
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <linux-mips-bounce@linux-mips.org>
In-Reply-To: <20070906153025.7cb71cb1.akpm@linux-foundation.org>
Sender: linux-mips-bounce@linux-mips.org
Errors-to: linux-mips-bounce@linux-mips.org
List-Id: netdev.vger.kernel.org

On Thu, 6 Sep 2007 15:30:25 -0700 Andrew Morton wrote:

> > On Thu, 6 Sep 2007 17:34:10 +0200 Matteo Croce <technoboy85@gmail.com> wrote:
> > Driver for the cpmac 100M ethernet driver.
> > It works fine disabling napi support, enabling it gives a kernel panic
> > when the first IPv6 packet has to be forwarded.
> > Other than that works fine.
> > 
> 
> I'm not too sure why I got cc'ed on this (and not on patches 1-6?) but
> whatever.
> 
> This patch introduces quite a number of basic coding-style mistakes. 
> Please run it through scripts/checkpatch.pl and review the output.
> 
> The patch introduces vast number of volatile structure fields.  Please see
> Documentation/volatile-considered-harmful.txt.
> 
> The patch inroduces a modest number of unneeded (and undesirable) casts of
> void*, such as
> 
> +	struct cpmac_mdio_regs *regs = (struct cpmac_mdio_regs *)bus->priv;
> 
> please check for those and fix them up.
> 
> The driver implements a driver-private skb pool.  I don't know if this is
> something which we like net drivers doing?  If it is approved then surely
> there should be a common implementation for it somewhere?
> 
> The driver does a lot of open-coded dma_cache_inv() calls (in a way which
> assumes a 32-bit bus, too).  I assume that dma_cache_inv() is some mips
> thing.  I'd have thought that it would be better to use the dma mapping API
> thoughout the driver, and its associated dma invalidation APIs.
> 
> The driver has some LINUX_VERSION_CODE ifdefs.  We usually prefer that such
> code not be present in a merged-up driver.
> 
> 
> 
> > +			priv->regs->mac_hash_low = 0xffffffff;
> > +			priv->regs->mac_hash_high = 0xffffffff;
> > +		} else {
> > +			for (i = 0, iter = dev->mc_list; i < dev->mc_count;
> > +			    i++, iter = iter->next) {
> > +				hash = 0;
> > +				tmp = iter->dmi_addr[0];
> > +				hash  ^= (tmp >> 2) ^ (tmp << 4);
> > +				tmp = iter->dmi_addr[1];
> > +				hash  ^= (tmp >> 4) ^ (tmp << 2);
> > +				tmp = iter->dmi_addr[2];
> > +				hash  ^= (tmp >> 6) ^ tmp;
> > +				tmp = iter->dmi_addr[4];
> > +				hash  ^= (tmp >> 2) ^ (tmp << 4);
> > +				tmp = iter->dmi_addr[5];
> > +				hash  ^= (tmp >> 4) ^ (tmp << 2);
> > +				tmp = iter->dmi_addr[6];
> > +				hash  ^= (tmp >> 6) ^ tmp;
> > +				hash &= 0x3f;
> > +				if (hash < 32) {
> > +					hashlo |= 1<<hash;
> > +				} else {
> > +					hashhi |= 1<<(hash - 32);
> > +				}
> > +			}
> > +
> > +			priv->regs->mac_hash_low = hashlo;
> > +			priv->regs->mac_hash_high = hashhi;
> > +		}
> 
> Do we not have a library function anywhere which will perform this little
> multicasting hash?

Depends on the ethernet controller, but the ones that I know about
just use a CRC (crc-16 IIRC) calculation for the multicast hash.

---
~Randy
*** Remember to use Documentation/SubmitChecklist when testing your code ***
