From: Rainer Weikusat <rainer.weikusat@sncag.com>
Subject: Re: Question on prism54 driver
Date: Thu, 14 Apr 2005 11:04:40 +0200
Message-ID: <87hdi9sp93.fsf@farside.sncag.com>
References: <87fyxu5oin.fsf@gxaafoot.homelinux.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com, prism54-devel@prism54.org
Return-path: <prism54-devel-bounces@prism54.org>
To: Jean-Baptiste Note <jean-baptiste.note@wanadoo.fr>
In-Reply-To: <87fyxu5oin.fsf@gxaafoot.homelinux.org> (Jean-Baptiste Note's
	message of "Wed, 13 Apr 2005 23:56:48 +0200")
List-Unsubscribe: <http://prism54.org/mailman/listinfo/prism54-devel>,
	<mailto:prism54-devel-request@prism54.org?subject=unsubscribe>
List-Archive: <http://prism54.org/pipermail/prism54-devel>
List-Post: <mailto:prism54-devel@prism54.org>
List-Help: <mailto:prism54-devel-request@prism54.org?subject=help>
List-Subscribe: <http://prism54.org/mailman/listinfo/prism54-devel>,
	<mailto:prism54-devel-request@prism54.org?subject=subscribe>
Sender: prism54-devel-bounces@prism54.org
Errors-To: prism54-devel-bounces@prism54.org
List-Id: netdev.vger.kernel.org

Jean-Baptiste Note <jean-baptiste.note@wanadoo.fr> writes:
> Going through the prism54 code for reuse in the softmac driver, i
> stumbled accross inconsistencies in the queue management functions for
> the mgmt rx queue and the data rx queue that i cannot understand.
>
> Is there any reason that we have the following call in
> islpci_mgt_receive (file islpci_mgt.c):
>
> 		/* Ensure the results of device DMA are visible to the CPU. */
> 		pci_dma_sync_single(priv->pdev, buf->pci_addr,
> 				    frag_len, PCI_DMA_FROMDEVICE);
>
> but have nothing of the sort in islpci_eth_receive (file islpci_eth.c)?
>
> In the same spirit, the control block is also written by DMA by the
> device, I guess ; so how comes we don't have such a syncing call in the
> interrupt handler before accessing the control block's values (file
> islpci_dev.c) ?
>
> Am i missing something very obvious or very subtle?

<sigh>
No, you are just hacking the code without even having tried to
understand

	a) what it is doing
        b) why it does this
[which, "by coincedence", happens to be the reason that this driver is
 so thouroughly broken]
</sigh>

The data transfers (all of them) use streaming DMA mappings, which
have to be synced explicitly between 'bus view' and 'CPU view',
because they may involve bounce buffers (in 2.4) and to ensure that
data the CPU has written to the cache is actually in memory and data
the DMA engine has written is not ignored because of (actually stale)
cache entries that predate it. The mgmt-queues use persistent
streaming mapping, which means they have to be synced everytime the
CPU intends to access them after they were accessed by the DMA engine.
The skbuffs used by the data transfer code are mapped before they are
passed to the device and unmapped (which syncs them) before the CPU
accesses them. This isn't needed for the control block, because it is
a consistent and not a streaming mapping.

BTW, I shouldn't be telling you how your code works, don't you think
so?
