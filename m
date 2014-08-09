From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH v2 net] net: Always untag vlan-tagged traffic on input.
Date: Sat, 9 Aug 2014 08:44:31 +0200
Message-ID: <20140809064431.GA1872@nanopsycho.orion>
References: <1407523333-31455-1-git-send-email-vyasevic@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>,
	Nithin Nayak Sujir <nsujir@broadcom.com>,
	Michael Chan <mchan@broadcom.com>
To: Vladislav Yasevich <vyasevic@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f173.google.com ([74.125.82.173]:52488 "EHLO
	mail-we0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751023AbaHIGoe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 9 Aug 2014 02:44:34 -0400
Received: by mail-we0-f173.google.com with SMTP id q58so6548834wes.18
        for <netdev@vger.kernel.org>; Fri, 08 Aug 2014 23:44:32 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1407523333-31455-1-git-send-email-vyasevic@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fri, Aug 08, 2014 at 08:42:13PM CEST, vyasevic@redhat.com wrote:
>Currently the functionality to untag traffic on input resides
>as part of the vlan module and is build only when VLAN support
>is enabled in the kernel.  When VLAN is disabled, the function
>vlan_untag() turns into a stub and doesn't really untag the
>packets.  This seems to create an interesting interaction
>between VMs supporting checksum offloading and some network drivers.
>
>There are some drivers that do not allow the user to change
>tx-vlan-offload feature of the driver.  These drivers also seem
>to assume that any VLAN-tagged traffic they transmit will
>have the vlan information in the vlan_tci and not in the vlan
>header already in the skb.  When transmitting skbs that already
>have tagged data with partial checksum set, the checksum doesn't
>appear to be updated correctly by the card thus resulting in a
>failure to establish TCP connections.
>
>The following is a packet trace taken on the receiver where a
>sender is a VM with a VLAN configued.  The host VM is running on
>doest not have VLAN support and the outging interface on the
>host is tg3:
>10:12:43.503055 52:54:00:ae:42:3f > 28:d2:44:7d:c2:de, ethertype 802.1Q
>(0x8100), length 78: vlan 100, p 0, ethertype IPv4, (tos 0x0, ttl 64, id 27243,
>offset 0, flags [DF], proto TCP (6), length 60)
>    10.0.100.1.58545 > 10.0.100.10.ircu-2: Flags [S], cksum 0xdc39 (incorrect
>-> 0x48d9), seq 1069378582, win 29200, options [mss 1460,sackOK,TS val
>4294837885 ecr 0,nop,wscale 7], length 0
>10:12:44.505556 52:54:00:ae:42:3f > 28:d2:44:7d:c2:de, ethertype 802.1Q
>(0x8100), length 78: vlan 100, p 0, ethertype IPv4, (tos 0x0, ttl 64, id 27244,
>offset 0, flags [DF], proto TCP (6), length 60)
>    10.0.100.1.58545 > 10.0.100.10.ircu-2: Flags [S], cksum 0xdc39 (incorrect
>-> 0x44ee), seq 1069378582, win 29200, options [mss 1460,sackOK,TS val
>4294838888 ecr 0,nop,wscale 7], length 0
>
>This connection finally times out.
>
>I've only access to the TG3 hardware in this configuration thus have
>only tested this with TG3 driver.  There are a lot of other drivers
>that do not permit user changes to vlan acceleration features, and
>I don't know if they all suffere from a similar issue.
>
>The patch attempt to fix this another way.  It moves the vlan header
>stipping code out of the vlan module and always builds it into the
>kernel network core.  This way, even if vlan is not supported on
>a virtualizatoin host, the virtual machines running on top of such
>host will still work with VLANs enabled.
>
>CC: Patrick McHardy <kaber@trash.net>
>CC: Nithin Nayak Sujir <nsujir@broadcom.com>
>CC: Michael Chan <mchan@broadcom.com>
>CC: Jiri Pirko <jiri@resnulli.us>
>Signed-off-by: Vladislav Yasevich <vyasevic@redhat.com>

Acked-by: Jiri Pirko <jiri@resnulli.us>
