From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [TCP]: Fix truesize underflow
Date: Tue, 18 Apr 2006 13:22:56 -0700 (PDT)
Message-ID: <20060418.132256.110004342.davem@davemloft.net>
References: <20060418123204.GA3962@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: bb@kernelpanic.ru, kernel@linuxace.com, nipsy@bitgnome.net,
	jesse.brandeburg@intel.com, jrlundgren@gmail.com, cat@zip.com.au,
	djani22@dynamicweb.hu, yoseph.basri@gmail.com, mykleb@no.ibm.com,
	olel@ans.pl, michal@feix.cz, chris@scorpion.nl,
	netdev@vger.kernel.org, jesse.brandeburg@gmail.com, ak@suse.de,
	jgarzik@pobox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:6786
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S932322AbWDRUXV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 18 Apr 2006 16:23:21 -0400
To: herbert@gondor.apana.org.au
In-Reply-To: <20060418123204.GA3962@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Tue, 18 Apr 2006 22:32:04 +1000

> You're absolutely right about there being a problem with the TSO packet
> trimming code.  The cause of this lies in the tcp_fragment() function.
> 
> When we allocate a fragment for a completely non-linear packet the
> truesize is calculated for a payload length of zero.  This means that
> truesize could in fact be less than the real payload length.
> 
> When that happens the TSO packet trimming can cause truesize to become
> negative.  This in turn can cause sk_forward_alloc to be -n * PAGE_SIZE
> which would trigger the warning.
> 
> I've copied the code you used in tso_fragment which should work here.
> 
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Thanks for discovering this, very nice work Herbert.

So what we find out time and time again, is that the TSO splitting and
trimming code enforces that the skb->truesize of every TCP packet must
be accurate at all times.

I think it is deserving of some run time assertions, else these bugs
will elude us continually.  Luckily there are only a few places that
would need the run time assertion checks on skb->truesize, and I'll
try to spend a few cycles on implementing this soon.

Patch applied, thanks a lot!

