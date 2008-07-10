From: "Shaun Jackman" <sjackman@gmail.com>
Subject: Re: Multicast and receive filtering in TUN/TAP
Date: Thu, 10 Jul 2008 14:38:23 -0700
Message-ID: <7f45d9390807101438q785232f1sfec7fcc580683d0f@mail.gmail.com>
References: <4875428F.4080704@qualcomm.com>
Reply-To: "Shaun Jackman" <sjackman@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: "Brian Braunstein" <linuxkernel@bristyle.com>,
	"Christian Borntraeger" <borntraeger@de.ibm.com>,
	netdev@vger.kernel.org, virtualization@lists.linux-foundation.org
To: "Max Krasnyansky" <maxk@qualcomm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from yw-out-2324.google.com ([74.125.46.31]:55598 "EHLO
	yw-out-2324.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752430AbYGJVi2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Jul 2008 17:38:28 -0400
Received: by yw-out-2324.google.com with SMTP id 9so1732148ywe.1
        for <netdev@vger.kernel.org>; Thu, 10 Jul 2008 14:38:24 -0700 (PDT)
In-Reply-To: <4875428F.4080704@qualcomm.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Max,

The original patch implemented receive multicast filtering by
emulating the implementation used by many physical Ethernet
interfaces: hashing the multicast address. TUN emulates two network
cards (and communication via the virtual link between them), the guest
and the host, or the character device and the network device, so there
are two receive filters: chr_filter and net_filter. I implemented the
filtering at the character device using chr_filter in tun_chr_readv,
and left filtering at the network device for someone else to
implement.

I'm not sure what you mean by TX filtering. Multicast filtering is
implemented uniquely at the receiver. There are, however, two
receivers: the character device and the network device.

I believe Brian's patch was mistaken. Two entirely distinct Ethernet
addresses are required: one for the character device and one for the
network device, or put another way, one for the virtual Ethernet
interface at the guest and one for the virtual Ethernet interface at
the host. For the same reason, there are two distinct multicast
filters.

Looking over the original patch, I believe I see a bug in tun_net_mclist:
memset(tun->chr_filter, 0, sizeof tun->chr_filter);
should be
memset(tun->net_filter, 0, sizeof tun->net_filter);

Cheers,
Shaun

On Wed, Jul 9, 2008 at 3:58 PM, Max Krasnyansky <maxk@qualcomm.com> wrote:
> Yesterday while fixing xoff stuckiness issue in the TUN/TAP driver I got a
> chance to look into the multicast filtering code in there. And immediately
> realized how terribly broken & confusing it is. The patch was originally
> done by Shaun (CC'ed) and went in without any proper ACK from me, Dave or
> Jeff.
> Here is the original ref
>        http://marc.info/?l=linux-netdev&m=110490502102308&w=2
>
> I'm not going to dive into too much details on what's wrong with the current
> code. The main issues are that it mixes RX and TX filtering which are
> orthogonal, and it reuses ioctl names and stuff for manipulating TX filter
> state as if it was a normal RX multicast state.
> Later on Brian's patch added insult to the injury
>        http://git.kernel.org/?p=linux/kernel/git/\
>                torvalds/linux-2.6.git;\
>                a=commit;h=36226a8ded46b89a94f9de5976f554bb5e02d84c
> Brian missed the point of the original patch (not his fault, as I said the
> original patch was not the best) that the separate address introduced by the
> MC patch was used for filtering _TX_ packets. It had nothing to do with the
> HW addr of the local network interface.
>
> The problem is that MC stuff is now even more broken and ioctls that were
> used originally now mean something different. So my first thinking was to
> just rip the MC stuff out because it's broken and probably nobody uses it
> (given that we got no complains after Brian's patch broke it completely).
> But then I realized that if done properly it might be very useful for
> virtualization.
>
> ---
>
> So the first question is are there any users out there that ever used the
> original patch. Shaun, any insight ? How did you intend to use it ?
>
> ---
>
> The second question is do you guys think that QEMU/KVM/LGUEST/etc would
> benefit if receive filtering was done by the host OS. Here is a specific
> example of what I'm talking about.
> We can do what qemu/hw/e1000.c:receive_filter() does in the _host_ context
> (that function currently runs in the guest context). By looking at libvirt,
> typical QEMU based setup is that you have a single bridge and all the TAPs
> from different VMs are hooked up to that bridge. What that means is that if
> one VM is getting MC traffic or when the bridge sees MACADDR that is not in
> its tables the packets get delivered to all the VMs. ie We have to wake all
> of the up only to so that they could drop that packet. Instead, we could
> setup filters in the host's side of the TAP device.
> Does that sound like something useful for QEMU/KVM ?
> If yes we can talk about the API. If not then I'll just nuke it.
>
> Thanx
> Max
>
