From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [patch net-next 00/13] introduce rocker switch driver with
 openvswitch hardware accelerated datapath
Date: Mon, 15 Sep 2014 13:43:58 +0100
Message-ID: <20140915124358.GA21541@casper.infradead.org>
References: <1409736300-12303-1-git-send-email-jiri@resnulli.us>
 <20140908135413.GA5995@casper.infradead.org>
 <20140909210910.GA25899@ITs-MacBook-Pro.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jiri Pirko <jiri@resnulli.us>, netdev@vger.kernel.org,
	davem@davemloft.net, nhorman@tuxdriver.com, andy@greyhouse.net,
	dborkman@redhat.com, ogerlitz@mellanox.com, jesse@nicira.com,
	pshelar@nicira.com, azhou@nicira.com, ben@decadent.org.uk,
	stephen@networkplumber.org, jeffrey.t.kirsher@intel.com,
	vyasevic@redhat.com, xiyou.wangcong@gmail.com,
	john.r.fastabend@intel.com, edumazet@google.com, jhs@mojatatu.com,
	sfeldma@cumulusnetworks.com, f.fainelli@gmail.com,
	roopa@cumulusnetworks.com, linville@tuxdriver.com,
	dev@openvswitch.org, jasowang@redhat.com, ebiederm@xmission.com,
	nicolas.dichtel@6wind.com, ryazanov.s.a@gmail.com,
	buytenh@wantstofly.org, aviadr@mellanox.com, nbd@openwrt.org,
	Neil.Jerram@metaswitch.com, ronye@mellanox.com
To: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:47470 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750790AbaIOMoG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Sep 2014 08:44:06 -0400
Content-Disposition: inline
In-Reply-To: <20140909210910.GA25899@ITs-MacBook-Pro.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/09/14 at 02:09pm, Alexei Starovoitov wrote:
> On Mon, Sep 08, 2014 at 02:54:13PM +0100, Thomas Graf wrote:
> > [0] https://docs.google.com/document/d/195waUliu7G5YYVuXHmLmHgJ38DFSte321WPq0oaFhyU/edit?usp=sharing
> > (Publicly accessible and open for comments)
> 
> Great doc. Very clear. I wish I could write docs like this :)
> 
> Few questions:
> - on the 1st slide dpdk is used accept vm and lxc packet. How is that working?
>   I know of 3 dpdk mechanisms to receive vm traffic, but all of them are kinda
>   deficient, since offloads need to be disabled inside VM, so VM to VM
>   performance over dpdk is not impressive. What is there for lxc?
>   Is there a special pmd that can take packets from veth?

Glad to see you are paying attention ;-) I'm assuming somebody to
write a veth PMD at some point. It does not exist yet.

> - full offload vs partial.
>   The doc doesn't say, but I suspect we want transition from full to partial
>   to be transparent? Especially for lxc. criu should be able to snapshot
>   container on one box with full offload and restore it seamlessly on the
>   other machine with partial offload, right?

Correct. In a full offload environment, the CPU path could still use
partial offload functionality. I'll update the doc.

> - full offload with two nics.
>   how bonding and redundancy suppose to work in such case?
>   If wire attached to eth0 no longer passing packet, how traffic from VM1
>   will reach eth1 on a different nic? Via sw datapath (flow table) ?

Yes.

>   I suspect we want to reuse current bonding/team abstraction here.

Yes, both kernel bond/team and OVS group table based abstraction (see
Simon's recent effrots).

>   I'm not quite getting the whole point of two separate physical nics.
>   Is it for completeness and generality of the picture ?

Correct. It is entirely to outline the more difficult case of multiple
physical NICs.

>   I think typical hypervisor will likely have only one multi-port nic, then
>   bonding can be off-loaded within single nic via bonding driver.

Agreed. I would expect that to be the reference architecture.

>   Partial offload scenario doesn't have this issue, since 'flow table'
>   is fed by standard netdev which can be bond-dev and everything else, right?

It is unclear how a virtual LAG device would forward flow table hints.
A particular NIC might take 5 tuples which point to a particular fwd
entry. The state of this offload might be different on individual NICs
forming a bond. Either case, it should be abstracted.

> - number of VFs
>   I believe it's still very limited even in the newest nics, but
>   number of containers will be large.

Agreed.

>   So some lxcs will be using VFs and some will use standard veth?

Likely yes. I could forsee this to be driven by an elephant detection
algorithm or driven by policy.

>   We cannot swap them dynamically based on load, so I'm not sure
>   how VF approach is generically applicable here. For some use cases
>   with demanding lxcs, it probably helps, but is it worth the gains?

TBH, I don't know. I'm trying to figure that out ;-) It is obvious that
dedicating individual cores to PMDs is not ideal either for lxc type
workloads. The same question also applies to live migration which is
complicated by this and DPDK type setups. However, I believe that a
proper HW offload abstraction API is superior in terms of providing
virtualization abstraction but I'm afraid we won't know for sure until
we've actually tried it ;-)
