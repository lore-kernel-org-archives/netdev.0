From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH][RFC] tcp: fix ambiguity in the `before' relation
Date: Wed, 20 Dec 2006 10:31:12 -0800 (PST)
Message-ID: <20061220.103112.85414445.davem@davemloft.net>
References: <200612141507.06888@strip-the-willow>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37341
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1030266AbWLTSbU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Dec 2006 13:31:20 -0500
To: gerrit@erg.abdn.ac.uk
In-Reply-To: <200612141507.06888@strip-the-willow>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Thu, 14 Dec 2006 15:07:06 +0000

> While looking at DCCP sequence numbers, I stumbled over a problem with
> the following definition of before in tcp.h:
> 
> static inline int before(__u32 seq1, __u32 seq2)
> {
>         return (__s32)(seq1-seq2) < 0;
> }
> 
> Problem: This definition suffers from an an ambiguity, i.e. always
>                    
>            before(a, (a + 2^31) % 2^32)) = 1
>            before((a + 2^31) % 2^32), a) = 1
>  
>          In text: when the difference between a and b amounts to 2^31,
>          a is always considered `before' b, the function can not decide. 
>          The reason is that implicitly 0 is `before' 1 ... 2^31-1 ... 2^31
>       
> Solution: There is a simple fix, by defining before in such a way that 
>           0 is no longer `before' 2^31, i.e. 0 `before' 1 ... 2^31-1
>           By not using the middle between 0 and 2^32, before can be made 
>           unambiguous. 
>           This is achieved by testing whether seq2-seq1 > 0 (using signed
>           32-bit arithmetic).
> 
> I attach a patch to codify this. Also the `after' relation is basically 
> a redefinition of `before', it is now defined as a macro after before.
> 
> Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>

Applied, thanks Gerrit.

I went over this patch and analysis a dozen times, because I
couldn't believe something like this has been broken for
so long :-)

Even BSD suffers of this issue, since the beginning.  See
SEQ_LT() in tcp_seq.h, and it seems that BSD's timestamp
sequence checking has the issue too (see TSTMP_LT() macro
in OpenBSD's tcp_input.c)

It seems that our PAWS timestamp checks are ok because we do:

(s32)(tp->rx_opt.ts_recent - tp->rx_opt.rcv_tsval) > TCP_PAWS_WINDOW

and

(s32)(tp->rx_opt.rcv_tsval - tp->rx_opt.ts_recent) >= 0

Thanks again Gerrit.


