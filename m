From: Vlad Yasevich <vladislav.yasevich@hp.com>
Subject: Re: Why does a connect to IPv6 LLA address fail ?
Date: Thu, 08 Nov 2007 13:15:52 -0500
Message-ID: <47335258.4000806@hp.com>
References: <20071107094007.GA15575@pingi.kke.suse.de> <20071107112838.GA22180@dhcp79.suse.cz> <4732151B.70309@hp.com> <200711081901.59334.agruen@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Jiri Bohac <jbohac@suse.cz>, netdev@vger.kernel.org,
	yoshfuji@linux-ipv6.org, kkeil@suse.de
To: Andreas Gruenbacher <agruen@suse.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from palrel10.hp.com ([156.153.255.245]:53993 "EHLO palrel10.hp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755186AbXKHSPz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 8 Nov 2007 13:15:55 -0500
In-Reply-To: <200711081901.59334.agruen@suse.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Andreas Gruenbacher wrote:
> On Wednesday 07 November 2007 20:42, Vlad Yasevich wrote:
>> The reason is that 2 different hosts may have the same link-local
>> address as long as they are on different links.  If the sender is
>> connected to both links then it may send the packet to the wrong
>> destination.
> 
> Good point.
> 
> What's confusing is that connect(2) fails even if the host itself has the 
> specified address. This isn't necessary.

Yes and no.  Since linux doesn't have the concept of default zone, we have
to fail, because from the perspective of the kernel, the address was not
fully specified.  OTOH, since this is our address, we 'could' have all
the info.

The problem is that this verification happens before we hit the routing logic.
It's an explicit check the if the sin6_scope_id is not set and we are not bound
to an interface, it's an error.

> 
> What's even more confusing is that the kernel doesn't seem to honor the 
> interface in all cases: with
>    fe80::20f:20ff:fe3b:e9c3 on eth0 and
>    ::1 on lo,
> I get the following:
> 
>   ping6 fe80::20f:20ff:fe3b:e9c3		fails with EINVAL
>   ping6 fe80::20f:20ff:fe3b:e9c3%eth0		succeeds

Yes, but if you run a capture, you'll see the packet on loopback.  That's
because you have a route to this address.

>   ping6 fe80::20f:20ff:fe3b:e9c3%lo		succeeds

Yes, same thing.  Routing code takes care of it.

> 
> At least the last ping should fail, shouldn't it?

No, because both pings really go over loopback.  You are on the same system
and have 'local' routes for those addresses:
  ip -6 r l t local

> 
>> A different and some might say 'better' alternative is to define a
>> default link.  Thus when the zone id is not specified the default is used.
>> This will work fine for link-scoped addresses.  A default zone would also
>> need to be defined for other scopes as well.  That's just one idea.
> 
> I think at least for host with only one link (in addition to loopback), 
> selecting that link for non-local addresses would make sense.
> 

Yes, you could do that.  Or you can push the interface check to the routing code
and do some logic to see if you can "select" an interface.

-vlad
