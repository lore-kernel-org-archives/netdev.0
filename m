From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [REGRESSION][PATCH v1] bpf jit: Let the arm jit handle
 negative memory references
Date: Sat, 07 Apr 2012 05:41:37 +0200
Message-ID: <1333770097.3007.24.camel@edumazet-glaptop>
References: <4F75CA89.4010709@googlemail.com>
	 <4F7F3C7D.1040007@googlemail.com>  <4F7F6DF9.5010902@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Jan Seiffert <kaffeemonster@googlemail.com>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	Russell King <linux@arm.linux.org.uk>
To: Mircea Gherzan <mgherzan@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f174.google.com ([74.125.82.174]:53055 "EHLO
	mail-we0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753911Ab2DGDln (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Apr 2012 23:41:43 -0400
In-Reply-To: <4F7F6DF9.5010902@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2012-04-07 at 00:28 +0200, Mircea Gherzan wrote:
> Hi,
> 
> Am 06.04.2012 20:57, schrieb Jan Seiffert:
> > The arm jit has the same problem as the other two jits.
> > It only tests for negative absolute memory references, and if it sees
> > one bails out to let the interpreter handle the filter program.
> > 
> > But this fails if the X register contains a negative memory reference
> > and is used for an indirect load.
> 
> I don't think that there's any use case for negative values in X. In
> both the original BPF design and in the LSF interpreter, A and X are
> considered unsigned. The role of X is mainly to allow variable length
> headers (load the length -> unsigned).
> 
> "Negative" K values are permitted for ancillary data loads based on the
> fact that we're not going to see 2GB packets any time soon.
> 

You are wrong.

Please carefully read net/core/filter.c its all here :

void *bpf_internal_load_pointer_neg_helper(const struct sk_buff *skb, int k, unsigned int size)
{
        u8 *ptr = NULL;

        if (k >= SKF_NET_OFF)
                ptr = skb_network_header(skb) + k - SKF_NET_OFF;
        else if (k >= SKF_LL_OFF)
                ptr = skb_mac_header(skb) + k - SKF_LL_OFF;

        if (ptr >= skb->head && ptr + size <= skb_tail_pointer(skb))
                return ptr;
        return NULL;
}


Then :

commit a998d4342337c82dacdc0897d30a9364de1576a1
Author: Jan Seiffert <kaffeemonster@googlemail.com>
Date:   Fri Mar 30 05:24:05 2012 +0000

    bpf jit: Let the x86 jit handle negative offsets
    
    Now the helper function from filter.c for negative offsets is exported,
    it can be used it in the jit to handle negative offsets.
    
    First modify the asm load helper functions to handle:
    - know positive offsets
    - know negative offsets
    - any offset
    
    then the compiler can be modified to explicitly use these helper
    when appropriate.
    
    This fixes the case of a negative X register and allows to lift
    the restriction that bpf programs with negative offsets can't
    be jited.
    
    Signed-of-by: Jan Seiffert <kaffeemonster@googlemail.com>
    Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
    Signed-off-by: David S. Miller <davem@davemloft.net>
