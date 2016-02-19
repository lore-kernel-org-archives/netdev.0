From: Jesse Gross <jesse@kernel.org>
Subject: Re: [PATCH/RFC] openvswitch: loosen restriction of output of MPLS to
 tunnel vports
Date: Fri, 19 Feb 2016 07:45:33 -0800
Message-ID: <CAEh+42j2iuvrVZwMCPVYcqQZS7PVrn=t4ms-iX83FquwxNypSg@mail.gmail.com>
References: <1455305133-23285-1-git-send-email-simon.horman@netronome.com>
 <CAEh+42g5GXduCgr0WCyAKvSO6LeATFuZoWU2aR0sfNDbJqG=6Q@mail.gmail.com> <20160219075940.GB6589@vergenet.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
	ovs dev <dev@openvswitch.org>,
	Pravin Shelar <pshelar@nicira.com>
To: Simon Horman <simon.horman@netronome.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.kernel.org ([198.145.29.136]:60649 "EHLO mail.kernel.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1422908AbcBSPpu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 19 Feb 2016 10:45:50 -0500
Received: from mail.kernel.org (localhost [127.0.0.1])
	by mail.kernel.org (Postfix) with ESMTP id 8FC9320459
	for <netdev@vger.kernel.org>; Fri, 19 Feb 2016 15:45:49 +0000 (UTC)
Received: from mail-qg0-f47.google.com (mail-qg0-f47.google.com [209.85.192.47])
	(using TLSv1.2 with cipher AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 64F6A203C4
	for <netdev@vger.kernel.org>; Fri, 19 Feb 2016 15:45:48 +0000 (UTC)
Received: by mail-qg0-f47.google.com with SMTP id b67so64182364qgb.1
        for <netdev@vger.kernel.org>; Fri, 19 Feb 2016 07:45:48 -0800 (PST)
In-Reply-To: <20160219075940.GB6589@vergenet.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Feb 18, 2016 at 11:59 PM, Simon Horman
<simon.horman@netronome.com> wrote:
> On Tue, Feb 16, 2016 at 02:53:39PM -0800, Jesse Gross wrote:
>> On Fri, Feb 12, 2016 at 11:25 AM, Simon Horman
>> <simon.horman@netronome.com> wrote:
>> > If an skb was not MPLS initially then it may be GSO and in that case if it
>> > became MPLS then GSO can't be performed because both MPLS and tunnels make
>> > use of the inner_protocol field of struct skbuff in order to allow GSO to
>> > be performed in the inner packet.
>> >
>> > On the other hand if an skb was MPLS initially then it will not be GSO,
>> > as there is no support for GRO for MPLS. Thus in this case it is safe
>> > to allow output of MPLS on tunnel vports.
>> >
>> > Signed-off-by: Simon Horman <simon.horman@netronome.com>
>>
>> I don't think that any tunnel implementations expose support for MPLS
>> offloads as part of their features. In that case, if we have an MPLS
>> GSO packet (regardless of how it came to be), I think it will be
>> broken apart in software before encapsulation. At that point, it
>> should be safe for the tunnel to overwrite any fields MPLS was
>> previously using for offloading. As a result, I believe we can allow
>> all combinations of MPLS with tunnels. (Note that historically this
>> wasn't true, the change is a result of lightweight tunnels.)
>
> Hi Jesse,
>
> wow, that does sound very promising.
> I would certainly be in favour of allowing MPLS with tunnels.
>
> I am wondering if you could point me in the general direction of the changes
> you mention above.

I actually don't think that any changes are really needed to make this
work. All we should have to do is remove the checks similar to the one
you are modifying here in flow_netlink.c and the the runtime one in
actions.c.

It's probably good to look through the overall code path to double
check but as long as tunnel devices don't enable support for MPLS
offloading by the time that encapsulation happens MPLS should really
just look like any other packet received off the wire.
