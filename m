From: David Woodhouse <dwmw2@infradead.org>
Subject: Re: vpnc-script fix for changed iproute output with newer kernels
Date: Fri, 29 Jul 2011 13:33:11 +0100
Message-ID: <1311942793.17528.57.camel@i7.infradead.org>
References: <20110728021227.GA3620@gmail.com>
	 <20110728021853.GB3620@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, shemminger@vyatta.com
To: Justin Bronder <jsbronder@gentoo.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:40936 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755367Ab1G2MdO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Jul 2011 08:33:14 -0400
In-Reply-To: <20110728021853.GB3620@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2011-07-28 at 03:18 +0100, Justin Bronder wrote:
> From 0a1c10c83f2043f00793c166ad351dc643bcefe3 Mon Sep 17 00:00:00 2001
> From: Justin Bronder <jsbronder@gmail.com>
> Date: Wed, 27 Jul 2011 22:10:06 -0400
> Subject: [PATCH] fix for newer kernels
> 
> newer kernels have added expires and mtu to the ip route output
> ---
>  vpnc-script |    8 +++++++-
>  1 files changed, 7 insertions(+), 1 deletions(-)
> 
> diff --git a/vpnc-script b/vpnc-script
> index e0140c5..b071e0b 100755
> --- a/vpnc-script
> +++ b/vpnc-script
> @@ -139,7 +139,13 @@ destroy_tun_device() {
>  
>  if [ -n "$IPROUTE" ]; then
>  	fix_ip_get_output () {
> -		sed 's/cache//;s/metric \?[0-9]\+ [0-9]\+//g;s/hoplimit [0-9]\+//g;s/ipid 0x....//g'
> +		sed \
> +            -e 's/cache//' \
> +            -e ';s/metric \?[0-9]\+ [0-9]\+//g' \
> +            -e 's/hoplimit [0-9]\+//g' \
> +            -e 's/ipid 0x....//g' \
> +            -e 's/expires [0-9]\+sec//g' \
> +            -e 's/mtu [0-9]\+//g'
>  	}
>  
>  	set_vpngateway_route() {

Thanks for this, Justin. But I'd really prefer not to do it this way.

This is the second time in as many kernel releases that this has broken;
we only added 'ipid' to that regex in May. If we have to keep doing this
dance, we are doing it *wrong*.

Stephen, what is the *right* way to do this?

This is for vpnc-script, as you ought to be able to tell from the patch
header. If we're adding routes to the newly-created VPN device, we first
have to ensure that the route to the VPN server *itself* doesn't change.

So effectively we want to do: 
 ip route add $(ip route get $VPNSERVER)

... except then we have to have that awful bunch of sed crap to make it
work right. I suppose we could at least make it opt-in, and include the
'via' and 'dev' and 'src' options and remove *everything* else? But that
doesn't really fill me with joy *either*.

Any suggestions that *aren't* going to be constantly broken?

-- 
dwmw2

