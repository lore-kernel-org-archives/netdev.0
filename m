From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH] sky2:  receive dma mapping error handling
Date: Sun, 31 Jan 2010 01:34:49 +0100
Message-ID: <20100131003449.GA11935@del.dom.local>
References: <4B61ADF1.7060705@majjas.com>
 <4B61BEA4.1030905@majjas.com>
 <20100128090835.0d93e53a@nehalam>
 <4B61DB79.4080703@majjas.com>
 <20100128223447.GC3109@del.dom.local>
 <4B621316.8070308@majjas.com>
 <20100128225621.GD3109@del.dom.local>
 <4B6216B9.1010802@majjas.com>
 <20100128153643.0fca3c51@nehalam>
 <4B645EF4.4050701@majjas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stephen Hemminger <shemminger@linux-foundation.org>,
	David Miller <davem@davemloft.net>, akpm@linux-foundation.org,
	flyboy@gmail.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, Michael Chan <mchan@broadcom.com>,
	Don Fry <pcnet32@verizon.net>,
	Francois Romieu <romieu@fr.zoreil.com>,
	Matt Carlson <mcarlson@broadcom.com>
To: Michael Breuer <mbreuer@majjas.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1753572Ab0AaAe7@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <4B645EF4.4050701@majjas.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Jan 30, 2010 at 11:31:48AM -0500, Michael Breuer wrote:
> On 01/28/2010 06:36 PM, Stephen Hemminger wrote:
> >Please try this patch (and only this patch), on 2.6.33-rc5[*];
> >none of the other patches that did not make it upstream because that
> >confuses things too much.
> >
> >The code that checks for DMA mapping errors on receive buffers would
> >not handle errors correctly.  I doubt you have these errors, but if you
> >did then it would explain the problems.  The code has to be a little
> >tricky and build mapping for new rx buffer before releasing old one,
> >that way if new mapping fails, the old one can be reused.
> >
> >If it works for you, I will resubmit with signed-off.
> >
> >-
> >
> Nope - tx crash again. This time the system stayed up (but hosed)
> for a few hours. When I tried to recover eth0 the system then
> crashed.
> 
> Brief summary of events (log extract below):
> 
> System start Jan 28 19:29
> Everything seemed good (load and all) until 17:13:11 the following
> day when I got rx errors:
> 
> Jan 29 17:13:11 mail kernel: sky2 eth0: rx error, status 0x6230010
> length 1518
> Jan 29 17:13:11 mail kernel: sky2 eth0: rx error, status 0x7f40010
> length 1518

These are length errors, but status shows more than 1518, e.g. 2036
here, unless I miss something. Please, don't use jumbo frames in your
network until we fully debug it for regular frames (Stephen admitted
sky2 jumbo might be broken).

...
> As I started looking at logs, the system hung and rebooted. I'm up
> now with dma debug enabled, however as with 2.6.32.4 num_entries is
> dropping and I don't think that dma debug will remain enabled long
> enough to catch a crash.

Could you try the patch below to show maybe some other users of
dma-debug entries?

Jarek P.
---

 lib/dma-debug.c |   52 +++++++++++++++++++++++++++++++++++++++++++++++++++-
 1 files changed, 51 insertions(+), 1 deletions(-)

diff --git a/lib/dma-debug.c b/lib/dma-debug.c
index 7d2f0b3..e2dcc9c 100644
--- a/lib/dma-debug.c
+++ b/lib/dma-debug.c
@@ -310,6 +310,53 @@ static void hash_bucket_del(struct dma_debug_entry *entry)
 	list_del(&entry->list);
 }
 
+struct dma_debug_dev {
+	struct device *dev;
+	unsigned int cnt;
+};
+
+#define DMA_DEBUG_DEVS 100
+static struct dma_debug_dev dma_debug_devs[DMA_DEBUG_DEVS];
+
+static void debug_dma_dump_devs(void)
+{
+	int idx, i;
+
+	memset(dma_debug_devs, 0, sizeof(struct dma_debug_dev) * DMA_DEBUG_DEVS);
+
+	for (idx = 0; idx < HASH_SIZE; idx++) {
+		struct hash_bucket *bucket = &dma_entry_hash[idx];
+		struct dma_debug_entry *entry;
+		unsigned long flags;
+
+		spin_lock_irqsave(&bucket->lock, flags);
+
+		list_for_each_entry(entry, &bucket->list, list) {
+			for (i = 0; i < DMA_DEBUG_DEVS; i++) {
+				struct device *dev = dma_debug_devs[i].dev;
+
+				if (!dev || dev == entry->dev) {
+					dma_debug_devs[i].dev = entry->dev;
+					dma_debug_devs[i].cnt++;
+					break;
+				}
+			}
+		}
+
+		spin_unlock_irqrestore(&bucket->lock, flags);
+	}
+
+	for (i = 0; i < DMA_DEBUG_DEVS; i++) {
+		struct device *dev = dma_debug_devs[i].dev;
+
+		if (!dev)
+			break;
+
+		pr_info("DMA-API: %s: entries: %d\n", dev_name(dev),
+			dma_debug_devs[i].cnt);
+	}
+}
+
 /*
  * Dump mapping entries for debugging purposes
  */
@@ -363,8 +410,11 @@ static struct dma_debug_entry *__dma_entry_alloc(void)
 	memset(entry, 0, sizeof(*entry));
 
 	num_free_entries -= 1;
-	if (num_free_entries < min_free_entries)
+	if (num_free_entries < min_free_entries) {
 		min_free_entries = num_free_entries;
+		if ((min_free_entries & 0xffff) == 0)
+			debug_dma_dump_devs();
+	}
 
 	return entry;
 }
