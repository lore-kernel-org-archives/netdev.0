From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH 00/13] mvneta Buffer Management and enhancements
Date: Wed, 25 Nov 2015 10:34:30 -0800
Message-ID: <5655FF36.20202@gmail.com>
References: <1448178839-3541-1-git-send-email-mw@semihalf.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: thomas.petazzoni@free-electrons.com, andrew@lunn.ch, linux@arm.linux.org.uk,
 jason@lakedaemon.net, jaz@semihalf.com, simon.guinot@sequanux.org,
 xswang@marvell.com, nadavh@marvell.com, alior@marvell.com, tn@semihalf.com,
 gregory.clement@free-electrons.com, nitroshift@yahoo.com,
 sebastian.hesselbarth@gmail.com, davem@davemloft.net, myair@marvell.com
To: Marcin Wojtas <mw@semihalf.com>, linux-kernel@vger.kernel.org,
 linux-arm-kernel@lists.infradead.org, netdev@vger.kernel.org
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <1448178839-3541-1-git-send-email-mw@semihalf.com>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-arm-kernel/>
List-Post: <mailto:linux-arm-kernel@lists.infradead.org>
List-Help: <mailto:linux-arm-kernel-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=subscribe>
Sender: "linux-arm-kernel" <linux-arm-kernel-bounces@lists.infradead.org>
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

On 21/11/15 23:53, Marcin Wojtas wrote:
> 
> 4. Buffer manager (BM) support with two preparatory commits. As it is a
> separate block, common for all network ports, a new driver is introduced,
> which configures it and exposes API to the main network driver. It is
> throughly described in binding documentation and commit log. Please note,
> that enabling per-port BM usage is done using phandle and the data passed
> in mvneta_bm_probe. It is designed for usage of on-demand device probe
> and dev_set/get_drvdata, however it's awaiting merge to linux-next.
> Therefore, deferring probe is not used - if something goes wrong (same
> in case of errors during changing MTU or suspend/resume cycle) mvneta
> driver falls back to software buffer management and works in a regular way.

Looking at your patches, it was not entirely clear to me how the buffer
manager on these Marvell SoCs work, but other networking products have
something similar, like Broadcom's Cable Modem SoCs (BCM33xx) FPM, and
maybe Freescale's FMAN/DPAA seems to do something similar.

Does the buffer manager allocation work by giving you a reference/token
to a buffer as opposed to its address? If that is the case, it would be
good to design support for such hardware in a way that it can be used by
more drivers.

Eric Dumazet suggested a while ago to me that you could get abstract
such allocation using hardware-assisted buffer allocation by either
introducing a new mm zone (instead of ZONE_NORMAL/DMA/HIGHMEM etc.), or
using a different NUMA node id, such that SKB allocation and freeing
helpers could deal with the specifics, and your networking stack and
driver would be mostly unaware of the buffer manager underlying
implementation. The purpose would be to get a 'struct page' reference to
your buffer pool allocation object, so it becomes mostly transparent to
other areas of the kernel, and you could further specialize everything
that needs to be based on this node id or zone.

Finally, these hardware-assisted allocation schemes typically work very
well when there is a forwarding/routing workload involved, because you
can easily steal packets and SKBs from the network stack, but that does
not necessarily play nicely with host-terminated/initiated traffic which
wants to have good feedback on what's happening at the NIC level
(queueing, buffering, etc.).

> 
> Known issues:
> - problems with obtaining all mapped buffers from internal SRAM, when
> destroying the buffer pointer pool
> - problems with unmapping chunk of SRAM during driver removal
> Above do not have an impact on the operation, as they are called during
> driver removal or in error path.

Humm, what is the reason for using the on-chip SRAM here, is it because
that's the only storage location the Buffer Manager can allocate from,
or is it because it is presumably faster or with constant access times
than DRAM? Would be nice to explain a bit more in details how the buffer
manager works and its interfacing with the network controllers.

Can I use the buffer manager with other peripherals as well? Like if I
wanted to do zero-copy or hardware-assisted memcpy DMA, would that be a
suitable scheme?

Thanks!
-- 
Florian
