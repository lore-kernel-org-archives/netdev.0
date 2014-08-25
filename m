From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [patch net-next RFC 10/12] openvswitch: add support for datapath
 hardware offload
Date: Mon, 25 Aug 2014 15:17:54 +0100
Message-ID: <20140825141754.GA30140@casper.infradead.org>
References: <1408637945-10390-1-git-send-email-jiri@resnulli.us>
 <1408637945-10390-11-git-send-email-jiri@resnulli.us>
 <53F79C54.5050701@gmail.com>
 <464DB0A8-0073-4CE0-9483-0F36B73A53A1@cumulusnetworks.com>
 <53F9459B.2070801@mojatatu.com>
 <20140824111218.GA32741@casper.infradead.org>
 <53FA01AC.10507@mojatatu.com>
 <A67C7591-19BF-4431-9119-F61361F5E618@cumulusnetworks.com>
 <53FAA2A2.7070801@gmail.com>
 <53FB3FD5.2030905@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: John Fastabend <john.fastabend@gmail.com>,
	Scott Feldman <sfeldma@cumulusnetworks.com>,
	Jiri Pirko <jiri@resnulli.us>, netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Neil Horman <nhorman@tuxdriver.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	dborkman <dborkman@redhat.com>, ogerlitz <ogerlitz@mellanox.com>,
	jesse@nicira.com, pshelar@nicira.com, azhou@nicira.com,
	ben@decadent.org.uk, stephen@networkplumber.org,
	jeffrey.t.kirsher@intel.com, vyasevic@redhat.com,
	xiyou.wangcong@gmail.com, john.r.fastabend@intel.com,
	edumazet@google.com, f.fainelli@gmail.com,
	roopa@cumulusnetworks.com, linville@tuxdriver.com,
	dev@openvswitch.org, jasowang@redhat.com, ebiederm@xmission.com,
	nicolas.dichtel@6wind.com, ryazanov.s.a@gmail.com,
	buytenh@wantstofly.org, aviadr@mellanox.com, nbd@openwrt.org,
	alexei.starovoitov@gmail.com, Neil.Jerram@metaswitch.com,
	ronye@mella
To: Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:43887 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932395AbaHYOSD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Aug 2014 10:18:03 -0400
Content-Disposition: inline
In-Reply-To: <53FB3FD5.2030905@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/25/14 at 09:53am, Jamal Hadi Salim wrote:
> On 08/24/14 22:42, John Fastabend wrote:
> 
> >In the L2 case we already have the fdb_add and fdb_del semantics that
> >are being used today by NICs with embedded switches. And we have a DSA
> >patch we could dig out of patchwork for those drivers.
> 
> Indeed. That is an excellent starting point of something that is proven
> to work. I was hoping L3 would follow this path. For L2,
> there is the mess of claiming unicast NIC addresses as part of
> the fdb, but that can almost be ignored.
> Caveat: fdb_XXX works well for NICs as well as different larger
> ASICs - but some quark handling is going to be needed for the tinier
> openwrt type devices.
> For larger switches we are going to need more for L2:
> Really, the bridge already covers everthing large switches
> offer (Vlan filtering, bridge port setting etc). We just need
> to offload that...

fdb_add() *is* flow based. At least in my understanding, the whole
point here is to extend the idea of fdb_add() and make it understand
L2-L4 in a more generic way for the most common protocols.

The reason fdb_add() is not reused is because it is Netlink specific
and only suitable for User -> HW offload. Kernel -> HW offload is
technically possible but not clean.

The only reason swdev is needed at all is to represent the port model
and to allow for non flow based models built on top of the same
hardware abstraction. I see now reason why br_fdb cannot be represented
through swdev as soon as the code is stable.

> >So I think it makes more sense to use the explicit interface rather
> >than put another shim layer in the kernel. Its simpler and more to the
> >point IMO. I suspect the resulting code will be smaller and easier to
> >read. I'm the squemish one in the audience here.
> >
> 
> L2/3 should be left alone and go this path. My concern on excessive
> NDOs was more on the flow view of the world.

The point I was trying to make earlier is that it is very hard to
program both protocol aware and generic filtering hardware through
a single NDO. It will make the driver specific part complex.

If you are saying we need yet another classifier model in the kernel
then I'm not sure that is needed in the presence of cls/act, iptables,
and nftables. They seem suitable to represent non flow based models
and I see nothing that would prevent an offload through swdev for them.
