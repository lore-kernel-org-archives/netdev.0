From: John Fastabend <john.r.fastabend@intel.com>
Subject: Re: RFC: bridge get fdb by bridge device
Date: Tue, 11 Feb 2014 12:30:29 -0800
Message-ID: <52FA8865.1070302@intel.com>
References: <52F21F72.2090405@mojatatu.com> <52F29747.7040008@redhat.com> <52F3CF76.9090404@mojatatu.com> <52F3E357.4040006@redhat.com> <52F79990.3000400@mojatatu.com> <52F8FEF1.60407@redhat.com> <52FA58E9.906@mojatatu.com> <52FA6A24.3030402@redhat.com> <52FA84FA.2030608@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: vyasevic@redhat.com,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Stephen Hemminger <stephen@networkplumber.org>,
	Scott Feldman <sfeldma@cumulusnetworks.com>
To: Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:35707 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754619AbaBKUab (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 11 Feb 2014 15:30:31 -0500
In-Reply-To: <52FA84FA.2030608@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2/11/2014 12:15 PM, Jamal Hadi Salim wrote:
> On 02/11/14 13:21, Vlad Yasevich wrote:
>> On 02/11/2014 12:07 PM, Jamal Hadi Salim wrote:
>>> On 02/10/14 11:31, Vlad Yasevich wrote:
>
>> No, this was more the point that the current iproute code sends an
>> ifinfomsg struct down, and you change that to send ndmsg struct.
>> This is risky, but we luck out since the index is at the same offset
>> in both structs.
>>
>
> ah, ok, thanks for catching that. I should have said something - the
> original code was wrong and i felt it was safe to make the change
> given that the kernel code never even looked at what was being
> sent to it. There is asymetry desires which are violated.
> It doesnt make sense to send and ifm and expect back an ndm.
> I should send that separately as a bug fix.
>
>
>> But that would only happen if the user said:
>>    # bridge fdb show br eth0
>>
>> If eth0 in this case is a hw bridge device, getting the device's
>> version of fdb data is exactly what would be expected, isn't it?
>>
>
> Well, if it is a "bridge device" why would it not be tagged as a bridge
> device?

What do you mean by "bridge device" are you specifically talking about
IFF_BRIDGE flag? This flag is used only for ./net/bridge devices. For
example macvlan uses its own flag. I think there is a good case to be
made for netdevices which are acting as the management interface for a
hardware bridge to set an identifying flag. Perhaps IFF_HWBRIDGE.

>
>> If you mean a 'software bridge' above, then that's not an issue
>> since that's a disallowed config.  You can't stack software bridges
>> without something in the middle like bond or vlan.
>>
>
> Ok, didnt realize that.
> So i cant add a bridge as a bridge port to another bridge?
>

# ip link set dev bridge0 master bridge1
RTNETLINK answers: Too many levels of symbolic links

in the bridge case this doesn't work. But you can stack a macvlan
on top of the bridge port,

# ip link add link bridge0 type macvlan mode vepa

11: macvlan0@bridge0: <BROADCAST,MULTICAST,M-DOWN> mtu 1500 qdisc noop 
state DOWN mode DEFAULT group default

And macvlans on macvlans is OK as well.

# ip link add link macvlan0 type macvlan mode vepa

[...]

>> When you configure multiple macvlan devices on top of the
>> same hw device, one could think of the hw device as a sort
>> of a bridge.  It's not really, but you could define it in
>> those terms.  The fdb entries, in this case, contain the mac
>> addresses of the macvlan devices.
>>
>
> It certainly has some equivalent semantics (looks at dst MAC then
> picks the port). Possible to add Vlans as well?
> Why dont we tag such a thing as a bridge then?
>

If its useful then we should. You can track them down in userspace
via /sys/class/net/ or looking for offloaded netdevices that point
to the interface but a flag is definitely more direct.

>>
>> Sorry, I wasn't very clear. What I meant was that you now support
>>    # bridge fdb show port <>
>>
>> The usage message should reflect it.
>>
>
> Sorry - I noticed the word "port" at exactly where your quote came.
> So i thought you noticed that "port" was already taken - it is used
> for VXLAN fdb entries (for udp ports).
>
>
> cheers,
> jamal
