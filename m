From: Phil Sutter <phil@nwl.cc>
Subject: Re: [PATCH iproute2] ip-address: properly display zero IPv4 peer
 address
Date: Tue, 24 Nov 2015 12:44:17 +0100
Message-ID: <20151124114417.GA23115@orbit.nwl.cc>
References: <1445502868-29474-1-git-send-email-thaller@redhat.com>
 <20151123160450.73eec3ef@xeon-e3>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Thomas Haller <thaller@redhat.com>, netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbit.nwl.cc ([176.31.251.142]:58117 "EHLO mail.nwl.cc"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751736AbbKXLoT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 24 Nov 2015 06:44:19 -0500
Content-Disposition: inline
In-Reply-To: <20151123160450.73eec3ef@xeon-e3>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Nov 23, 2015 at 04:04:50PM -0800, Stephen Hemminger wrote:
> On Thu, 22 Oct 2015 10:34:28 +0200
> Thomas Haller <thaller@redhat.com> wrote:
> 
> > Kernel allows for zero IPv4 peer addresses (IFA_ADDRESS):
> > 
> >    ip address add 192.168.5.1 peer 0.0.0.0/24 dev dummy
> > 
> > which is distinct from a usual address like:
> > 
> >    ip address add 192.168.5.1/24 dev dummy
> >    ip address add 192.168.5.1 peer 192.168.5.1/24 dev dummy
> > 
> > For IPv4, a missing IFA_ADDRESS attribute means that the peer
> > is 0.0.0.0. See inet_fill_ifaddr(), which does:
> > 
> >   if ((ifa->ifa_address &&
> >        nla_put_in_addr(skb, IFA_ADDRESS, ifa->ifa_address)) ||
> > 
> > Signed-off-by: Thomas Haller <thaller@redhat.com>
> 
> I would prefer that this apply to both IPv4 and IPv6.

The case that patch handles does not happen in IPv6.

> If the kernel sends back an address, then display it.

It's rather "if the kernel *does not* send back an address ...".

When reviewing this patch, I tried to find an easier (and less ugly)
solution, but failed.  Here's the result from testing all variants:

1) ip a a 192.168.1.1/24                             dev test0
2) ip a a 192.168.2.1        peer 192.168.2.1/24     dev test0
3) ip a a 192.168.3.1        peer 0.0.0.0/24         dev test0
4) ip a a 192.168.4.1        peer 192.168.4.2        dev test0
5) ip a a feed:babe::1:1/112                         dev test0
6) ip a a feed:babe::2:1     peer feed:babe::2:1/112 dev test0
7) ip a a feed:babe::3:1     peer ::/112             dev test0
8) ip a a feed:babe::4:1     peer feed:babe::4:2     dev test0

cmd ifa_local      ifa_address
---------------------------------
1)  192.168.1.1    192.168.1.1
2)  192.168.2.1    192.168.2.1
3)  192.168.3.1    unset
4)  192.168.4.1    192.168.4.2
5)  unset          feed:babe::1:1
6)  unset          feed:babe::2:1
7)  unset          feed:babe::3:1
8)  feed:babe::4:1 feed:babe::4:2

No idea how this looks for decnet and ipx. Looking only at IPv6 though,
the patch's check for !AF_INET before setting rta_tb[IFA_ADDRESS] =
rta_tb[IFA_LOCAL] could indeed be skipped.

On a side note, I'm pretty sure the later memcmp() could be skipped in
many cases, at least by comparing the pointer values of
rta_tb[IFA_ADDRESS] and rta_tb[IFA_LOCAL].

Cheers, Phil
