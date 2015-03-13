From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH net-next] mpls: Infer payload of packet from via address family.
Date: Fri, 13 Mar 2015 12:08:39 -0500
Message-ID: <87sid8u8o8.fsf@x220.int.ebiederm.org>
References: <1426078702-23246-1-git-send-email-rshearma@brocade.com>
	<87sidba1ea.fsf@x220.int.ebiederm.org> <5500BB5E.4070909@brocade.com>
	<87385a13jz.fsf@x220.int.ebiederm.org> <5502F96B.6030407@brocade.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: "davem\@davemloft.net" <davem@davemloft.net>,
	"netdev\@vger.kernel.org" <netdev@vger.kernel.org>
To: Robert Shearman <rshearma@brocade.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out01.mta.xmission.com ([166.70.13.231]:35722 "EHLO
	out01.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753338AbbCMRMW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Mar 2015 13:12:22 -0400
In-Reply-To: <5502F96B.6030407@brocade.com> (Robert Shearman's message of
	"Fri, 13 Mar 2015 14:51:23 +0000")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Robert Shearman <rshearma@brocade.com> writes:

> On 12/03/15 18:19, Eric W. Biederman wrote:
>> Robert Shearman <rshearma@brocade.com> writes:

> Agreed. How about adding a netlink attribute indicating the FEC, or at
> least the address family in the case of IP FECs? That would then give
> a an indicator of the traffic that the LSP is carrying, regardless of
> nexthop type. The same method could then be used to indicate whether
> the label route is for a PW and then the presence or lack or control
> word.

Not a problem. I fully expect we will do that at some point.
My current code is just a starting point, and additions like that can be
made incrementally and easily.

I fully expect David Miller will merge any same well thought out patch
with a good description.

To be clear.  I was not proposing forcing MPLS to be something it is not
where there is a type in each packet identifying the data.  All I meant
was that in the common cases it can be inferred what the packet type is
I don't mind taking advantage of it as it makes the code simpler to
write and easier to use.

> I'm fine with keeping that an option with the above suggestion of the
> netlink attribute, for users that want to take that gamble. However,
> I'd also like the option of a control plane that wants to only use a
> label for one traffic type at a time can specify this to guard against
> bugs and allow better observability of the MPLS label table to the
> operator.

No objections from me.  I just picked a default that was easy and
useful.  Knobs to tighten things down assuming they don't make the fast
path complicated and slow are fine by me.

>> What I don't currently have in mpls_route is a distinction between
>> popping a label and popping a final label.  If we want to draw such a
>> distinction now would be a good time to have that conversation.
>
> Yes, that would be highly desirable in the case of MPLS-VPN where a
> label route is added via CE. In order to prevent unexpected MPLS
> traffic being sent to the CE (perhaps MPLS-OAM), the control plane
> would want to ask the dataplane to install an "unlabeled" entry where
> packets with the BOS bit not set should be dropped.
>
> I'd like to propose that we change the semantics of no labels being
> specified to be: pop and forward if BOS bit set, drop if BOS not
> set. Then we can allow the control plane to specify a label value with
> the reserved implicit-null value which wouldn't be put into a packet,
> but translated into pop and forward regardless of BOS bit (i.e. IP if
> BOS set, MPLS if BOS not set).

I am not certain about having two different ways to say pop a label,
that seems to create unnecessary complications.

This raises an interesting question.  Are there cases where we need to
support variable depth label stacks.  So that sometimes a label is
popped and the packet is then forwarded over mpls, and that sometimes a
label is popped the BOS bit is set and we treat the packet as a local IP
packet?

I think the answer is we don't need to support that case.  It seems an
even stranger case than having both IPv4 and IPv6 in the same label
stack.

So I think it may be sufficient to simply specify what is in an mpls
tunnel under the label that we are popping.   If we specify more MPLS
it is just a label pop and BOS of stack must not be set (or drop).  If
we specify IPv4, the BOS must be set or drop.

I am not particularly motivated to go after that aspect right now so I
will let you cook up a patch.

Eric
