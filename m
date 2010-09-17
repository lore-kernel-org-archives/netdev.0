From: Sridhar Samudrala <sri@us.ibm.com>
Subject: Re: [v2 RFC PATCH 0/4] Implement multiqueue virtio-net
Date: Fri, 17 Sep 2010 08:42:01 -0700
Message-ID: <1284738121.9761.11.camel@w-sridhar.beaverton.ibm.com>
References: <20100917100307.21276.79185.sendpatchset@krkumar2.in.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: rusty@rustcorp.com.au, davem@davemloft.net, mst@redhat.com,
	kvm@vger.kernel.org, arnd@arndb.de, netdev@vger.kernel.org,
	avi@redhat.com, anthony@codemonkey.ws
To: Krishna Kumar <krkumar2@in.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e3.ny.us.ibm.com ([32.97.182.143]:42183 "EHLO e3.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754833Ab0IQPmG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 17 Sep 2010 11:42:06 -0400
In-Reply-To: <20100917100307.21276.79185.sendpatchset@krkumar2.in.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2010-09-17 at 15:33 +0530, Krishna Kumar wrote:
> Following patches implement transmit MQ in virtio-net.  Also
> included is the user qemu changes. MQ is disabled by default
> unless qemu specifies it.
> 
> 1. This feature was first implemented with a single vhost.
>    Testing showed 3-8% performance gain for upto 8 netperf
>    sessions (and sometimes 16), but BW dropped with more
>    sessions.  However, adding more vhosts improved BW
>    significantly all the way to 128 sessions. Multiple
>    vhost is implemented in-kernel by passing an argument
>    to SET_OWNER (retaining backward compatibility). The
>    vhost patch adds 173 source lines (incl comments).
> 2. BW -> CPU/SD equation: Average TCP performance increased
>    23% compared to almost 70% for earlier patch (with
>    unrestricted #vhosts).  SD improved -4.2% while it had
>    increased 55% for the earlier patch.  Increasing #vhosts
>    has it's pros and cons, but this patch lays emphasis on
>    reducing CPU utilization.  Another option could be a
>    tunable to select number of vhosts threads.
> 3. Interoperability: Many combinations, but not all, of qemu,
>    host, guest tested together.  Tested with multiple i/f's
>    on guest, with both mq=on/off, vhost=on/off, etc.
> 
>                   Changes from rev1:
>                   ------------------
> 1. Move queue_index from virtio_pci_vq_info to virtqueue,
>    and resulting changes to existing code and to the patch.
> 2. virtio-net probe uses virtio_config_val.
> 3. Remove constants: VIRTIO_MAX_TXQS, MAX_VQS, all arrays
>    allocated on stack, etc.
> 4. Restrict number of vhost threads to 2 - I get much better
>    cpu/sd results (without any tuning) with low number of vhost
>    threads.  Higher vhosts gives better average BW performance
>    (from average of 45%), but SD increases significantly (90%).
> 5. Working of vhost threads changes, eg for numtxqs=4:
>        vhost-0: handles RX
>        vhost-1: handles TX[0]
>        vhost-0: handles TX[1]
>        vhost-1: handles TX[2]
>        vhost-0: handles TX[3]

This doesn't look symmetrical.
TCP flows that go via TX(1,3) use the same vhost thread for RX packets,
whereas flows via TX(0,2) use a different vhost thread.

Thanks
Sridhar

