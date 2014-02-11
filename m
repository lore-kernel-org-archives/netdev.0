From: Vlad Yasevich <vyasevic@redhat.com>
Subject: Re: RFC: bridge get fdb by bridge device
Date: Tue, 11 Feb 2014 13:21:24 -0500
Message-ID: <52FA6A24.3030402@redhat.com>
References: <52F21F72.2090405@mojatatu.com> <52F29747.7040008@redhat.com> <52F3CF76.9090404@mojatatu.com> <52F3E357.4040006@redhat.com> <52F79990.3000400@mojatatu.com> <52F8FEF1.60407@redhat.com> <52FA58E9.906@mojatatu.com>
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
Received: from mx1.redhat.com ([209.132.183.28]:39066 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751185AbaBKSVc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 11 Feb 2014 13:21:32 -0500
In-Reply-To: <52FA58E9.906@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02/11/2014 12:07 PM, Jamal Hadi Salim wrote:
> On 02/10/14 11:31, Vlad Yasevich wrote:
>> On 02/09/2014 10:06 AM, Jamal Hadi Salim wrote:
> 
> 
>>> +    ndm = nlmsg_data(cb->nlh);
>>> +    if (ndm->ndm_ifindex) {
>>
>> We get really lucky here that ndm_ifindex and ifi_index happen to map to
>> the same location.
>>
> 
> Didnt follow - but I have a feeling you are looking at the reference
> point of a bridge port.
> Note as per my response to John: The target is a bridge device, not
> a bridge port.
> 

No, this was more the point that the current iproute code sends an
ifinfomsg struct down, and you change that to send ndmsg struct.
This is risky, but we luck out since the index is at the same offset
in both structs.

> 
> 
>>
>> I agree with both of Johns commens fro the above code.
>> I think you can use ndo_dflt_fdb_dump() here and remove the first check
>> for IFF_EBRIDGE.
>>
> 
> Same comment i made to John. The goal is to emulate
> brctl showmacs <bridge>
> ndo_dflt_fdb_dump() gives me in theory all the bridge ports
> unicast and multicast MAC addresses. There is a posibility that
> the bridgeport is a bridge - in which case I can find out from
> user space and safely request for it directly instead of via
> its parent.
> 

But that would only happen if the user said:
  # bridge fdb show br eth0

If eth0 in this case is a hw bridge device, getting the device's
version of fdb data is exactly what would be expected, isn't it?

If you mean a 'software bridge' above, then that's not an issue
since that's a disallowed config.  You can't stack software bridges
without something in the middle like bond or vlan.

>> The only odd thing is that it would permit syntax like:
>>   # bridge fbd show br eth0
>> or
>>   # bridge fdb show br macvlan0
>>
>> but I think that's ok.
> 
> Ok, since both you and John point to macvlan - is that
> considered as something with an fdb? It doesnt forward
> packets between two devices.
> 

Yes, macvlan can forward data to other macvlans, but that's
not the interesting thing.
When you configure multiple macvlan devices on top of the
same hw device, one could think of the hw device as a sort
of a bridge.  It's not really, but you could define it in
those terms.  The fdb entries, in this case, contain the mac
addresses of the macvlan devices.

> 
> 
>>> diff --git a/bridge/fdb.c b/bridge/fdb.c
>>> index e2e53f1..f3073d6 100644
>>> --- a/bridge/fdb.c
>>> +++ b/bridge/fdb.c
>>> @@ -33,7 +33,7 @@ static void usage(void)
>>>       fprintf(stderr, "Usage: bridge fdb { add | append | del |
>>> replace }
>> ADDR dev DEV {self|master} [ temp ]\n"
>>>                   "              [router] [ dst IPADDR] [ vlan VID ]\n"
>>>                   "              [ port PORT] [ vni VNI ] [via DEV]\n");
>>> -    fprintf(stderr, "       bridge fdb {show} [ dev DEV ]\n");
>>> +    fprintf(stderr, "       bridge fdb {show} [ br BRDEV ] [ dev DEV
>>> ]\n");
>>
>> 'port' option is now allowed in the show operation
>>
> 
> Thanks - it is already taken seems by vxlan using the same interface.
> 

Sorry, I wasn't very clear. What I meant was that you now support
  # bridge fdb show port <>

The usage message should reflect it.

-vlad
> 
> cheers,
> jamal
> 
