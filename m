From: Lorenzo Colitti <lorenzo@google.com>
Subject: Re: [PATCH net-next] net: ipv6: put autoconf routes into
 per-interface tables
Date: Thu, 12 Jan 2017 01:46:34 +0900
Message-ID: <CAKD1Yr3ikvLs70pNet4rcO=WhVHytBRzn=_2+ad9K9KrD+4O4A@mail.gmail.com>
References: <bbcab8bb-6a2a-6b90-f6a2-ad840a2c389c@cumulusnetworks.com>
 <un3fkd-lod.ln1@banana.localnet> <CAKD1Yr3nfOp1LNfvVuTGZyThwu8Z+gaSN-DVaa11ZJYR+tMemg@mail.gmail.com>
 <20170111.091139.1754139535517451753.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "Andrey Jr. Melnikov" <temnota.am@gmail.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ua0-f175.google.com ([209.85.217.175]:32769 "EHLO
        mail-ua0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S938616AbdAKQq4 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 11 Jan 2017 11:46:56 -0500
Received: by mail-ua0-f175.google.com with SMTP id i68so410522754uad.0
        for <netdev@vger.kernel.org>; Wed, 11 Jan 2017 08:46:56 -0800 (PST)
In-Reply-To: <20170111.091139.1754139535517451753.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jan 11, 2017 at 11:11 PM, David Miller <davem@davemloft.net> wrote:
> I understand what you're saying, but if you look at how apps can be
> put into hierarchical control groups, and automatically bind to VRF's
> based upon where they are in that cgroup hierarchy, it matches your
> use case precisely.

I think whether an app is in bound to a certain VRF or not is not
directly related to this patch. What this patch does is provide a way
to ensure that routes learned via autoconf go into a specific routing
table, so that policy routing rules can select them.

Without this patch, and without VRFs, the routes for all networks and
all interfaces all go into the same routing table (main). That doesn't
work well on a multinetwork device. As David A. points out, with VRFs
this can be done - since each VRF has its own routing table, the
routes are isolated and ip rules can be applied to determine which
ones are used. However, I'm not convinced that VRFs are a great
solution to this problem. A couple of problems I see here are:

1. When an interface is created on the fly, the system must guarantee
that a VRF for it exists, and the interface is put into it, before it
comes up and receives an RA. This is not insurmountable - for example,
you can set net.conf.default.disable_ipv6 to 1, and set it to 0 on the
interface once it's in a VRF. Not sure this is feasible on a
mainstream distribution, but it could be done on something like
Android that's more tightly integrated.

2. I'm not sure it's possible to use routing policy to select between
interfaces in the same VRF. For example, if you have a carrier that
provides the user with the same IP address and similar connectivity on
both cellular data and a carrier-operated wifi network, and you put
those two in the same VRF, I don't see a way to say via routing policy
"prefer wifi over cellular", because the routes for both are in the
same table and AIUI the only discriminator between the two - the oif -
has to be set to the VRF ifindex. I suppose it might be possible to
alter the metrics of routes that were previously created by autoconf
but that sounds desperately hacky.

I suppose both of these could also be resolved by ensuring that each
interface is its own VRF at creation time. But if every VRF only
contains exactly one interface, the VRF construct doesn't really seem
useful.

That said, we've maintained this patch out of tree for a few years now
and we can continue to do so for a while longer. When the VRF code
rolls into enough SoC kernels we can make an attempt to use it and see
what issues we find.
