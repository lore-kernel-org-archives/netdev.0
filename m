From: Al Viro <viro@ZenIV.linux.org.uk>
Subject: Re: [patch 02/21] drivers/net/3c501.c: replace init_module&cleanup_module with module_init&module_exit
Date: Fri, 28 Mar 2008 21:58:17 +0000
Message-ID: <20080328215817.GF10722@ZenIV.linux.org.uk>
References: <200803282141.m2SLfGGa011804@imap1.linux-foundation.org> <20080328214755.GE10722@ZenIV.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jeff@garzik.org, netdev@vger.kernel.org, jkschind@gmail.com
To: akpm@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from zeniv.linux.org.uk ([195.92.253.2]:39444 "EHLO
	ZenIV.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757519AbYC1V6V (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Mar 2008 17:58:21 -0400
Content-Disposition: inline
In-Reply-To: <20080328214755.GE10722@ZenIV.linux.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Mar 28, 2008 at 09:47:55PM +0000, Al Viro wrote:
> On Fri, Mar 28, 2008 at 02:41:16PM -0700, akpm@linux-foundation.org wrote:
> 
> > Replace init_module and cleanup_module with static functions and
> > module_init/module_exit.
> 
> Would the esteemed sir bother to build the resulting tree with drivers
> in question non-modular?
> 
> Damnit, people, try to think for a minute.  If these functions were
> not called directly in non-modular case, the driver would not work
> built-in.  Which is not apriori impossible, but might warrant some
> further investigation.  Use of grep, for starters...

Argh.  My apologies for sloppiness of flame.  Conclusion still stands.

	* This conversion makes the modular-case init run in built-in case.
	* Either driver does not work built-in, or we'd just gained duplicate
init for built-in.
	* Built-in init would have to be non-static.  Therefore, looking for
non-static functions in that sucker would be a good idea.
	* The very first one is
 * el1_probe:           -       probe for a 3c501
 * @dev: The device structure passed in to probe.
 *
 * This can be called from two places. The network layer will probe using
 * a device structure passed in with the probe information completed. For a
 * modular driver we use #init_module to fill in our own structure and probe
 * for it.
 *
 * Returns 0 on success. ENXIO if asked not to probe and ENODEV if asked to
 * probe and failing to find anything.
 */

struct net_device * __init el1_probe(int unit)

	* Explanatory comment aside, grep for el1_probe() in drivers/net
immediately shows that it *is* called from drivers/net/Space.c and yes,
with the patch in question you are a happy owner of messed probe/init
sequence.  Looking at drivers/net/Space.c shows that it's called from
/*  Statically configured drivers -- order matters here. */
static int __init net_olddevs_init(void)
and yes, it *does* matter - google for gory details, but it's very much
a "hang the box on blind probe in the wrong order" territory.
