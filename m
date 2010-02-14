From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH net-next-2.6] macvtap: Add GSO/csum offload support
Date: Sun, 14 Feb 2010 20:13:08 +0100
Message-ID: <201002142013.08745.arnd@arndb.de>
References: <1266013667.6105.18.camel@w-sridhar.beaverton.ibm.com> <201002131834.00612.arnd@arndb.de> <4B7711C9.2090800@us.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-15"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	netdev <netdev@vger.kernel.org>
To: Sridhar Samudrala <sri@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.126.186]:51556 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752256Ab0BNURs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 14 Feb 2010 15:17:48 -0500
In-Reply-To: <4B7711C9.2090800@us.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Saturday 13 February 2010 21:55:37 Sridhar Samudrala wrote:
> > Also, what about IFF_TAP and IFF_NO_PI, should those be always set?
> >    
> Atleast it is not required for qemu to have these flags set. If we are 
> not doing anything different based on
> these flags, i felt we don't need to have them.

The point is that other applications might depend on them. We only support
IFF_TAP operation (not IFF_TUN), and we do not understand the !IFF_NO_PI
frame format, so any program that tries to use the PI header or use cooked
IP packets will get incorrect data.

> >> -            /* TODO: add support for these, so far we don't
> >> -                     support any offload */
> >> -            if (arg&  (TUN_F_CSUM | TUN_F_TSO4 | TUN_F_TSO6 |
> >> -                     TUN_F_TSO_ECN | TUN_F_UFO))
> >> -                    return -EINVAL;
> >> -
> >> -            return 0;
> >> +            q = macvtap_file_get_queue(file);
> >> +            if (!q)
> >> +                    return -ENOLINK;
> >> +            ret = 0;
> >> +            if (!(q->flags&  IFF_VNET_HDR))
> >> +                    ret =  -EINVAL;
> >> +            macvtap_file_put_queue(q);
> >> +            return ret;
> >>
> >>      default:
> >>              return -EINVAL;
> >>      
> > At least the first check needs to be in there, in case we are running with
> > new user space that knows additional flags. Moreover, shouldn't we check
> > the flags against the capabilities of vlan->lowerdev? I though it would be
> > best to report the capabilities of the real hardware to the guest kernel
> > so it can do the right thing.
> >    
> Originally, i also thought we should check these based on the real 
> device capabilities. But later i realized,
> that it is not really required as we fall back to software offload via 
> dev_gso_segment() call in dev_hard_start_xmit()
> if the real device doesn't support any of the offloads. So we can 
> advertise that all the offloads are supported to
> the guest and let host deal with any offloads that are not supported by 
> the real device.

Ah, good point. Will that also work for the checksumming? Also, should the
host really be doing segmentation and checksumming for the guest if the
hardware can't do it? So even if everything works correctly, we might
want to let the guest do the work in order to get accounting of the CPU
cycles right.
OTOH, for data transfers between guests, we can probably use all the offloads
independent of what the HW can do, so when optimizing for inter-guest
communication, we might want to ignore the accounting problems.

I'd like to hear other opinions on this.

	Arnd
