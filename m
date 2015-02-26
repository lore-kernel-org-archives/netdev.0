From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: What are the intended semantics of IFLA_LINK_NETNSID?
Date: Thu, 26 Feb 2015 07:48:26 -0600
Message-ID: <87wq34okb9.fsf@x220.int.ebiederm.org>
References: <CAOYZPENnpPP-N-ST3xYE7vcCFhbNd-FMKj9OvBebYSMu42OdaQ@mail.gmail.com>
	<54EDF7BB.2060809@6wind.com> <871tldstju.fsf_-_@x220.int.ebiederm.org>
	<54EEDF9C.20302@6wind.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Eugene Yakubovich <eugene.yakubovich@coreos.com>,
	netdev@vger.kernel.org
To: nicolas.dichtel@6wind.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from out02.mta.xmission.com ([166.70.13.232]:45176 "EHLO
	out02.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752193AbbBZNvz convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Feb 2015 08:51:55 -0500
In-Reply-To: <54EEDF9C.20302@6wind.com> (Nicolas Dichtel's message of "Thu, 26
	Feb 2015 09:55:56 +0100")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Nicolas Dichtel <nicolas.dichtel@6wind.com> writes:

> Le 25/02/2015 20:03, Eric W. Biederman a =C3=A9crit :
>>
>> Reading through the code of rtnl_newlink I am perplexed with what yo=
ur
>> intended semantics of IFLA_LINK_NETNSID are supposed to be.
>>
>> My expectation was something with the same semantics IFLA_NET_NS_PID=
 and
>> IFLA_NET_NS_FD just a different data representation and something th=
at
>> could be used in more netlink messages, so you could report the netw=
ork
>> namespace where the other end of a tunnel or the the network namespa=
ce
>> of an underlying device is.
>>
>> Being very slow I would expect that ILFA_LINK_NETNSID would replace
>> dest_net or possibly net in rtnl_newlink but it does not replace eit=
her
>> of those completely.  Which causes me to think that the implementati=
on
>> of IFLA_LINK_NETNSID in rtnl_newlink is broken.
>>
>> I suspect the correct fix for rtnl_newlink is to just use
>> IFLA_LINK_NETNSID in rtnl_link_get_net and have it be an alternative=
 way
>> of setting dest_net.  But you may intend some different semantics th=
at
>> I don't understand.
> ILFA_LINK_NETNSID is used to point to the i/o netns of the interface,=
 ie the
> opposite netns of dest_net.

=46air enough.  That makes sense given how it is used in the reporting.
With those semantics the code may arguably be correct.

> The interface is first created in link_net and moved at the end in de=
st_net.
>
> IP tunnels interfaces (ipip, sit, ip6_tunnels, gre[v6]) does not use =
src_net,

I am pretty certain that is simply something that was overlooked when
cross network namespace support was added to those network device types=
=2E
Right now I would be surprised if anything in userspace cares, so we ca=
n
probably just change those device types to look at src_net from newlink=
=2E

Certainly for our sanity in maintaining rtnl_newlink finding a way to
make that change would be preferable.  Even if we ultimately have to ad=
d
a flag that says only make src_net different from dev->net when
IFLA_LINK_NETNSID is passed.

As making that change allows much more consistency in the code and
allows us to get rid of an unnecessary dev_change_net_namespace.

> thus when you create an ipip interface by specifying an attribute
> IFLA_NET_NS_PID it will result to an interface which is not across tw=
o netns but
> only in the netns pointed by IFLA_NET_NS_PID. If you use IFLA_LINK_NE=
TNSID, it
> allows you to create this kind of x-netns interfaces.
> In fact, the goal of this attribute is to replace the two following c=
ommand by
> only one:
> ip link add foo ...
> ip link set foo netns bar
> =3D> ip link add foo link-netnsid barID

Eric
