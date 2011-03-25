From: Jan =?ISO-8859-1?Q?L=FCbbe?= <jluebbe@debian.org>
Subject: Re: [PATCH] Fix IP timestamp option (IPOPT_TS_PRESPEC) handling in
 ip_options_echo()
Date: Fri, 25 Mar 2011 07:11:12 +0100
Message-ID: <1301033472.3890.181.camel@mordor>
References: <1300988662-13204-1-git-send-email-jluebbe@debian.org>
	 <20110324.162005.71589730.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sirius.lasnet.de ([78.47.116.19]:33027 "EHLO sirius.lasnet.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932237Ab1CYGyH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 25 Mar 2011 02:54:07 -0400
In-Reply-To: <20110324.162005.71589730.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi!

On Thu, 2011-03-24 at 16:20 -0700, David Miller wrote: 
> From: Jan Luebbe <jluebbe@debian.org>
> Date: Thu, 24 Mar 2011 18:44:22 +0100
> 
> > -					if (soffset + 8 <= optlen) {
> > +					if (soffset + 7 <= optlen) {
> 
> I don't see how you can legally reduce this check from 8 to 7 bytes.
> 
> > +						if (inet_addr_type(dev_net(skb_dst(skb)->dev), addr) != RTN_UNICAST) {
> >  							dopt->ts_needtime = 1;
> >  							soffset += 8;
> >  						}
> 
> Yet keep this code which advances soffset by 8.

The encoding of soffset is a bit unusual, in that the option is 'full'
when soffset = optlen + 1. We need to keep advancing soffset by 8
because that's really the amount of data per entry.

In ip_options_compile, near 'case IPOPT_TS_PRESPEC:' (line 382 in
2.6.38), we have: 
      case IPOPT_TS_PRESPEC:
        if (optptr[2]+7 > optptr[1]) {  
                pp_ptr = optptr + 2;            
                goto error;
        }
        opt->ts = optptr - iph;
        {
                __be32 addr;
                memcpy(&addr, &optptr[optptr[2]-1], 4);
                if (inet_addr_type(net, addr) == RTN_UNICAST)
                        break;
                if (skb)
                        timeptr = (__be32*)&optptr[optptr[2]+3];
        }
        opt->ts_needtime = 1;
        optptr[2] += 8;
        break;

Here optptr[1] matches optlen from _echo and optptr[2] is soffset.

When we use soffset to index into the packet we substract 1. See the
memcpy in my patch which reads from the packet and also the memcpys in
_compile around line 390.

If we checked soffset + 8 <= optlen, we abort updating the timestamp
when exactly space for one entry remains.

Also, I don't think writing to unallocated memory is possible when the
IP header in the echoed packet are doesn't have enough space for the
length indicated by optlen, as we clear dopt with memset(dopt, 0,
sizeof(struct ip_options)) so it dopt must have the right size already.

Best regards,
Jan

