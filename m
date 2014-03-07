From: Pravin Shelar <pshelar@nicira.com>
Subject: Re: [PATCH] openvswitch: Orphan frags before sending to userspace via
 Netlink to avoid guest stall
Date: Thu, 6 Mar 2014 20:46:15 -0800
Message-ID: <CALnjE+rWc=n_F+1jSLQtPrgKSvvxONEkkYxWEHon2_KVNG9z3Q@mail.gmail.com>
References: <1393615016-9187-1-git-send-email-zoltan.kiss@citrix.com>
	<5318ABC0.4040307@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Jesse Gross <jesse@nicira.com>, Thomas Graf <tgraf@redhat.com>,
	"dev@openvswitch.org" <dev@openvswitch.org>,
	xen-devel@lists.xenproject.org, netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>, kvm@vger.kernel.org
To: Zoltan Kiss <zoltan.kiss@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog117.obsmtp.com ([74.125.149.242]:43495 "HELO
	na3sys009aog117.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1751013AbaCGEqQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Mar 2014 23:46:16 -0500
Received: by mail-ve0-f180.google.com with SMTP id jz11so3582245veb.25
        for <netdev@vger.kernel.org>; Thu, 06 Mar 2014 20:46:15 -0800 (PST)
In-Reply-To: <5318ABC0.4040307@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Mar 6, 2014 at 9:09 AM, Zoltan Kiss <zoltan.kiss@citrix.com> wrote:
> Do you have any feedback on this? I'm also adding KVM list as they might be
> interested in this.
>
> Zoli
>
>
> On 28/02/14 19:16, Zoltan Kiss wrote:
>>
>> The kernel datapath now switched to zerocopy Netlink messages, but that
>> also
>> means that the pages on frags array are sent straight to userspace. If
>> those
>> pages came outside the kernel, we have to swap them out with local copies.
>>
>> Signed-off-by: Zoltan Kiss <zoltan.kiss@citrix.com>

I do not think this is required, netlink zero copy only maps
pre-allocated buffers to user-space.

But I found bug in datapath user-space queue code. I am not sure how
this can work with skb fragments and MMAP-netlink socket.
Here is what happens, OVS allocates netlink skb and adds fragments to
skb using skb_zero_copy(), then calls genlmsg_unicast().
But if netlink sock is mmped then netlink-send queues netlink
allocated skb->head (linear data of skb) and ignore skb frags.

Currently this is not problem with OVS vswitchd since it does not use
netlink MMAP sockets. But if vswitchd stats using MMAP-netlink socket,
it can break it.
