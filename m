From: Andi Kleen <ak@suse.de>
Subject: Re: dst_entry and friends
Date: Mon, 29 Apr 2002 16:55:03 +0200
Sender: owner-netdev@oss.sgi.com
Message-ID: <20020429165503.A14300@wotan.suse.de>
References: <15561.20004.964497.762468@robur.slu.se> <3CCD1D18.F33EAEE8@sics.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <owner-netdev@oss.sgi.com>
To: Gabriel Paues <gabriel@sics.se>
Content-Disposition: inline
In-Reply-To: <3CCD1D18.F33EAEE8@sics.se>
List-Id: netdev.vger.kernel.org

On Mon, Apr 29, 2002 at 12:14:48PM +0200, Gabriel Paues wrote:
> My idea is to use netfilter and in the PRE_ROUTING-hook check the flowlabel for
> values other than zero, and set the dst_entry in the skbuff to something with
> its input-function to ip6_output. I dont know if I should allocate this
> fabricated dst_entry myself or if I should scan the list of already existing
> ones. By setting the input-function-pointer to ip6_output i will skip the whole

That won't work for most networking protocols, which always route themselves.
All you can do is to drop the route later in netfilter and reroute/resubmit

Still your concept will fail for path mtu discovery for example, which
assumes that an incoming ICMP can be matched to an dst_entry in the routing
cache to communicate the new pmtu. 

It may be easier to just change ip_route_output(). Routes are often 
cached however, so you would need to make sure that the caches 
are invalidated when the flow label changes (e.g. by setting dst->obsolete) 

Overall the concept does not look very promising however. I guess to make 
the labels unique you'll have to add srcip/dstip to your private tables too,
and that means that the label lookup is exactly equivalent in cost to 
a normal routing cache lookup - even if you didn't need the src/dst it 
probably wouldn't be much cheaper.

-Andi
