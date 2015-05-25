From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: Re: [PATCH net-next v2 0/7] netns: ease netlink use with a lot of
 netns
Date: Mon, 25 May 2015 09:45:25 +0200
Message-ID: <5562D315.9070405@6wind.com>
References: <1430906288-5108-1-git-send-email-nicolas.dichtel@6wind.com>	<1430989373-4515-1-git-send-email-nicolas.dichtel@6wind.com> <874mnn9t12.fsf@x220.int.ebiederm.org> <555F969B.3090706@ahsoftware.de>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "Eric W. Biederman" <ebiederm@xmission.com>,
	netdev@vger.kernel.org, tgraf@suug.ch, davem@davemloft.net
To: Alexander Holler <holler@ahsoftware.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f48.google.com ([74.125.82.48]:35349 "EHLO
	mail-wg0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750856AbbEYHp3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 May 2015 03:45:29 -0400
Received: by wgfl8 with SMTP id l8so66247925wgf.2
        for <netdev@vger.kernel.org>; Mon, 25 May 2015 00:45:27 -0700 (PDT)
In-Reply-To: <555F969B.3090706@ahsoftware.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 22/05/2015 22:50, Alexander Holler a =C3=A9crit :
> Am 08.05.2015 um 14:02 schrieb Eric W. Biederman:
>>
>> So I am dense.  I have read through the patches and I don't see wher=
e
>> you tag packets from other network namespaces with a network namespa=
ce
>> id.
>
> Me too,
>
> I've recently written a little tool called snetmanmon (source is
> available at github) to monitor and handle network related events
> by using rtnetlink.
>
> Having seen this patch series (thanks!), I've played with it.
>
> I've applied the patch series to v4.1-rc4.
>
> Maybe I'm using or holding it wrong, but I've some comments.
>
> First I think if NETLINK_LISTEN_ALL_NSID is enabled, a dump
> of the interfaces through RTM_GETLINK together with NLM_F_DUMP and
> NLM_F_REQUEST should return all interfaces of all reachable namespace=
s.
This option is only for 'listening', ie spontaneous notifications from =
the
kernel. It does nothing for request.

>
> Next, if NETLINK_LISTEN_ALL_NSID is enabled, I receive RTM_NEWLINK
> but without any indication of the namespace. E.g. if I do
>      ip netns add netns1
>      ip netns exec netns1 brctl addbr br0
> the RTM_NEWLINK for br0 (received in the root ns, not netns1) doesn't
> have the attribute IFLA_LINK_NETNSID.
nsid is sent through control message (see rcvmsg).
Try iproute2 branch net-next: 'ip monitor all-nsid'. It's an
example of how to use it.

>
> Same for the RTM_DELLINK msg if I call
>      ip netns exec netns1 brctl delbr br0
> afterwards. So both netlink messages are looking like br0 was
> created in the root ns.
>
> Another problem seems to be with veth devices. E.g. if I do
>      ip link add veth0 type veth peer name veth1
>      ip link set veth1 netns netns1
> I receive
>      RTM_NEWLINK for veth0 (no nsid)
>      RTM_NEWLINK for veth1 (no nsid)
>      RTM_DELLINK for veth1 (no nsid)
>      RTM_NEWLINK for veth1 (with nsid 0)
> That looks ok, except the missing RTM_NEWLINK for lo in netns1, which
The nsid for netns1 in the current netns is allocated when the veth1 is=
 moved to
netns1. At this time, lo is created since a long time, thus the kernel =
won't
send any notification.
Note, you can manually allocate it with 'ip netns set netns1 -1', but y=
ou
won't get any notifications for the loopback.

> was created together with the namespace. But if I now request a dump,
> I get
>      RTM_NEWLINK for veth0 (with nsid 0)
> which looks like veth0 is part of nsid 0, and I get nothing for veth1=
=2E
The netlink message gives informations about veth1. With iproute2:
$ ip netns
netns1 (id: 0)
$ ip -d l ls veth0
9: veth0@if8: <BROADCAST,MULTICAST> mtu 1500 qdisc noop state DOWN mode=
 DEFAULT=20
group default qlen 1000
     link/ether 72:36:c0:f4:35:64 brd ff:ff:ff:ff:ff:ff link-netnsid 0=20
promiscuity 0
     veth addrgenmode eui64

Peer veth is the interface with ifindex 8 (@if8) in netns1 (link-netnsi=
d 0).
To get informations about this interface, you need to dump it in netns1=
=2E

> Of course, that vlan device might be part of nsid 0 too (as veth1),
> but its part named veth0 is not part of that namespace. So the
> IFLA_LINK_NETNSID attribute received with the RTM_NEWLINK for veth0 t=
hrough
> the dump is misleading.
Not sure to follow you. veth0 sits in the current netns (let's say init=
_net)
and veth1 in netns1.
So, when you dump veth0 in init_net, its link-netnsid is set to the id =
of
netns1 in init_net. And when you dump veth1 in netns1, it's link-netnsi=
d is set
to the id of init_net in netns1.

>
> So it looks like either I missed something, I'm doing something wrong=
,
> or there still is some work todo to make NETLINK_LISTEN_ALL_NSID work
> like expected (or like my simple mind would expect it).
Having a patch that allows to perform request from a netns foo for a ne=
tns bar
is something doable, but much more complicated. And I think it requires=
 more
thought. Let's see what will happen ;-)

>
> Thanks again for the patches, regards,
Thank you,


Regards,
Nicolas
