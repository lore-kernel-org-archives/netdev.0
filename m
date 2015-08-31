From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH v2 net-next 0/3] ipv4: Hash-based multipath routing
Date: Mon, 31 Aug 2015 11:02:11 +0200
Message-ID: <20150831090211.GA12707@pox.localdomain>
References: <1440792050-2109-1-git-send-email-pch@ordbogen.com>
 <20150829.131429.360433621593751136.davem@davemloft.net>
 <20150829223115.523553db@tyr>
 <20150829.134628.1013990034021542524.davem@davemloft.net>
 <CALx6S35AUXFKfazU4bbpNL90r7P8i3wSFTB_0YDDRUgKg-3vqw@mail.gmail.com>
 <20150830232829.7e598151@tyr>
 <CALx6S36wZ36jS9fmrFJZ3BddnpGpBJXph5HtOBYQ=ekatSKDNw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Peter N??rlund <pch@ordbogen.com>,
	David Miller <davem@davemloft.net>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>, linux-api@vger.kernel.org,
	Roopa Prabhu <roopa@cumulusnetworks.com>,
	sfeldma <sfeldma@gmail.com>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>,
	Jiri Benc <jbenc@redhat.com>
To: Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f179.google.com ([209.85.212.179]:37835 "EHLO
	mail-wi0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752650AbbHaJCO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 31 Aug 2015 05:02:14 -0400
Received: by wicfv10 with SMTP id fv10so63513799wic.0
        for <netdev@vger.kernel.org>; Mon, 31 Aug 2015 02:02:12 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <CALx6S36wZ36jS9fmrFJZ3BddnpGpBJXph5HtOBYQ=ekatSKDNw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/30/15 at 03:29pm, Tom Herbert wrote:
> On Sun, Aug 30, 2015 at 2:28 PM, Peter N??rlund <pch@ordbogen.com> wrote:
> > It would definitely be simpler, and it would be nice to just fetch the
> > hash directly from the NIC - and for link aggregation it would probably
> > be fine. But with L4, we always need to consider fragmented packets,
> > which might cause some packets of a flow to be routed differently - and
> > with ECMP, the ramifications of suddenly choosing another path for a
> > flow are worse than for link aggregation. The latency through the
> > different paths may differ enough to cause out-or-order packets and bad
> > TCP performance as a consequence. Both Cisco and Juniper routers
> > defaults to L3 for ECMP - exactly for that reason, I believe. RFC 2991
> > also points out that ports probably shouldn't be used as part of the
> > flow key with ECMP.
> >
> That's more reason why we need vendors to use IPv6 flow label instead
> of ports to do ECMP :-). In any case, if we're fragmenting TCP packets
> then we're already in a bad place performance-wise-- we really don't
> need to optimize for that case. Albeit, it would be nice if fragments
> of packet  followed same path, but the would require devices to not do
> L4 hash over ports when MF is set-- I don't know if anyone does that
> (I have been meaning to add that to stack).

+1 for solving this at hash level. Being able to rely on the L4 HW
hash for multipath routing is very desirable. A simple MF bit ||
FO > 0 check with fall back to flow dissector to generate an L3 hash
in case the HW provided an L4 hash should be sufficient to address the
fragmentation concern.

Since performance is gone anyway, I'm not sure it's worth offloading
this behaviour to the HW.
