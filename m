From: Zoltan Kiss <zoltan.kiss@citrix.com>
Subject: Re: [PATCH net-next v2 1/9] xen-netback: Introduce TX grant map definitions
Date: Mon, 16 Dec 2013 15:21:40 +0000
Message-ID: <52AF1A84.3090304@citrix.com>
References: <1386892097-15502-1-git-send-email-zoltan.kiss@citrix.com> <1386892097-15502-2-git-send-email-zoltan.kiss@citrix.com> <20131213153138.GL21900@zion.uk.xensource.com> <52AB506E.3040509@citrix.com> <20131213191423.GA12582@zion.uk.xensource.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <ian.campbell@citrix.com>, <xen-devel@lists.xenproject.org>,
	<netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	<jonathan.davies@citrix.com>
To: Wei Liu <wei.liu2@citrix.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20131213191423.GA12582@zion.uk.xensource.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 13/12/13 19:14, Wei Liu wrote:
>>>> +	spin_lock_irqsave(&vif->dealloc_lock, flags);
>>>> > >>+	do {
>>>> > >>+		pending_idx = ubuf->desc;
>>>> > >>+		ubuf = (struct ubuf_info *) ubuf->ctx;
>>>> > >>+		index = pending_index(vif->dealloc_prod);
>>>> > >>+		vif->dealloc_ring[index] = pending_idx;
>>>> > >>+		/* Sync with xenvif_tx_action_dealloc:
>>>> > >>+		 * insert idx then incr producer.
>>>> > >>+		 */
>>>> > >>+		smp_wmb();
>>>> > >>+		vif->dealloc_prod++;
>>>> > >>+	} while (ubuf);
>>>> > >>+	wake_up(&vif->dealloc_wq);
>>>> > >>+	spin_unlock_irqrestore(&vif->dealloc_lock, flags);
> [...]
>>> > >
>>>> > >>+		smp_rmb();
>>>> > >>+
>>>> > >>+		while (dc != dp) {
>>>> > >>+			pending_idx =
>>>> > >>+				vif->dealloc_ring[pending_index(dc++)];
>>>> > >>+
>>>> > >>+			/* Already unmapped? */
>>>> > >>+			if (vif->grant_tx_handle[pending_idx] ==
>>>> > >>+				NETBACK_INVALID_HANDLE) {
>>>> > >>+				netdev_err(vif->dev,
>>>> > >>+					"Trying to unmap invalid handle! "
>>>> > >>+					"pending_idx: %x\n", pending_idx);
>>>> > >>+				continue;
>>>> > >>+			}
>>> > >
>>> > >Should this be BUG_ON? AIUI this kthread should be the only one doing
>>> > >unmap, right?
>> >The NAPI instance can do it as well if it is a small packet fits
>> >into PKT_PROT_LEN. But still this scenario shouldn't really happen,
>> >I was just not sure we have to crash immediately. Maybe handle it as
>> >a fatal error and destroy the vif?
>> >
> It depends. If this is within the trust boundary, i.e. everything at the
> stage should have been sanitized then we should BUG_ON because there's
> clearly a bug somewhere in the sanitization process, or in the
> interaction of various backend routines.

My understanding is that crashing should be avoided if we can bail out 
somehow. At this point there is clearly a bug in netback somewhere, 
something unmapped that page before it should have happened, or at least 
that array get corrupted somehow. However there is a chance that 
xenvif_fatal_tx_err() can contain the issue, and the rest of the system 
can go unaffected.

Zoli
