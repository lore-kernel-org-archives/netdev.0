From: Vlad Yasevich <vyasevic@redhat.com>
Subject: Re: Guest 8021q VLAN tags and macvtap
Date: Wed, 16 Jul 2014 19:36:52 -0400
Message-ID: <53C70C94.6050507@redhat.com>
References: <53C6DD6B.5090007@linux.vnet.ibm.com>
Reply-To: vyasevic@redhat.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: Matthew Rosato <mjrosato@linux.vnet.ibm.com>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:24580 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752695AbaGPXg5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 16 Jul 2014 19:36:57 -0400
In-Reply-To: <53C6DD6B.5090007@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/16/2014 04:15 PM, Matthew Rosato wrote:
> Prior to commit 6acf54f1cf (macvtap: Add support of packet capture on
> macvtap device), I was able to setup an environment where qemu guests
> connected via macvtaps (eg, guest eth0 --> host macvtap0 --> host eth0)
> could configure guest 8021q tagging and communicate with each other over
> the vlan, with the guests being responsible for tagging/untagging. I
> accomplished this by configuring the desired vlan id on both the guest
> interface (guest eth0.123) as well as by adding the vlan to the
> underlying host macvtap (macvtap0.123).  Configuring the id on the
> macvtap was done to allow the tagged packets to get past the lowerdev.
> 
> Now, post 6acf54f1cf, guest-tagged traffic never arrives on the target
> guest (untagged traffic is fine).  I did some tracing as a tagged packet
> comes in on the target host, summarized:
> 
> 1) __netif_receive_skb calls untag_vlan, vlan_tci is stashed,
> vlan_do_receive returns false
> 2) rx_handler (macvlan_handle_frame) is called
> 3) netif_rx_ni is called, skb queued/dequeued (pass to macvtap)
> 4) __netif_receive_skb called again - vlan_do_receive is called
> successfully, causing us to lose our stashed vlan_tci
> 5) rx_handler (macvtap_handle_frame) is called
> 
> My understanding is that macvtap expects packets to get untagged, and
> intends to re-tag them later at macvtap_put_user.  But, because the
> macvtap is vlan-enabled, the stashed vlan_tci is always gone because of
> vlan_do_receive.
> 
> I think it boils down to the old macvtap_receive/forward logic not
> calling vlan_do_receive, but now we do since we're using netif.  Was my
> configuration wrong in the first place, or is this a bug?
> 
> FWIW, I hacked __netif_receive_skb to skip the vlan_do_receive call for
> IFF_MACVLAN, and sure enough that restores my expected behavior, but
> I'm not sure if that's the right solution.

No, that's not the right solution.  The reason you are seeing loss of
vlan_tci is due to the existance of macvtap0.123 (the host side vlan
device).  If you remove that device, guest-guest comms will work,
but guest-remote will stop

Getting the tagged packets received at the lower dev is the issue.
You could unload vlan module and that should restore guest-remote
communications.
You could setting promisc mode on the lower dev, but that's not a nice
solution.

I need to thing about more about how better solve this.

Thanks
-vlad


> 
> Thanks,
> Matt
> 
