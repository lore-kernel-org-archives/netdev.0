From: Patrick McHardy <kaber@trash.net>
Subject: Re: nftables
Date: Wed, 18 Mar 2009 08:47:28 +0100
Message-ID: <49C0A710.8050207@trash.net>
References: <4976FF54.1000009@linux.vnet.ibm.com> <200901271540.36749.rusty@rustcorp.com.au> <497ED2B5.4040703@trash.net> <497F059F.7070903@linux.vnet.ibm.com> <497F09CA.2040306@trash.net> <497FEBE5.1050508@linux.vnet.ibm.com> <498013D7.3010401@trash.net> <49C083F4.9010506@linux.vnet.ibm.com> <49C089A2.2020809@trash.net> <49C09610.1010106@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: Netfilter Developer Mailing List
	<netfilter-devel@vger.kernel.org>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Varun Chandramohan <varunc@linux.vnet.ibm.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <49C09610.1010106@linux.vnet.ibm.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Varun Chandramohan wrote:
> Iam interested in hooking nftables to TC. Could you elaborate on this
> a little bit?
> And when you talk about in-kernel mangle table i suppose you mean the
> mangle table of iptables? 

OK first about mangle - usually tables with nftables should be created
by userspace. The mangle table contains special functionality that needs
to be implemented in the kernel (rerouting), so nftables (just as iptables)
includes some code and table definitions for this. The way it should be is
that rerouting is just a property that can be optionally specified for a
chain.

About TC - thats one of the more complicated things I suppose. The first
thing that needs to be investigated is whether hooking it natively (meaning
it is called directly, similar to the TC classifiers today) or through a TC
classifier would make more sense. The second approach is definitely less
intrusive, but the TC classifier is pretty much useless with nftables
and it imposes some undesirable limits. In the end each class should offer
a chain to attach rules to. I'd also suggest to have a table-like container
for each qdisc, so chains can be added that are not attached directly to
classes (which I'm not sure is possible when using a TC classifier).

What's further needed is:

- a way to transport the nftables netlink attributes to the kernel.
  Either encapsulated in TC attributes or the "normal" way, depending
  on how it is hooked.

- nftables needs to be taught about TC verdicts. Classes bound to the
  classifier should be treated similar to nftables chains (meaning a
  lookup is made and the reference is stored). Check out nft_data_init()
  for reference.

- the ruleset evaluation function probably needs to be split into a
  generic part, dealing with internal flow control, and the netfilter/
  TC specific part, dealing with netfilter verdicts and class IDs.

