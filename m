From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [Bugme-new] [Bug 10371] New: On big-endian machines getsockopt
 returns 0 (via optval) for optlen==1 when returned value should 255
Date: Mon, 31 Mar 2008 11:33:49 -0700
Message-ID: <20080331113349.1c3abb48.akpm@linux-foundation.org>
References: <bug-10371-10286@http.bugzilla.kernel.org/>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: bugme-daemon@bugzilla.kernel.org, netdev@vger.kernel.org
To: M.Piechaczek@osmosys.tv
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:50914 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753263AbYCaSeB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 31 Mar 2008 14:34:01 -0400
In-Reply-To: <bug-10371-10286@http.bugzilla.kernel.org/>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 31 Mar 2008 08:16:05 -0700 (PDT) bugme-daemon@bugzilla.kernel.org wrote:

> http://bugzilla.kernel.org/show_bug.cgi?id=10371
> 
>            Summary: On big-endian machines getsockopt returns 0 (via optval)
>                     for optlen==1 when returned value should 255
>            Product: Networking
>            Version: 2.5
>      KernelVersion: 2.6.24
>           Platform: All
>         OS/Version: Linux
>               Tree: Mainline
>             Status: NEW
>           Severity: normal
>           Priority: P1
>          Component: IPV4
>         AssignedTo: shemminger@linux-foundation.org
>         ReportedBy: M.Piechaczek@osmosys.tv
> 
> 
> Latest working kernel version: 
> Earliest failing kernel version: all 2.6
> Distribution: 
> Hardware Environment: 
> Software Environment: 
> Problem Description: 
> 
> On big-endian machines getsockopt fails for optlen==1 when returned value is
> 255.
> Eg. after calling
>   unsigned char ttl = 255;
>   socklen_t     len = sizeof(ttl);
>   setsockopt(socket, IPPROTO_IP, IP_MULTICAST_TTL, &ttl, &len);
> the following call will fail:
>   getsockopt(socket, IPPROTO_IP, IP_MULTICAST_TTL, &ttl, &len);
> "ttl" returned will be 0.
> 
> 
> It's because of bug in /net/ipv4/ip_sockglue.c:
> 
>  static int do_ip_getsockopt(struct sock *sk, int level, int optname,
>                             char __user *optval, int __user *optlen) 
>  ....
>         if (len < sizeof(int) && len > 0 && val>=0 && val<255) {
>                 unsigned char ucval = (unsigned char)val;
>                 len = 1;
>                 if (put_user(len, optlen))
>                         return -EFAULT;
>                 if (copy_to_user(optval,&ucval,1))
>                         return -EFAULT;
>         } else {
>                 len = min_t(unsigned int, sizeof(int), len);
>                 if (put_user(len, optlen))
>                         return -EFAULT;
>                 if (copy_to_user(optval,&val,len))
>                         return -EFAULT;
>         }
>         return 0;
> } 
> 
> The comparision in if-statement should be:
>         if (len < sizeof(int) && len > 0 && val>=0 && val<=255)
> 
> Otherwise on big-endian machines copy_to_user(optval,&val,len) routine copies
> first (highest) byte which is 0 in that case.
> 
> 
> This bug does not occur on low-endian machines since
> copy_to_user(optval,&val,len) copies right (lowest) byte in that case.
> 

You've done all the hard work - please email us a tested patch?
