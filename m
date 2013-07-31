From: Jesse Gross <jesse@nicira.com>
Subject: Re: [PATCH net-next 2/2] openvswitch: Use skb_zerocopy() to prepare
 skb for upcall
Date: Tue, 30 Jul 2013 17:02:50 -0700
Message-ID: <CAEP_g=-YTwbPQ9iH+fd=pODpaciTJakd_1D_drwfDJ0j9OsB5g@mail.gmail.com>
References: <cover.1374756042.git.tgraf@suug.ch> <9d4aaa5319c684e14721e0bed2ef22ddc409caf1.1374756042.git.tgraf@suug.ch>
 <CAEP_g=_ExeJ+pJ4KU7+=vdyFgLQtY2v6fiK0GzLKpeNF8NULbw@mail.gmail.com> <20130726101558.GA22120@casper.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	"dev@openvswitch.org" <dev@openvswitch.org>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog130.obsmtp.com ([74.125.149.143]:37950 "HELO
	na3sys009aog130.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1758334Ab3GaADK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Jul 2013 20:03:10 -0400
Received: by mail-oa0-f49.google.com with SMTP id n16so118406oag.22
        for <netdev@vger.kernel.org>; Tue, 30 Jul 2013 17:03:10 -0700 (PDT)
In-Reply-To: <20130726101558.GA22120@casper.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jul 26, 2013 at 3:15 AM, Thomas Graf <tgraf@suug.ch> wrote:
> On 07/25/13 at 06:39pm, Jesse Gross wrote:
>> On Thu, Jul 25, 2013 at 5:43 AM, Thomas Graf <tgraf@suug.ch> wrote:
>> > From: Thomas Graf <tgraf@rhlap.localdomain>
>
> The question is, can we move checksum completion to user space? We only
> need to complete the checksum if the packet is sent to a controller at
> which point performance does not matter anymore. What do you think
> about a datapath flag indicating whether user space supports checksum
> completion and if so skipping the checksum completion in the fast
> path?

This seems like a premature optimization to me. In order for userspace
to be able to either complete the checksums in cases where it needs it
or allow the NIC to do it when packets are resent, we would have to
also carry around offsets, etc. I would also consider the various
hardware offloads to be internal kernel optimization which tend to be
fairly platform specific and shouldn't really be exposed to userspace.

>> > +       /* Fix alignment of .nlmsg_len, OVS user space enforces a strict
>> > +        * total message size alignment.
>> > +        */
>> > +       ((struct nlmsghdr *) user_skb->data)->nlmsg_len = NLA_ALIGN(user_skb->len);
>>
>> Do we still need to do this manually now that we are enforcing
>> alignment of the payload above?
>
> We could use genlmsg_end() again if we also fix the skb-> pointer
> above. But we could drop the NLA_ALIGN() because user_skb->len is
> not always aligned.

Isn't the goal of the block above this to make user_skb->len aligned?
