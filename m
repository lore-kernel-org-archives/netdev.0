From: Max Krasnyansky <maxk@qualcomm.com>
Subject: Re: Multicast and receive filtering in TUN/TAP
Date: Thu, 10 Jul 2008 20:05:12 -0700
Message-ID: <4876CDE8.2020200@qualcomm.com>
References: <4875428F.4080704@qualcomm.com>	 <7f45d9390807101438q785232f1sfec7fcc580683d0f@mail.gmail.com> <480487c50807101932u7b4020a8qb31227a85f79c187@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Shaun Jackman <sjackman@gmail.com>,
	Brian Braunstein <linuxkernel@bristyle.com>,
	Christian Borntraeger <borntraeger@de.ibm.com>,
	netdev@vger.kernel.org, virtualization@lists.linux-foundation.org
To: Brian Braunstein <brian@bristyle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wolverine01.qualcomm.com ([199.106.114.254]:32194 "EHLO
	wolverine01.qualcomm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751828AbYGKDFN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Jul 2008 23:05:13 -0400
In-Reply-To: <480487c50807101932u7b4020a8qb31227a85f79c187@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



Brian Braunstein wrote:
> Sorry that I was confused here and it seems I am still confused.
> 
> I was thinking that for any one instance of a TAP interface, there
> should be only 1 MAC address, since there is only 1 network interface,
> since the character device is not a network interface but rather the
> interface for the application to send and receive on that virtual
> network interface.
> 
Exactly. Your understanding is perfectly correct.
See my previous reply. It should clear up all the confusion.


> For the MC stuff, I have to admit I haven't looked into it much, but it
> seems like the basic operation of setting the MAC address of the network
> interface should be supported, and it seems like an ioctl called
> SIOCSIFHWADDR should Set the InterFace HardWare ADDRess.  Sorry if I was
> wrong about this.  It might be good to add a comment to SIOCSIFHWADDR
> that says "This does not actually set the network interface hardware
> address, this is for multicast filtering" or whatever it actually is
> suppose to do.  Or perhaps create a new ioctl that has something about
> multicast filtering in the name, and leave SIOCSIFHWADDR doing what it
> is doing now.
Yep. That's what I'm going to do (ie a different ioctl). Again see my prev
email. We're totally on the same page :).

Max







> 
> brian
> 
> 
> On Thu, Jul 10, 2008 at 2:38 PM, Shaun Jackman <sjackman@gmail.com
> <mailto:sjackman@gmail.com>> wrote:
> 
>     Hi Max,
> 
>     The original patch implemented receive multicast filtering by
>     emulating the implementation used by many physical Ethernet
>     interfaces: hashing the multicast address. TUN emulates two network
>     cards (and communication via the virtual link between them), the guest
>     and the host, or the character device and the network device, so there
>     are two receive filters: chr_filter and net_filter. I implemented the
>     filtering at the character device using chr_filter in tun_chr_readv,
>     and left filtering at the network device for someone else to
>     implement.
> 
>     I'm not sure what you mean by TX filtering. Multicast filtering is
>     implemented uniquely at the receiver. There are, however, two
>     receivers: the character device and the network device.
> 
>     I believe Brian's patch was mistaken. Two entirely distinct Ethernet
>     addresses are required: one for the character device and one for the
>     network device, or put another way, one for the virtual Ethernet
>     interface at the guest and one for the virtual Ethernet interface at
>     the host. For the same reason, there are two distinct multicast
>     filters.
> 
> 
> 
>     Looking over the original patch, I believe I see a bug in
>     tun_net_mclist:
>     memset(tun->chr_filter, 0, sizeof tun->chr_filter);
>     should be
>     memset(tun->net_filter, 0, sizeof tun->net_filter);
> 
>     Cheers,
>     Shaun
> 
>     On Wed, Jul 9, 2008 at 3:58 PM, Max Krasnyansky <maxk@qualcomm.com
>     <mailto:maxk@qualcomm.com>> wrote:
>     > Yesterday while fixing xoff stuckiness issue in the TUN/TAP driver
>     I got a
>     > chance to look into the multicast filtering code in there. And
>     immediately
>     > realized how terribly broken & confusing it is. The patch was
>     originally
>     > done by Shaun (CC'ed) and went in without any proper ACK from me,
>     Dave or
>     > Jeff.
>     > Here is the original ref
>     >        http://marc.info/?l=linux-netdev&m=110490502102308&w=2
>     <http://marc.info/?l=linux-netdev&m=110490502102308&w=2>
>     >
>     > I'm not going to dive into too much details on what's wrong with
>     the current
>     > code. The main issues are that it mixes RX and TX filtering which are
>     > orthogonal, and it reuses ioctl names and stuff for manipulating
>     TX filter
>     > state as if it was a normal RX multicast state.
>     > Later on Brian's patch added insult to the injury
>     >        http://git.kernel.org/?p=linux/kernel/git/\
>     <http://git.kernel.org/?p=linux/kernel/git/%5C>
>     >                torvalds/linux-2.6.git;\
>     >                a=commit;h=36226a8ded46b89a94f9de5976f554bb5e02d84c
>     > Brian missed the point of the original patch (not his fault, as I
>     said the
>     > original patch was not the best) that the separate address
>     introduced by the
>     > MC patch was used for filtering _TX_ packets. It had nothing to do
>     with the
>     > HW addr of the local network interface.
>     >
>     > The problem is that MC stuff is now even more broken and ioctls
>     that were
>     > used originally now mean something different. So my first thinking
>     was to
>     > just rip the MC stuff out because it's broken and probably nobody
>     uses it
>     > (given that we got no complains after Brian's patch broke it
>     completely).
>     > But then I realized that if done properly it might be very useful for
>     > virtualization.
>     >
>     > ---
>     >
>     > So the first question is are there any users out there that ever
>     used the
>     > original patch. Shaun, any insight ? How did you intend to use it ?
>     >
>     > ---
>     >
>     > The second question is do you guys think that QEMU/KVM/LGUEST/etc
>     would
>     > benefit if receive filtering was done by the host OS. Here is a
>     specific
>     > example of what I'm talking about.
>     > We can do what qemu/hw/e1000.c:receive_filter() does in the _host_
>     context
>     > (that function currently runs in the guest context). By looking at
>     libvirt,
>     > typical QEMU based setup is that you have a single bridge and all
>     the TAPs
>     > from different VMs are hooked up to that bridge. What that means
>     is that if
>     > one VM is getting MC traffic or when the bridge sees MACADDR that
>     is not in
>     > its tables the packets get delivered to all the VMs. ie We have to
>     wake all
>     > of the up only to so that they could drop that packet. Instead, we
>     could
>     > setup filters in the host's side of the TAP device.
>     > Does that sound like something useful for QEMU/KVM ?
>     > If yes we can talk about the API. If not then I'll just nuke it.
>     >
>     > Thanx
>     > Max
>     >
> 
> 
