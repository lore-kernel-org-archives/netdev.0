From: David Stevens <dlstevens@us.ibm.com>
Subject: Re: [Patch net-next v3 3/4] vxlan: add ipv6 support
Date: Mon, 15 Apr 2013 09:27:45 -0400
Message-ID: <OF357ECAC4.3A0B75DA-ON85257B4E.0048447C-85257B4E.0049F64D@us.ibm.com>
References: <1365387536-25217-1-git-send-email-amwang@redhat.com>	 <1365387536-25217-3-git-send-email-amwang@redhat.com>
	 <OF82703BAC.20223779-ON85257B47.0040E058-85257B47.0046C8A6@us.ibm.com> <1365504446.2557.17.camel@cr0>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Stephen Hemminger <stephen@networkplumber.org>
To: Cong Wang <amwang@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e8.ny.us.ibm.com ([32.97.182.138]:39151 "EHLO e8.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751741Ab3DON2K (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 15 Apr 2013 09:28:10 -0400
Received: from /spool/local
	by e8.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <dlstevens@us.ibm.com>;
	Mon, 15 Apr 2013 09:28:09 -0400
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by d01dlp01.pok.ibm.com (Postfix) with ESMTP id B1E4A38C8047
	for <netdev@vger.kernel.org>; Mon, 15 Apr 2013 09:27:59 -0400 (EDT)
Received: from d03av06.boulder.ibm.com (d03av06.boulder.ibm.com [9.17.195.245])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r3FDRwLh331306
	for <netdev@vger.kernel.org>; Mon, 15 Apr 2013 09:27:59 -0400
Received: from d03av06.boulder.ibm.com (loopback [127.0.0.1])
	by d03av06.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r3FDUa8C014738
	for <netdev@vger.kernel.org>; Mon, 15 Apr 2013 07:30:37 -0600
In-Reply-To: <1365504446.2557.17.camel@cr0>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Cong Wang <amwang@redhat.com> wrote on 04/09/2013 06:47:26 AM:

> From: Cong Wang <amwang@redhat.com>
> To: David Stevens/Beaverton/IBM@IBMUS
> Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
> Stephen Hemminger <stephen@networkplumber.org>
> Date: 04/09/2013 06:47 AM
> Subject: Re: [Patch net-next v3 3/4] vxlan: add ipv6 support
> 
> On Mon, 2013-04-08 at 08:53 -0400, David Stevens wrote:
> >         With your current definitions, "sin6" is just an in6_addr, but
> > you are not checking the sin6_scope_id, which is not correct for IPv6
> > link-local addresses. You can rely on "ifindex" in vxlan_rdst for
> > fdb entries, but you'd at least need to make sure it is not 0 for LL
> > scope, and you still need sin6_scope_id to match for calls in 
> > vxlan_snoop()
> > and vxlan_group_used(). The same sin6_addr with different
> > sin6_scope_id
> > for link-local addrs is not the same address in v6. 
> 
> It seems this is not very easy to do, at least for me. So I will send
> another patch after this patcheset is merged, now let's not make this to
> be a blocker for this patchset.

Cong,
        I'm not sure if you mean you're withdrawing the v6 support patch,
or asking that we address link-local v6 addresses separately. I don't
think we want to have code in a distro that doesn't handle LL properly
without error when an LL address is added, and I also think a solution
may influence the netlink API, so I'd like to see LL support go in at
the same time as v6 support.
        I think we want essentially the same solution used in the socket
API, so the layout should be a sockaddr with the sin6_scope_id field
present and verified for the AF_INET6 family variant. It could be a
matching type with a different name if there are user-level include
issues as Dave referenced before.
        Then, if it's an AF_INET6 and a link-local sin6_addr, the
sin6_scope_id must be non-zero and a valid interface index, or return
error. Deleted interfaces could still result in stale fdb entries, but
those could be removed (or at least matching packets dropped) based on
the route failures they would cause during packet forwarding.

                                                                +-DLS
