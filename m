From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [Bugme-new] [Bug 9545] New: Cannot bring up a bridge interface
 without a MAC address set
Date: Tue, 11 Dec 2007 13:26:14 -0800
Message-ID: <20071211132614.5854b0f1.akpm@linux-foundation.org>
References: <bug-9545-10286@http.bugzilla.kernel.org/>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: bugme-daemon@bugzilla.kernel.org,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	berrange@redhat.com, Jeff Garzik <jeff@garzik.org>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	"Rafael J. Wysocki" <rjw@sisk.pl>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:33240 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751714AbXLKV2G (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Dec 2007 16:28:06 -0500
In-Reply-To: <bug-9545-10286@http.bugzilla.kernel.org/>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


(please respond via emailed reply-to-all, not via the bugzilla web
interface).

On Tue, 11 Dec 2007 11:04:55 -0800 (PST)
bugme-daemon@bugzilla.kernel.org wrote:

> http://bugzilla.kernel.org/show_bug.cgi?id=9545
> 
>            Summary: Cannot bring up a bridge interface without a MAC address
>                     set
>            Product: Networking
>            Version: 2.5
>      KernelVersion: 2.6.24-0.81.rc4.git7.fc9
>           Platform: All
>         OS/Version: Linux
>               Tree: Fedora
>             Status: NEW
>           Severity: normal
>           Priority: P1
>          Component: Other
>         AssignedTo: acme@ghostprotocols.net
>         ReportedBy: berrange@redhat.com
> 
> 
> Most recent kernel where this bug did not occur: Any 2.6.23 or earlier
> Distribution: Fedora 9 rawhide
> Hardware Environment: Intel(R) Core(TM)2 Duo CPU     E6850, x86_64
> Software Environment:  2.6.24-0.81.rc4.git7.fc9 #1 SMP  x86_64 GNU/Linux
> Problem Description:
> It is not possible to bring up a bridge interface unless one first assigns a
> MAC address to it. This is a regression from earlier kernels where one could
> always bring up a bridge device immediately after creating it. The bridge
> should not require a MAC address because it is not going to be configured with
> any IP addr - in my scenario I merely wish to use it to connect a number of
> 'tap' devices associated with KVM guests.
> 
> Steps to reproduce:
> # brctl addbr demobr
> # ifconfig demobr up
> SIOCSIFFLAGS: Invalid argument
> 
> It is failing on the ioctl to bring up the interface
> 
> ioctl(4, SIOCGIFFLAGS, {ifr_name="demobr",
> ifr_flags=IFF_BROADCAST|IFF_MULTICAST}) = 0
> ioctl(4, SIOCSIFFLAGS, 0x7fff38a6f180)  = -1 EINVAL (Invalid argument)
> 
> 
> The following Fedora kernel BZ has the original problem report:
> 
> https://bugzilla.redhat.com/bugzilla/show_bug.cgi?id=390991
> 
> The problem appears to have been introduced by this patch:
> 
> Commit bada339ba24dee9e143bfb42e1dc61f146619846
> Author: Jeff Garzik <jgarzik@redhat.com>
> Date:   Tue Oct 23 20:19:37 2007 -0700
> 
>     [NET]: Validate device addr prior to interface-up
> 
>     Signed-off-by: Jeff Garzik <jgarzik@redhat.com>
>     Signed-off-by: David S. Miller <davem@davemloft.net>
> 
> diff --git a/net/core/dev.c b/net/core/dev.c
> index 8726589..f861555 100644
> --- a/net/core/dev.c
> +++ b/net/core/dev.c
> @@ -1007,17 +1007,20 @@ int dev_open(struct net_device *dev)
>          *      Call device private open method
>          */
>         set_bit(__LINK_STATE_START, &dev->state);
> -       if (dev->open) {
> +
> +       if (dev->validate_addr)
> +               ret = dev->validate_addr(dev);
> 
> 
> 
> Which rejects MAC addresses with all 0s
> 
> Herbert Xu tells me...
> 
> "This is clearly a bug in the upstream bridge device.  It should override the
>  default address validator so that when there are no devices attached that a
>  zero MAC address is allowed."
> 

Rafael, another for the regression list please.
