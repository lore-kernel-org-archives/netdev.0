From: ANNIE LI <annie.li@oracle.com>
Subject: Re: [PATCH 0/4] Implement persistent grant in xen-netfront/netback
Date: Fri, 16 Nov 2012 19:37:00 +0800
Message-ID: <50A6255C.10108@oracle.com>
References: <1352962987-541-1-git-send-email-annie.li@oracle.com> <1353059821.3499.190.camel@zakaz.uk.xensource.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "xen-devel@lists.xensource.com" <xen-devel@lists.xensource.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"konrad.wilk@oracle.com" <konrad.wilk@oracle.com>
To: Ian Campbell <Ian.Campbell@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:49047 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750980Ab2KPLhJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Nov 2012 06:37:09 -0500
In-Reply-To: <1353059821.3499.190.camel@zakaz.uk.xensource.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 2012-11-16 17:57, Ian Campbell wrote:
> On Thu, 2012-11-15 at 07:03 +0000, Annie Li wrote:
>> This patch implements persistent grants for xen-netfront/netback.
> Hang on a sec. It has just occurred to me that netfront/netback in the
> current mainline kernels don't currently use grant maps at all, they use
> grant copy on both the tx and rx paths.

Ah, this patch is based on v3.4-rc3.
Current mainline kernel does not pass the netperf/netserver case. As I 
mentioned earlier, I hit BUG_ON with your debug patch too when testing 
mainline kernel with netperf/netserver.
This is interesting, I should have check the latest code.

>
> The supposed benefit of persistent grants is to avoid the TLB shootdowns
> on grant unmap, but in the current code there should be exactly zero of
> those.

Is there any performance document about current grant copy code in 
mainline kernel?

>
> If I understand correctly this patch goes from using grant copy
> operations to persistently mapping frames and then using memcpy on those
> buffers to copy in/out to local buffers. I'm finding it hard to think of
> a reason why this should perform any better, do you have a theory which
> explains it?

This patch is aiming to fix spin lock issue of grant operations, it 
comes out to avoid possible grant operations(including grant map and copy).

> (my best theory is that it has a beneficial impact on where
> the cache locality of the data, but netperf doesn't typically actually
> access the data so I'm not sure why that would matter)
>
> Also AIUI this is also doing persistent grants for both Tx and Rx
> directions?

Yes.

>
> For guest Rx does this mean it now copies twice, in dom0 from the DMA
> buffer to the guest provided buffer and then again in the guest from the
> granted buffer to a normal one?

Yes.

>
> For guest Tx how do you handle the lifecycle of the grant mapped pages
> which are being sent up into the dom0 network stack? Or are you also now
> copying twice in this case? (i.e. guest copies into a granted buffer and
> dom0 copies out into a local buffer?)

Copy twice: guest copies into a granted buffer and dom0 copies out into 
a local buffer.

>
> Did you do measurement of the Tx and Rx cases independently?

No.

> Do you know
> that they both benefit from this change (rather than for example an
> improvement in one direction masking a regression in the other).

On theory, this implementation avoid spinlock issue of grant operation, 
so they should both benefit from it.

> Were
> the numbers you previously posted in one particular direction or did you
> measure both?

One particular direction, one runs as server, the other runs as client.

Thanks
Annie
>
> Ian.
>
