From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH] macvlan: Support creating macvlans from macvlans
Date: Fri, 06 Mar 2009 06:17:17 -0800
Message-ID: <m1sklqohw2.fsf@fess.ebiederm.org>
References: <m1ocwfsgw7.fsf@fess.ebiederm.org> <49B12B20.7000602@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out02.mta.xmission.com ([166.70.13.232]:47990 "EHLO
	out02.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751897AbZCFORW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Mar 2009 09:17:22 -0500
In-Reply-To: <49B12B20.7000602@trash.net> (Patrick McHardy's message of "Fri\, 06 Mar 2009 14\:54\:40 +0100")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Patrick McHardy <kaber@trash.net> writes:

> Eric W. Biederman wrote:
>> When running in a network namespace whose only link to
>> the outside world is a macvlan device, not being
>> able to create another macvlan is a real pain.
>>
>> So modify macvlan creation to allow automatically forward
>> a creation of a macvlan on a macvlan to become a creation
>> of a macvlan on the underlying network device.
>
> I'm not sure I understand the constallation, what is the underlying
> device in this case? A device outside the namespace?

Yes.

Typical usage would be:

eth0 in the initial namespace.
A macvlan off of eth0 in each child namespace.

Which works fine until I do things like create a network namespace
when I am already inside of a network namespace.  A child of a child.
In which case I have to start rigging up something like a pair of
veths an bridging or routing to get outside connectivity.

Or roughly:
ip link add mv0 link eth0 type macvlan.
ip link add mv1 link eth0 type macvlan.
ip link set mv0 netns 1234
ip link set mv1 netns 6789

Then later I would find it very handy to do:
echo $$ -> 1234
ip link add mv3 link mv0 type macvlan
ip link set mv3 netns 101112

The fact that we only bridge traffic on the ingress from the external
world is also a pain, but that isn't trivial to fix, and fixing
it might possibly break valid macvlan users.

Eric
