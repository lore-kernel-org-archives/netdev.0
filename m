From: liusdu <liusdu@126.com>
Subject: Re: [PATCH] netfilter: fix dependency issues between IPv6 defragmentation
 and ip6tables
Date: Sun, 03 May 2015 22:18:26 +0800
Message-ID: <55462E32.2060806@126.com>
References: <1430646618-7625-1-git-send-email-sdu.liu@huawei.com> <20150503110715.GE22481@breakpoint.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, kadlec@blackhole.kfki.hu, kaber@trash.net,
	pablo@netfilter.org, netfilter-devel@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Florian Westphal <fw@strlen.de>, Liu Hua <sdu.liu@huawei.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from m50-111.126.com ([123.125.50.111]:34625 "EHLO m50-111.126.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751060AbbECOTD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 3 May 2015 10:19:03 -0400
In-Reply-To: <20150503110715.GE22481@breakpoint.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On 2015=E5=B9=B405=E6=9C=8803=E6=97=A5 19:07, Florian Westphal wrote:
> Liu Hua <sdu.liu@huawei.com> wrote:
>> commit f6318e558806c925029dc101f14874be9f9fa78f fix some related iss=
ue
>> when ip6tables is enabled. But when IP6_NF_IPTABLES is disabled and
>> NETFILTER_XT_TARGET_TPROXY is enabled. We will meet build failure wi=
th
>> "net/built-in.o: In function `tproxy_tg_init':
>> net/netfilter/xt_TPROXY.c:588: undefined reference to `nf_defrag_ipv=
6_enable'
>> "
>> So this patch change the Kconfig as ipv4 does.
>> --- a/net/netfilter/Kconfig
>> +++ b/net/netfilter/Kconfig
>> @@ -865,7 +865,7 @@ config NETFILTER_XT_TARGET_TPROXY
>>   	depends on (IPV6 || IPV6=3Dn)
>>   	depends on IP_NF_MANGLE
>>   	select NF_DEFRAG_IPV4
>> -	select NF_DEFRAG_IPV6 if IP6_NF_IPTABLES
>> +	select NF_DEFRAG_IPV6
> IP6_NF_IPTABLES
> If IP6_NF_IPTABLES is not set, why would we have to pick
> up IPV6 defragmentation?
>
> Without ip6tables, TPROXY cannot be used for ipv6; in fact;
> xt_TPROXY should be built without ipv6 support in this case.
>
> My guess is that you have TPROXY=3Dy but DEFRAG_IPV6=3Dm, but that
> might warrant a better fix (xt_socket seems to have same issue).
Hi Florian,

Yes, It was exactly what I did.  Actually there is a macro to
determine whether we compile nf_defrag_ipv6_enable or not,
called XT_TPROXY_HAVE_IPV6, which will be set to 1 while
IP6_NF_IPTABLES=3Dy or m.  With the patch below  we can
make the compiling pass. But I am not sure it is good enough
or not.

diff --git a/net/netfilter/xt_TPROXY.c b/net/netfilter/xt_TPROXY.c
index cca96ce..abbda64 100644
--- a/net/netfilter/xt_TPROXY.c
+++ b/net/netfilter/xt_TPROXY.c
@@ -24,7 +24,7 @@

  #include <net/netfilter/ipv4/nf_defrag_ipv4.h>

-#if IS_ENABLED(CONFIG_IP6_NF_IPTABLES)
+#if IS_BUILTIN(CONFIG_IP6_NF_IPTABLES)
  #define XT_TPROXY_HAVE_IPV6 1
  #include <net/if_inet6.h>
  #include <net/addrconf.h>
diff --git a/net/netfilter/xt_socket.c b/net/netfilter/xt_socket.c
index e092cb0..239fccf 100644
--- a/net/netfilter/xt_socket.c
+++ b/net/netfilter/xt_socket.c
@@ -21,7 +21,7 @@
  #include <net/inet_sock.h>
  #include <net/netfilter/ipv4/nf_defrag_ipv4.h>

-#if IS_ENABLED(CONFIG_IP6_NF_IPTABLES)
+#if IS_BUILTIN(CONFIG_IP6_NF_IPTABLES)
  #define XT_SOCKET_HAVE_IPV6 1
  #include <linux/netfilter_ipv6/ip6_tables.h>
  #include <net/inet6_hashtables.h>
