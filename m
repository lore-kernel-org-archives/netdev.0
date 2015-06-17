From: ebiederm@xmission.com (Eric W. Biederman)
Subject: [PATCH net-next 00/43] Simplify netfilter and network namespaces (take 2)
Date: Wed, 17 Jun 2015 10:09:40 -0500
Message-ID: <87r3pae5hn.fsf@x220.int.ebiederm.org>
References: <87616ppt3h.fsf@x220.int.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <netfilter-devel@vger.kernel.org>,
	Stephen Hemminger <stephen@networkplumber.org>,
	Juanjo Ciarlante <jjciarla@raiz.uncu.edu.ar>,
	Wensong Zhang <wensong@linux-vs.org>,
	Simon Horman <horms@verge.net.au>,
	Julian Anastasov <ja@ssi.bg>,
	Pablo Neira Ayuso <pablo@netfilter.org>,
	Patrick McHardy <kaber@trash.net>,
	Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	Steffen Klassert <steffen.klassert@secunet.com>,
	Herbert Xu <herbert@gondor.apana.org.au>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out01.mta.xmission.com ([166.70.13.231]:60261 "EHLO
	out01.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932236AbbFQPPD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Jun 2015 11:15:03 -0400
In-Reply-To: <87616ppt3h.fsf@x220.int.ebiederm.org> (Eric W. Biederman's
	message of "Sun, 14 Jun 2015 22:07:30 -0500")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


While looking into what it would take to route packets out to network
devices in other network namespaces I started looking at the netfilter
hooks, and there is a lot of nasty code to figure out which network
namespace to filter the packets in.

Passing the network namespace into the netfilter hooks is a significant
simplication in the code, and worth it as the first thing most netfilter
hooks do is compute the network namespace.

I collided with Pablos work on per network namespace netfilter hooks
the first time I submitted his changes, so now this patchset includes
a per network namespace nftable hooks.  Inspired by Pablos work but
largely rewritten to fix and avoid the bugs I was finding in Pablos
work to register the netfilter hooks per network namespace.

These per network namespace netfilter hooks fix a long standing bug in
nftables, where packets passing through nftables would be run against
the nftables configuration of every network namespace.

I have noticed what appears to be one more bug in nftables.  Today the
nf_queue code takes a module reference count to prevent the netfilter
hook that it stops at from being unregistered.  As it is the module
initialization and module cleanup code that call nf_unregister_hook[s]
in everything but nftables this works.  Unfortunately it appears that
someone can cause a packet to be queued, delete the nftable chain that
caused the queueing and then cause the packet to be reinjected.  So it
looks like nfqnl_rcv_dev_event is needed for netfilter hook
unregistration.

The first group of changes roots out all of the very weird network
namespace computation logic (except for the code in ipvs) and fixes it.
I really don't like how the code has been essentially guessing which
network namespace to use.

Probably the worst guessing is in ipvs in the function skb_net. I have
some preliminary changes to fix ipvs but they are not quite ready yet.
Cleaning up ipvs enough that I can kill skb_net is on my short list.

There are a few extra cleanups in the first group of changes sprinkled
in as I noticed a few other things as I was sorting out the network
namespace computation logic.

There rest of the changes are based on Pablos per network namespace
netfilter hook work and include related cleanups and simplifications.
The most non-obvious detail were the necessary header file cleanups.

The changes where I started with Pablos patches in some cases the
credits get a little weird and the descriptions are a little weaker than
I would like but overall I think it is all close enough.

Eric W. Biederman (36):
      ipvs: Read hooknum from state rather than ops->hooknum
      netfilter: Pass priv instead of nf_hook_ops to netfilter hooks
      netfilter: Add a network namespace Kconfig conflict
      netfilter: Add a struct net parameter to nf_register_hook[s]
      netfilter: Add a struct net parameter to nf_unregister_hook[s]
      netfilter: Make the netfilter hooks per network namespace
      netfilter: Make nf_hook_ops just a parameter structure
      netfitler: Remove spurios included of netfilter.h
      x_tables: Add magical hook registration in the common case
      x_tables: Where possible convert to the new hook registration method
      x_tables: Kill xt_[un]hook_link
      x_tables: Update ip?table_nat to register their hooks in all network namespaces
      netfilter: bridge: adapt it to pernet hooks
      ipvs: Register netfilter hooks in all network namespaces
      netfilter: nf_conntract: Register netfilter hooks in all network namespaces
      netfilter: nf_defrag: Register netfilter hooks in all network namespaces
      netfilter: synproxy: Register netfilter hooks in all network namespaces
      smack: adapt it to pernet hooks
      netfilter bridge: Make the sysctl knobs per network namespace
      netfilter: Skip unnecessary calls to synchronize_net
      netfilter: Kill unused copies of RCV_SKB_FAIL
      netfilter: Pass struct net into the netfilter hooks
      netfilter: Use nf_hook_state.net
      ebtables: Simplify the arguments to ebt_do_table
      inet netfilter: Remove hook from ip6t_do_table, arp_do_table, ipt_do_table
      inet netfilter: Prefer state->hook to ops->hooknum
      nftables: kill nft_pktinfo.ops
      tc: Simplify em_ipset_match
      x_tables: Pass struct net in xt_action_param
      x_tables: Use par->net instead of computing from the passed net devices
      nftables: Pass struct net in nft_pktinfo
      nf_tables: Use pkt->net instead of computing net from the passed net_devices
      nf_conntrack: Add a struct net parameter to l4_pkt_to_tuple
      ipv4: Pass struct net into ip_defrag and ip_check_defrag
      ipv6: Pass struct net into nf_ct_frag6_gather
      netfilter: Remove the network namespace Kconfig conflict

Pablo Neira Ayuso (7):
      net: include missing headers in net/net_namespace.h
      netfilter: use forward declaration instead of including linux/proc_fs.h
      netfilter: don't pull include/linux/netfilter.h from netns headers
      netfilter: nf_tables: adapt it to pernet hooks
      netfilter: ipt_CLUSTERIP: adapt it to support pernet hooks
      netfilter: ebtables: adapt the filter and nat table to pernet hooks
      selinux: adapt it to pernet hooks

Eric
