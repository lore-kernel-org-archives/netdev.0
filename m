From: Lorenzo Colitti <lorenzo@google.com>
Subject: Re: [RFC net-next 0/4] Support UID range routing.
Date: Wed, 7 May 2014 12:59:17 +0900
Message-ID: <CAKD1Yr24VnDU9swPzq67uocFvyD2EOkLVT0Ph7Xwkq=wGkzNgQ@mail.gmail.com>
References: <20140428.125807.409036177577836732.davem@davemloft.net>
 <CAKD1Yr1HN4=42JYfe9LYguWukXxNE38vvwLBt-aEeQ-zSisN9Q@mail.gmail.com>
 <CAKD1Yr0wqj0wG3Ges9NeqMBALO-SxY9KTgZo_sp_8VYKnihKMQ@mail.gmail.com> <20140502.152441.695810627123047.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Newall <davidn@davidnewall.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	JP Abgrall <jpa@google.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f170.google.com ([209.85.223.170]:64267 "EHLO
	mail-ie0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755895AbaEGD7i (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 May 2014 23:59:38 -0400
Received: by mail-ie0-f170.google.com with SMTP id rd18so460243iec.15
        for <netdev@vger.kernel.org>; Tue, 06 May 2014 20:59:37 -0700 (PDT)
In-Reply-To: <20140502.152441.695810627123047.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, May 3, 2014 at 4:24 AM, David Miller <davem@davemloft.net> wrote:
> > did that help clarify what I'm proposing here? Does this patch still
> > seem misguided to you even though its semantics match existing
> > functionality?
>
> I understand what you're trying to achieve, but it still leaves a very
> bad taste in my mouth.
>
> And I question whether you absolutely cannot get the desired source
> address set with appropriate adjustments to the netfilter config,
> netfilter can mangle the packet any way you desire it to so why can't
> it do so to the source address?

The problem is not that netfilter picks the wrong source address. The
problem is that it that address doesn't match the socket's source
address. The source address in the socket is selected by the initial
routing lookup (e.g., in tcp_v[46]_connect), but the packet source
address is from the output interface . So if the application calls
getsockname(), it will get an IP address that's not the one that is
actually being used to send its packets (and in fact is on a different
interface). This breaks applications that need end-to-end
connectivity. It also doesn't allow applications to select their
source address using things like bind(), IPV6_PKTINFO,
IPV6_ADDR_PREFERENCES,  etc.

This doesn't just affect the source address, it similarly affects any
other parameters that are taken from route lookups and stored in the
socket, such as MSS, initial cwnd / rwnd / RTO, etc. Some (like MSS)
can be fixed up with netfilter, but not all. Also, every connection
made through this scheme takes up conntrack state, is affected by
conntrack timeouts, etc.

Assuming you agree that this is sane use case, then I think UID-based
routing rules are a much cleaner way to do it than netfilter. The
kernel has all the information it needs to do this correctly, but
today we do not use that information in the initial lookup - we just
use it later on to do NAT. That breaks app expectations before the
packet even hits the wire, and that leaves a bad taste in my mouth.

I can see why we wouldn't want to add new rule types when things can
be done with netfilter. But I think that when it comes to making
routing decisions based on information that's in the socket structure
(i.e., from the application), those have to be made using routing
rules. For output packets, netfilter only gets to influence things too
late, so it can at best patch things up later.
