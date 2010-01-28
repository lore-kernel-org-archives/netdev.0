From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: Hang: 2.6.32.4 sky2/DMAR (was [PATCH] sky2: Fix WARNING: at
 lib/dma-debug.c:902 check_sync)
Date: Thu, 28 Jan 2010 09:08:35 -0800
Message-ID: <20100128090835.0d93e53a@nehalam>
References: <20100120094103.GA6225@ff.dom.local>
	<4B58B217.8030001@majjas.com>
	<20100121204133.GB3085@del.dom.local>
	<4B59E7EB.3050605@majjas.com>
	<20100122215304.GA3105@del.dom.local>
	<4B5A2362.6000306@majjas.com>
	<20100122230605.GB3105@del.dom.local>
	<4B5A33D8.90501@majjas.com>
	<20100122234656.GC3105@del.dom.local>
	<4B5A39BD.8020305@majjas.com>
	<20100123232133.GA3487@del.dom.local>
	<4B605D1B.60402@majjas.com>
	<20100127085049.5b5048e9@nehalam>
	<4B60707F.1000608@majjas.com>
	<20100127095614.14313677@nehalam>
	<4B608128.7090607@majjas.com>
	<4B6089C7.4010803@majjas.com>
	<4B61ADF1.7060705@majjas.com>
	<4B61BEA4.1030905@majjas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Jarek Poplawski <jarkao2@gmail.com>,
	David Miller <davem@davemloft.net>, akpm@linux-foundation.org,
	flyboy@gmail.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, Michael Chan <mchan@broadcom.com>,
	Don Fry <pcnet32@verizon.net>,
	Francois Romieu <romieu@fr.zoreil.com>,
	Matt Carlson <mcarlson@broadcom.com>
To: Michael Breuer <mbreuer@majjas.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1756252Ab0A1RJs@vger.kernel.org>
In-Reply-To: <4B61BEA4.1030905@majjas.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 28 Jan 2010 11:43:16 -0500
Michael Breuer <mbreuer@majjas.com> wrote:

> Update: I played with dma-debug. Was being disabled due to lack of 
> memory. I forced it back on while pumping traffic through and got this:
> Jan 28 11:39:30 mail kernel: ------------[ cut here ]------------
> Jan 28 11:39:30 mail kernel: WARNING: at lib/dma-debug.c:902 
> check_sync+0xc1/0x43f()
> Jan 28 11:39:30 mail kernel: Hardware name: System Product Name
> Jan 28 11:39:30 mail kernel: sky2 0000:06:00.0: DMA-API: device driver 
> tries to sync DMA memory it has not allocated [device 

This test in dma-debug is bogus. Because the debug code matches
dma based on address and size; and is perfectly valid to sync a value
less than size. This is the patch I sent earlier, it isn't 100%
correct but it will let you keep testing
....................................


This should fix the dma-debug API code (and documentation), to
avoid false positives when sync is done on a partial map.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

--- a/Documentation/DMA-API.txt	2010-01-20 15:17:01.390143729 -0800
+++ b/Documentation/DMA-API.txt	2010-01-20 15:18:48.967875255 -0800
@@ -377,9 +377,10 @@ void
 pci_dma_sync_sg(struct pci_dev *hwdev, struct scatterlist *sg,
 		       int nelems, int direction)
 
-Synchronise a single contiguous or scatter/gather mapping.  All the
-parameters must be the same as those passed into the single mapping
-API.
+Synchronise a single contiguous or scatter/gather mapping.  The
+device and handle must be the same as those passed into the single mapping
+API. The size can be less than the original mapping if only part
+of the mapping needs to be accessed.
 
 Notes:  You must do this:
 
--- a/lib/dma-debug.c	2010-01-20 15:22:55.919519883 -0800
+++ b/lib/dma-debug.c	2010-01-20 15:26:31.648895638 -0800
@@ -285,11 +285,9 @@ static struct dma_debug_entry *hash_buck
 	}
 
 	/*
-	 * If we have multiple matches but no perfect-fit, just return
-	 * NULL.
+	 * If we have multiple matches but no perfect-fit
+	 * return best value and let caller deal with it.
 	 */
-	ret = (matches == 1) ? ret : NULL;
-
 	return ret;
 }
 
