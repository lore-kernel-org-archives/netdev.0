From: Timur Tabi <timur@freescale.com>
Subject: Re: [PATCH 1/4] ucc_geth: Change private immrbar_virt_to_phys to
 generic iopa
Date: Wed, 07 Feb 2007 11:03:02 -0600
Message-ID: <45CA0646.3060203@freescale.com>
References: <45C86715.6090600@freescale.com> <001EB06E-FC1D-4F0A-A910-8E08EE0B8CE2@kernel.crashing.org> <45CA01C9.3020309@freescale.com> <AC7EDFBD-7282-460F-9D0E-2E3AA9ED7718@kernel.crashing.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Li Yang <leoli@freescale.com>, netdev@vger.kernel.org,
	linuxppc-dev@ozlabs.org
To: Kumar Gala <galak@kernel.crashing.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from de01egw01.freescale.net ([192.88.165.102]:52133 "EHLO
	de01egw01.freescale.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1161435AbXBGRDI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Feb 2007 12:03:08 -0500
In-Reply-To: <AC7EDFBD-7282-460F-9D0E-2E3AA9ED7718@kernel.crashing.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Kumar Gala wrote:

> If its been mapped with ioremap() you know the physical address already 
> so why do you need iopa().  

That's what the original function immrbar_virt_to_phys() does.  We're trying to 
get rid of it, because we thought is redundant with iopa().

static inline unsigned long immrbar_virt_to_phys(volatile void * address)
{
	if ( ((u32)address >= (u32)qe_immr) &&
			((u32)address < ((u32)qe_immr + QE_IMMAP_SIZE)) )
		return (unsigned long)(address - (u32)qe_immr +
				(u32)get_qe_base());
	return (unsigned long)virt_to_phys(address);
}

get_qe_base() does a search of the OF tree the first time it's called.

Here's the code that calls immrbar_virt_to_phys():

	out_be32(&ugeth->p_send_q_mem_reg->sqqd[i].bd_ring_base,
		 (u32) immrbar_virt_to_phys(ugeth->
					    p_tx_bd_ring[i]));


Would it be better to replace this code with something like this:

out_be32(&ugeth->p_send_q_mem_reg->sqqd[i].bd_ring_base,
	get_qe_base() + ((void *) ugeth->p_tx_bd_ring[i] - (void *) qe_immr));


-- 
Timur Tabi
Linux Kernel Developer @ Freescale
