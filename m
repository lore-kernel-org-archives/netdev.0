From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [RFC RTNETLINK 00/09]: Netlink link creation API
Date: Wed, 06 Jun 2007 09:25:38 -0600
Message-ID: <m1d509umtp.fsf@ebiederm.dsl.xmission.com>
References: <20070605141250.15650.47178.sendpatchset@localhost.localdomain>
	<m1tztlvrsp.fsf@ebiederm.dsl.xmission.com>
	<46669FA0.3030405@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, socketcan@hartkopp.net, hadi@cyberus.ca,
	xemul@sw.ru, tgraf@suug.ch
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ebiederm.dsl.xmission.com ([166.70.28.69]:50120 "EHLO
	ebiederm.dsl.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755151AbXFFP1u (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Jun 2007 11:27:50 -0400
In-Reply-To: <46669FA0.3030405@trash.net> (Patrick McHardy's message of "Wed,
	06 Jun 2007 13:50:56 +0200")
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Patrick McHardy <kaber@trash.net> writes:

> Eric W. Biederman wrote:
>> Reading through the patches they look usable to me.
>> 
>> Having to patch iproute to create the more interesting network
>> devices sucks, but that problem seems fundamental.  We might
>> be able to avoid it if we allowed fields to be reused between
>> different types of devices but that makes the error checking
>> trickier, and we aren't likely to have that many types of
>> devices so there likely isn't much value in generalizing.
>
>
> You don't really need to patch it, installing a new iplink_XXX.so
> file is enough. Generalizing driver specific options more than
> what we currently have doesn't look very promising. I think your
> driver was simple enough to get along with the generic device
> attributes though (IFLA_LINK or IFLA_MASTER).

I need to know the other device in the pair of devices I am creating.
If ifindex was selectable IFLA_LINK or IFLA_MASTER might be
interesting however they are currently are not, and I'm not quite
certain about letting a user select the ifindex.  Although there may
come a point when dealing with migration when it makes sense.

Hmm.  I guess if I had a reasonable default I could find out the
pair device by looking at the returned NEW_LINK message.

Looking more close.  IFLA_MASTER does not work because I don't
have a master/slave relationship.

IFLA_LINK looks like it will work.  I don't precisely match the
semantics though which makes me nervous.  In particular my other
device is not something I am sending through but what I am sending
to.  The way the IPv6 code uses iflink to get the link local address
starting with the hardware address of the iflink would be completely
the wrong thing to do in my case.  Now my device won't have the magic
IPv6 tunnel arp type so that code won't trigger.  Still it is
a challenge.

I still think adding a IFLA_PARTNER or a custom attribute is cleaner
in this case.  Slight semantic mismatches are the worst design bugs
to correct.

To some extent this is a practical problematic point for me, because
in the context of multiple network namespaces I could theoretically
have both network devices have the same name and the same ifindex in
different network namespaces.  Although it really doesn't matter
unless they are in the same network namespace in which case they
can't have the same ifindex or ifname.

>> I do think we should specify the IFLA_KIND (was: IFLA_NAME) values in
>> a header file.  So it is easy to get a list of all of the different
>> kinds and so we don't conflict.
>
>
> I don't think conflicts are going to be a problem (it would be
> nice if modpost would warn about duplicate aliases though).
> How is listing IFLA_KIND types in a header file going to help
> get a list? Presuming the user knows what kind of device he
> wants to set up and is not just looking for things to play
> around with I also don't see any real value in this.

This isn't about the user this is about maintaining the ABI.

We have to control set of strings for IFLA_KIND.  Having them all
in a single header file means that we can easily look when we add
support for a new kind to see if some other driver has already
used that kind.

The same reason we stick the rest of the enumerations into a header
file.

Strings don't conflict as easily as small integers do, but it is still
possible to have a conflict, so having something like an ifla_kind.h to
hold them would be useful.

Eric
