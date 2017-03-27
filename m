From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH net-next 1/4] net: mpls: Convert number of nexthops to u8
Date: Mon, 27 Mar 2017 17:54:34 -0500
Message-ID: <87wpbagwk5.fsf@xmission.com>
References: <1490461408-9551-1-git-send-email-dsa@cumulusnetworks.com>
        <1490461408-9551-2-git-send-email-dsa@cumulusnetworks.com>
        <871stjmn0o.fsf@xmission.com>
        <b370c097-d0ad-95c5-2687-264da22d37d6@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netdev@vger.kernel.org, roopa@cumulusnetworks.com,
        rshearma@brocade.com
To: David Ahern <dsa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out03.mta.xmission.com ([166.70.13.233]:53067 "EHLO
        out03.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752773AbdC0XAk (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 27 Mar 2017 19:00:40 -0400
In-Reply-To: <b370c097-d0ad-95c5-2687-264da22d37d6@cumulusnetworks.com> (David
        Ahern's message of "Mon, 27 Mar 2017 08:43:05 -0600")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Ahern <dsa@cumulusnetworks.com> writes:

> On 3/26/17 9:11 PM, Eric W. Biederman wrote:
>> I don't like this.  Byte writes don't exist on all architectures.
>> 
>> So while I think always writing to rtn_nhn_alive under the
>> rtn_lock ensures that we don't have wrong values written
>> it is quite subtle.  And I don't know how this will interact with other
>> fields that you are introducing.
>> 
>> AKA this might be ok, but I expect this formulation of the code
>> will easily bit-rot and break.
>
> net/ has other use cases -- e.g., ipv6 tunneling has proto as a u8.
>
> It unrealistic for a route to have 255 or more nexthops so the point of
> this patch is to not waste 8 bytes tracking it - especially when
> removing it gets routes with ipv4 and ipv6 via's into a cache line.

The argument isn't that 255 nexthops is too few but that there is no
instruction to write to a single byte on some architectures.

My concern is that if we are writing a field using a non-byte write
without care we could easily have confusion with adjacent fields.

> I can make the alive counter a u16 without increasing the size of the
> struct. I'd prefer to leave it as an u8 to have a u8 hole for flags
> should something be needed later.

u16 is no better than u8.

The original architecture was that all changes to an mpls route would
be done in read, copy, allocate a new route, and replace the pointer
fashion.  Which allows rcu access.

There was argument made that it is silly to do that when a the network
device for a hop goes up or down.  Something about the memory allocation
not being reliable as I recall. And so we now have rt_nhn_alive and it
stored as an int so that it can be read and written atomically.

It is absolutely a no-brainer to change rt_nhn to a u8.  And I very much
appreciate all work to keep mpls_route into a single cache line.  As in
practices that is one of the most important parts to performance.

Which leads to the functions mpls_ifup, mpls_ifdown, and
mpls_select_multipath.

To make this all work correctly we need a couple of things.
- A big fat comment on struct mpls_route and mpls_nh about how
  and why these structures are modified and not replaced during
  nexthop processing.  Including the fact that it all modifications
  may only happen with rntl_lock held.

- The use of READ_ONCE and WRITE_ONCE on all rt->rt_nhn_alive accesses,
  that happen after the route is installed (and is thus rcu reachable).

- The use of READ_ONCE and WRITE_ONCE on all nh->nh_flags accesses,
  that happen after the route is installed (and is thus rcu reachable).

Someone needs to fix mpls_ifup AKA something like:

 			struct net_device *nh_dev =
 				rtnl_dereference(nh->nh_dev);

+			unhsigned int flags = READ_ONCE(nh->nh_flags);
+			if (nh_dev == dev) {
+				flags &= ~nh_flags;
+				WRITE_ONCE(nh->nh_flags, flags);
+			}
+			if (!(flags & (RTNH_F_DEAD | RTNH_F_LINKDOWN)))
+				alive++;
-			if (!(nh->nh_flags & nh_flags)) {
-				alive++;
-				continue;
-			}
-			if (nh_dev != dev)
-				continue;
-			alive++;
-			nh->nh_flags &= ~nh_flags;
 		} endfor_nexthops(rt);
 
-		ACCESS_ONCE(rt->rt_nhn_alive) = alive;
+		WRITE_ONCE(rt->rt_nhn_alive, alive);
 	}
 }

If we comment it all clearly and make very certain that the magic with
nh->nh_flags and rt->rt_nhn_alive works I don't object.  But we need to
let future people who touch the code know: here be dragons.

Especially as anything else in the same 32bits as rt->nhn_alive as our
update of that field will can rewrite those values too.  So we need
very careful to serialize any update like that.

Eric
