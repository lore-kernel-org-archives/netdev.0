From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: [Xen-devel] Re: [PATCH 3/4] [Net] Support Xen accelerated
 network plugin modules
Date: Tue, 22 May 2007 08:05:12 -0700
Message-ID: <20070522080512.6c9528a1@freepuppy>
References: <C2785EC4.F4E3%keir@xensource.com>
	<1179837868.28562.22.camel@moonstone.uk.level5networks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Keir Fraser <keir@xensource.com>, muli@il.ibm.com,
	netdev@vger.kernel.org, xen-devel@lists.xensource.com,
	herbert@gondor.apana.org.au
To: Kieran Mansley <kmansley@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([207.189.120.12]:42747 "EHLO smtp.osdl.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756790AbXEVPGM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 22 May 2007 11:06:12 -0400
In-Reply-To: <1179837868.28562.22.camel@moonstone.uk.level5networks.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 22 May 2007 13:44:28 +0100
Kieran Mansley <kmansley@solarflare.com> wrote:

> On Tue, 2007-05-22 at 08:48 +0100, Keir Fraser wrote:
> > 
> > 
> > On 22/5/07 08:28, "Kieran Mansley" <kmansley@solarflare.com> wrote:
> > 
> > > On Tue, 2007-05-22 at 08:15 +0100, Kieran Mansley wrote:
> > >> RCU on its own wouldn't
> > >> prevent the accelerated plugin being unloaded while netfront was using
> > >> one of the hooks.
> > > 
> > > Hmm, actually I think it could be used to do that.  I'll take a look.
> > 
> > Eagerly zap the function pointers, then wait one RCU period so every CPU
> > goes through a quiescent point before unloading the module?
> > 
> >  -- Keir
> 
> Am I right in thinking that if one of the functions that was protected
> by RCU was to block, that would be a bad thing?  Clearly the data path
> hooks can't/don't block, but I'm not sure it's so obvious for things
> like probing a new device. 
> 
> Kieran
> 

The same thing is already done to handle network protocols already.
RCU is used for the object handle (including function pointers).
You need to use:
  * put rcu structure in accelerator list member
    and initialize it to the callback
  * on addition increase refcount
on deletion
  * call list_del_rcu() on removal
  * in rcu callback you do last step
	like drop module refcount and free.

-- 
Stephen Hemminger <shemminger@linux-foundation.org>
