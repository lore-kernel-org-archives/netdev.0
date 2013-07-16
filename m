From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH net-next v2] vxlan: Fix kernel crash on rmmod.
Date: Tue, 16 Jul 2013 16:31:56 -0700
Message-ID: <20130716163156.2374b233@nehalam.linuxnetplumber.net>
References: <1373567886-28494-1-git-send-email-pshelar@nicira.com>
	<20130711.114617.1413498443504266635.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: pshelar@nicira.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f173.google.com ([209.85.192.173]:60304 "EHLO
	mail-pd0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755209Ab3GPXcA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Jul 2013 19:32:00 -0400
Received: by mail-pd0-f173.google.com with SMTP id v14so1181548pde.18
        for <netdev@vger.kernel.org>; Tue, 16 Jul 2013 16:32:00 -0700 (PDT)
In-Reply-To: <20130711.114617.1413498443504266635.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 11 Jul 2013 11:46:17 -0700 (PDT)
David Miller <davem@davemloft.net> wrote:

> From: Pravin B Shelar <pshelar@nicira.com>
> Date: Thu, 11 Jul 2013 11:38:06 -0700
> 
> > vxlan exit module unregisters vxlan net and then it unregisters
> > rtnl ops which triggers vxlan_dellink() from __rtnl_kill_links().
> > vxlan_dellink() deletes vxlan-dev from vxlan_list which has
> > list-head in vxlan-net-struct but that is already gone due to
> > net-unregister. That is how we are getting following crash.
> > 
> > Following commit fixes the crash by fixing module exit path.
>  ...
> > Signed-off-by: Pravin B Shelar <pshelar@nicira.com>
> 
> Applied, thanks for fixing the commit message.

This now crashes for me with

# Test 4a new - up - rmmod
ip li add vxlan3 type vxlan id 42 group 239.1.1.1 dev eth0
ip li set dev vxlan3 up
sleep 2
rmmod vxlan

The root cause is that rtnl_kill_links calls dellink even if device is still
UP. Since this a generic problem (several other tunnels will crash or leak
if rmmod when up), I am working on a generic fix.
