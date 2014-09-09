From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [patch net-next 00/13] introduce rocker switch driver with
 openvswitch hardware accelerated datapath
Date: Tue, 9 Sep 2014 14:09:12 -0700
Message-ID: <20140909210910.GA25899@ITs-MacBook-Pro.local>
References: <1409736300-12303-1-git-send-email-jiri@resnulli.us>
 <20140908135413.GA5995@casper.infradead.org>
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
To: Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f175.google.com ([209.85.192.175]:38718 "EHLO
	mail-pd0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752006AbaIIVJP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Sep 2014 17:09:15 -0400
Received: by mail-pd0-f175.google.com with SMTP id z10so9692013pdj.6
        for <netdev@vger.kernel.org>; Tue, 09 Sep 2014 14:09:15 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20140908135413.GA5995@casper.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Sep 08, 2014 at 02:54:13PM +0100, Thomas Graf wrote:
> On 09/03/14 at 11:24am, Jiri Pirko wrote:
> > This patchset can be divided into 3 main sections:
> > - introduce switchdev api for implementing switch drivers
> > - add hardware acceleration bits into openvswitch datapath, This uses
> >   previously mentioned switchdev api
> > - introduce rocker switch driver which implements switchdev api
> 
> Jiri, Scott,
> 
> Enclosed is the GOOG doc which outlines some details on my particular
> interests [0]. It includes several diagrams which might help to
> understand the overall arch. It is highly related to John's work as
> well. Please let me know if something does not align with the model
> you have in mind.
> 
> Summary:
> The full virtual tunnel endpoint flow offload attempts to offload full
> flows to the hardware and utilize the embedded switch on the host NIC
> to empower the eSwitch with the required flexibility of the software
> driven network. In this model, the guest (VM or LXC) attaches through a
> SR-IOV VF which serves as the primary path. A slow path / software path
> is provided via the CPU which can route packets back into the VF by
> tagging packets with forwarding metadata and sending the frame back to
> the NIC.
> 
> [0] https://docs.google.com/document/d/195waUliu7G5YYVuXHmLmHgJ38DFSte321WPq0oaFhyU/edit?usp=sharing
> (Publicly accessible and open for comments)

Great doc. Very clear. I wish I could write docs like this :)

Few questions:
- on the 1st slide dpdk is used accept vm and lxc packet. How is that working?
  I know of 3 dpdk mechanisms to receive vm traffic, but all of them are kinda
  deficient, since offloads need to be disabled inside VM, so VM to VM
  performance over dpdk is not impressive. What is there for lxc?
  Is there a special pmd that can take packets from veth?

- full offload vs partial.
  The doc doesn't say, but I suspect we want transition from full to partial
  to be transparent? Especially for lxc. criu should be able to snapshot
  container on one box with full offload and restore it seamlessly on the
  other machine with partial offload, right?

- full offload with two nics.
  how bonding and redundancy suppose to work in such case?
  If wire attached to eth0 no longer passing packet, how traffic from VM1
  will reach eth1 on a different nic? Via sw datapath (flow table) ?
  I suspect we want to reuse current bonding/team abstraction here.
  I'm not quite getting the whole point of two separate physical nics.
  Is it for completeness and generality of the picture ?
  I think typical hypervisor will likely have only one multi-port nic, then
  bonding can be off-loaded within single nic via bonding driver.
  Partial offload scenario doesn't have this issue, since 'flow table'
  is fed by standard netdev which can be bond-dev and everything else, right?

- number of VFs
  I believe it's still very limited even in the newest nics, but
  number of containers will be large.
  So some lxcs will be using VFs and some will use standard veth?
  We cannot swap them dynamically based on load, so I'm not sure
  how VF approach is generically applicable here. For some use cases
  with demanding lxcs, it probably helps, but is it worth the gains?

Thanks!
