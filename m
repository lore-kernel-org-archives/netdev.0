From: Cong Wang <cwang@twopensource.com>
Subject: Re: [PATCH net-next v2 0/7] netns: ease netlink use with a lot of netns
Date: Fri, 22 May 2015 14:04:29 -0700
Message-ID: <CAHA+R7NCjKn86R+OLX+4bkB0kv3WcXGB5NPui+v_X=CKqQtPLA@mail.gmail.com>
References: <1430906288-5108-1-git-send-email-nicolas.dichtel@6wind.com>
	<1430989373-4515-1-git-send-email-nicolas.dichtel@6wind.com>
	<874mnn9t12.fsf@x220.int.ebiederm.org>
	<555F969B.3090706@ahsoftware.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Nicolas Dichtel <nicolas.dichtel@6wind.com>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	netdev <netdev@vger.kernel.org>, Thomas Graf <tgraf@suug.ch>,
	David Miller <davem@davemloft.net>
To: Alexander Holler <holler@ahsoftware.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f50.google.com ([74.125.82.50]:32956 "EHLO
	mail-wg0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757693AbbEVVEa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 May 2015 17:04:30 -0400
Received: by wgez8 with SMTP id z8so28337093wge.0
        for <netdev@vger.kernel.org>; Fri, 22 May 2015 14:04:29 -0700 (PDT)
In-Reply-To: <555F969B.3090706@ahsoftware.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, May 22, 2015 at 1:50 PM, Alexander Holler <holler@ahsoftware.de> wrote:
> Am 08.05.2015 um 14:02 schrieb Eric W. Biederman:
>>
>>
>> So I am dense.  I have read through the patches and I don't see where
>> you tag packets from other network namespaces with a network namespace
>> id.
>
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
> NLM_F_REQUEST should return all interfaces of all reachable namespaces.
>
> Next, if NETLINK_LISTEN_ALL_NSID is enabled, I receive RTM_NEWLINK
> but without any indication of the namespace. E.g. if I do
>         ip netns add netns1
>         ip netns exec netns1 brctl addbr br0
> the RTM_NEWLINK for br0 (received in the root ns, not netns1) doesn't
> have the attribute IFLA_LINK_NETNSID.


Bridge doesn't have an underlying link, so no LINK_NETNSID. LINK_NETNSID
is only added when its underlying link is in a different netns.


>
> Same for the RTM_DELLINK msg if I call
>         ip netns exec netns1 brctl delbr br0
> afterwards. So both netlink messages are looking like br0 was
> created in the root ns.
>
> Another problem seems to be with veth devices. E.g. if I do
>         ip link add veth0 type veth peer name veth1
>         ip link set veth1 netns netns1
> I receive
>         RTM_NEWLINK for veth0 (no nsid)
>         RTM_NEWLINK for veth1 (no nsid)
>         RTM_DELLINK for veth1 (no nsid)
>         RTM_NEWLINK for veth1 (with nsid 0)
> That looks ok, except the missing RTM_NEWLINK for lo in netns1, which
> was created together with the namespace. But if I now request a dump,
> I get
>         RTM_NEWLINK for veth0 (with nsid 0)
> which looks like veth0 is part of nsid 0, and I get nothing for veth1.
> Of course, that vlan device might be part of nsid 0 too (as veth1),
> but its part named veth0 is not part of that namespace. So the
> IFLA_LINK_NETNSID attribute received with the RTM_NEWLINK for veth0 through
> the dump is misleading.

That is because the code tries to do "lazy" allocation for netnsid,
it defers it util the dumping, veth case is special here given how they pair,
I noticed the same "problem" (it doesn't have to be a bug) when I reviewed
the code, nobody cared. ;-/
