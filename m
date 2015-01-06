From: Fan Du <fengyuleidian0615@gmail.com>
Subject: Re: [PATCH net] gso: do GSO for local skb with size bigger than MTU
Date: Tue, 06 Jan 2015 17:34:11 +0800
Message-ID: <54ABAC13.9070402@gmail.com>
References: <1417156385-18276-1-git-send-email-fan.du@intel.com> <1417158128.3268.2@smtp.corp.redhat.com> <5A90DA2E42F8AE43BC4A093BF0678848DED92B@SHSMSX104.ccr.corp.intel.com> <20141201135225.GA16814@casper.infradead.org> <20141202154839.GB5344@t520.home> <20141202170927.GA9457@casper.infradead.org> <20141202173401.GB4126@redhat.com> <20141202174158.GB9457@casper.infradead.org> <5A90DA2E42F8AE43BC4A093BF0678848DEDFDB@SHSMSX104.ccr.corp.intel.com> <54AA2912.6090903@gmail.com> <CAEP_g=-R1FrcA0sTJJjQhypRtVCwoRZ+LieKaSJxqA-HACZqEw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "Du, Fan" <fan.du@intel.com>, Thomas Graf <tgraf@suug.ch>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"Michael S. Tsirkin" <mst@redhat.com>,
	Jason Wang <jasowang@redhat.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"fw@strlen.de" <fw@strlen.de>,
	"dev@openvswitch.org" <dev@openvswitch.org>,
	"pshelar@nicira.com" <pshelar@nicira.com>
To: Jesse Gross <jesse@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f49.google.com ([209.85.220.49]:32884 "EHLO
	mail-pa0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753825AbbAFJeX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Jan 2015 04:34:23 -0500
Received: by mail-pa0-f49.google.com with SMTP id eu11so30472677pac.22
        for <netdev@vger.kernel.org>; Tue, 06 Jan 2015 01:34:22 -0800 (PST)
In-Reply-To: <CAEP_g=-R1FrcA0sTJJjQhypRtVCwoRZ+LieKaSJxqA-HACZqEw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On 2015/1/6 1:58, Jesse Gross wrote:
> On Mon, Jan 5, 2015 at 1:02 AM, Fan Du <fengyuleidian0615@gmail.com> =
wrote:
>> =E4=BA=8E 2014=E5=B9=B412=E6=9C=8803=E6=97=A5 10:31, Du, Fan =E5=86=99=
=E9=81=93:
>>
>>>
>>>> -----Original Message-----
>>>> From: Thomas Graf [mailto:tgr@infradead.org] On Behalf Of Thomas G=
raf
>>>> Sent: Wednesday, December 3, 2014 1:42 AM
>>>> To: Michael S. Tsirkin
>>>> Cc: Du, Fan; 'Jason Wang'; netdev@vger.kernel.org; davem@davemloft=
=2Enet;
>>>> fw@strlen.de; dev@openvswitch.org; jesse@nicira.com; pshelar@nicir=
a.com
>>>> Subject: Re: [PATCH net] gso: do GSO for local skb with size bigge=
r than
>>>> MTU
>>>>
>>>> On 12/02/14 at 07:34pm, Michael S. Tsirkin wrote:
>>>>> On Tue, Dec 02, 2014 at 05:09:27PM +0000, Thomas Graf wrote:
>>>>>> On 12/02/14 at 01:48pm, Flavio Leitner wrote:
>>>>>>> What about containers or any other virtualization environment t=
hat
>>>>>>> doesn't use Virtio?
>>>>>>
>>>>>> The host can dictate the MTU in that case for both veth or OVS
>>>>>> internal which would be primary container plumbing techniques.
>>>>>
>>>>> It typically can't do this easily for VMs with emulated devices:
>>>>> real ethernet uses a fixed MTU.
>>>>>
>>>>> IMHO it's confusing to suggest MTU as a fix for this bug, it's an
>>>>> unrelated optimization.
>>>>> ICMP_DEST_UNREACH/ICMP_FRAG_NEEDED is the right fix here.
>>>>
>>>> PMTU discovery only resolves the issue if an actual IP stack is ru=
nning
>>>> inside the
>>>> VM. This may not be the case at all.
>>>    ^^^^^^^^^^^^^^^^^^^^^^^^^^^
>>>
>>> Some thoughts here:
>>>
>>> Think otherwise, this is indeed what host stack should forge a
>>> ICMP_DEST_UNREACH/ICMP_FRAG_NEEDED
>>> message with _inner_ skb network and transport header, do whatever =
type of
>>> encapsulation,
>>> and thereafter push such packet upward to Guest/Container, which ma=
ke them
>>> feel, the intermediate node
>>> or the peer send such message. PMTU should be expected to work corr=
ect.
>>> And such behavior should be shared by all other encapsulation tech =
if they
>>> are also suffered.
>>
>> Hi David, Jesse and Thomas
>>
>> As discussed in here:
>> https://www.marc.info/?l=3Dlinux-netdev&m=3D141764712631150&w=3D4 an=
d
>> quotes from Jesse:
>> My proposal would be something like this:
>>   * For L2, reduce the VM MTU to the lowest common denominator on th=
e
>> segment.
>>   * For L3, use path MTU discovery or fragment inner packet (i.e.
>> normal routing behavior).
>>   * As a last resort (such as if using an old version of virtio in t=
he
>> guest), fragment the tunnel packet.
>>
>>
>> For L2, it's a administrative action
>> For L3, PMTU approach looks better, because once the sender is alert=
ed the
>> reduced MTU,
>> packet size after encapsulation will not exceed physical MTU, so no
>> additional fragments
>> efforts needed.
>> For "As a last resort... fragment the tunnel packet", the original p=
atch:
>> https://www.marc.info/?l=3Dlinux-netdev&m=3D141715655024090&w=3D4 di=
d the job, but
>> seems it's
>> not welcomed.
> This needs to be properly integrated into IP processing if it is to
> work correctly.
Do you mean the original patch in this thread? yes, it works correctly
in my cloud env. If you has any other concerns, please let me know. :)
> One of the reasons for only doing path MTU discovery
> for L3 is that it operates seamlessly as part of normal operation -
> there is no need to forge addresses or potentially generate ICMP when
> on an L2 network. However, this ignores the IP handling that is going
> on (note that in OVS it is possible for L3 to be implemented as a set
> of flows coming from a controller).
>
> It also should not be VXLAN specific or duplicate VXLAN encapsulation
> code. As this is happening before encapsulation, the generated ICMP
> does not need to be encapsulated either if it is created in the right
> location.
Yes, I agree. GRE share the same issue from the code flow.
Pushing back ICMP msg back without encapsulation without circulating do=
wn
to physical device is possible. The "right location" as far as I know
could only be in ovs_vport_send. In addition this probably requires wra=
pper
route looking up operation for GRE/VXLAN, after get the under layer=20
device MTU
from the routing information, then calculate reduced MTU becomes feasib=
le.
