From: Jesse Gross <jesse@nicira.com>
Subject: Re: [PATCH net] gso: do GSO for local skb with size bigger than MTU
Date: Wed, 3 Dec 2014 10:07:42 -0800
Message-ID: <CAEP_g=9C+D3gbjJ4n1t6xuyjqEAMYi4ZfqPoe92UAoQJH-UsKg@mail.gmail.com>
References: <1417156385-18276-1-git-send-email-fan.du@intel.com>
 <1417158128.3268.2@smtp.corp.redhat.com> <5A90DA2E42F8AE43BC4A093BF0678848DED92B@SHSMSX104.ccr.corp.intel.com>
 <20141201135225.GA16814@casper.infradead.org> <20141202154839.GB5344@t520.home>
 <20141202170927.GA9457@casper.infradead.org> <20141202173401.GB4126@redhat.com>
 <20141202174158.GB9457@casper.infradead.org> <CAEP_g=-86Z6pxNow-wjnbx_v9er_TSn6x5waigqVqYHa7tEQJw@mail.gmail.com>
 <20141203090339.GA9299@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Thomas Graf <tgraf@suug.ch>, "Du, Fan" <fan.du@intel.com>,
	Jason Wang <jasowang@redhat.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"fw@strlen.de" <fw@strlen.de>,
	"dev@openvswitch.org" <dev@openvswitch.org>,
	Pravin Shelar <pshelar@nicira.com>
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na6sys009bog032.obsmtp.com ([74.125.150.106]:46931 "HELO
	na6sys009bog032.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1750927AbaLCSIE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Dec 2014 13:08:04 -0500
Received: by mail-qc0-f170.google.com with SMTP id x3so11523125qcv.15
        for <netdev@vger.kernel.org>; Wed, 03 Dec 2014 10:08:03 -0800 (PST)
In-Reply-To: <20141203090339.GA9299@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Dec 3, 2014 at 1:03 AM, Michael S. Tsirkin <mst@redhat.com> wrote:
> On Tue, Dec 02, 2014 at 10:12:04AM -0800, Jesse Gross wrote:
>> On Tue, Dec 2, 2014 at 9:41 AM, Thomas Graf <tgraf@suug.ch> wrote:
>> > On 12/02/14 at 07:34pm, Michael S. Tsirkin wrote:
>> >> On Tue, Dec 02, 2014 at 05:09:27PM +0000, Thomas Graf wrote:
>> >> > On 12/02/14 at 01:48pm, Flavio Leitner wrote:
>> >> > > What about containers or any other virtualization environment that
>> >> > > doesn't use Virtio?
>> >> >
>> >> > The host can dictate the MTU in that case for both veth or OVS
>> >> > internal which would be primary container plumbing techniques.
>> >>
>> >> It typically can't do this easily for VMs with emulated devices:
>> >> real ethernet uses a fixed MTU.
>> >>
>> >> IMHO it's confusing to suggest MTU as a fix for this bug, it's
>> >> an unrelated optimization.
>> >> ICMP_DEST_UNREACH/ICMP_FRAG_NEEDED is the right fix here.
>> >
>> > PMTU discovery only resolves the issue if an actual IP stack is
>> > running inside the VM. This may not be the case at all.
>>
>> It's also only really a correct thing to do if the ICMP packet is
>> coming from an L3 node. If you are doing straight bridging then you
>> have to resort to hacks like OVS had before, which I agree are not
>> particularly desirable.
>
> The issue seems to be that fundamentally, this is
> bridging interfaces with variable MTUs (even if MTU values
> on devices don't let us figure this out)-
> that is already not straight bridging, and
> I would argue sending ICMPs back is the right thing to do.

How do you deal with the fact that there is no host IP stack inside
the tunnel? And isn't this exactly the same as the former OVS
implementation that you said you didn't like?

>> > I agree that exposing an MTU towards the guest is not applicable
>> > in all situations, in particular because it is difficult to decide
>> > what MTU to expose. It is a relatively elegant solution in a lot
>> > of virtualization host cases hooked up to an orchestration system
>> > though.
>>
>> I also think this is the right thing to do as a common case
>> optimization and I know other platforms (such as Hyper-V) do it. It's
>> not a complete solution so we still need the original patch in this
>> thread to handle things transparently.
>
> Well, as I believe David (and independently Jason) is saying, it looks like
> the ICMPs we are sending back after applying the original patch have the
> wrong MTU.

The problem is actually that the ICMP messages won't even go to the
sending VM because the host IP stack and the VM are isolated from each
other and there is no route.

> And if I understand what David is saying here, IP is also the wrong place to
> do it.

ICMP can't be the complete solution in any case because it only works
for IP traffic. I think there are only two full solutions: find a way
to adjust the guest MTU to the minimum MTU that its traffic could hit
in an L2 domain or fragmentation. ICMP could be a possible
optimization in the fragmentation case.
