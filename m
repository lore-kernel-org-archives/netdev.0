From: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
Subject: Re: [PATCH] net: allow configuration of the size of page in
 __netdev_alloc_frag
Date: Tue, 30 Oct 2012 12:53:10 -0400
Message-ID: <20121030165309.GA30483@phenom.dumpdata.com>
References: <1351078936-14159-1-git-send-email-ian.campbell@citrix.com>
 <1351081703.6537.99.camel@edumazet-glaptop>
 <1351084618.18035.27.camel@zakaz.uk.xensource.com>
 <1351085403.6537.102.camel@edumazet-glaptop>
 <1351087326.18035.50.camel@zakaz.uk.xensource.com>
 <1351092068.6537.107.camel@edumazet-glaptop>
 <1351095739.18035.83.camel@zakaz.uk.xensource.com>
 <1351097000.6537.109.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="0F1p//8PRICkK4MW"
Cc: Ian Campbell <Ian.Campbell@citrix.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>,
	"xen-devel@lists.xen.org" <xen-devel@lists.xen.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1050.oracle.com ([156.151.31.82]:36102 "EHLO
	userp1050.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965010Ab2J3RjE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Oct 2012 13:39:04 -0400
Received: from userp1040.oracle.com (userp1040.oracle.com [156.151.31.81])
	by userp1050.oracle.com (Sentrion-MTA-4.2.2/Sentrion-MTA-4.2.2) with ESMTP id q9UHd2Cp017514
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <netdev@vger.kernel.org>; Tue, 30 Oct 2012 17:39:02 GMT
Content-Disposition: inline
In-Reply-To: <1351097000.6537.109.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--0F1p//8PRICkK4MW
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Wed, Oct 24, 2012 at 06:43:20PM +0200, Eric Dumazet wrote:
> On Wed, 2012-10-24 at 17:22 +0100, Ian Campbell wrote:
> > On Wed, 2012-10-24 at 16:21 +0100, Eric Dumazet wrote:
> 
> > > If you really have such problems, why locally generated TCP traffic
> > > doesnt also have it ?
> > 
> > I think it does. The reason I noticed the original problem was that ssh
> > to the machine was virtually (no pun intended) unusable.
> > 
> > > Your patch doesnt touch sk_page_frag_refill(), does it ?
> > 
> > That's right. It doesn't. When is (sk->sk_allocation & __GFP_WAIT) true?
> > Is it possible I'm just not hitting that case?
> > 
> 
> I hope not. GFP_KERNEL has __GFP_WAIT.
> 
> > Is it possible that this only affects certain traffic patterns (I only
> > really tried ssh/scp and ping)? Or perhaps its just that the swiotlb is
> > only broken in one corner case and not the other.
> 
> Could you try a netperf -t TCP_STREAM ?

For fun I did a couple of tests - I setup two machines (one r8168, the other
e1000e) and tried to do netperf/netserver. Both of them are running a baremetal
kernel and one of them has 'iommu=soft swiotlb=force' to simulate the worst
case. This is using v3.7-rc3.

The r8169 is booted without any arguments, the e1000e is using 'iommu=soft
swiotlb=force'.

So r8169 -> e1000e, I get ~940 (this is odd, I expected that the e1000e
on the recv side would be using the bounce buffer, but then I realized it
sets up using pci_alloc_coherent an 'dma' pool).

The other way - e1000e -> r8169 got me around ~128. So it is the sending
side that ends up using the bounce buffer and it slows down considerably.

I also swapped the machine that had e1000e with a tg3 - and got around
the same numbers.

So all of this points to the swiotlb and to just make sure that nothing
was amiss I wrote a little driver that would allocate a compound page,
setup DMA mapping, do some writes, sync and unmap the DMA page. And it works
correctly - so swiotlb (and the xen variant) work right just right.
Attached for your fun.

Then I decided to try v3.6.3, with the same exact parameters.. and
the problem went away.

The e1000e -> r8169 which got me around ~128, now gets ~940! Still
using the swiotlb bounce buffer.


> 
> Because ssh use small packets, and small TCP packets dont use frags but
> skb->head.
> 
> You mentioned a 70% drop of performance, but what test have you used
> exactly ?

Note, I did not provide any arguments to netperf, but it did pick the
test you wanted:

> netperf -H tst019
TCP STREAM TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET to tst019.dumpdata.com (192.168.101.39) port 0 AF_INET

> 
> 

--0F1p//8PRICkK4MW
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="dma_test.c"

#include <linux/module.h>
#include <linux/kthread.h>
#include <linux/pagemap.h>
#include <linux/init.h>
#include <linux/dma-mapping.h>
#include <linux/slab.h>
#include <xen/page.h>

#define DMA_TEST  "0.1"

MODULE_AUTHOR("Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>");
MODULE_DESCRIPTION("dma_test");
MODULE_LICENSE("GPL");
MODULE_VERSION(DMA_TEST);

static struct bus_type fallback_bus_type = {
	.name = "fallback_bus:",
};

static void fake_release(struct device *dev)
{
	/* No kfree as the device was allocated on stack. */
}

struct args {
	int len;
	enum dma_data_direction dir;
};

#define MAGIC_DEVICE 0xffffffdd
#define MAGIC_CPU 0xffffffcc

static int dma_test_thread(void *arg)
{
	struct page *page;
	dma_addr_t dma_addr = 0;
	struct device fake = {
		.coherent_dma_mask = DMA_BIT_MASK(32),
		.bus = &fallback_bus_type,
		.release = fake_release,
	};
	gfp_t gfp = __GFP_COMP | __GFP_NOWARN | GFP_ATOMIC;
	int ret;
	int i;
	void *addr;
	struct page *p;

	struct args *args = (struct args *)arg;
	int dir = args->dir;
	int len = args->len;

	dev_set_name(&fake, "%s", dir == DMA_TO_DEVICE ? "to_dev" : "to_cpu");
 	fake.dma_mask = &fake.coherent_dma_mask;
 	ret = device_register(&fake);
	if (ret)
		goto out;

	do {
		unsigned long prev_mfn = 0;
		bool bus_and_dma_same;

		page = alloc_pages(gfp, get_order(len));
		p = page;
		/* Check that the bus addresses are contingous. */
		for (i = 0; i < len / PAGE_SIZE; i++, p++) {
			unsigned long pfn, mfn;

			addr = page_address(p);
			pfn = PFN_DOWN(virt_to_phys(addr));
			if (xen_domain())
				mfn = pfn_to_mfn(pfn);
			else
				mfn = pfn;
			if (i != 0) {
				if (prev_mfn + 1 != mfn)
					dev_warn(&fake, "va: %lx (pfn:%lx, mfn:%lx) w.r.t prev mfn: %lx!\n",
						 (unsigned long)addr, pfn, mfn, prev_mfn);
			}
			prev_mfn = mfn;
		}
		dma_addr = dma_map_page(&fake, page, 0 /* no offset */, len, dir);
		/* Note, dma_addr is the physical address ! */
		if (dma_mapping_error(&fake, dma_addr)) {
			dev_warn(&fake, "DMA %lx for %lx is not right\n", (unsigned long)dma_addr,
				(unsigned long)page_address(page));
			__free_pages(page, get_order(len));
			page = NULL;
		}
		bus_and_dma_same = false;
		if (page) {
			unsigned long phys;
			unsigned long pfn, mfn, bus_addr_mfn;
			unsigned long bus_addr = 0;

			p = page;
			for (i = 0; i < len / PAGE_SIZE; i++, p++) {
				void *bus_va;

				addr = page_address(p);
				phys = virt_to_phys(addr);
				pfn = PFN_DOWN(phys);

				bus_va = (void *)(dma_addr + (i * PAGE_SIZE));

				if (xen_domain()) {
					void * tmp;

					/* Find the bus frame for the physical frame*/
					mfn = pfn_to_mfn(pfn);
					/* and .. voodoo time! */
					bus_addr_mfn = PFN_DOWN(dma_addr + (i * PAGE_SIZE));
					bus_addr = PFN_PHYS(mfn_to_pfn(bus_addr_mfn));
					tmp = __va(bus_addr);
					bus_va = mfn_to_virt(bus_addr_mfn);
					WARN(bus_va != tmp, "Expected %lx (%lx+%d*PAGE_SIZE), got: %lx (pfn: %lx, mfn: %lx)!\n",
						(unsigned long)bus_va, (unsigned long)dma_addr, i, (unsigned long)tmp, PFN_DOWN(bus_addr), bus_addr_mfn);
				} else {
					mfn = pfn;
					bus_addr = (unsigned long)bus_va;
					/* Assume DMA addr == physical addr */
					bus_addr_mfn = PFN_DOWN(bus_addr);
					bus_va = __va(PFN_PHYS(bus_addr_mfn));
				}

				dev_info(&fake, "%lx (pfn:%lx, bus frame: %lx) %s %lx (addr: %lx, frame: %lx)\n",
					(unsigned long)addr, pfn, mfn,
					dir == DMA_TO_DEVICE ? "=>" : "<=",
					(unsigned long)bus_va, bus_addr, bus_addr_mfn);

				if (!virt_addr_valid(bus_va))
					break;
				if (!virt_addr_valid(addr))
					break;

				/* CPU */
				memset(addr, 0xCC, PAGE_SIZE);

				/* Device */
				memset(bus_va, 0xDD, PAGE_SIZE);
				if (addr == bus_va)
					bus_and_dma_same = true;
			}
		}
		set_current_state(TASK_INTERRUPTIBLE);
		schedule_timeout_interruptible(5*HZ);

		if (!page)
			continue;
		p = page;

		for (i = 0; i < len / PAGE_SIZE; i++, p++) {
			if (bus_and_dma_same)
				continue;
			addr = page_address(p);
			if (((char *)addr)[0] != MAGIC_CPU)
				dev_warn(&fake, "%lx with DMA (%lx) has %x (expected %lx)\n",
					(unsigned long)addr, (unsigned long)(dma_addr + (i * PAGE_SIZE)),
					((char *)addr)[0], (unsigned long)MAGIC_CPU);
		}
		/* sync the page */
		dma_sync_single_for_cpu(&fake, dma_addr, len, dir);
		p = page;
		for (i = 0; i < len / PAGE_SIZE; i++, p++) {
			unsigned long check_val = MAGIC_DEVICE;

			addr = page_address(p);
			if (dir == DMA_TO_DEVICE)
				check_val = MAGIC_CPU;
			if (dir == DMA_FROM_DEVICE)
				check_val = MAGIC_DEVICE;

			dev_info(&fake, "%lx with DMA (%lx) has %x (expected %lx)\n",
				(unsigned long)addr, (unsigned long)(dma_addr + (i * PAGE_SIZE)),
				((char *)addr)[0], check_val);
		}
		dma_unmap_page(&fake, dma_addr, len, dir);
		dma_addr = 0;
		__free_pages(page, get_order(len));
		page = NULL;
	} while (!kthread_should_stop());

	if (dma_addr)
		dma_unmap_page(&fake, dma_addr, len, dir);
	if (page)
		__free_pages(page, get_order(len));
   	put_device(&fake);
 	device_unregister(&fake);
out:
	return 0;
}
static struct task_struct *t[2];
static struct args a[2];

static int __init dma_test_init(void)
{
	int ret;

	/* No point doing this without SWIOTLB */
	if (!swiotlb_nr_tbl())
		return -ENODEV;

	ret = bus_register(&fallback_bus_type);
	if (ret)
		return ret;

	a[0].dir = DMA_TO_DEVICE;
	a[0].len = 32768;
	t[0] = kthread_run(dma_test_thread, &a[0], "dma_test_dev");

	a[1].len = 16384;
	a[1].dir = DMA_FROM_DEVICE;
	t[1] = kthread_run(dma_test_thread, &a[1], "dma_test_cpu");
	return 0;
}
static void __exit dma_test_exit(void)
{
	if (t[0])
		kthread_stop(t[0]);
	if (t[1])
		kthread_stop(t[1]);

 	bus_unregister(&fallback_bus_type);
}
module_init(dma_test_init);
module_exit(dma_test_exit);

--0F1p//8PRICkK4MW--
