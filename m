From: Stefan Richter <stefanr@s5r6.in-berlin.de>
Subject: Re: IPv6 over firewire
Date: Sat, 12 Jan 2013 10:24:52 +0100
Message-ID: <20130112102452.13babc65@stein>
References: <50EF1AEB.1080704@gmail.com>
	<20130110210912.09c62d38@stein>
	<50F10E94.9090302@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux1394-devel@lists.sourceforge.net, yoshfuji@linux-ipv6.org,
	netdev@vger.kernel.org
To: stephan.gatzka@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from einhorn.in-berlin.de ([192.109.42.8]:57701 "EHLO
	einhorn.in-berlin.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752510Ab3ALJZL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 12 Jan 2013 04:25:11 -0500
In-Reply-To: <50F10E94.9090302@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[Cc'ing netdev.  This is about
http://marc.info/?l=linux1394-devel&m=135723690427469]

On Jan 12 Stephan Gatzka wrote:
> On Jan 10 Stefan Richter wrote:
> > Relative to mentioned preliminary patch, there need to be some cleanups
> > done, in my opinion:
> >   - The move of struct fwnet_device from drivers/firewire/net.c into
> >     include/linux/firewire.h, the inclusion of <linux/firewire.h> into
> >     net/ipv6/ndisc.c, and the use of <linux/firewire.h> definitions in
> >     net/ipv6/ndisc.c need to be undone.
> >   - Instead, the dependencies should be solved such that
> >     include/net/ndisc.h (or whatever net header would be appropriate
> >     for these kinds of definitions) defines RFC 3146 specific structs
> >     or/and functions (or extensions of existing functions by additional
> >     arguments) or/and driver ops (alias methods alias callbacks, in the
> >     style of net_device.header_ops and the likes).  Then, both
> >     net/ipv6/ndisc.c and drivers/firewire/net.c would use these new RFC
> >     3146 related definitions but net/ipv6/ndisc.c would not become a
> >     user of any <linux/firewire.h> definitions.
> 
> 
> Just to know if I understood you correctly. You want to have a function 
> pointer in struct net_device like fill_link_layer_option(). This 
> function pointer has to be set when allocating a struct net_device object.
> 
> This is certainly possible, but if I do so, I'd assume that then _every_ 
> network device (ethernet, infiniband, ...) in linux has to implement 
> such a function. Otherwise, I think the ndisc code only for a firewire 
> net device will call the callback function. So I would introduce a 
> callback routine in struct net_device just for firewire.
> 
> The problem is, that right now, firewire is the _only_ device that 
> requires this special link layer option format. All other network device 
> do not require this right now. So I ask myself if its worth to introduce 
> this callback routine just for firewire.

I haven't looked in detail into what is really required here.  Maybe a new
driver op (callback) isn't actually needed.

But if a new callback is needed, it doesn't have to burden the kernel much:

  - In the linux-kernel OOP model, there are mandatory methods as well
    as optional methods.  A new method for RFC 3146 Neighbor Discovery
    should of course be an optional one.

  - There is a downside to optional methods:  The core code which may
    have to use the method first needs to do a NULL check of the
    method's function pointer or needs to check a correlated
    capabilities flag or something like that.  Such additional checks
    are undesirable in hot paths, but I suppose IPv6 Neighbor Discovery
    is not a particularly hot path.

  - There is another downside:  Each new driver method increases the
    memory footprint of instances of respective function pointer tables
    by 4 or 8 bytes.

Both downsides can be countered somewhat by enclosing the respective
code into #ifdef CONFIG_RFC3146_NDISC...#endif and have something like
    select RFC3146_NDISC if IPV6 = y || (IPV6 = m && FIREWIRE_NET = m)
in the "config FIREWIRE_NET" section.

But the new callback (if one is really needed) doesn't have to be a driver
method.  It could also look about like this:

    include/net/ndisc.h:
    -extern struct ndisc_options *ndisc_parse_options(u8 *opt, int opt_len,
    -		struct ndisc_options *ndopts);
    +extern struct ndisc_options *__ndisc_parse_options(u8 *opt,
    +		int opt_len, struct ndisc_options *ndopts,
    +		whatever_type *callback);
    +
    +static inline struct ndisc_options *ndisc_parse_options(u8 *opt,
    +		int opt_len, struct ndisc_options *ndopts)
    +{
    +	return __ndisc_parse_options(opt, len, ndopts, NULL);
    +}

    net/ipv6/ndisc.c:
    -struct ndisc_options *ndisc_parse_options(u8 *opt, int opt_len,
    -		struct ndisc_options *ndopts)
    +struct ndisc_options *__ndisc_parse_options(u8 *opt, int opt_len,
    +		struct ndisc_options *ndopts, whatever_type *callback)
     {

Or the (optional!) callback could be a new member of struct ndisc_options.

However, does net/ipv6/ndisc.c really need to be aware of the RFC 3146
Neighbor Discovery related packet header layouts?  Isn't it possible to
rewrite these headers in-place in drivers/firewire/net.c?
-- 
Stefan Richter
-=====-===-= ---= -==--
http://arcgraph.de/sr/
