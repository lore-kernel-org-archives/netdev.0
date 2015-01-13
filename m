From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH 2/6] vxlan: Group Policy extension
Date: Tue, 13 Jan 2015 11:32:28 +0000
Message-ID: <20150113113228.GJ20387@casper.infradead.org>
References: <cover.1420756324.git.tgraf@suug.ch>
 <7339e3bff124cecaf65cd04ea9bdc973c730ba34.1420756324.git.tgraf@suug.ch>
 <CA+mtBx8SWiwjBfxx05omur1gDeF9QcKtjDKJQ+XdUgi_U8LWig@mail.gmail.com>
 <20150113010357.GB20387@casper.infradead.org>
 <CA+mtBx8-rMYSkj2KKXBq60KeF=V=iCG2K0HgVxO5JMVK1yhwCg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, Jesse Gross <jesse@nicira.com>,
	Stephen Hemminger <stephen@networkplumber.org>,
	Pravin B Shelar <pshelar@nicira.com>,
	Alexei Starovoitov <alexei.starovoitov@gmail.com>,
	Linux Netdev List <netdev@vger.kernel.org>,
	"dev@openvswitch.org" <dev@openvswitch.org>
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:51359 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751184AbbAMLca (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Jan 2015 06:32:30 -0500
Content-Disposition: inline
In-Reply-To: <CA+mtBx8-rMYSkj2KKXBq60KeF=V=iCG2K0HgVxO5JMVK1yhwCg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/12/15 at 06:28pm, Tom Herbert wrote:
> On Mon, Jan 12, 2015 at 5:03 PM, Thomas Graf <tgraf@suug.ch> wrote:
> >>
> >> Creating a level of indirection for extensions seems overly
> >> complicated to me. Why not just define IFLA_VXLAN_GBP as just another
> >> enum above?
> >
> > I think it's cleaner to group them in a nested attribute.
> > It clearly separates the optional extensions from the base
> > attributes. RCO, GPE, GBP can all live in there.
> 
> This is inconsistent with similar things in GRE and GUE. For instance,
> GRE keyid is set as its own attribute. It just seems like this adding
> more code to the driver than is necessary for the functionality
> needed.

The major difference here is that we have to consider backwards
compatibility specifically for VXLAN. Your initial feedback on GPE
actually led me to how I implemented GBP.

I think the axioms we want to establish are as follows:
 1. Extensions need to be explicitly enabled by the user. A previously
    dropped frame should only be processed if the user explitly asks
    for it.
 2. As a consequence: only share a VLXAN UDP port if the enabled
    extensions match (vxlan_sock_add), e.g. user A might want RCO
    but user B might be unaware. They cannot share the same UDP port.

The 2nd lead me to introduce the 'exts' member to vxlan_sock so we can
compare it in vxlan_find_sock() and only share a UDP port if the
enabled extensions match.

Your patch currently implements (1) but not (2).
