From: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>
Subject: Re: [RFC PATCH net-next 0/7 v2]IPv6:netfilter: defragment
Date: Thu, 25 Mar 2010 11:07:55 +0100 (CET)
Message-ID: <alpine.DEB.2.00.1003251028580.21825@blackhole.kfki.hu>
References: <4B88BE30.80206@cn.fujitsu.com> <4B97D34C.4020509@gmail.com> <4B98B4FC.50904@cn.fujitsu.com> <4B9B9766.3090200@linux-ipv6.org> <4B9E5FEC.9010002@trash.net> <4BA8EC4A.9070802@linux-ipv6.org> <4BA8F75E.2040303@trash.net> <4BA90F72.6010404@linux-ipv6.org>
 <alpine.DEB.2.00.1003232050540.18241@blackhole.kfki.hu> <4BAB2121.2030503@plouf.fr.eu.org> <4BAB2954.9010608@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Pascal Hambourg <pascal.mail@plouf.fr.eu.org>,
	YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>,
	David Miller <davem@davemloft.net>,
	Alexey Dobriyan <adobriyan@gmail.com>,
	Yasuyuki KOZAKAI <yasuyuki.kozakai@toshiba.co.jp>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	netfilter-devel@vger.kernel.org
To: Shan Wei <shanwei@cn.fujitsu.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <4BAB2954.9010608@cn.fujitsu.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 25 Mar 2010, Shan Wei wrote:

> Pascal Hambourg wrote, at 03/25/2010 04:38 PM:
> > 
> > Jozsef Kadlecsik a ?crit :
> >> On Wed, 24 Mar 2010, YOSHIFUJI Hideaki wrote:
> >>
> >>>> In this case without conntrack, IPv6 would send an ICMPv6 message,
> >>>> so in my opinion the transparent thing to do would be to still send
> >>>> them. Of course only if reassembly is done on an end host.
> >>> Well, no.  conntrack should just forward even uncompleted fragments
> >>> to next process (e.g. core ipv6 code), and then the core would send
> >>> ICMP error back.  ICMP should be sent by the core ipv6 code according
> >>> to decision of itself, not according to netfilter.
> >> But what state could be associated by conntrack to the uncompleted 
> >> fragments but the INVALID state? In consequence, in any sane setup, the 
> >> uncompleted fragments will be dropped silently by a filter table rule
> >> and no ICMP error message will be sent back.
> > 
> > AFAIK, in the IPv4 stack the reassembly takes place before the INPUT
> > chains (NF_IP_LOCAL_IN hook). Is it different in the IPv6 stack ?
> 
> Yes, they are different.
> 
> In IPv4 stack?for an end host, ip_local_deliver() reassemble 
> fragments before LOCAL_IN hook .
> 
> But in IPv6 stack, ip6_input_finish() handles fragment extension headers
> and try to reassemble them *after* LOCAL_IN hook.

But we are discussing netfilter and (de)fragmentation: what should happen 
when the packet reassembly in netfilter times out and the destination is 
the host itself.

In IPv4 the very first subsystem is ipv4_conntrack_defrag, called from 
NF_INET_PRE_ROUTING. Then comes the raw table and after that conntrack.

In IPv6 the very first is the raw table, then comes ipv6_defrag and then 
conntrack.

Why the order of the raw table and defragmentation is reversed for IPv6?

That makes impossible to use the NOTRACK target in IPv6: for example if 
someone enters

ip6tables -t raw -A PREROUTING -p tcp --dport 80 -j NOTRACK

and if we receive fragmented packets then the first fragment will be 
untracked and thus skip nf_ct_frag6_gather (and conntrack), while all 
subsequent fragments enter nf_ct_frag6_gather and reassembly will never 
successfully be finished.

IMHO this is a bug and should be fixed. Patrick, please consider applying 
the patch below.

Singed-off-by: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>

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
index ed1a118..3d8c6f0 100644
--- a/net/ipv6/netfilter/ip6table_raw.c
+++ b/net/ipv6/netfilter/ip6table_raw.c
@@ -70,14 +70,14 @@ static struct nf_hook_ops ip6t_ops[] __read_mostly = {
 	  .hook = ip6t_pre_routing_hook,
 	  .pf = NFPROTO_IPV6,
 	  .hooknum = NF_INET_PRE_ROUTING,
-	  .priority = NF_IP6_PRI_FIRST,
+	  .priority = NF_IP6_PRI_RAW,
 	  .owner = THIS_MODULE,
 	},
 	{
 	  .hook = ip6t_local_out_hook,
 	  .pf = NFPROTO_IPV6,
 	  .hooknum = NF_INET_LOCAL_OUT,
-	  .priority = NF_IP6_PRI_FIRST,
+	  .priority = NF_IP6_PRI_RAW,
 	  .owner = THIS_MODULE,
 	},
 };


Best regards,
Jozsef
-
E-mail  : kadlec@blackhole.kfki.hu, kadlec@mail.kfki.hu
PGP key : http://www.kfki.hu/~kadlec/pgp_public_key.txt
Address : KFKI Research Institute for Particle and Nuclear Physics
          H-1525 Budapest 114, POB. 49, Hungary
