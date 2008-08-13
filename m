From: David Stevens <dlstevens@us.ibm.com>
Subject: Re: Multicast socket behaviour?
Date: Wed, 13 Aug 2008 09:12:16 -0700
Message-ID: <OFB63F1889.F6ECCEEF-ON882574A4.0056055F-882574A4.00590247@us.ibm.com>
References: <loom.20080813T082132-707@post.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Cc: netdev@vger.kernel.org, netdev-owner@vger.kernel.org
To: Daniel Ng <daniel_ng11@lycos.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e32.co.us.ibm.com ([32.97.110.150]:35086 "EHLO
	e32.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751802AbYHMQM1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Aug 2008 12:12:27 -0400
In-Reply-To: <loom.20080813T082132-707@post.gmane.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

netdev-owner@vger.kernel.org wrote on 08/13/2008 01:21:58 AM:

> Hi,
> 
> The below C code registers the socket with the multicast group 
'HELLO_GROUP':
> 
>     mreq.imr_multiaddr.s_addr=inet_addr(HELLO_GROUP);
>     mreq.imr_address.s_addr=htonl(INADDR_ANY);
> 
>     mreq.imr_ifindex = if_nametoindex("ppp1");
> 
>     if (setsockopt(fd,IPPROTO_IP,IP_ADD_MEMBERSHIP,&mreq,sizeof(mreq)) < 
0) {
>         perror("setsockopt");
>         exit(1);
>     }
> 
> I understand that if 'INADDR_ANY' is used, it is up to the kernel to 
decide 
> what action to take.

Daniel,
        Neil has already pointed you to a fuller description for your
question about joining on multiple interfaces, but just
to be clear, the code above has specified the interface, so there is
no choice for the kernel. The code above will always join on "ppp1"
You can specify the interface by address (imr_address), by index
(imr_ifindex, as above), or not at all.
        In the unlikely event that you wanted the kernel to
pick which interface you join the group on, you would need
both imr_address==INADDR_ANY and imr_ifindex==0.
        The sockets API has never included a "join on all
interfaces" mechanism. If you're looking for traffic from
a particular set of machines, you only need to join on a
single interface that includes that set. Joining on another
interface for the same set will give you duplicate traffic.
The same group number on a different interface is either an
entirely different set (from a different multicast routing
domain), or the same one (resulting in duplicate traffic). If
you want both of two sets, you need to join each separately. If you
only want one, you only need to join on one of them, and joining
on both would be bad.
        So, if you followed all that, the conclusion is that
it usually doesn't make sense for an app in a single multicast
routing domain to want to join on multiple interfaces, and if
you have multiple routing domains, joining each separately is
appropriate, especially since some of the interfaces may be
in the same routing domain even if some are not.

                                                                +-DLS

