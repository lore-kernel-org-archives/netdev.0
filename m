From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [Bugme-new] [Bug 34322] New: No ECN marking in IPv6
Date: Thu, 5 May 2011 14:41:46 -0700
Message-ID: <20110505144146.4bc1e744.akpm@linux-foundation.org>
References: <bug-34322-10286@https.bugzilla.kernel.org/>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: bugzilla-daemon@bugzilla.kernel.org,
	bugme-daemon@bugzilla.kernel.org, sgunderson@bigfoot.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:51627 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753252Ab1EEWnh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 May 2011 18:43:37 -0400
In-Reply-To: <bug-34322-10286@https.bugzilla.kernel.org/>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


(switched to email.  Please respond via emailed reply-to-all, not via the
bugzilla web interface).

On Tue, 3 May 2011 20:05:00 GMT
bugzilla-daemon@bugzilla.kernel.org wrote:

> https://bugzilla.kernel.org/show_bug.cgi?id=34322
> 
>            Summary: No ECN marking in IPv6
>            Product: Networking
>            Version: 2.5
>     Kernel Version: 2.6.38.4
>           Platform: All
>         OS/Version: Linux
>               Tree: Mainline
>             Status: NEW
>           Severity: normal
>           Priority: P1
>          Component: IPV6
>         AssignedTo: yoshfuji@linux-ipv6.org
>         ReportedBy: sgunderson@bigfoot.com
>         Regression: No
> 
> 
> Hi,
> 
> I'm completely unable to get ECN to work for IPv6. /proc/sys/net/ipv4/tcp_ecn
> is set to 1 on both sides, and ECN works just fine for IPv4 TCP connections,
> but when I connect over IPv6 tclass just stays at 0x0, and as far as I'd
> understood, there should be two bits here set to 10 (like in the diffserv field
> of IPv4), right?
> 
> I do get ECN-echo bits in the TCP header, though (for the initial SYN and
> SYN/ACK  packets).
> 

and

> I looked at the code, and although I don't understand all of it, it
> looks like e9df2e8fd8fbc95c57dbd1d33dada66c4627b44c (which also brought
> ECN for IPv6 SCTP) might be the culprit.  It seems like TCP_ECN_send()
> calls INET_ECN_xmit(), which only sets the ECN bit in the IPv4 ToS
> field (inet_sk(sk)->tos), but after the patch, what's checked is
> inet6_sk(sk)->tclass, which is a completely different field.
> 
> Is the analysis correct? Should the tclass be set as well?

and

> OK, as a quick hack, I did this:
> 
> --- a/linux-2.6.38.5/include/net/inet_ecn.h    2011-04-14 22:03:56.000000000+0200
> +++ b/linux-2.6.38.5/include/net/inet_ecn.h    2011-05-04 00:36:52.803377902+0200
> @@ -38,7 +38,7 @@
>      return outer;
>  }
> 
> -#define    INET_ECN_xmit(sk) do { inet_sk(sk)->tos |= INET_ECN_ECT_0; } while (0)
> +#define    INET_ECN_xmit(sk) do { inet_sk(sk)->tos |= INET_ECN_ECT_0; if (inet6_sk(sk) != NULL) inet6_sk(sk)->tclass |= INET_ECN_ECT_0; } while (0)
>  #define    INET_ECN_dontxmit(sk) \
>      do { inet_sk(sk)->tos &= ~INET_ECN_MASK; } while (0)
> 
> and now my packets are properly marked with tclass 0x02 (ie.,
> signalling ECN-capable transport, no congestion experienced yet).
> 
> I guess this isn't the right way of doing it, but at least it confirms
> that the lack of setting tclass is part of the problem.

