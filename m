From: Zoltan Kiss <zoltan.kiss@citrix.com>
Subject: Re: [PATCH net-next] xen-netback: Adding debugfs "io_ring_qX" files
Date: Wed, 2 Jul 2014 19:43:25 +0100
Message-ID: <53B452CD.7020903@citrix.com>
References: <1404160411-23747-1-git-send-email-zoltan.kiss@citrix.com> <1404298567.5562.13.camel@kazak.uk.xensource.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Wei Liu <wei.liu2@citrix.com>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>, <xen-devel@lists.xenproject.org>
To: Ian Campbell <Ian.Campbell@citrix.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1404298567.5562.13.camel@kazak.uk.xensource.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 02/07/14 11:56, Ian Campbell wrote:
> On Mon, 2014-06-30 at 21:33 +0100, Zoltan Kiss wrote:
>> This patch adds debugfs capabilities to netback. There used to be a similar
>> patch floating around for classic kernel, but it used procfs. It is based on a
>> very similar blkback patch.
>> It creates xen-netback/[vifname]/io_ring_q[queueno] files, reading them output
>> various ring variables etc. Writing "kick" into it imitates an interrupt
>> happened, it can be useful to check whether the ring is just stalled due to a
>> missed interrupt.
>
> Shouldn't there be some CONFIG_XEN_DEBUG_FS ifdefs sprinkled around
> here?

Good question! I've checked where else is this used, it is in 
arch/x86/xen, particularly in spinlock.c and p2m.c. The goal there is, 
as far as I see, to make it configurable whether you want debugging in 
fast path. However here in netback it's not fast path.
It would be nice to have this netback debugfs stuff in production 
systems, but if it is tied to this same config option, that wouldn't be 
possible.
So either we don't put it behind a config option, or create a whole new 
one just for this. I don't see the benefit of the latter one, so I would 
prefer keep it like it is now.
>
>> 	if (tx_ring->sring) {
>> +		struct xen_netif_tx_sring *sring = tx_ring->sring;
>> +
>> +		err = snprintf(buf + rv, XEN_NETBACK_DBG_IORING_BUF_SIZE - rv,
>> +			       "TX queue %d: nr_ents %u\n", i,
>> +			       tx_ring->nr_ents);
>> +		if (err >= XEN_NETBACK_DBG_IORING_BUF_SIZE - rv)
>> +			return XEN_NETBACK_DBG_IORING_BUF_SIZE;
>> +		else
>> +			rv += err;
>
> Does debugfs not provide helpers which let this be done in some more
> palatable way?
>
> arch/x86/xen/p2m.c seems to use some useful seq_*/single_* helpers for
> something very similar and it looks much cleaner.
It took some time until I figured it out how to use them, but I've 
changed it for the next version.


>
>> +	if (vif->xenvif_dbg_root)
>
> No IS_ERR check?
>
> And in backend_disconnect/connect too.
Indeed, I fixed that
>
> Ian.
>
