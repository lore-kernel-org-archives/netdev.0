From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH net-next 2/2] openvswitch: Use zerocopy if applicable
 when performing the upcall
Date: Fri, 7 Jun 2013 13:21:39 +0100
Message-ID: <20130607122139.GA21856@casper.infradead.org>
References: <cover.1369406826.git.tgraf@suug.ch>
 <064a09fffe48540b66a3ee503860ed9e8a1eb5f1.1369406826.git.tgraf@suug.ch>
 <CAEP_g=87CuiS92YtCZ1V1ME05qq0jGWD9p1WgKZ2jaaG1AWS7w@mail.gmail.com>
 <1369421900.3301.431.camel@edumazet-glaptop>
 <CAEP_g=898=iOWV15Y_bcjvS9sGSfDQSP1zQLNkffoXB5imdU7g@mail.gmail.com>
 <1369432621.3301.445.camel@edumazet-glaptop>
 <CAEP_g=9Yqcf6_cpPYNAbiQUGjQa46PEz6gQdKAopiNNUDRhGYA@mail.gmail.com>
 <20130525070222.GB30252@casper.infradead.org>
 <1369492772.3301.468.camel@edumazet-glaptop>
 <CAEP_g=944Wq982rDSC0hrqUBu8Sf6MCtQN0NhgyU5FDr9UB3ww@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	netdev <netdev@vger.kernel.org>,
	"dev@openvswitch.org" <dev@openvswitch.org>
To: Jesse Gross <jesse@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:32890 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752118Ab3FGMVl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Jun 2013 08:21:41 -0400
Content-Disposition: inline
In-Reply-To: <CAEP_g=944Wq982rDSC0hrqUBu8Sf6MCtQN0NhgyU5FDr9UB3ww@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/27/13 at 10:28am, Jesse Gross wrote:
> On Saturday, May 25, 2013, Eric Dumazet wrote:
> 
> > On Sat, 2013-05-25 at 08:02 +0100, Thomas Graf wrote:
> >
> > > I ran TCP_CRR to verify the SYN/ACK use case and I did not
> > > observe a difference. If you have any specific test in mind
> > > I will be glad to run that before posting the 2nd revision.
> >
> > I guess you should test with rx checksum disabled as well, Jesse seemed
> > to be concerned about that.
> 
> 
>  I was actually thinking about the transmit side - rx checksum verification
> doesn't matter much here since the result will get thrown away. However, if
> the packet is CHECKSUM_PARTIAL then the checksum will have to get filled in
> first and that's the code path that is a little different now.

Do we actually need to complete the checksum before doing the
upcall and if so, why? Couldn't the slow path do that if needed?
The only reason I can think of where it would matter is if a
controller injects the packet into another network stack such
as RouteFlow.

On the receive side, hitting an ovs bridge connected to two
interface with ~18G of randomized flows:

3.10.0-rc2+:
+   9.44%   ksoftirqd/0  [k] csum_partial_copy_generic
+   3.54%  ovs-vswitchd  [k] copy_user_enhanced_fast_string
+   3.08%       swapper  [k] intel_idle
+   2.47%   ksoftirqd/0  [k] memset
+   2.21%   ksoftirqd/0  [k] memcpy
+   1.64%   ksoftirqd/0  [k] __nla_reserve
+   1.26%  ovs-vswitchd  [k] netlink_recvmsg
+   1.07%   ksoftirqd/0  [k] __netif_receive_skb_core
+   1.02%   ksoftirqd/0  [k] __pskb_pull_tail
+   0.98%       swapper  [k] csum_partial_copy_generic
+   0.95%  ovs-vswitchd  [k] _raw_spin_lock
+   0.94%  ovs-vswitchd  [k] _raw_spin_lock_irqsave
+   0.83%  ovs-vswitchd  [k] memcpy
+   0.80%   ksoftirqd/0  [k] __alloc_skb
+   0.78%   ksoftirqd/0  [k] skb_copy_bits
+   0.71%       swapper  [k] menu_select
+   0.71%   ksoftirqd/2  [k] csum_partial_copy_generic                              

3.10.0-rc2+ + zerocopy
+   4.84%    ovs-vswitchd  [k] copy_user_enhanced_fast_string
+   4.74%         swapper  [k] intel_idle
+   3.14%         swapper  [k] memset
+   3.04%         swapper  [k] memcpy
+   2.10%         swapper  [k] __nla_reserve
+   1.44%         swapper  [k] skb_copy_bits
+   1.40%         swapper  [k] __netif_receive_skb_core
+   1.34%         swapper  [k] __pskb_pull_tail
+   1.23%    ovs-vswitchd  [k] _raw_spin_lock
+   1.16%    ovs-vswitchd  [k] fib_table_lookup
+   1.16%         swapper  [k] irq_entries_start
+   1.09%    ovs-vswitchd  [k] memcpy
+   1.05%         swapper  [k] __alloc_skb
+   1.03%         swapper  [k] lapic_next_deadline
+   1.02%         swapper  [k] build_skb
+   0.99%         swapper  [k] skb_zerocopy                  
