From: "Ian Brown" <ianbrn@gmail.com>
Subject: Re: Why MLDv2 Report packet is freed ?
Date: Thu, 17 Apr 2008 08:49:27 +0300
Message-ID: <d0383f90804162249t64072de4kf97248f42e66c0ed@mail.gmail.com>
References: <d0383f90804150623r2eb071fau200a67c6ce65a7e0@mail.gmail.com>
	 <20080415.234844.99535411.yoshfuji@linux-ipv6.org>
	 <d0383f90804160450x31e1577en60d4a6cca29a00ca@mail.gmail.com>
	 <48063F53.4030102@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "=?BIG5?B?WU9TSElGVUpJIEhpZGVha2kgLyCmTsPDrV6p+g==?="
	<yoshfuji@linux-ipv6.org>, netdev@vger.kernel.org
To: "Brian Haley" <brian.haley@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.153]:5205 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751599AbYDQFtb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Apr 2008 01:49:31 -0400
Received: by fg-out-1718.google.com with SMTP id l27so2715333fgb.17
        for <netdev@vger.kernel.org>; Wed, 16 Apr 2008 22:49:28 -0700 (PDT)
In-Reply-To: <48063F53.4030102@hp.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

First, I have multicast routing enabled:
/proc/sys/net/ipv6/conf/*/mc_forwarding is 1 and
CONFIG_IPV6_MROUTE=y when building the kernel.

Second, when MLDV2 report reaches ip6_mc_input(),
the ICMPv6 header has a type of ICMPV6_MLD2_REPORT; and it is a router
alert. This causes a call to ip6_input() and **not** ip6_mr_input().
This casue it to be handled by the ICMPv6 handler, which is icmpv6_rcv().
I am absolutely sure about it, as I added some printk() in these kernel methods.
I see that I reach the icmpv6_rcv() and the packet is dropped.
The sock_queue_rcv_skb() method in p6mr_cache_report() is NOT called
in this case -
simply because we don't get there, since ip6_mc_input() in this case
does **not**
call ip6_mr_input() ; it does call ip6_mr_input() in other cases.

Moreover, I added printing in the accept_mld6() method of the pim6sd
daemon, which is the
handler for these packets, and I do not get there.

Could it be that this is a bug ?

Any ideas ?

IB





On Wed, Apr 16, 2008 at 9:02 PM, Brian Haley <brian.haley@hp.com> wrote:
> Ian Brown wrote:
>  > Hello,
>  >
>  > I am sorry, I tried to delve into the code and I not sure I can figure out this
>  > point.
>  >> MLD packets are handled in other place.
>  >
>  > Can anybody please try to elaborate on this point: how
>  > are MLD packets handled ? Shouldn't MLD packets be
>  > handled by pim6sd daemon?
>
>  Yes.
>
>
>  > I see handlers for accepting MLD (v1 and v2)
>  > in pim6sd daemon;
>  > And in case MLD packets  should be handled by pim6sd  - shouldn't the kernel
>  > pass these MLD packets to the pim6sd daemon (by calling sock_queue_rcv_skb()
>  > in ip6mr.c) ? As far as I can understand, these MLD packets are
>  > dropped in icmpv6_rcv()
>
>  From what I can tell, ip6_mc_input() makes a copy if multicast routing
>  is enabled.  Those copies eventually get to ip6mr_cache_report() which
>  delivers them to user-space (there's even a reference to pim6sd in
>  net/ipv6/ip6mr.c).
>
>  Have you seen them not get delivered?
>
>  -Brian
>
