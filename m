From: "Jesse Brandeburg" <jesse.brandeburg@gmail.com>
Subject: Re: [PATCH] [e1000]: Remove unnecessary tx_lock
Date: Sun, 6 Aug 2006 16:16:19 -0700
Message-ID: <4807377b0608061616p5731524fvb0612bdbc32e59b@mail.gmail.com>
References: <20060804101017.GA17393@gondor.apana.org.au>
	 <20060804.163111.85390037.davem@davemloft.net>
	 <1154797002.5081.21.camel@jzny2>
	 <20060805230517.GA25468@gondor.apana.org.au>
	 <1154819868.5517.34.camel@jzny2>
	 <20060805231959.GA25768@gondor.apana.org.au>
	 <1154821010.5517.48.camel@jzny2>
	 <20060806025123.GA27051@gondor.apana.org.au>
	 <1154867083.6269.35.camel@jzny2> <1154867589.6269.40.camel@jzny2>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Herbert Xu" <herbert@gondor.apana.org.au>,
	"David Miller" <davem@davemloft.net>, shemminger@osdl.org,
	mchan@broadcom.com, jesse.brandeburg@intel.com,
	auke-jan.h.kok@intel.com,
	"Edgar E. Iglesias" <edgar.iglesias@axis.com>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.187]:7877 "EHLO
	nf-out-0910.google.com") by vger.kernel.org with ESMTP
	id S1750762AbWHFXQV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 6 Aug 2006 19:16:21 -0400
Received: by nf-out-0910.google.com with SMTP id p46so260647nfa
        for <netdev@vger.kernel.org>; Sun, 06 Aug 2006 16:16:19 -0700 (PDT)
To: hadi@cyberus.ca
In-Reply-To: <1154867589.6269.40.camel@jzny2>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 8/6/06, jamal <hadi@cyberus.ca> wrote:
> Q: Do you know the historical context of why TX_WAKE_THRESHOLD and
> E1000_TX_WEIGHT are hard-coded (and not for example related to the size
> of the ring)? Jesse?
> Otherwise i would like to submit a patch for the above. eventually
> probably even allow the setting via ethtool.

Yeah those are both created by me, interestingly up until a couple of
releases ago we had neither.

To answer your question of context, I noticed very specific problems
and fixed them with the simplest method that worked.  I figure we can
address it as time goes on (like we are now) with improvements.

As for specifics, for TX_WAKE_THRESHOLD, i noticed that we were
starting the queue after every packet was cleaned, so when the ring
went full there was a lot of queue thrash.  tg3 seemed to fix it in a
smart way and so I did a similar fix.  Note we should have at least
MAX_SKB_FRAGS (usually 32) + a few descriptors free before we should
start the tx again, otherwise we run the risk of a maximum fragmented
packet being unable to fit in the tx ring.

now, for E1000_TX_WEIGHT, that was more of an experiment as i noticed
we could stay in transmit clean up forEVER (okay not literally) which
would really violate our NAPI timeslice.  I messed with some values
and 64 didn't really seem like too bad a compromise (it does slow
things down just a tad in the general case) while really helping a
couple of tests where there were lots of outstanding transmits
happening at the same time as lots of receives.

This need for a tx weight is yet another global (design) problem with
NAPI enabled drivers, but someday I'll try to document some of the
issues I've seen.

Jesse
