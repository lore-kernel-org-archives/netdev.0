From: "Eilon Greenstein" <eilong@broadcom.com>
Subject: Re: [PATCH net 2/9] bnx2x: Prevent an illegal pointer
 dereference during panic
Date: Thu, 17 Oct 2013 21:47:27 +0300
Message-ID: <1382035647.20308.3.camel@lb-tlvb-eilong.il.broadcom.com>
References: <1381847335-32662-1-git-send-email-yuvalmin@broadcom.com>
 <1381847335-32662-3-git-send-email-yuvalmin@broadcom.com>
 <20131017.142134.1058688642083607743.davem@davemloft.net>
Reply-To: eilong@broadcom.com
Mime-Version: 1.0
Content-Type: text/plain;
 charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: yuvalmin@broadcom.com, netdev@vger.kernel.org, ariele@broadcom.com,
	dmitry@broadcom.com
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:1403 "EHLO mms3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758121Ab3JQSrk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 17 Oct 2013 14:47:40 -0400
In-Reply-To: <20131017.142134.1058688642083607743.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2013-10-17 at 14:21 -0400, David Miller wrote:
> From: "Yuval Mintz" <yuvalmin@broadcom.com>
> Date: Tue, 15 Oct 2013 16:28:48 +0200
> 
> > @@ -775,6 +775,15 @@ void bnx2x_fw_dump_lvl(struct bnx2x *bp, const char *lvl)
> >  		trace_shmem_base = bp->common.shmem_base;
> >  	else
> >  		trace_shmem_base = SHMEM2_RD(bp, other_shmem_base_addr);
> > +
> > +	/* sanity */
> > +	if (trace_shmem_base < MCPR_SCRATCH_BASE(bp) ||
> > +	    trace_shmem_base > MCPR_SCRATCH_BASE(bp) + 0x28000) {
> 
> I would say that this second test should be ">=" rather than ">".
> 
> Actually, there are a lot of holes still remaining here.
> 
> trace_shmem_base is validated, but then you access the signature at
> 0x800 bytes before trace_shmem_base value.  That should be accounted
> for in the test above too.
> 
> And what about that 'mark' value you read?  Any validations needed on
> that?
> 
> And then you read from "addr" to "mark", and I see no checks that this
> range makes any sense either.

The failure that we saw was due to PCI read failure, so we could have
checked that we did not read all 1's, but then we thought about a
stronger validation to make sure this address is not being overrun for
some unknown reason (maybe stack overflow of the FW, after all, we are
at a FW bug handling routine) so this added condition validate that the
address is within the scratchpad limitation. To make it more precious,
we should account for the differences between the different silicon
revisions, but we did not really see such a failure - the failure we saw
was reading all 1's, the extra sanity will catch some more failure, but
obviously not all.

I guess we should really re-spin and check for all 1's, or add some more
code to make it really accurate, or at least fix the ">" to ">=". We
will send a revised series with a fix.

Thanks,
Eilon
