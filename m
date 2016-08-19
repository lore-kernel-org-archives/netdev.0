From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [RFC PATCH 0/5] Add eBPF hooks for cgroups
Date: Fri, 19 Aug 2016 11:19:41 +0200
Message-ID: <20160819091941.GA2113@salvia>
References: <1471442448-1248-1-git-send-email-daniel@zonque.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: htejun@fb.com, daniel@iogearbox.net, ast@fb.com,
        davem@davemloft.net, kafai@fb.com, fw@strlen.de, harald@redhat.com,
        netdev@vger.kernel.org
To: Daniel Mack <daniel@zonque.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ganesha.gnumonks.org ([213.95.27.120]:46152 "EHLO
        ganesha.gnumonks.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752581AbcHSJ5j (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 19 Aug 2016 05:57:39 -0400
Content-Disposition: inline
In-Reply-To: <1471442448-1248-1-git-send-email-daniel@zonque.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Daniel,

On Wed, Aug 17, 2016 at 04:00:43PM +0200, Daniel Mack wrote:
> I'd appreciate some feedback on this. Pablo has some remaining concerns
> about this approach, and I'd like to continue the discussion we had
> off-list in the light of this patchset.

OK, I'm going to summarize them here below:

* This new hook allows us to enforce an *administrative filtering
  policy* that must be visible to anyone with CAP_NET_ADMIN. This is
  easy to display in nf_tables as you can list the ruleset via the nft
  userspace tool. Otherwise, in your approach if a misconfigured
  filtering policy causes connectivity problems, I don't see how the
  sysadmin is going to have an easy way to troubleshoot what is going on.

* Interaction with other software. As I could read from your patch,
  what you propose will detach any previous existing filter. So I
  don't see how you can attach multiple filtering policies from
  different processes that don't cooperate each other. In nf_tables
  this is easy since they can create their own tables so they keep their
  ruleset in separate spaces. If the interaction is not OK, again the
  sysadmin can very quickly debug this since the policies would be
  visible via nf_tables ruleset listing.

* During the Netfilter Workshop, the main concern to add this new socket
  ingress hook was that it is too specific. However this new hook in
  the network stack looks way more specific more specific since *it only
  works for cgroups*.

So what I'm proposing goes in the direction of using the nf_tables
infrastructure instead:

* Add a new socket family for nf_tables with an input hook at
  sk_filter(). This just requires the new netfilter hook there and
  the boiler plate code to allow creating tables for this new family.
  And then we get access to many of the existing features in
  nf_tables for free.

* We can quickly find a verdict on the packet using using any combination
  of selectors through concatenations and maps in nf_tables. In
  nf_tables we can express the policy with a non-linear ruleset. On
  top of this, by delaying the nf_reset() calls we can reach the
  conntrack information from sk_filter(). That would be useful to skip
  evaluating packets that belong to already established flows. Thus, we
  incur the performance penalty in classifying only for the first
  packet of the flow.

* We can skip the socket egress hook (that you don't know where to place
  yet) since you can use the existing local output hook in netfilter that
  is available for IPv4 and IPv6.

* This new hook would fit into the existing netfilter set of hooks,
  the sysadmin is already familiarized with the administrative
  infrastructure to define filtering policies in our stack, so adding this
  new hook to what we have looks natural to me.

Thanks for your patience on debating this!
