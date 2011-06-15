From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Subject: Re: [ipv6] valid_lft and active connections
Date: Wed, 15 Jun 2011 12:37:41 +0900
Message-ID: <1308109061.19757.40.camel@cirrhata>
References: <4DF73A6D.1050809@samba.org> <1308051710.3424.15.camel@takos>
	 <4DF753C6.1000700@samba.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-2022-JP"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, yoshfuji@linux-ipv6.org
To: "Stefan (metze) Metzmacher" <metze@samba.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 94.43.138.210.xn.2iij.net ([210.138.43.94]:39875 "EHLO
	mail.st-paulia.net" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753939Ab1FODhx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Jun 2011 23:37:53 -0400
In-Reply-To: <4DF753C6.1000700@samba.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Stefan (metze) Metzmacher wrote:
> Am 14.06.2011 13:41, schrieb YOSHIFUJI Hideaki:
> > Hello.
> > 
> > Stefan (metze) Metzmacher wrote:
> >> If I use ipv6 addresses with valid_lft != forever, the ipv6 addresses
> >> are removed from the interface if the valid_lft expires, even if there're
> >> established connection which use with address.
> >>
> >> Would it be possible keep the address until the last active connection
> >> is closed? Otherwise the usable of the privacy extensions will make
> >> very long living tcp connections impossible.
> >>
> > 
> > I cannot imagine why you do not hear RAs before the address expires.
> 
> They do not reset the valid lifetime counter for temporary addresses.
> 
> And I think that valid_lft and preferred_lft should work with a manual
> configured setup in a similar way.

This is because of RFC3041 Section 3.3:

|   1) Process the Prefix Information Option as defined in [ADDRCONF],
|      either creating a public address or adjusting the lifetimes of
|      existing addresses, both public and temporary.  When adjusting the
|      lifetimes of an existing temporary address, only lower the
|      lifetimes.  Implementations must not increase the lifetimes of an
|      existing temporary address when processing a Prefix Information
|      Option.

It would be make sense to allow extending valid lifetime of non-deprecated
addresses, but not sure.

> > And well, I don't think it is a good idea because it is not what
> > "valid lifetime" means.
> > 
> > We have 3 states:
> > 
> > 1) time <= preferred lifetime
> > 2) preferred lifetime < time <= valid lifetime
> > 3) valid lifetime < lifetime
> > 
> > You can make new connection during the period of 1 and you can continue
> > using that connection during the period of 1 and 2.
> 
> But it means tcp connection can not last longer than the valid lifetime of
> a temporary address, which is very ugly as the application layer will
> run into
> timeouts instead of getting an immediate error when the kernel drops the
> related ip.
> 

Valid lifetime represents administrative "hard" lifetime.  If it 
expired, all address must be gone.

> > Ask network administrator to advertise longer "valid" lifetime, if
> > needed, and you may want to make net.ipv6.conf.*.max_addresses larger.
> 
> My aim is to have a preferred lifetime of say 4 hours, in order to have
> no limit
> on the lifetime of tcp connections, I'd have to set valid lifetime to
> forever,
> which means that I'll have about 180 addresses on an interface after
> a month (8760 after a year) which are mostly all unused.

This is how it works.

How can you determine if one address is not unused at all?
For UDP, applications only know, for example.

In fact, RFC3041 Section 3.4 says:
|   As an optional optimization, an implementation may wish to remove a
|   deprecated temporary address that is not in use by applications or
|   upper-layers.  For TCP connections, such information is available in
|   control blocks.  For UDP-based applications, it may be the case that
|   only the applications have knowledge about what addresses are
|   actually in use.  Consequently, one may need to use heuristics in
|   deciding when an address is no longer in use (e.g., the default
|   TEMP_VALID_LIFETIME suggested above).

Of course, we could have some sysctl (but default must be off
(or moderate; do it if the number addresses exceeds some limit).

> Do you know a better solution?

Ask your administrator to advertise larger valid lifetime.
Otherwise, other implementation will have similar issues, anyway.

We could have above "optimization" with sysctl.

And, please note that if you want to change address preference in 
an application, consider using IPV6_ADDR_PREFERENCES socket
option.

--yoshfuji

