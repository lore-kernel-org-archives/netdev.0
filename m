From: Vlad Yasevich <vyasevic@redhat.com>
Subject: Re: RFC: bridge get fdb by bridge device
Date: Tue, 11 Feb 2014 16:00:59 -0500
Message-ID: <52FA8F8B.3080500@redhat.com>
References: <52F21F72.2090405@mojatatu.com> <52F29747.7040008@redhat.com> <52F3CF76.9090404@mojatatu.com> <52F3E357.4040006@redhat.com> <52F79990.3000400@mojatatu.com> <52F8FEF1.60407@redhat.com> <52FA58E9.906@mojatatu.com> <52FA6A24.3030402@redhat.com> <52FA84FA.2030608@mojatatu.com>
Reply-To: vyasevic@redhat.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <stephen@networkplumber.org>,
	Scott Feldman <sfeldma@cumulusnetworks.com>,
	John Fastabend <john.r.fastabend@intel.com>
To: Jamal Hadi Salim <jhs@mojatatu.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:49999 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752614AbaBKVBZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 11 Feb 2014 16:01:25 -0500
In-Reply-To: <52FA84FA.2030608@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02/11/2014 03:15 PM, Jamal Hadi Salim wrote:
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

Because it just a multi-function nic that isn't tagged with any
kine of bridge flag.  As John said, this might be useful, but not
done yet.

> 
>> If you mean a 'software bridge' above, then that's not an issue
>> since that's a disallowed config.  You can't stack software bridges
>> without something in the middle like bond or vlan.
>>
> 
> Ok, didnt realize that.
> So i cant add a bridge as a bridge port to another bridge?

Not directly.  However, if you put a layered software device in between
(vlan, bond, macvlan), then you can add that device to another bridge.
In fact, people do that to get GVRP working with VMs.

> 
>>
>> Yes, macvlan can forward data to other macvlans, but that's
>> not the interesting thing.
> 
> Sample config?
> 
>> When you configure multiple macvlan devices on top of the
>> same hw device, one could think of the hw device as a sort
>> of a bridge.  It's not really, but you could define it in
>> those terms.  The fdb entries, in this case, contain the mac
>> addresses of the macvlan devices.
>>
> 
> It certainly has some equivalent semantics (looks at dst MAC then
> picks the port). Possible to add Vlans as well?

I suppose.   You can do things like:
# ip link add link eth0 dev vlan100 protocol 8021Q id 100
# ip link add link vlan0 dev mac100 type macvlan

Now, you have a macvlan (mac100) that will only receive vlan100 traffic.
Expressing this in terms of fdb would be a bit difficult since each
interface is separate and eth0 doesn't really know about the stack.
It would require quite a lot of code.

> Why dont we tag such a thing as a bridge then?
> 

Because they are not always a bridge.  It could be just a nic capable of
mac filtering.

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

Didn't realize it has different connotation for vxlan.  The you probably
don't want to include and support in the bridge fdb show command.

-vlad

> 
> cheers,
> jamal
