From: Krzysztof Mazur <krzysiek@podlesie.net>
Subject: Re: [PATCH v2 3/3] pppoatm: protect against freeing of vcc
Date: Tue, 27 Nov 2012 18:39:06 +0100
Message-ID: <20121127173906.GA11390@shrek.podlesie.net>
References: <1350926091-12642-1-git-send-email-krzysiek@podlesie.net>
 <1350926091-12642-3-git-send-email-krzysiek@podlesie.net>
 <1354036592.2534.6.camel@shinybook.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, nathan@traverse.com.au
To: David Woodhouse <dwmw2@infradead.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1354036592.2534.6.camel@shinybook.infradead.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Nov 27, 2012 at 05:16:32PM +0000, David Woodhouse wrote:
> Krzysztof, you've fixed a bunch of races... but I think there's one
> still left.
> 
> An ATM driver will often have code like this, which gets called from
> arbitrary contexts:
>         if (vcc->pop)
>                 vcc->pop(vcc, skb);
> 
> Now, what happens if pppoatm_send(vcc, NULL) happens after the address
> of vcc->pop (currently pppoatm_pop) has been loaded, but before the
> function is actually called?
> 
> You tear down all the setup and set vcc->user_back to NULL. And then
> pppoatm_pop() gets called. And promptly crashes because pvcc is NULL.
> 
> A lot of these problems exist for br2684 too, and in prodding at it a
> little I can consistently crash the system by sending a flood of
> outbound packets while I kill the br2684ctl program. I end up in
> br2684_pop() with vcc->user_back == NULL. In looking to see how you'd
> fixed that in pppoatm, I realised that you haven't... :)
> 

Yes, I missed that one - it's even worse, I introduced that bug 
in "[PATCH 1/7] atm: detach protocol before closing vcc". Before that
patch that scenario shouldn't happen because vcc was closed before
calling pppoatm_send(vcc, NULL) - the driver should provide appropriate
synchronization.

I think that we should just drop that patch. With later changes it's not
necessary - the pppoatm_send() can be safely called while closing vcc.

Krzysiek
