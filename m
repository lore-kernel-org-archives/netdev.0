From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [Bugme-new] [Bug 10880] New: include/linux/if_addr.h: negative
 preferred lifetimes of addresses
Date: Sat, 7 Jun 2008 12:01:51 -0700
Message-ID: <20080607120151.72c0f53b.akpm@linux-foundation.org>
References: <bug-10880-10286@http.bugzilla.kernel.org/>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: bugme-daemon@bugzilla.kernel.org, benedikt@gollatz.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:59355 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932093AbYFGTB5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 7 Jun 2008 15:01:57 -0400
In-Reply-To: <bug-10880-10286@http.bugzilla.kernel.org/>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat,  7 Jun 2008 03:04:43 -0700 (PDT) bugme-daemon@bugzilla.kernel.org wrote:

> http://bugzilla.kernel.org/show_bug.cgi?id=10880
> 
>            Summary: include/linux/if_addr.h: negative preferred lifetimes of
>                     addresses
>            Product: Networking
>            Version: 2.5
>      KernelVersion: 2.6.25.4
>           Platform: All
>         OS/Version: Linux
>               Tree: Mainline
>             Status: NEW
>           Severity: normal
>           Priority: P1
>          Component: IPV6
>         AssignedTo: yoshfuji@linux-ipv6.org
>         ReportedBy: benedikt@gollatz.net
> 
> 
> Recently, I noticed that iproute2 would return me preferred lifetimes of IPv6
> adresses close to 2^32 on links where prefixes are advertised with a preferred
> lifetime of 0. A quick look into the source revealed that the preferred
> lifetime is output using a format string containing "%u"; the incriminating
> lines being
> 
>   struct ifa_cacheinfo *ci = RTA_DATA(rta_tb[IFA_CACHEINFO]);
>   char buf[128];
>   fprintf(fp, "%s", _SL_);
>   [...]
>   if (ci->ifa_prefered == INFINITY_LIFE_TIME)
>        sprintf(buf+strlen(buf), " preferred_lft forever");
>   else
>        sprintf(buf+strlen(buf), " preferred_lft %usec",
>                ci->ifa_prefered);
>   fprintf(fp, "       %s", buf);
> 
> When calling iproute2 oftenly shortly after a prefix has been advertised on the
> link, one could see that there actually was an integer underflow going on (the
> output changed from "0" to "forever" to 2^32-1).
> 
> Interestringly, if_addr.h does define ifa_prefered to be a __u32, so iproute2
> merely implements the interface. RFC4862 mandates that the preferred lifetime
> always is lower than or equal to the valid lifetime, which is also defined to
> be a __u32.
> 
> I'm certainly no expert in the linux kernel code, but this looks like a bug to
> me. Why is ifa_prefered defined to be non-negative?
> 
> Benedikt
> 
> 
> -- 
> Configure bugmail: http://bugzilla.kernel.org/userprefs.cgi?tab=email
> ------- You are receiving this mail because: -------
> You are on the CC list for the bug, or are watching someone who is.
