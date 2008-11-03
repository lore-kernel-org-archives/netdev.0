From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: patch: support long (above 14 bytes) HW addresses in arp_ioctl
Date: Mon, 3 Nov 2008 13:58:11 -0800
Message-ID: <20081103135811.5307508e@extreme>
References: <490EDBDD.1030104@gmail.com>
	<ada63n4wvxp.fsf@cisco.com>
	<490F496C.2010608@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Constantine Gavrilov <constantine.gavrilov@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:42860 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752719AbYKCV6N (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 3 Nov 2008 16:58:13 -0500
In-Reply-To: <490F496C.2010608@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 03 Nov 2008 20:56:44 +0200
Constantine Gavrilov <constantine.gavrilov@gmail.com> wrote:

> 
> In arp_req_get() in net/arp.c, there is code:
> 
> memcpy(r->arp_ha.sa_data, neigh->ha, dev->addr_len);
> 
> dev->addr_len can be larger than size of r->arp_ha.sa_data. Inititally, 
> I thought it would corrupt kernel stack. I was wrong, since r still has 
> enough space not to overflow even for the largest HW address (32 bytes). 
> It would corrupt the data structure though, and that corrupted reply 
> would be propagated to user.
> 
> There is a similar situation in arp_req_set(), where a "junk" arp entry 
> will be set if dev->addr_len is larger that 14 bytes. 
> 
> At the very minimum, both arp_req_set() and arp_req_get() should return 
> error (-EINVAL), and not return junk or set junk. Truncated 
> /proc/net/arp output should also be fixed.
> 
> I was not aware that rtnetlink is capable of doing things like arp  
> table or interface manipulation (like netdevice ioctls). My applications 
> needs to be able to manipulate arp cache for large macs, and I do not 
> mind recompiling by adding a flag. I do not mind fixing arp cli to use 
> this either (venerable arp  does use arp_ioctl). And there are many many 
> legacy solutions that use arp_ioctl() in programs and arp utility in 
> scripts. Consider porting those to infiniband.
> 
> Will rtnetlink work for any net_device (like netdevice ioctls do) for 
> ARP and interface configurations calls or does it require special 
> support in net_device itself? Any possible problems with rtnetlink?
> 
> Roland Dreier wrote:
> >  > * arp_ioctl will corrupt the kernel and user memory when this ioctl is
> >  > used on the adapters that have HW addresses longer that 14 bytes.
> >  > This is because when copying the HW address, the arp_ioctl code copies
> >  > dev->addr_len bytes without checking that addr_len is not above 14
> >  > bytes. This is done both for copy_to_user() and memcpy() calls on
> >  > kernel data structures allocated on stack. The memcpy() call in
> >  > particular, will corrupt kernel stack.
> >
> > It's not obvious to me after a quick glance where this kernel memory
> > corruption occurs, but clearly we should at least fix this bug.
> >
> >  > The patch does not change the existing ABI but extends it.  The kernel
> >  > structure used in arp_ioctl calls is changed to support larger
> >  > addresses, while the user-space structure is extended by appending
> >  > extra-space to the end of the structure if ATF_NEWARPCTL -- a new flag
> >  > -- is set in arp_flags of existing user-space structure. This allows
> >  > avoiding big changes to the existing code while preserving the ABI
> >  > compatibility.
> >
> > However, given that applications need to be changed to use this,
> > wouldn't it make more sense just to change those applications to use
> > rtnetlink, which already supports large hardware addresses?  ie is there
> > much point to extending a legacy ABI to add a feature that the preferred
> > modern interface already has?
> >
> >  - R.
> >   
> 

Since this is a generic networking issue, please move discussion
to netdev mailing list <netdev@vger.kernel.org>
