From: Jiri Benc <jbenc@redhat.com>
Subject: Re: [PATCH net] ipvlan: fix addr hash list corruption
Date: Tue, 24 Mar 2015 09:58:09 +0100
Message-ID: <20150324095809.6d6b911c@griffin>
References: <2ca7312e5e3df10ce129315f89c3ab5d82d4d428.1427145009.git.jbenc@redhat.com>
	<CAF2d9jgbJ793VygsX0vmPDP-2mttVn_eT26NdirkaKg-hQ7FYw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-netdev <netdev@vger.kernel.org>,
	Dan Williams <dcbw@redhat.com>
To: Mahesh Bandewar <maheshb@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:43172 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752225AbbCXI6O (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 24 Mar 2015 04:58:14 -0400
In-Reply-To: <CAF2d9jgbJ793VygsX0vmPDP-2mttVn_eT26NdirkaKg-hQ7FYw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 23 Mar 2015 18:10:01 -0700, Mahesh Bandewar wrote:
> On Mon, Mar 23, 2015 at 2:10 PM, Jiri Benc <jbenc@redhat.com> wrote:
> > When ipvlan interface with IP addresses attached is brought down and then
> > deleted, the assigned addresses are deleted twice from the address hash
> > list, first on the interface down and second on the link deletion.
> > Similarly, when an address is added while the interface is down, it is added
> > second time once the interface is brought up.
> >
> Presumably this is creating problems for you and I'm not sure why? Do
> you have a script  / (sequence of commands) to produce this condition?

You cannot call hlist_del_rcu on the same pointer twice. Nor
hlist_add_head_rcu, for that matter.

Try e.g.:

ip link add link eth0 name ipvl0 type ipvlan mode l2
ip link set ipvl0 up
ip addr add 1.2.3.1/24 dev ipvl0
ip link set ipvl0 down
	-> ipvlan_ht_addr_del(1.2.3.1)
ip link del ipvl0
	-> ipvlan_ht_addr_del(1.2.3.1)
-> crash

Or:

ip link add link eth0 name ipvl0 type ipvlan mode l2
ip addr add 1.2.3.1/24 dev ipvl0
	-> ipvlan_ht_addr_add(1.2.3.1)
ip link set ipvl0 up
	-> ipvlan_ht_addr_add(1.2.3.1)
-> does not crash immediately but the list is corrupted, go see how the
   pointers in port->hlhead[hash] list look now

> ipvlan_ht_addr_del() does use synchronize_rcu() expect when the device
> in dismantle state. Could that be a reason?

This has nothing to do with RCU.

 Jiri

-- 
Jiri Benc
