From: Patrick McHardy <kaber@trash.net>
Subject: Re: [NETFILTER]: Introduce nf_inet_address
Date: Tue, 19 Feb 2008 15:01:33 +0100
Message-ID: <47BAE13D.4060206@trash.net>
References: <200801291316.m0TDGivY024953@hera.kernel.org> <1203428949.3223.25.camel@shinybook.infradead.org>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------080103070801030409030206"
Cc: netdev@vger.kernel.org, Jan Engelhardt <jengelh@computergmbh.de>,
	"David S. Miller" <davem@davemloft.net>, varevoka@redhat.com
To: David Woodhouse <dwmw2@infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from viefep32-int.chello.at ([62.179.121.50]:44458 "EHLO
	viefep32-int.chello.at" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753054AbYBSOBu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Feb 2008 09:01:50 -0500
In-Reply-To: <1203428949.3223.25.camel@shinybook.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------080103070801030409030206
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit

David Woodhouse wrote:
>> +union nf_inet_addr {
>> +	u_int32_t	all[4];
>> +	__be32		ip;
>> +	__be32		ip6[4];
>> +};
>> +
>>  #ifdef __KERNEL__
>>  #ifdef CONFIG_NETFILTER
> 
> This breaks the busybox build:
> 
> CC      ipsvd/tcpudp.o
> In file included from /usr/include/linux/netfilter_ipv4.h:8,
>                  from ipsvd/tcpudp.c:33:
> /usr/include/linux/netfilter.h:40: error: expected specifier-qualifier-list before 'u_int32_t'
> 
> What is this 'u_int32_t' nonsense anyway?
> 
> If a user-visible header is likely to be included by libc directly from
> a 'standard' header, it may not require <stdint.h>. Therefore it should
> use the system-specific types such as '__u32'.

Right, I queued this patch to fix it.

> If it isn't likely to be included by libc, which is the case for
> netfilter, then it might as well just use the proper C types. Those who
> are stuck on C89 or earlier might still prefer to use '__u32' even when
> there's no need for it, but 'u_int32_t' is just silly. I suspect we
> should eradicate it.

Yes, some more consitency would be nice. So far the consensus was
to not use it in new code, but keep using it in subsystems like
netfilter that (almost) consistently use it everywhere.

> I couldn't make busybox work with it --
> __BIT_TYPES_DEFINED__ is defined in <sys/types.h> and prevents the
> definitions of u_int32_t et al from appearing in <linux/types.h>. And if
> I include <linux/types.h> first, other things break.
> 
> A later commit adds struct in_addr and struct in6_addr to this union
> too, which breaks busybox even harder.

Thats odd, the iptables headers have always used struct in_addr and
struct in6_addr in struct ipt_ip/struct ip6t_ip6, which are also
used by userspace. What is "ipsvd/tcpudp.c"? I couldn't find it in
the Debian busybox source.

> How is this supposed to be used in userspace? Or is it even supposed to
> be exposed?

Yes, its meant to replace many self-made "AF-independant" address
representations.

--------------080103070801030409030206
Content-Type: text/plain;
 name="x"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="x"

commit 6f2e68f81457d72bdb14a7ead305a1da06e78893
Author: Patrick McHardy <kaber@trash.net>
Date:   Tue Feb 19 14:54:36 2008 +0100

    [NETFILTER]: Use __u32 in struct nf_inet_addr
    
    As reported by David Woodhouse <dwmw2@infradead.org>, using u_int32_t in
    struct nf_inet_addr breaks the busybox build. Fix by using __u32.
    
    Signed-off-by: Patrick McHardy <kaber@trash.net>

diff --git a/include/linux/netfilter.h b/include/linux/netfilter.h
index d74e79b..b74b615 100644
--- a/include/linux/netfilter.h
+++ b/include/linux/netfilter.h
@@ -51,7 +51,7 @@ enum nf_inet_hooks {
 };
 
 union nf_inet_addr {
-	u_int32_t	all[4];
+	__u32		all[4];
 	__be32		ip;
 	__be32		ip6[4];
 	struct in_addr	in;

--------------080103070801030409030206--
