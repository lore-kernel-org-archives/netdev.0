From: Tom Herbert <therbert@google.com>
Subject: Re: [patch net-next v2 8/9] switchdev: introduce Netlink API
Date: Tue, 23 Sep 2014 13:57:08 -0700
Message-ID: <CA+mtBx9kKATy7LUSaD1nXrY=h0LiEVciDGzWnyjqCXt_LVQMyQ@mail.gmail.com>
References: <CAADnVQ+=vKEjzUTcEW+yzA4bTL4TKabrzzk=gb=OyfuVGwOyPA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Thomas Graf <tgraf@suug.ch>, Jiri Pirko <jiri@resnulli.us>,
	John Fastabend <john.r.fastabend@intel.com>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Neil Horman <nhorman@tuxdriver.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	Daniel Borkmann <dborkman@redhat.com>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Jesse Gross <jesse@nicira.com>,
	Pravin Shelar <pshelar@nicira.com>,
	Andy Zhou <azhou@nicira.com>,
	Ben Hutchings <ben@decadent.org.uk>,
	Stephen Hemminger <stephen@networkplumber.org>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Vladislav Yasevich <vyasevic@redhat.com>,
	Cong Wang <xiyou.wangcong@gmail.com>,
	Eric Dumazet <edumazet@google.com>,
	Scott Feldman <sfeldma@cumulusnetworks.com>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Roopa Prabhu <roopa@cumulusnetworks.com>,
	John Linville <linvi
To: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f182.google.com ([209.85.223.182]:43746 "EHLO
	mail-ie0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932184AbaIWU5J (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Sep 2014 16:57:09 -0400
Received: by mail-ie0-f182.google.com with SMTP id tp5so4989415ieb.27
        for <netdev@vger.kernel.org>; Tue, 23 Sep 2014 13:57:09 -0700 (PDT)
In-Reply-To: <CAADnVQ+=vKEjzUTcEW+yzA4bTL4TKabrzzk=gb=OyfuVGwOyPA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> SKB_GSO_UDP_TUNNEL_CSUM was the right way
> to start splitting overloaded and messy semantics of
> UDP_TUNNEL. I'm still not sure whether you've intended
> it for both rx and tx, since to support tunnel_csum on rx,
> parsing of encap is needed, whereas tx is so much simpler.
> Unless you're assuming checksum_complete model for rx...
>
>> If properly implemented, HW can implement a whole bunch of
>> UDP encap protocols without knowing how to parse them.
>
> on a tx side... yes, but I cannot see how you can do rx
> with inner csum verify without parsing encap.
> What do you have in mind ?
>
Implement checksum-complete. It does not require a device to parse the
encap, is usable with probably all encapsulation formats being
discussed, and easily supports multiple checksums in a packet. This
will even work with something like L2TP where a device can't do
stateless parsing (pseudo wire encapsulation).

Of the five basic NIC offloads (RX-csum, TX-csum, TSO, LRO, and RSS),
LRO is the one that probably cannot be generalized so that NICs don't
need to parse specific encapsulation protocols. Fortunately, GRO
performance is now very comparable anyway so I tend to think LRO
support is not crucial (the same argument might be made for GSO/TSO I
suppose, but TSO we can mostly generalize). HW support for checksum
offloads and RSS are definitely still very relevant!

>> I don't see how
>> a switch on the NIC helps this...
>
> correct, just a switch on a nic isn't very useful.
>
> If immediate consumer of the packet is a VM,
> then doing switching in the nic after decap doesn't
> add much speed, since bridge+router+nat+policy in sw
> after decap and csum verify done by hw are fast enough.
> But switching in HW becomes useful when VF
> is a destination device, since it avoids hw->sw->hw
> roundtrip as Thomas was saying.
>
> Also there are x86 network gateways where tunneled
> traffic from virtual network is terminated and sent
> over internet or to other datacenter. Performance
> demands are high, so if tunnel+switch+nat+policy
> can be done in off-the-shelf HW it would be great.
>
>>> And this is just tx offload. On rx smart tunnel offload in HW parses
>>> encap and goes all the way to inner headers to verify checksums,
>>> it also steers based on inner headers.
>>> Try mellanox nics with and without vxlan offload to see
>>> the difference.
>>
>> Turn on UDP RSS on the device and I bet you'll see those differences
>> go away!
>
> Logically it should, since all inner flows should get
> hashed into different outer src_port, but somehow
> that didn't work. Need to re-investigate with your
> l4_hash stuff.
>
You may need to enable RSS for UDP. Like "ethtool -N eth0 rx-flow-hash
udp4 sdfn"

>> Alexei, I believe you said previously said that SW should not dictate
>> HW models. I agree with this, but also believe the converse is true--
>> HW shouldn't dictate SW model.
>
> completely agree!
>
>> This is really why I'm raising the
>> question of what it means to integrate a switch into the host stack.
>> If this is something that doesn't require any model change to the
>> stack and is just a clever backend for rx-filters or tc, then I'm fine
>> with that!
>
> agree as well. I'm not excited about switchdev
> abstraction from this given patch, since it looks overly
> simplified and not applicable to real silicon, but
> discussion about exposing programmable
> nics/switches to sw in a generic way is worth having :)
