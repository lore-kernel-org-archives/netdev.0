From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: commit 1faa4356 breaks IPv6 assignment on libvirtd
Date: Thu, 1 Sep 2011 08:51:26 -0700
Message-ID: <20110901085126.76cdda54@nehalam.ftrdhcpuser.net>
References: <4E5F99E2.50301@sfc.wide.ad.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Ang Way Chuang <wcang@sfc.wide.ad.jp>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:59512 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932439Ab1IAPvR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 1 Sep 2011 11:51:17 -0400
In-Reply-To: <4E5F99E2.50301@sfc.wide.ad.jp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 01 Sep 2011 23:42:42 +0900
Ang Way Chuang <wcang@sfc.wide.ad.jp> wrote:

> Hi all,
> 
>    Commit 1faa4356 break IPv6 assignment on libvirtd. The configuration for my VM bridge network is as such:
> 
> <network>
>   <name>default</name>
>   <forward mode='nat'/>
>   <bridge name='virbr0' stp='on' delay='0' />
>   <ip address='192.168.122.1' netmask='255.255.255.0'>
>     <dhcp>
>       <range start='192.168.122.2' end='192.168.122.254' />
>     </dhcp>
>   </ip>
>   <ip family='ipv6' address='2001:d30:113:504::1' prefix='64'>
>   </ip>
> </network>
> 
>     This configuration worked fine on kernel 2.6.38. Updating my distro kernel broke the setup. My colleague 
> and I traced the problem and found that libvirtd failed because there wasn't any carrier on virbr0 interface 
> due to the change introduced by that commit. How can this be fixed? Thanks in advance.
> 
> Regards,
> Ang Way Chuang

The issue is that address is assigned to a bridge device with no ports.
IPv6 needs carrier to do duplicate address detection. Without any ports
the DAD will always succeed, and there is a possibility that when ports
are later added to the bridge the address actually is a duplicate.

A couple of possible options are:
1. Default to carrier on in bridge when there are no ports.
   The downside with this is that IPv6 DAD is being fooled.


2. Change libvirt to allow turning off DAD. This is controlled
   in kernel by writing 0 to /proc/sys/net/ipv6/conf/virbr0/accept_dad
