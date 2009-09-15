From: Zhu Yi <yi.zhu@intel.com>
Subject: alloc skb based on a given data buffer
Date: Tue, 15 Sep 2009 16:30:20 +0800
Message-ID: <1253003420.7549.51.camel@debian>
References: <200909060941.01810.elendil@planet.nl>
	 <4AA67139.80301@lwfinger.net> <20090909150418.GI24614@csn.ul.ie>
	 <200909091759.33655.elendil@planet.nl> <20090909165545.GK24614@csn.ul.ie>
	 <1252526738.30150.91.camel@rc-desk> <20090910090206.GA22276@csn.ul.ie>
	 <1252617290.30150.321.camel@rc-desk> <20090911084717.GB32497@csn.ul.ie>
	 <1252897270.5650.169.camel@debian>  <20090914130612.GA11778@csn.ul.ie>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "Chatre, Reinette" <reinette.chatre@intel.com>,
	Frans Pop <elendil@planet.nl>,
	Larry Finger <Larry.Finger@lwfinger.net>,
	"John W. Linville" <linville@tuxdriver.com>,
	Pekka Enberg <penberg@cs.helsinki.fi>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"linux-wireless@vger.kernel.org" <linux-wireless@vger.kernel.org>,
	"ipw3945-devel@lists.sourceforge.net"
	<ipw3945-devel@lists.sourceforge.net>,
	Andrew Morton <akpm@linux-foundation.org>,
	"cl@linux-foundation.org" <cl@linux-foundation.org>,
	"Krauss, Assaf" <assaf.krauss@intel.com>,
	Johannes Berg <johannes@sipsolutions.net>,
	"Abbas, Mohamed" <mohamed.abbas@intel.com>, netdev@vger.kernel.org
To: Mel Gorman <mel@csn.ul.ie>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:65417 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751278AbZIOIaV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 15 Sep 2009 04:30:21 -0400
In-Reply-To: <20090914130612.GA11778@csn.ul.ie>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[ Cc netdev and change the subject ]

On Mon, 2009-09-14 at 21:06 +0800, Mel Gorman wrote:
> > Essentially, the hardware only requires an order-1 allocation aligned on
> > 256 bytes boundary. But as it is used as an SKB, a trailing struct
> > skb_shared_info is added. This forces us to both increase the order and
> > do alignment ourselves. I believe some improvement could be done here.
> > But it should not be an easy one.
> > 
> 
> Probably not. I can only assume that moving the location of
> skb_shared_info such that it is sometimes located after the buffer and
> sometimes allocated via a separate kmalloc() would be a significant
> undertaking.

Shall I propose below function as a variant to alloc_skb()?

struct sk_buff *alloc_skb_attach_buff(void *data_buff,
				      unsigned int real_size,
				      unsigned int size, gfp_t mask);

If real_size >= size + sizeof(struct skb_shared_info), we can still put
the shinfo at the end of the buffer. Otherwise we can allocate from a
new slab that put sk_buff and shinfo together. Of course, kfree_skbmem()
needs to recognize it.

This way, device drivers can allocate the Rx buffers with their own size
and alignment requirement. i.e. do an order-1 page allocation directly
with free_pages() in the iwlagn driver for a 256 bytes aligned 8K Rx
buffer. After DMA is finished, drivers can use the above function to
assemble an skb based on the Rx buffer. It should resolve the problem
for requiring an order-2 allocation by alloc_skb() in the first place.

Comments are welcome.

Thanks,
-yi

