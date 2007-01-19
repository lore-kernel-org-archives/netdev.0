From: Pekka Pietikainen <pp@ee.oulu.fi>
Subject: Re: TKIP encryption should allocate enough tailroom
Date: Fri, 19 Jan 2007 14:23:23 +0200
Message-ID: <20070119122323.GA32747@ee.oulu.fi>
References: <87bqky759v.fsf@ten22.rhodesmill.org> <87mz4h61p0.fsf@ten22.rhodesmill.org> <20070118131631.GA24622@ee.oulu.fi> <87hcuo30di.fsf@ten22.rhodesmill.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ee.oulu.fi ([130.231.61.23]:37344 "EHLO ee.oulu.fi"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965081AbXASMXa (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 19 Jan 2007 07:23:30 -0500
To: Brandon Craig Rhodes <brandon@rhodesmill.org>
Content-Disposition: inline
In-Reply-To: <87hcuo30di.fsf@ten22.rhodesmill.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Jan 18, 2007 at 08:55:37AM -0500, Brandon Craig Rhodes wrote:
> to debugging messages!  In some circumstances, debug messages are
> always produced; in several others, net_ratelimit() is called to
> decided whether to print an error (but why in these cases and not
> others?); and in many cases, nothing is printed at all (is this
> because convention would dictate that the caller discover the error
> and print something out?).
> 
> If I want to generate a patch that festoons the ieee80211 functions
> with informative error messages, what are the guidelines?
My understanding is:

BUG_ON() / BUG() if it's a clear "impossible" condition ("function calling
me was wrong") null pointers/buffer lengths being inconsistent. Might even be
justified in this case? 

net_ratelimit() says:
/*
 * All net warning printk()s should be guarded by this function.
 */
int net_ratelimit(void)
{
        return __printk_ratelimit(net_msg_cost, net_msg_burst);
}

Especially important if the code path can be triggered by anyone (local user
or arbitrary packet from the network). Otherwise not that big a deal if it's
buggy code elsewhere in the kernel that causes the message to be printed.
You fix the code and you stop getting thousands of lines of debug
messages/second (which is why net_ratelimit() exists).

If it's an arbitrary packet from the network, there probably should even
be a sysctl to enable/disable debug output completely. IPv4 has:

static void ip_handle_martian_source(struct net_device *dev,
                                     struct in_device *in_dev,
                                     struct sk_buff *skb,
                                     __be32 daddr,
                                     __be32 saddr)
{
        RT_CACHE_STAT_INC(in_martian_src);
#ifdef CONFIG_IP_ROUTE_VERBOSE
        if (IN_DEV_LOG_MARTIANS(in_dev) && net_ratelimit()) {
                /*
                 *      RFC1812 recommendation, if source is martian,
                 *      the only hint is MAC header.
                 */
                printk(KERN_WARNING "martian source %u.%u.%u.%u from "
                        "%u.%u.%u.%u, on dev %s\n",
                        NIPQUAD(daddr), NIPQUAD(saddr), dev->name);
...

(so there's a #ifdef _and_ a log_martians sysctl to see debug output).
In general #ifdefs should be avoided.

