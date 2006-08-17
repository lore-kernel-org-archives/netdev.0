From: David Stevens <dlstevens@us.ibm.com>
Subject: Re: Possible leak of multicast source filter sctructure
Date: Thu, 17 Aug 2006 08:26:06 -0700
Message-ID: <OF083D59F3.3D70F47B-ON882571CD.0052BC5E-882571CD.0054C940@us.ibm.com>
References: <200608171126.k7HBQZ6u031969@gateplz.comstar.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Cc: davem@davemloft.net, kuznet@ms2.inr.ac.ru, netdev@vger.kernel.org,
	netdev-owner@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from e4.ny.us.ibm.com ([32.97.182.144]:43650 "EHLO e4.ny.us.ibm.com")
	by vger.kernel.org with ESMTP id S965139AbWHQP1S (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Aug 2006 11:27:18 -0400
In-Reply-To: <200608171126.k7HBQZ6u031969@gateplz.comstar.cz>
To: "Michal Ruzicka" <michal.ruzicka@comstar.cz>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

"Michal Ruzicka" <michal.ruzicka@comstar.cz> wrote on 08/17/2006 05:26:35 
AM:

> I've reviewed your patch (the IPv4 part of it) and I think I can say 
that
> our soulutions are actually quite similar.
> But I can come up with one difference that I'd like know your opinion 
on.

        If you have a duplicated address and the application is not using
interface index to identify the interface, then which one you join or 
leave
on is not unique, and which one you'll get is not defined. It is, in fact,
an error to leave the group on an interface with a different index, and
the duplicate scenario has effectively changed the meaning of that 
address's
interface.
        In the same scenario, if you have not deleted any interfaces and
attempt to leave the group, your code may get the "pppY" interface from
ip_mc_find_dev(), not have a matching index for the group you actually
joined, and will return EADDRNOTAVAIL rather than leaving the group you
joined on.
        In both cases, it'd simply be an error for an application to be
using address to identify the interface when that is not unique. If the
addresses are used (or reused) on multiple interfaces, the application
has to use interface index to work properly.

                                                                +-DLS


> Suppose the following situatuion:
> 
> 1) create pppX interface:
>   IP: A.B.C.D
> 
> 2) join a multicast group by address: A.B.C.D
>   ASSUMPTION: no other interface with the same IP address exists;
>   the result should be that the group is joined on the pppX interface
> 
> 3) create pppY interface
>   IP: A.B.C.D (Yes the same IP, not unusual on ppp links.)
> 
> 4) delete the pppX interace
> 
> 5) attempt to leave the multicast group by address: A.B.C.D
> 
> 6) * if your algorthim is used -EADDRNOTAVAIL is returned
>    * if mine is used the multicast group is left on the pppX interface
> 
> Surely this won't be a common problem but I think it's worth pointing 
out
> here.
> 
> Michal
> -
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

