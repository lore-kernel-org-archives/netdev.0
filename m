From: Tom Herbert <tom@herbertland.com>
Subject: Re: [RFC PATCH net-next 0/3] L3 RX handler
Date: Sat, 29 Aug 2015 11:02:11 -0700
Message-ID: <CALx6S37JNtd-+A0pCTGGq=4oj_YoVHc0XZpX-tPzv9L8YvmGyg@mail.gmail.com>
References: <1440808463-14526-1-git-send-email-dsa@cumulusnetworks.com>
	<1440811867.8932.111.camel@edumazet-glaptop2.roam.corp.google.com>
	<20150828.221417.905062374709400810.davem@davemloft.net>
	<55E1CDCB.2030205@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Shrijeet Mukherjee <shm@cumulusnetworks.com>
To: David Ahern <dsa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f176.google.com ([209.85.223.176]:33436 "EHLO
	mail-io0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752693AbbH2SCM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 29 Aug 2015 14:02:12 -0400
Received: by iods203 with SMTP id s203so122905404iod.0
        for <netdev@vger.kernel.org>; Sat, 29 Aug 2015 11:02:12 -0700 (PDT)
In-Reply-To: <55E1CDCB.2030205@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> Cumulus Networks is invested in the VRF solution, and we will be here for
> the long haul. We want a feature complete, performant and stable solution
> for open networking. My preference is for a built-in solution rather than a
> bolted on one and I am trying to do that by engaging the community and
> getting feedback early for decisions and preferences.
>
> As for the details, I am finishing IPv4 integration now. Basic VRF-lite
> situations work great and I have tested a few IPsec and MPLS setups as well.
> I have one more patch to address Tom's comment regarding udp_sendmsg; I need
> to verify it works for fragmentation and I'll push it out. After that I will
> start on IPv6 next week.
>
Hi David,

The feedback was that this code was too invasive and poorly
abstracted. For instance, I expressly pointed out that common stack
code should _never_ need to know about specific netifs (loopback being
the only exception). So before you proceed to post IPv6 changes let's
heed Dave's advice and try to fix the abstraction.

To begin with, can we abstract out the need for common code to know
about the VRF device (netif_index_is_vrf). Looking more closely at
udp_semdmsg code, there's seems to be some potential problems:

1) In the VRF case route lookup is being called twice for every
unconnected packet when going through vrf path :-(
2) The "unconnected socket" comment is not incorrect, this path is
taken for connected sockets also before there is a cache route
3) Looks like in VRF path the source address can be arbitrarily
overwritten in the case that it is non-zero (that is non-zero, but not
a connect socket).

AFAICT, the only purpose of this code is find a VRF specific source
address when VRF is the output device. If this is true, can we just
add an ndo_inet_select_addr function and call it from
inet_select_addr? e.g. at top of inet_select_addr do:

if (dev-> ndo_inet_select_addr) {
    addr = (*dev-> ndo_inet_select)(dev, dst, scope));
   if (addr)
       return addr;
}

And then define the appropriate ndo function in the vrf device or any
device that wants to provide an alternate source address, and also
remove VRF specific code in udp_sendmsg.

Tom

> David
>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
