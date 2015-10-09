From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: [PATCH net-next] net: Fix vti use case with oif in dst lookups
 for IPv6
Date: Fri, 9 Oct 2015 11:27:36 -0600
Message-ID: <5617F908.8060807@cumulusnetworks.com>
References: <1444055571-82546-1-git-send-email-dsa@cumulusnetworks.com>
 <m2a8rs7crl.wl@gmail.com> <20151009071710.GJ7701@secunet.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------010708020407070209040908"
Cc: netdev@vger.kernel.org
To: Steffen Klassert <steffen.klassert@secunet.com>,
	Hajime Tazaki <thehajime@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f45.google.com ([209.85.220.45]:34393 "EHLO
	mail-pa0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752824AbbJIR1b (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Oct 2015 13:27:31 -0400
Received: by padhy16 with SMTP id hy16so91953165pad.1
        for <netdev@vger.kernel.org>; Fri, 09 Oct 2015 10:27:31 -0700 (PDT)
In-Reply-To: <20151009071710.GJ7701@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------010708020407070209040908
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit

On 10/9/15 1:17 AM, Steffen Klassert wrote:
>>> diff --git a/net/ipv6/xfrm6_policy.c b/net/ipv6/xfrm6_policy.c
>>> index 30caa289c5db..5cedfda4b241 100644
>>> --- a/net/ipv6/xfrm6_policy.c
>>> +++ b/net/ipv6/xfrm6_policy.c
>>> @@ -37,6 +37,7 @@ static struct dst_entry *xfrm6_dst_lookup(struct net *net, int tos, int oif,
>>>
>>>   	memset(&fl6, 0, sizeof(fl6));
>>>   	fl6.flowi6_oif = oif;
>>> +	fl6.flowi6_flags = FLOWI_FLAG_SKIP_NH_OIF;
>>>   	memcpy(&fl6.daddr, daddr, sizeof(fl6.daddr));
>>>   	if (saddr)
>>>   		memcpy(&fl6.saddr, saddr, sizeof(fl6.saddr));
>>
>> I found that this fix is still not sufficient with the mip6
>> (Mobile IPv6) use case.
>
> It does not even fix the vti case. The behaviour of the vti devices is
> the same, with and without the patch.
>

The attached patch applied to Linus' tree works for me. Currently the 
above change is not in his tree, so I added it to this patch. Once you 
confirm that it works for you I'll create the delta-patch for net and 
send out.

Thanks,
David

--------------010708020407070209040908
Content-Type: text/plain; charset=UTF-8; x-mac-type="0"; x-mac-creator="0";
 name="really-fix-vti6-with-oif.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename="really-fix-vti6-with-oif.patch"

diff --git a/net/ipv6/ip6_output.c b/net/ipv6/ip6_output.c
index 92b1aa38f121..2dbd73014a1b 100644
--- a/net/ipv6/ip6_output.c
+++ b/net/ipv6/ip6_output.c
@@ -874,7 +874,8 @@ static struct dst_entry *ip6_sk_dst_check(struct sock *sk,
 #ifdef CONFIG_IPV6_SUBTREES
 	    ip6_rt_check(&rt->rt6i_src, &fl6->saddr, np->saddr_cache) ||
 #endif
-	    (fl6->flowi6_oif && fl6->flowi6_oif != dst->dev->ifindex)) {
+	   (!(fl6->flowi6_flags & FLOWI_FLAG_SKIP_NH_OIF) &&
+	      (fl6->flowi6_oif && fl6->flowi6_oif != dst->dev->ifindex))) {
 		dst_release(dst);
 		dst = NULL;
 	}
diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index cb32ce250db0..df24cff4a0cb 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -1068,6 +1068,9 @@ static struct rt6_info *ip6_pol_route(struct net *net, struct fib6_table *table,
 	fn = fib6_lookup(&table->tb6_root, &fl6->daddr, &fl6->saddr);
 	saved_fn = fn;
 
+	if (fl6->flowi6_flags & FLOWI_FLAG_SKIP_NH_OIF)
+		oif = 0;
+
 redo_rt6_select:
 	rt = rt6_select(fn, oif, strict);
 	if (rt->rt6i_nsiblings)
diff --git a/net/ipv6/xfrm6_policy.c b/net/ipv6/xfrm6_policy.c
index 30caa289c5db..5cedfda4b241 100644
--- a/net/ipv6/xfrm6_policy.c
+++ b/net/ipv6/xfrm6_policy.c
@@ -37,6 +37,7 @@ static struct dst_entry *xfrm6_dst_lookup(struct net *net, int tos, int oif,
 
 	memset(&fl6, 0, sizeof(fl6));
 	fl6.flowi6_oif = oif;
+	fl6.flowi6_flags = FLOWI_FLAG_SKIP_NH_OIF;
 	memcpy(&fl6.daddr, daddr, sizeof(fl6.daddr));
 	if (saddr)
 		memcpy(&fl6.saddr, saddr, sizeof(fl6.saddr));

--------------010708020407070209040908--
