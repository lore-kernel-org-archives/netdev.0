From: Rusty Russell <rusty@rustcorp.com.au>
Subject: Re: [netfilter-core] Re: skb linearization
Date: Tue, 16 Sep 2003 12:58:53 +1000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030916033014.5A03D2C106@lists.samba.org>
References: <1063662564.1358.19.camel@localhost>
Cc: coreteam@netfilter.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Andras Kis-Szabo <kisza@securityaudit.hu>
In-reply-to: Your message of "15 Sep 2003 23:49:24 +0200."
             <1063662564.1358.19.camel@localhost>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

In message <1063662564.1358.19.camel@localhost> you write:
> I got the large linearization patch from Rusty. At first look I noticed
> that it could be a large work for IPv6, BCF the extension headers.
> At netfilter6 we inspect these headers in ip6_target.c, ip6t_LOG.c and
> the extension header matches.
> So, my real questions. Could you check some files for me?
> 
> - net/ipv6/ah6.c:ipv6_clear_mutable_options()
> 	this function uses the skb as a linear one w/o skb_copy_bits or
> 	skb_linearize. Am I right?

Well, yes, but this is at output, and current code always produces a
linear header (the data may be non-linear for zero-copy though).  I
tried not to rely on this in netfilter hooks, in case it changes
later.

> - net/ipv6/ah6.c
> 	where are these functions called? Before or after the netfilter 
	hooks?

Best guesses follow based on a little grepping.  Dave/Alexey will
correct me if this is wrong 8)

ah6_output called as a dst->output function, so after
NF_IP6_POST_ROUTING.

ah6_input called from xfrm6_rcv, called from ip6_input_finish, so
after NF_IP6_LOCAL_IN.

> - net/ipv6/esp6.c
> 	mainly the same functions as ah6.c, but this file uses 	skb_copy_bits!

It's an input function, so can't assume linear beyond the header.
Header is pulled in ip6_input_finish, although I feel it should be
done in ip6_input itself so the netfilter hook gets a linear header,
but there's IPv6 header wierdness here (multuple handlers as it
iterates through the headers) which I think makes the current ordering
reasonable.

> - net/ipv6/exthdrs.c:ipv6_invert_rthdr()
> 	this function manipulates/modifies the routing addresses in an
> 	extension header. It uses the skb as a linear one w/o checks or
> 	linearization. Am I right? (This extension header can be far 	from the
> main IPv6 header and this header can contain lot of IPv6 	addresses in a
> chain.)

Headers are linearized in ip6_input_finish IIUC.

> - net/ipv6/exthdrs.c:ipv6_skip_exthdr()
> 	it is a nice solution with linearization of the required areas 	only.
> It can be a good solution to use in the extension header based matches.

Yes, that is a good plan.

> The whole function could be used in the 	ip6_targt.c:ip6_packet_match()
> to get the real next level value. 	(Currently I have added a similar
> function into that function.)
> 	Do you see any chance to export this function into the 	namespace?

Hmm, they look similar, but different enough that merging them might
not be worthwhile: you already use ipv6_ext_hdr().  You'd have to try
it and see if it gets uglier or prettier.

> The 3rd problem is the ip6t_LOG.c, but I think that we stole the
> solution from ipt_LOG.c, as usual :)

Good idea.

Cheers,
Rusty.
--
  Anyone who quotes me in their sig is an idiot. -- Rusty Russell.
