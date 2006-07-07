From: Stefan Rompf <stefan@loplof.de>
Subject: Re: [VLAN]: translate IF_OPER_DORMANT to netif_dormant_on()
Date: Fri, 7 Jul 2006 11:45:05 +0200
Message-ID: <200607071145.09325.stefan@loplof.de>
References: <200603211829.k2LITMNR029085@hera.kernel.org> <44AC2C4C.9060001@candelatech.com> <44ACBEDB.2020101@trash.net>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Ben Greear <greearb@candelatech.com>,
	Linux Netdev List <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from natklopstock.rzone.de ([81.169.145.174]:4008 "EHLO
	natklopstock.rzone.de") by vger.kernel.org with ESMTP
	id S932090AbWGGJna (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 7 Jul 2006 05:43:30 -0400
To: Patrick McHardy <kaber@trash.net>
In-Reply-To: <44ACBEDB.2020101@trash.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Am Donnerstag 06 Juli 2006 09:42 schrieb Patrick McHardy:

> > I believe this link-state logic was added by someone else.  I'm not
> > sure exactly what these flags are supposed to do, so I am not sure if
> > they should be propagated to the VLAN or not.
>
> I looked into this. The present flag used to get propagated from the
> real device until this patch, presumably to make sure no operations
> on the vlan device will be passed through to the underlying device
> when it is not present.

The present flag is changed by netif_device_attach() and 
netif_device_detach(), and these functions do not emit a 
netdev_state_change() afterwards. So there is a good chance that 
vlan_device_event() won't be called and cannot transfer the flag. 
netif_device_detach() also sets __LINK_STATE_XOFF implicitely. 

Ok, let's see who cares for netif_device_present():

-SIOCSIFMAP, dev->set_config() (change media type)
-dev_open()
-dev_set_mtu()
-dev_set_mac_address()
-dev_watchdog()
 ->not implemented by VLAN / does not call through to underlying device

-multicast ioctls
 ->calls dev_mc_upload() of the underlying device sooner or later, this 
function checks whether the device is present or not. However, if you change 
the multicast list on a VLAN while the real device is not present, 
dev_mc_upload() won't be called on netif_device_attach(). Good thing is that 
most drivers setup multicast list after attach. Fishy.

-several private ioctls
 ->vlan_dev_ioctl() checks whether the real device is present before passing 
an ioctl

So I'd rather drop the __LINK_STATE_PRESENT transfer part, because not 
guaranteed to be called anyway and mostly unneeded. Ok, let me look through 
the history now to find who added transferring it (hope this happened after 
the bitkeeper->git move)

Stefan
