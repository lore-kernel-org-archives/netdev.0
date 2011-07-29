From: Andreas Steffen <andreas.steffen@strongswan.org>
Subject: Re: Kernel IPSec Questions
Date: Fri, 29 Jul 2011 22:20:04 +0200
Message-ID: <4E3315F4.1020701@strongswan.org>
References: <CAL0-=Wwb+T_VYgMnOW9UiqQ2gVe8FaJCZgcFmHMLX1Yv3tVAdQ@mail.gmail.com> <4E325B58.6030202@strongswan.org> <CAL0-=WwDFeCJX62_Bgty615MtjuBY3rBp6BtHP7p9_3NvJ3u+g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: T C <tccheung1@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sitav-80024.hsr.ch ([152.96.80.24]:36179 "EHLO strongswan.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752602Ab1G2UUI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 29 Jul 2011 16:20:08 -0400
In-Reply-To: <CAL0-=WwDFeCJX62_Bgty615MtjuBY3rBp6BtHP7p9_3NvJ3u+g@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello Terry,

each IPsec SA in the kernel has a lifetime configuration consisting
of both a soft and a hard limit for the number of bytes, number of
packets and time:

	lifetime config:
	  limit: soft (INF)(bytes), hard (INF)(bytes)
	  limit: soft (INF)(packets), hard (INF)(packets)
	  expire add: soft 903(sec), hard 1200(sec)
	  expire use: soft 0(sec), hard 0(sec)

Each time one of the soft or hard limits is reached, the Linux kernel
generates an XFRM_MSG_EXPIRE message to which the charon daemon
subscribes when creating the NETLINK_XFRM socket:

http://git.strongswan.org/?p=strongswan.git;a=blob;f=src/libhydra/plugins/kernel_netlink/kernel_netlink_ipsec.c;h=06720a0f4bddf9fde60288f796df0eca647ae995;hb=HEAD#l2664

The callback function receive_events() is triggered by these
subscribed XFRM messages:

http://git.strongswan.org/?p=strongswan.git;a=blob;f=src/libhydra/plugins/kernel_netlink/kernel_netlink_ipsec.c;h=06720a0f4bddf9fde60288f796df0eca647ae995;hb=HEAD#l939

In the case of XFRM_MSG_EXPIRE the function process_expire() is
called:

http://git.strongswan.org/?p=strongswan.git;a=blob;f=src/libhydra/plugins/kernel_netlink/kernel_netlink_ipsec.c;h=06720a0f4bddf9fde60288f796df0eca647ae995;hb=HEAD#l939

which in turn calls hydra->kernel_interface->expire():

http://git.strongswan.org/?p=strongswan.git;a=blob;f=src/libhydra/kernel/kernel_interface.c;h=ebe653ec4582ef2c16024d1cc5711d51c8b45970;hb=HEAD#l388

All registered expire listeners are notified, in our case the libcharon
listener:

http://git.strongswan.org/?p=strongswan.git;a=blob;f=src/libcharon/kernel/kernel_handler.c;h=51fccb1acd6d7813bb83517428fc8f7b15f841d5;hb=HEAD#l75

As you can see, if a soft limit was reached then a CHILD_SA rekeying
job is scheduled

  job = (job_t*)rekey_child_sa_job_create(reqid, proto, spi);

and if a hard limit is reached (what should not happen with rekey=yes)
then the CHILD_SA is deleted

  job = (job_t*)delete_child_sa_job_create(reqid, proto, spi);

Best regards

Andreas

On 29.07.2011 19:56, T C wrote:
> Hi Andreas,
> 
> Thanks for the URLs.  I'll look thru them.
> 
> As far as strongswan is concerned, Martin has been very helpful in
> explaining all the active actions that StrongSwan takes from
> the user side.  So actions taken by IKE daemon based on configuration
> files I already have info on that.  However,
> the part that remains mostly unfamiliar is those actions taken by the
> kernel during rekeying by sending messages back
> from the kernel to the IKE daemon.  Do you happen to know anything
> about that?  How are those actions trigged and what
> happens to the communication channels during rekeying is what I am
> most interested in finding out.  If your URLs already
> contain something that'll point to those, I'll find out from them.  If
> there is additional info on this, could you share them
> as well?
> 
> Thanks,
> Terry
> 
> On Fri, Jul 29, 2011 at 12:03 AM, Andreas Steffen
> <andreas.steffen@strongswan.org> wrote:
>> Hello Terry,
>>
>> here a repost of my email including the netdev list and fixing
>> the last URL which was wrong.
>>
>> Here the definition of strongSwan's IPsec high level kernel interface
>>
>> http://git.strongswan.org/?p=strongswan.git;a=blob;f=src/libhydra/kernel/kernel_ipsec.h;h=986e21fca1bbd109445e95d86dbf458095299573;hb=HEAD
>>
>> and here the link to the kernel-netlink plugin which implements
>> configuration and management of IPsec Policies and SAs via XFRM
>>
>> http://git.strongswan.org/?p=strongswan.git;a=blob;f=src/libhydra/plugins/kernel_netlink/kernel_netlink_ipsec.c;h=06720a0f4bddf9fde60288f796df0eca647ae995;hb=HEAD
>>
>> Our plugin of course relies on the ipsec.h, netlink.h, rtnetlink.h,
>> and xfrm.h Linux header files which define the API of the XFRM Netlink
>> kernel interface
>>
>> http://git.strongswan.org/?p=strongswan.git;a=tree;f=src/include/linux;h=a41d3e9a10954c47aff2efeb06576f323c039483;hb=HEAD
>>
>> Much more documentation than the Linux header files and the XFRM kernel
>> source code itself does not exist.
>>
>> Finally a link which shows how strongSwan installs, updates, queries
>> and deletes IPsec Policies and SAs
>>
>> http://git.strongswan.org/?p=strongswan.git;a=blob;f=src/libcharon/sa/child_sa.c;h=cda150f8736d010cf8d897071427daf8a02a337a;hb=HEAD
>>
>> Just look for all "hydra->kernel_interface" function calls.
>>
>> Best regards
>>
>> Andreas

======================================================================
Andreas Steffen                         andreas.steffen@strongswan.org
strongSwan - the Linux VPN Solution!                www.strongswan.org
Institute for Internet Technologies and Applications
University of Applied Sciences Rapperswil
CH-8640 Rapperswil (Switzerland)
===========================================================[ITA-HSR]==
