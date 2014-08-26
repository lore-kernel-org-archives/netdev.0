From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [patch net-next RFC 10/12] openvswitch: add support for datapath
 hardware offload
Date: Tue, 26 Aug 2014 16:06:30 +0200
Message-ID: <20140826140630.GA1848@nanopsycho.lan>
References: <53F9459B.2070801@mojatatu.com>
 <20140824111218.GA32741@casper.infradead.org>
 <53FA01AC.10507@mojatatu.com>
 <A67C7591-19BF-4431-9119-F61361F5E618@cumulusnetworks.com>
 <53FAA2A2.7070801@gmail.com>
 <53FB3FD5.2030905@mojatatu.com>
 <20140825141754.GA30140@casper.infradead.org>
 <53FB6122.2040901@mojatatu.com>
 <20140825225057.GD30140@casper.infradead.org>
 <53FC909D.8090000@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Thomas Graf <tgraf@suug.ch>, Jamal Hadi Salim <jhs@mojatatu.com>,
	John Fastabend <john.fastabend@gmail.com>,
	Scott Feldman <sfeldma@cumulusnetworks.com>,
	netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Neil Horman <nhorman@tuxdriver.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	dborkman <dborkman@redhat.com>, ogerlitz <ogerlitz@mellanox.com>,
	jesse@nicira.com, pshelar@nicira.com, azhou@nicira.com,
	ben@decadent.org.uk, stephen@networkplumber.org,
	jeffrey.t.kirsher@intel.com, vyasevic@redhat.com,
	xiyou.wangcong@gmail.com, john.r.fastabend@intel.com,
	edumazet@google.com, f.fainelli@gmail.com, linville@tuxdriver.com,
	dev@openvswitch.org, jasowang@redhat.com, ebiederm@xmission.com,
	nicolas.dichtel@6wind.com, ryazanov.s.a@gmail.com,
	buytenh@wantstofly.org, aviadr@mellanox.com, nbd@openwrt.org,
	alexei.starovoitov@gmail.com, Neil.Jerram@metaswitch.com,
	ron
To: Roopa Prabhu <roopa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f179.google.com ([209.85.212.179]:53172 "EHLO
	mail-wi0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758364AbaHZOGm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Aug 2014 10:06:42 -0400
Received: by mail-wi0-f179.google.com with SMTP id f8so4217354wiw.12
        for <netdev@vger.kernel.org>; Tue, 26 Aug 2014 07:06:40 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <53FC909D.8090000@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Tue, Aug 26, 2014 at 03:50:21PM CEST, roopa@cumulusnetworks.com wrote:
>On 8/25/14, 3:50 PM, Thomas Graf wrote:
>>On 08/25/14 at 12:15pm, Jamal Hadi Salim wrote:
>>>On 08/25/14 10:17, Thomas Graf wrote:
>>>>On 08/25/14 at 09:53am, Jamal Hadi Salim wrote:
>>>>fdb_add() *is* flow based. At least in my understanding, the whole
>>>>point here is to extend the idea of fdb_add() and make it understand
>>>>L2-L4 in a more generic way for the most common protocols.
>>>>
>>>>The reason fdb_add() is not reused is because it is Netlink specific
>>>>and only suitable for User -> HW offload. Kernel -> HW offload is
>>>>technically possible but not clean.
>>>>
>>>I dont think we have a problem handling any of this today.
>>Yes we do. It's restricted to L2 and we can't extend it easily
>>because it is based on NDA_*. The use of Netlink makes in-kernel
>>usage a pain. To me this is the sole reason for not using fdb_add()
>>in the first place. It seems absolutely clear though that fdb_add()
>>should be removed after the more generic ndo is in place providing
>>a superset of what fdb_add() can do today.
>>
>>>This is where our (shall i say strong) disagreement is.
>>>I think you will find it non-trivial to show me how you can
>>>actually take the simple L2 bridge and map it to a "flow".
>>>Since your starting point is "everything can be represented via a flow
>>>and some table" - we are at a crosspath.
>>OK, let me do the convertion for you:
>>
>>NDA_DST		unused
>>NDA_LLADDR	sw_flow_key.eth.dst
>>NDA_CACHEINFO	unused
>>NDA_PROBES	unused
>>NDA_VLAN	sw_flow_key.eth.tci
>>NDA_PORT	unused
>>NDA_VNI		sw_flow_key.tun_key.tun_id
>>NDA_IFINDEX	sw_flow_key.phys.in_port
>>NDA_MASTER	unused
>>
>>>The tc filter API seems to be doing just that.
>>>You have different types of classifiers - the h/w may not be able
>>>to support some classifier types - but that is a capability discovery
>>>challenge.
>>Agreed but tc is only one out of many possible existing interfaces
>>we have. macvtap (given we want to extend beyond L2), routing,
>>OVS, bridge and eventually even things like a team device can and
>>should make use of offloads.
>>
>>>I am saying two things:
>>>1) There are a few "fundamental" interfaces; L2 and L3 being some.
>>>Add crypto offload and a few i mentioned in  my presentation. We
>>Can you share that preso? I was not present.
>>
>>>know how to do those. example; there is nothing i cant do with
>>>the rtmsg that is L3. or the fdb/port/vlan filter for L2.
>>>This flow thing should stay out of those.
>>Let me remind you about the name of the structure behind all L3
>>forwarding decisions:
>>
>>         struct flowi4 {
>>		[...]
>>	}
>>
>>Adding a route means adding a flow. Can we please stop the flow
>>bashing? The concept of a flow is very generic, well known and already
>>very present in the kernel.
>>
>>The sw_flow_key proposed comes close to flowi4. Some fields are
>>different. They can eventually get merged. The strict IPv4/IPv6
>>separation is what makes it non obvious and probably why Jiri chose
>>the OVS representation. If you say rtmsg is complete then that clearly
>>is not the case. In particular VTEP fields, ARP, and TCP flags are
>>clearly missing for many uses.
>>
>>Again, I'm not saying flow is the ultimate answer to everything. It
>>is not. But a lot of hardware out there is aware of flows in combination
>>with some form of action execution. Non flow based hardware can have
>>their own classifier.
>>
>>>2) The flow thing should allow a variety of classifiers to be
>>>handled. Again capability discovery would take care of differences.
>>So you want the flow to represent something that is not a flow. Again,
>>this comes back to the conversation in the other email. If this is
>>all about having a single ndo I'm sure we can find common grounds on
>>that.
>
>From what i understood (trying to summarize here for my own benefit):
>the switchdev api currently under review proposes every switch asic offload
>abstraction as a flow.
>It does not mandate this via code, however, there seems to be some discussion
>along those lines.
>
>The switchdev api flow ndo's need to stay for switch asic drivers that
>support flows directly or
>possibly want all their hw offload abstraction to be represented by the flow
>abstraction (openvswitch, the rocker dev ). The details of how the flow is
>mapped to hw lies in the corresponding switch driver code.

Nod.

>
>We think rtnetlink is the api to model switch asic hw tables.
>We have a working model (Cumulus) that maps rtnetlink to switch
>asic hw tables (via snooping rtnetlink msgs). This can be done by extending
>the switchdev api
>with new ndo's for l2 and l3.
>
>Example:
>  new switchdev ndo's for fdb_add/fdb_del
>  new switchdev ndo's for l3

Nod.

>
>Now we only need working patches that implement switchdev api ndo ops for
>l2/l3 (this is in the works).
>
>As long as the current patches under review allow the extension of the api to
>cover non-flow based l2/l3 switch asic offloads, we might be good (?).


Yes. Flows are phase one. The api will be extended in for whatever is
needed for l2/l3 as you said. Also I see a possibility to implement the
l2/l3 use case with flows as well. But generally, as stands for ever in-kernel
api, we can extend it and change it.


>
>
>
>--
>To unsubscribe from this list: send the line "unsubscribe netdev" in
>the body of a message to majordomo@vger.kernel.org
>More majordomo info at  http://vger.kernel.org/majordomo-info.html
