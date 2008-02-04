From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [Bugme-new] [Bug 9888] New: tun device without protocol info
 header fails under IPv6
Date: Mon, 4 Feb 2008 14:53:04 -0800
Message-ID: <20080204145304.f4921bf4.akpm@linux-foundation.org>
References: <bug-9888-10286@http.bugzilla.kernel.org/>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: bugme-daemon@bugzilla.kernel.org, netdev@vger.kernel.org,
	maxk@qualcomm.com
To: steve.zabele@baesystems.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:37725 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753670AbYBDWxS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Feb 2008 17:53:18 -0500
In-Reply-To: <bug-9888-10286@http.bugzilla.kernel.org/>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon,  4 Feb 2008 13:46:13 -0800 (PST)
bugme-daemon@bugzilla.kernel.org wrote:

> http://bugzilla.kernel.org/show_bug.cgi?id=9888
> 
>            Summary: tun device without protocol info header fails under IPv6
>            Product: Networking
>            Version: 2.5
>      KernelVersion: >=2.6.23
>           Platform: All
>         OS/Version: Linux
>               Tree: Mainline
>             Status: NEW
>           Severity: low
>           Priority: P1
>          Component: IPV6
>         AssignedTo: yoshfuji@linux-ipv6.org
>         ReportedBy: steve.zabele@baesystems.com
> 
> 
> Latest working kernel version: None known -- appears to be a historic bug
> Earliest failing kernel version: All
> Distribution:
> Hardware Environment:
> Software Environment:
> Problem Description:
> 
> Steps to reproduce: 
> 
> Open a tun device as type TUN, set the TUN_NO_PI flag, and try sending an IPv6
> packet. The packet appears at the interface under tcpdumps, but propagates no
> further. This is because the default protocol info used for tun devices where
> the TUN_NO_PI flag is set assumes IPv4 as can be seen by the initialization at
> the top of the tun_get_user function in drivers/net/tun.c file given by
> 
>         struct tun_pi pi = { 0, __constant_htons(ETH_P_IP) };
> 
> This can easily be fixed by adding a quick check at the top of tun_get_user.
> Basically the code that used to read
> 
>         if (!(tun->flags & TUN_NO_PI)) {
>                 if ((len -= sizeof(pi)) > count)
>                         return -EINVAL;
> 
>                 if(memcpy_fromiovec((void *)&pi, iv, sizeof(pi)))
>                         return -EFAULT;
>         }
> 
> when changed to read
> 
>         if (!(tun->flags & TUN_NO_PI)) {
>                 if ((len -= sizeof(pi)) > count)
>                         return -EINVAL;
> 
>                 if(memcpy_fromiovec((void *)&pi, iv, sizeof(pi)))
>                         return -EFAULT;
>         }
>         else {
>           /* Fixup default pi if IPv6 rather than IPv4 */
>           if (((tun->flags & TUN_TYPE_MASK) == TUN_TUN_DEV) &&
>               (*(char *)(iv->iov_base)      == 0x60)) {
>             pi.proto = __constant_htons(ETH_P_IPV6);
>           }
>         }
> 
> fixes the problem. 
> 
> How do we get this in as part of the maintained codebase??
> 

Please email a tested patch prepared as described in

	Documentation/SubmittingPatches
	Documentation/SubmitChecklist
	http://www.zip.com.au/~akpm/linux/patches/stuff/tpp.txt

to

	Maxim Krasnyansky <maxk@qualcomm.com>
	"David S. Miller" <davem@davemloft.net>
	Andrew Morton <akpm@linux-foundation.org>
	netdev@vger.kernel.org

thanks.
