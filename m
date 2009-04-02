From: Avi Kivity <avi@redhat.com>
Subject: Re: [RFC PATCH 00/17] virtual-bus
Date: Thu, 02 Apr 2009 19:19:15 +0300
Message-ID: <49D4E583.4080505@redhat.com>
References: <20090331184057.28333.77287.stgit@dev.haskins.net> <87ab71monw.fsf@basil.nowhere.org> <49D35825.3050001@novell.com> <20090401132340.GT11935@one.firstfloor.org> <49D37805.1060301@novell.com> <20090401170103.GU11935@one.firstfloor.org> <49D3B64F.6070703@codemonkey.ws> <49D3D7EE.4080202@novell.com> <49D46089.5040204@redhat.com> <49D497A1.4090900@novell.com> <49D4A4EB.8020105@redhat.com> <49D4AE0C.3000604@novell.com> <49D4B2C0.5060906@redhat.com> <49D4B594.6080703@novell.com> <49D4B8B4.4020003@redhat.com> <49D4BF70.1060301@novell.com> <49D4C191.2070502@redhat.com> <49D4CAA7.3020004@novell.com> <49D4CC61.6010105@redhat.com> <49D4CEB1.9020001@redhat.com> <49D4D075.9010702@codemonkey.ws> <49D4E33F.5000303@codemonkey.ws>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Gregory Haskins <ghaskins@novell.com>,
	Andi Kleen <andi@firstfloor.org>, linux-kernel@vger.kernel.org,
	agraf@suse.de, pmullaney@novell.com, pmorreale@novell.com,
	rusty@rustcorp.com.au, netdev@vger.kernel.org, kvm@vger.kernel.org
To: Anthony Liguori <anthony@codemonkey.ws>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:56964 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753001AbZDBQT0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 2 Apr 2009 12:19:26 -0400
In-Reply-To: <49D4E33F.5000303@codemonkey.ws>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Anthony Liguori wrote:
>> I don't think we even need that to end this debate.  I'm convinced we 
>> have a bug somewhere.  Even disabling TX mitigation, I see a ping 
>> latency of around 300ns whereas it's only 50ns on the host.  This 
>> defies logic so I'm now looking to isolate why that is.
>
> I'm down to 90us.  Obviously, s/ns/us/g above.  The exec.c changes 
> were the big winner... I hate qemu sometimes.
>
>

What, this:

> diff --git a/qemu/exec.c b/qemu/exec.c
> index 67f3fa3..1331022 100644
> --- a/qemu/exec.c
> +++ b/qemu/exec.c
> @@ -3268,6 +3268,10 @@ uint32_t ldl_phys(target_phys_addr_t addr)
>      unsigned long pd;
>      PhysPageDesc *p;
>  
> +#if 1
> +    return ldl_p(phys_ram_base + addr);
> +#endif
> +
>      p = phys_page_find(addr >> TARGET_PAGE_BITS);
>      if (!p) {
>          pd = IO_MEM_UNASSIGNED;
> @@ -3300,6 +3304,10 @@ uint64_t ldq_phys(target_phys_addr_t addr)
>      unsigned long pd;
>      PhysPageDesc *p;
>  
> +#if 1
> +    return ldq_p(phys_ram_base + addr);
> +#endif
> +
>      p = phys_page_find(addr >> TARGET_PAGE_BITS);
>      if (!p) {
>          pd = IO_MEM_UNASSIGNED;

The way I read it, it will run only run slowly once per page, then 
settle to a cache miss per page.

Regardless, it makes a memslot model even more attractive.


-- 
error compiling committee.c: too many arguments to function

