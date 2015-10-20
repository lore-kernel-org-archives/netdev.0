From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: [PATCH net-next] net: Fix vti use case with oif in dst lookups
 for IPv6
Date: Tue, 20 Oct 2015 11:48:48 -0600
Message-ID: <56267E80.5030500@cumulusnetworks.com>
References: <1444055571-82546-1-git-send-email-dsa@cumulusnetworks.com>
 <m2a8rs7crl.wl@gmail.com> <20151009071710.GJ7701@secunet.com>
 <5617F908.8060807@cumulusnetworks.com> <m21td17d5p.wl@gmail.com>
 <561A64B4.5080301@cumulusnetworks.com> <m2zizp5vqm.wl@gmail.com>
 <561AA3FA.7070001@cumulusnetworks.com> <m2lhaxoh5r.wl@gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------040803050900020707040904"
Cc: steffen.klassert@secunet.com, netdev@vger.kernel.org
To: Hajime Tazaki <thehajime@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f175.google.com ([209.85.214.175]:36270 "EHLO
	mail-ob0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752913AbbJTRs4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Oct 2015 13:48:56 -0400
Received: by obcqt19 with SMTP id qt19so20511665obc.3
        for <netdev@vger.kernel.org>; Tue, 20 Oct 2015 10:48:56 -0700 (PDT)
In-Reply-To: <m2lhaxoh5r.wl@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------040803050900020707040904
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit

On 10/20/15 6:31 AM, Hajime Tazaki wrote:
> yes, this sendmsg uses non-zero flowi6_oif.
>
>
> the conditions are
>
> - sendmsg () with INET6/RAW socket (with IPPROTO_MH)
> - ip6_pktinfo.ipi6_addr (fl6.saddr) and ipi6_oif
>    (fl6.flowi6_oif) are non-NULL.
> => ipi6_addr (fl6.saddr) is not the IP address of oif, but
>      another interfaces (home address of mip6)

interesting. so forcing a send out of interface X but using the source 
address of interface Y.

Does the attached patch work for you?

--------------040803050900020707040904
Content-Type: text/plain; charset=UTF-8; x-mac-type="0"; x-mac-creator="0";
 name="ipv6-oif-with-saddr.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename="ipv6-oif-with-saddr.patch"

diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index d0619632723a..2701cb3d88e9 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -1171,6 +1171,7 @@ struct dst_entry *ip6_route_output(struct net *net, const struct sock *sk,
 {
 	struct dst_entry *dst;
 	int flags = 0;
+	bool any_src;
 
 	dst = l3mdev_rt6_dst_by_oif(net, fl6);
 	if (dst)
@@ -1178,11 +1179,12 @@ struct dst_entry *ip6_route_output(struct net *net, const struct sock *sk,
 
 	fl6->flowi6_iif = LOOPBACK_IFINDEX;
 
+	any_src = ipv6_addr_any(&fl6->saddr);
 	if ((sk && sk->sk_bound_dev_if) || rt6_need_strict(&fl6->daddr) ||
-	    fl6->flowi6_oif)
+	    (fl6->flowi6_oif && any_src))
 		flags |= RT6_LOOKUP_F_IFACE;
 
-	if (!ipv6_addr_any(&fl6->saddr))
+	if (!any_src)
 		flags |= RT6_LOOKUP_F_HAS_SADDR;
 	else if (sk)
 		flags |= rt6_srcprefs2flags(inet6_sk(sk)->srcprefs);

--------------040803050900020707040904--
