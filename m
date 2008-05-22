From: <glenn_engel@agilent.com>
Subject: RE: natsemi.c ioctl fix or mii register access
Date: Thu, 22 May 2008 12:46:13 -0600
Message-ID: <010200463BAAFF45926C5BFD8E21F515FD47AC@cos-us-mb01.cos.agilent.com>
References: <010200463BAAFF45926C5BFD8E21F515F523F0@cos-us-mb01.cos.agilent.com> <4835B5C0.2000701@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <netdev@vger.kernel.org>
To: <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from aglcosbs01.cos.agilent.com ([192.25.218.35]:36276 "EHLO
	aglcosbs01.cos.agilent.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750786AbYEVStF convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 22 May 2008 14:49:05 -0400
Content-class: urn:content-classes:message
In-Reply-To: <4835B5C0.2000701@pobox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The core only copies the ifreq struct.  In the case of SIOC[GS]MIIPHY the ifru_data field is a pointer to additional user space information about the ioctl (phy_id, register number).

Thus, an additional copy_from/to_user is required to extract this additional information.  

I suppose this copy could be done in dev.c for these ioctls but it would also need to tweak the ifru_data field to point to local storage before/after the ioctl calls.  Perhaps this was the original intent and was not noticed since ethtool doesn't use these ioctls.  I just assumed the natsemi driver was the odd duck but perhaps none of them work with these ioctls at this point.

--
Glenn

> -----Original Message-----
> From: Jeff Garzik [mailto:jgarzik@pobox.com]
> Sent: Thursday, May 22, 2008 11:05 AM
> To: ENGEL,GLENN (A-Labs,ex1)
> Cc: netdev@vger.kernel.org
> Subject: Re: natsemi.c ioctl fix or mii register access
> 
> glenn_engel@agilent.com wrote:
> > Hi,
> >
> > I recently discovered the ioctl implementation in natsemi.c had a few
> bugs in dealing with the user ioctls to send and receive MII commands
> (SIOCGMIIPHY and SIOCSMIIPHY).
> >
> > The specific problems noted and fixed:
> >
> > 1. The if_mii macro casts it's return to be (struct mii_ioctl_data *)
> but in reality it returns a pointer to the user space pointer (struct
> mii_ioctl_data**).   This looks to be a problem with the mii_macro to
> me.  I changed this to use the ifr_data macro instead.
> >
> > 2. Since the mii_ioctl_data structure resides in user space, it must
> be copied into kernel space before access and copied back for read
> results.  References to the pointer were changed to point to the local
> copy (data-> changed to mii_data.)
> 
> This is completely incorrect.  The copying is done for us inside net
> core.
> 
> 	Jeff
> 
> 
> 


