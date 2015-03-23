From: Robert Shearman <rshearma@brocade.com>
Subject: Re: [PATCH net-next v2 3/5] mpls: Differentiate implicit-null and
 unlabeled neighbours
Date: Mon, 23 Mar 2015 11:47:45 +0000
Message-ID: <550FFD61.8050708@brocade.com>
References: <1426800772-22378-1-git-send-email-rshearma@brocade.com>	<1426866170-28739-1-git-send-email-rshearma@brocade.com>	<1426866170-28739-4-git-send-email-rshearma@brocade.com>	<87fv8w95ir.fsf@x220.int.ebiederm.org> <87h9tc4u9y.fsf@x220.int.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-000f0801.pphosted.com ([67.231.152.113]:34394 "EHLO
	mx0b-000f0801.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752218AbbCWLru (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Mar 2015 07:47:50 -0400
In-Reply-To: <87h9tc4u9y.fsf@x220.int.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 22/03/15 21:06, Eric W. Biederman wrote:
> ebiederm@xmission.com (Eric W. Biederman) writes:
>
>> Robert Shearman <rshearma@brocade.com> writes:
>>
>>> The control plane can advertise labels for neighbours that don't have
>>> an outgoing label. RFC 3032 s3.22 states that either the remaining
>>> labels should be popped (if the control plane can determine that it's
>>> safe to do so, which in light of MPLS-VPN, RFC 4364, is never the case
>>> now) or that the packet should be discarded.
>>
>> I can not figure out what you are referring to.  There is no section 3.2
>> in RFC3022.
>
> I have found it.  That is is RFC3021 Section 3.22.  This is something
> the code already does.  If the label can not be looked up with
> mpls_route_input_rcu the packet is dropped.

No, the existing code handles the lack of an incoming label. s3.22 is 
stating what should be done with the lack of an outgoing label.

> Beyond that I believe the rest of my comments still stand.  If you want
> to do this explicitly some form of explicit blackhole route needs to be
> supported.  Either just allowing a route to be configured with no output
> device or an explicit RTN_BLACKHOLE route.

No, that isn't going to address the problem this patch solves.

>
>>> Therefore, if the peer is unlabeled and the last label wasn't popped
>>> then drop the packet. The peer being unlabeled is signalled by an
>>> empty label stack. However, implicit-null still needs to be supported
>>> (i.e. penultimate hop popping) where the incoming label is popped and
>>> no labels are put on and the packet can still go out labeled with the
>>> unpopped part of the stack. This is achieved by the control plane
>>> specifying a label stack consisting of the single special
>>> implicit-null value.
>>
>> As I understand it you want to handle the case for a label for which
>> there is no next hop, and the packet should be black-holed.
>>
>> In struct mpls_route such routes are currently represented by routes
>> that have no network device.  And in rtnetlink should be represented
>> with routes of type RTN_BLACKHOLE which I do not currently support
>> parsing.  But that should be simple enough to correc.t
>>
>> With respect to Implicit NULL it should be an error to accept a route
>> that has an RTA_NEWDST that includes an implicit NULL.
>>
>> The rtnetlink is not ldp nor should it have ldp semantics and be made
>> complicated by those semantics.

This isn't specific to LDP - it is used by MP-BGP as well, or indeed 
would be perfectly valid to be specified in static configuration. As per 
RFC3031 s4.1.5 (https://tools.ietf.org/html/rfc3031#section-4.1.5) this 
signals that penultimate hop popping should be done, as opposed to 
dropping the packet if it would go out as MPLS (s3.22).

Thanks,
Rob

>> The semantics of RTA_NEWDST are the labels to push on after the top most
>> label has been popped off.  I see no reason to include other mechanisms
>> into that processing when it is easy enough to add or tweak other
>> attributes to have those semantics.
>>
>> Certainly it is not something that I think is worth special casing on
>> the fast path in mpls_forward.
