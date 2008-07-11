From: Max Krasnyansky <maxk@qualcomm.com>
Subject: Re: Multicast and receive filtering in TUN/TAP
Date: Thu, 10 Jul 2008 20:01:36 -0700
Message-ID: <4876CD10.7060500@qualcomm.com>
References: <4875428F.4080704@qualcomm.com> <7f45d9390807101438q785232f1sfec7fcc580683d0f@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: Brian Braunstein <linuxkernel@bristyle.com>,
	Christian Borntraeger <borntraeger@de.ibm.com>,
	netdev@vger.kernel.org, virtualization@lists.linux-foundation.org
To: Shaun Jackman <sjackman@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wolverine02.qualcomm.com ([199.106.114.251]:34568 "EHLO
	wolverine02.qualcomm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751828AbYGKDBs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Jul 2008 23:01:48 -0400
In-Reply-To: <7f45d9390807101438q785232f1sfec7fcc580683d0f@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Shaun Jackman wrote:
> Hi Max,
> 
> The original patch implemented receive multicast filtering by
> emulating the implementation used by many physical Ethernet
> interfaces: hashing the multicast address. TUN emulates two network
> cards (and communication via the virtual link between them), 
Nope. It does not. That's where the confusion is coming from.
TUN/TAP emulates _single_ network interface.
A better analogy of what TUN/TAP is is the "disconnected Ethernet port". It's
up to the application to simulate wire|loopback|another nic|etc.
Character device is simply a mechanism to reading and writing frames.
Application that uses TUN/TAP _may_ chose to treat the other end of it as
another network interface but TUN/TAP driver itself does not. Consider a
tunneling application like OpenVPN for example.
What you're describing is more like TAP (host) <-> TAP (guest) kind of thing.
ie Separate TAP instance for the guest.

> the guest
> and the host, or the character device and the network device, so there
> are two receive filters: chr_filter and net_filter. I implemented the
> filtering at the character device using chr_filter in tun_chr_readv,
> and left filtering at the network device for someone else to
> implement.
> 
> I'm not sure what you mean by TX filtering. Multicast filtering is
> implemented uniquely at the receiver. There are, however, two
> receivers: the character device and the network device.
See my explanation above. You came up with a bit different interpretation of
what TUN/TAP is which is not correct. With the proper TUN/TAP model in mind
your patch implemented filtering of the packets _transmitted_ on the TAP.
That's what I meant by the TX filtering.

> I believe Brian's patch was mistaken. Two entirely distinct Ethernet
> addresses are required: one for the character device and one for the
> network device, or put another way, one for the virtual Ethernet
> interface at the guest and one for the virtual Ethernet interface at
> the host. For the same reason, there are two distinct multicast
> filters.
If you see my first email on this thread I mentioned that the wrong set of
ioctls() was used in the original MC patch. Since most people think of the
TUN/TAP as the single device, Brian rightfully assumed that SIOCSIFHWADDR
sets the HW address of that single interface. ie It looks as if it's just a
short cut. Instead of having to open a socket, lookup TAP device and set HW
addr via the socket, application can just set it via TUN/TAP fd directly.

Also look at one of the comments in your original patch
        case SIOCGIFHWADDR:
                /* Note: the actual net device's address may be different */

In your TUN model the addresses _must_ be different. How can they be the same
if you're saying it's two different network cards ? That comment was incorrect
and confusing, it makes people think that it's kind of the same thing.
In fact it took me awhile to understand what it was that you were trying to do :).

> Looking over the original patch, I believe I see a bug in tun_net_mclist:
> memset(tun->chr_filter, 0, sizeof tun->chr_filter);
> should be
> memset(tun->net_filter, 0, sizeof tun->net_filter);
Yep that too. It made me think that you're mixing TX and RX filtering.
Especially because net_filter was not used anywhere else.

So the correct way to do this is to clearly state that ioctl modifies TX
filters. ie Instead of using generic SIOCGIFHWADDR it should've been
TUNSETTXFILTER or something. And tun->dev_addr thing looks awfully similar to
the net->dev_addr. Again it should be tun->tx_filter_addr or something like that.

Anyway, do you have a use case for this stuff ?

I have a patch that cleans it all up. Looks like it might be useful for the
virt folks. Let me know what your use case was so that I could make sure it'd
still work. Unfortunately I'm going to have to replace existing SIOC* ioctls.

Max

> On Wed, Jul 9, 2008 at 3:58 PM, Max Krasnyansky <maxk@qualcomm.com> wrote:
>> Yesterday while fixing xoff stuckiness issue in the TUN/TAP driver I got a
>> chance to look into the multicast filtering code in there. And immediately
>> realized how terribly broken & confusing it is. The patch was originally
>> done by Shaun (CC'ed) and went in without any proper ACK from me, Dave or
>> Jeff.
>> Here is the original ref
>>        http://marc.info/?l=linux-netdev&m=110490502102308&w=2
>>
>> I'm not going to dive into too much details on what's wrong with the current
>> code. The main issues are that it mixes RX and TX filtering which are
>> orthogonal, and it reuses ioctl names and stuff for manipulating TX filter
>> state as if it was a normal RX multicast state.
>> Later on Brian's patch added insult to the injury
>>        http://git.kernel.org/?p=linux/kernel/git/\
>>                torvalds/linux-2.6.git;\
>>                a=commit;h=36226a8ded46b89a94f9de5976f554bb5e02d84c
>> Brian missed the point of the original patch (not his fault, as I said the
>> original patch was not the best) that the separate address introduced by the
>> MC patch was used for filtering _TX_ packets. It had nothing to do with the
>> HW addr of the local network interface.
>>
>> The problem is that MC stuff is now even more broken and ioctls that were
>> used originally now mean something different. So my first thinking was to
>> just rip the MC stuff out because it's broken and probably nobody uses it
>> (given that we got no complains after Brian's patch broke it completely).
>> But then I realized that if done properly it might be very useful for
>> virtualization.
>>
>> ---
>>
>> So the first question is are there any users out there that ever used the
>> original patch. Shaun, any insight ? How did you intend to use it ?
>>
>> ---
>>
>> The second question is do you guys think that QEMU/KVM/LGUEST/etc would
>> benefit if receive filtering was done by the host OS. Here is a specific
>> example of what I'm talking about.
>> We can do what qemu/hw/e1000.c:receive_filter() does in the _host_ context
>> (that function currently runs in the guest context). By looking at libvirt,
>> typical QEMU based setup is that you have a single bridge and all the TAPs
>> from different VMs are hooked up to that bridge. What that means is that if
>> one VM is getting MC traffic or when the bridge sees MACADDR that is not in
>> its tables the packets get delivered to all the VMs. ie We have to wake all
>> of the up only to so that they could drop that packet. Instead, we could
>> setup filters in the host's side of the TAP device.
>> Does that sound like something useful for QEMU/KVM ?
>> If yes we can talk about the API. If not then I'll just nuke it.
>>
>> Thanx
>> Max
>>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
