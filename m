From: Patrick McHardy <kaber@trash.net>
Subject: Re: [RFC PATCH net-next 0/7 v2]IPv6:netfilter: defragment
Date: Thu, 25 Mar 2010 11:20:20 +0100
Message-ID: <4BAB38E4.7050706@trash.net>
References: <4B88BE30.80206@cn.fujitsu.com> <4B97D34C.4020509@gmail.com> <4B98B4FC.50904@cn.fujitsu.com> <4B9B9766.3090200@linux-ipv6.org> <4B9E5FEC.9010002@trash.net> <4BA8EC4A.9070802@linux-ipv6.org> <4BA8F75E.2040303@trash.net> <4BA90F72.6010404@linux-ipv6.org> <alpine.DEB.2.00.1003232050540.18241@blackhole.kfki.hu> <4BAB2121.2030503@plouf.fr.eu.org> <4BAB2954.9010608@cn.fujitsu.com> <alpine.DEB.2.00.1003251028580.21825@blackhole.kfki.hu>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------080304020808010602060808"
Cc: Shan Wei <shanwei@cn.fujitsu.com>,
	Pascal Hambourg <pascal.mail@plouf.fr.eu.org>,
	YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>,
	David Miller <davem@davemloft.net>,
	Alexey Dobriyan <adobriyan@gmail.com>,
	Yasuyuki KOZAKAI <yasuyuki.kozakai@toshiba.co.jp>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	netfilter-devel@vger.kernel.org
To: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:48391 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753781Ab0CYKUV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Mar 2010 06:20:21 -0400
In-Reply-To: <alpine.DEB.2.00.1003251028580.21825@blackhole.kfki.hu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------080304020808010602060808
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit

Jozsef Kadlecsik wrote:
> Why the order of the raw table and defragmentation is reversed for IPv6?
> 
> That makes impossible to use the NOTRACK target in IPv6: for example if 
> someone enters
> 
> ip6tables -t raw -A PREROUTING -p tcp --dport 80 -j NOTRACK
> 
> and if we receive fragmented packets then the first fragment will be 
> untracked and thus skip nf_ct_frag6_gather (and conntrack), while all 
> subsequent fragments enter nf_ct_frag6_gather and reassembly will never 
> successfully be finished.
> 
> IMHO this is a bug and should be fixed. Patrick, please consider applying 
> the patch below.

Indeed. I've applied your patch with a minor fixup (attached) to
apply cleanly to the current tree, thanks.


--------------080304020808010602060808
Content-Type: text/plain;
 name="x"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="x"

commit 9c13886665c43600bd0af4b38e33c654e648e078
Author: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>
Date:   Thu Mar 25 11:17:26 2010 +0100

    netfilter: ip6table_raw: fix table priority
    
    The order of the IPv6 raw table is currently reversed, that makes impossible
    to use the NOTRACK target in IPv6: for example if someone enters
    
    ip6tables -t raw -A PREROUTING -p tcp --dport 80 -j NOTRACK
    
    and if we receive fragmented packets then the first fragment will be
    untracked and thus skip nf_ct_frag6_gather (and conntrack), while all
    subsequent fragments enter nf_ct_frag6_gather and reassembly will never
    successfully be finished.
    
    Singed-off-by: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>
    Signed-off-by: Patrick McHardy <kaber@trash.net>

diff --git a/include/linux/netfilter_ipv6.h b/include/linux/netfilter_ipv6.h
index d654873..1f7e300 100644
--- a/include/linux/netfilter_ipv6.h
+++ b/include/linux/netfilter_ipv6.h
@@ -59,6 +59,7 @@
 enum nf_ip6_hook_priorities {
 	NF_IP6_PRI_FIRST = INT_MIN,
 	NF_IP6_PRI_CONNTRACK_DEFRAG = -400,
+	NF_IP6_PRI_RAW = -300,
 	NF_IP6_PRI_SELINUX_FIRST = -225,
 	NF_IP6_PRI_CONNTRACK = -200,
 	NF_IP6_PRI_MANGLE = -150,
diff --git a/net/ipv6/netfilter/ip6table_raw.c b/net/ipv6/netfilter/ip6table_raw.c
index aef31a2..b9cf7cd 100644
--- a/net/ipv6/netfilter/ip6table_raw.c
+++ b/net/ipv6/netfilter/ip6table_raw.c
@@ -13,7 +13,7 @@ static const struct xt_table packet_raw = {
 	.valid_hooks = RAW_VALID_HOOKS,
 	.me = THIS_MODULE,
 	.af = NFPROTO_IPV6,
-	.priority = NF_IP6_PRI_FIRST,
+	.priority = NF_IP6_PRI_RAW,
 };
 
 /* The work comes in here from netfilter.c. */

--------------080304020808010602060808--
