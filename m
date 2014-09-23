From: Tom Herbert <therbert@google.com>
Subject: Re: [patch net-next v2 8/9] switchdev: introduce Netlink API
Date: Mon, 22 Sep 2014 19:16:47 -0700
Message-ID: <CA+mtBx-mJE6SW2bqf3_t6iu=o5FY1WAF1ByeZpDJnc+6fpK6nA@mail.gmail.com>
References: <1411134590-4586-1-git-send-email-jiri@resnulli.us>
	<1411134590-4586-9-git-send-email-jiri@resnulli.us>
	<541C4AFC.8060500@mojatatu.com>
	<20140919154946.GH1980@nanopsycho.orion>
	<541C6E6D.9000109@mojatatu.com>
	<541CAA3C.5080105@intel.com>
	<20140920081426.GE1821@nanopsycho.orion>
	<20140920105354.GA29419@casper.infradead.org>
	<CAADnVQK0wT2Fjqdg+C=ruSt8jF6sKeMo7cFj7K1fsu7-1u5g=g@mail.gmail.com>
	<20140922081341.GA20905@casper.infradead.org>
	<CA+mtBx-ZvkZ2ALGLsLEN7Cgn9gN_rY36ZhuqYC3mZ9WVxjFDaQ@mail.gmail.com>
	<CAADnVQKhUAR=qVg9q82ngYMzQnoDVbq+wupzdMrH8WiCeMiU4A@mail.gmail.com>
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
Received: from mail-ie0-f179.google.com ([209.85.223.179]:64605 "EHLO
	mail-ie0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755801AbaIWCQs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Sep 2014 22:16:48 -0400
Received: by mail-ie0-f179.google.com with SMTP id tp5so3868208ieb.38
        for <netdev@vger.kernel.org>; Mon, 22 Sep 2014 19:16:48 -0700 (PDT)
In-Reply-To: <CAADnVQKhUAR=qVg9q82ngYMzQnoDVbq+wupzdMrH8WiCeMiU4A@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Sep 22, 2014 at 6:54 PM, Alexei Starovoitov
<alexei.starovoitov@gmail.com> wrote:
> On Mon, Sep 22, 2014 at 8:10 AM, Tom Herbert <therbert@google.com> wrote:
>> On Mon, Sep 22, 2014 at 1:13 AM, Thomas Graf <tgraf@suug.ch> wrote:
>>> On 09/20/14 at 03:50pm, Alexei Starovoitov wrote:
>>>> I think HW should not be limited by SW abstractions whether
>>>> these abstractions are called flows, n-tuples, bridge or else.
>>>> Really looking forward to see "device reporting the headers as
>>>> header fields (len, offset) and the associated parse graph"
>>>> as the first step.
>>>>
>>>> Another topic that this discussion didn't cover yet is how this
>>>> all connects to tunnels and what is 'tunnel offloading'.
>
>> encapsulation (stuffing a few bytes of header into a packet) is in
>> itself not nearly an expensive enough operation to warrant offloading
>> to the NIC. Personally, I wish if NIC vendors are going to focus on
>
> On contrary, generic tunneling is most important one to get right
> when we're talking offloads.
> Adding encap header is easy to do in hw, but it breaks all other
> offloads if hw is not generic. Consider gso packet coming from vm.
> Generic tunnel allows sw to add inner headers, outer headers and
> setup offload offsets, so that HW does segmentation, checksuming
> of inner packet, adjusts inner headers and adds final outer encap.

As I pointed out on a previous thread, we already have a sufficiently
generic interface to allow HW to do encapsulated TSO
(SKB_GSO_UDP_TUNNEL and SKB_GSO_UDP_TUNNEL_CSUM with the inner
headers). If properly implemented, HW can implement a whole bunch of
UDP encap protocols without knowing how to parse them. I don't see how
a switch on the NIC helps this...

> And this is just tx offload. On rx smart tunnel offload in HW parses
> encap and goes all the way to inner headers to verify checksums,
> it also steers based on inner headers.
> Try mellanox nics with and without vxlan offload to see
> the difference.

Turn on UDP RSS on the device and I bet you'll see those differences
go away! Once we moved to UDP encapsulation, there's really little
value in looking at inner headers for RSS or ECMP, this should be
sufficient. Sure someone might want to parse the inner headers for
some sort of advanced RX steering, but again this implies rx-filtering
and not switch functionality.

Alexei, I believe you said previously said that SW should not dictate
HW models. I agree with this, but also believe the converse is true--
HW shouldn't dictate SW model. This is really why I'm raising the
question of what it means to integrate a switch into the host stack.
If this is something that doesn't require any model change to the
stack and is just a clever backend for rx-filters or tc, then I'm fine
with that!

Thanks,
Tom

> It looks like fm10k will be just as good, but existing encaps are
> not going to last forever, so RX should be improved they way John
> is saying. There gotta to be a 'parse graph' for HW to see past
> variable length encap and into inner headers.
> checksum_complete style of offloading checksum verification
> is not efficient. The cost of adjusting it over and over while
> parsing encaps is too high. Plus cpu steering based on outer
> headers is just too slow when speeds are in 40G range.
>
>> stateful offload I rather see it be for encryption which I believe
>> currently does warrant offload at 40G and higher speeds.
>
> encryption offload is badly needed as well. Unfortunately it's
> not seen as nic feature yet.
