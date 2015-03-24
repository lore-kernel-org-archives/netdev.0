From: Robert Shearman <rshearma@brocade.com>
Subject: Re: [PATCH net-next v2 2/5] mpls: Remove incorrect PHP comment
Date: Tue, 24 Mar 2015 15:18:13 +0000
Message-ID: <55118035.2090806@brocade.com>
References: <1426800772-22378-1-git-send-email-rshearma@brocade.com>	<1426866170-28739-1-git-send-email-rshearma@brocade.com>	<1426866170-28739-3-git-send-email-rshearma@brocade.com>	<87fv8wals4.fsf@x220.int.ebiederm.org> <550FF9C9.2000308@brocade.com> <87h9tb37g6.fsf@x220.int.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-000f0801.pphosted.com ([67.231.144.122]:63478 "EHLO
	mx0a-000f0801.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752936AbbCXPST (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Mar 2015 11:18:19 -0400
In-Reply-To: <87h9tb37g6.fsf@x220.int.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 23/03/15 18:16, Eric W. Biederman wrote:
> Robert Shearman <rshearma@brocade.com> writes:
>
>> On 22/03/15 19:12, Eric W. Biederman wrote:
>>> Robert Shearman <rshearma@brocade.com> writes:
>>>
>>>> Popping the last label on the stack does not necessarily imply
>>>> performing penultimate hop popping. There is no reason why this
>>>> couldn't be the last hop in the network, so remove the comment.
>>>
>>> So this change I will disagree with.
>>>
>>> What the code implements is Penultimate hop popping.  Even if you send
>>> the packets over loopback that is what the code is doing.
>>
>> No, RFC3031 s3.16 (https://tools.ietf.org/html/rfc3031#page-18) talks in terms
>> of LSRs (label switch routers), not passes through the forwarding
>> code.
>
> In very simple terms the code always removes the labels and forwards the
> code.  That is by definition penultimate hop popping.  That is all that
> is implmeneted in the code today.  And that is what the comment is
> noting.
>

I think we might be talking at cross purposes here so I'd like to back 
up a little bit and make sure that we are using the same terminology and 
are talking about the same problem.

In terms of terminology this is what I mean -

PHP means popping the label in the penultimate hop router in the 
*signalled* LSP. Note: There may be more hops beyond this LSP - either 
MPLS using an inner label or payload - such as IP.

UHP means popping the label in the ultimate hop router in the signalled 
LSP. Again there may be further hops that are outside of the LSP.

Orthogonal to this is the relation of the FEC to the UH router.

a) All traffic for this FEC needs to be sent to another router (which is 
beyond this LSP).
b) The FEC requires the UH router to do a payload lookup in order to 
identify where the payload should go. This can be a label lookup on the 
next label in (e.g. where the outer label is a TE tunnel over which 
further LSPs have been setup). Or it can be a payload protocol lookup 
e.g. IP. There are a couple of sub-cases here - the common case is where 
the FEC is for a prefix that is directly connected to the UH - in which 
case the lookup we need is conceptually a neighbour lookup. Another case 
is where the FEC corresponds to a summary prefix that this router has 
advertised to its peer - in which case the lookup is a routing table lookup.
c) The FEC is destined for the UH router and needs to be "received" by 
it. Typically this case can be handled in exactly the same way as B 
above but mention it here for completeness.

Does this terminology work for you?

If it does then I hope you will also agree that PHP is really aimed at 
decreasing the work for the UH router in the cases where the FEC 
corresponds to B above. (And it also allows C to be handled using 
existing e.g. IP path mechanisms). If we want to do UHP then we'd 
require the UH router to first lookup the outer label (which would be 
exp-null) and then an additional protocol lookup.

But there are a couple of cases where you either can't or may not want 
to do PHP.

Firstly with an application like MPLS VPN the UH router is the PE and it 
needs the label in order to identify which routing table to do the (IP) 
payload lookup in.

Secondly, in case A, PHP doesn't offer any benefit. The PH is already 
able to use the incoming label to determine how to forward without 
needing a further lookup. It's a choice, but there are certainly stacks 
out there that will choose to advertise a real label for the FEC so that 
we do UHP here. (I'd actually expect that to be the norm).

Does this description of behaviours work for you?

If we are still together at this point then my last question is why you 
say that "remov[ing] a label and forward[ing] the [packet]" is "by 
definition penultimate-hop popping"?

I'm actually more interested in getting aligned on this than the comment 
itself. I also have some comments on what you say below about local 
delivery but I suspect it will all make more sense once we sort this out.

Thanks,
Rob

>>> This is relevant because I think the code may actually be wrong in the
>>> local reception case.  By preforming penultimate hop popping and
>>> receving the code on loopback I think this code allows bypassing
>>> iptables rules that apply to incoming ip packets.  Certainly there is a
>>> loss of information as to which hardware interface the packet came in on
>>> that it may be desirable to correct.
>>
>> Indeed, but network operators may well want to apply different rules to traffic
>> coming in as IP versus traffic coming in as MPLS.
>>
>> This may well merit a comment of its own, but this isn't directly relevant to
>> the comment I'm removing.
>
> My point is and what is directly relevant is the case of local delivery
> is a hack.  A hack that a pretty strong case can be made that it does
> the wrong thing and something we probably should fix before the code
> makes it to Linus for 4.1 so the bug does not get cast in stone.
>
> In other words the disparity between the comment and the code indicates
> an actual bug, not just a wrong comment.
>
> Eric
>
>>>> Cc: "Eric W. Biederman" <ebiederm@xmission.com>
>>>> Signed-off-by: Robert Shearman <rshearma@brocade.com>
>>>> ---
>>>>    net/mpls/af_mpls.c | 1 -
>>>>    1 file changed, 1 deletion(-)
>>>>
>>>> diff --git a/net/mpls/af_mpls.c b/net/mpls/af_mpls.c
>>>> index 0d6763a..bf3459a 100644
>>>> --- a/net/mpls/af_mpls.c
>>>> +++ b/net/mpls/af_mpls.c
>>>> @@ -199,7 +199,6 @@ static int mpls_forward(struct sk_buff *skb, struct net_device *dev,
>>>>    	skb->protocol = htons(ETH_P_MPLS_UC);
>>>>
>>>>    	if (unlikely(!new_header_size && dec.bos)) {
>>>> -		/* Penultimate hop popping */
>>>>    		if (!mpls_egress(rt, skb, dec))
>>>>    			goto drop;
>>>>    	} else {
