From: Patrick McHardy <kaber@trash.net>
Subject: Re: [net-next-2.6 PATCH v3 4/5] rtnetlink: Add VF config code to
 rtnetlink
Date: Thu, 11 Feb 2010 07:07:55 +0100
Message-ID: <4B739EBB.3040004@trash.net>
References: <20100210114303.14483.71368.stgit@localhost.localdomain> <20100210114403.14483.11004.stgit@localhost.localdomain> <4B72A061.40905@trash.net> <EA929A9653AAE14F841771FB1DE5A1365FE3CBE343@rrsmsx501.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: "Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"gospo@redhat.com" <gospo@redhat.com>
To: "Williams, Mitch A" <mitch.a.williams@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:34180 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750897Ab0BKGIJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Feb 2010 01:08:09 -0500
In-Reply-To: <EA929A9653AAE14F841771FB1DE5A1365FE3CBE343@rrsmsx501.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Williams, Mitch A wrote:
>> From: Patrick McHardy [mailto:kaber@trash.net]
> [snip]
>> We usually encapsulate lists of the same attribute type in another
>> top-level attribute. Check out the IFLA_VLAN_*_QOS attributes for
>> an example.
>>
>> The interface should also be symetrical, IOW you should dump the
>> same attributes used in the userspace->kernel direction instead
>> of a combined "info" attribute.
> 
> Sheesh, Patrick, where were you three months ago when I first
> posted this stuff? It would have helped a lot if I heard from
> you back then. We've had at least five internal review cycles
> here and nobody caught this, mostly because nobody understands
> it.

Well .. sorry :)

> That being said, I'll take another look at the NLA_NESTED stuff
> and see what I can figure out. Do you know of any place (outside
> of the code) where this is documented?  It's particularly
> difficult to follow this code.

No, but its quite simple. For dumping attributes, you create
a top-level nested attribute, then add all inner attributes
and "end" the top-level attribute, which fills in the entire
length. In terms of the kernel netlink helpers:

	nest = nla_nest_start(skb, IFLA_VF);
	if (nest == NULL)
		goto nla_put_failure;

	for (...) {
		<get info>
		NLA_PUT(skb, IFLA_VF_INFO, &info);
	}

	nla_nest_end(skb, nest);

For parsing withing the kernel, you use nla_for_each_nested()
to iterate over the encapsulated attributes and (unless the
inner attributes are nested themselves) nla_data() to get
at the payload:

	nla_for_each_nested(attr, nla[IFLA_VF_INFO], rem) {
		if (nla_type(attr) != MY_TYPE)
			goto err_inval;
		info = nla_data(attr);
		<do something with info>
	}

You can also put nested attributes into the list, in that case
you'd use nla_parse_nested(attr, ...) instead of nla_data().

> I see your point about symmetrical interfaces, but I'm not sure
> it's the best thing here. We want the user to be able to set these
> attributes independently, without blowing away any other settings.
> If we put all three settings together into one data structure,
> the code flow will end up being much more complicated.

Using a symetrical interface doesn't necessarily prevent incremental
configuration. Please see below.

> I'd prefer to leave the data structures as they are, and switch
> to using nested attributes for the status reporting part, i.e.
> what happens when you type 'ip link show'. Would this work for you?

The way rtnetlink is currently built the only difference between
configuration requests from userspace and notifications from the
kernel is the NLM_F_REQUEST bit. This is a useful property because
you can re-create objects in the kernel simply be replaying a
notification as request. Its also necessary to be able to use
the same parsing functions for notifications and error messages
in userspace (error messages have the original request appended).

What should be relatively easy to do is to use lists of (combined
or non-combined) attributes in both directions. In the userspace->
kernel direction all you need to change is to encapsulate your
new attributes and walk through the list. In the kernel->userspace
direction you can use the combined struct within the kernel if
thats more useful and translate it into individual attributes when
filling the netlink message.
