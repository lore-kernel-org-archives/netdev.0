From: Fan Du <fan.du@windriver.com>
Subject: Re: [DISCUSSION] rt6i_genid
Date: Thu, 18 Jul 2013 17:28:02 +0800
Message-ID: <51E7B522.4070105@windriver.com>
References: <51E75F82.4080300@windriver.com> <51E7B1B0.3000109@6wind.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>
To: <nicolas.dichtel@6wind.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail1.windriver.com ([147.11.146.13]:33352 "EHLO
	mail1.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751646Ab3GRJ1q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Jul 2013 05:27:46 -0400
In-Reply-To: <51E7B1B0.3000109@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Thanks for replying :)

On 2013=E5=B9=B407=E6=9C=8818=E6=97=A5 17:13, Nicolas Dichtel wrote:
> Le 18/07/2013 05:22, Fan Du a =C3=A9crit :
>> Hello Nicolas
>>
>> Commit 6f3118b571b8a4c06c7985dc3172c3526cb86253: "ipv6: use net->rt_=
genid to
>> check dst validity"
>> makes ip6_dst_check to check rt6i_genid against with struct net->rt_=
genid,
>> As a matter of fact, struct net->rt_genid could only be modified by =
two places,
>> first is adding/delete IPv4 address, second is inserting new XFRM po=
licy.
>>
>> Is there any other considerations that adding/deleting IPv4 address =
would
>> invalid all IPv6 dst
>> as well? because I'm working a patch which actually depends on the r=
esult of
>> this question.
> No, the goal was to cover the IPsec case, ie invalidate dst entries w=
hen an xfrm policy is inserted/deleted.

Ok, then how about we only checking rt6i_genid against rt_genid *only*
when XFRM is enabled for IPv6, because when XFRM is not enabled for IPv=
6
ip6_dst_check for rt_genid is really not necessary.

So what do you think of below modifications?

diff --git a/include/net/ip6_fib.h b/include/net/ip6_fib.h
index 2a601e7..4ae35fd 100644
--- a/include/net/ip6_fib.h
+++ b/include/net/ip6_fib.h
@@ -119,7 +119,9 @@ struct rt6_info {
         struct inet6_dev                *rt6i_idev;
         unsigned long                   _rt6i_peer;

+#ifdef CONFIG_XFRM
         u32                             rt6i_genid;
+#endif

         /* more non-fragment space at head required */
         unsigned short                  rt6i_nfheader_len;
diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index bd5fd70..1b64406 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -277,7 +277,9 @@ static inline struct rt6_info *ip6_dst_alloc(struct=
 net *net,

                 memset(dst + 1, 0, sizeof(*rt) - sizeof(*dst));
                 rt6_init_peer(rt, table ? &table->tb6_peers : net->ipv=
6.peers);
+#ifdef CONFIG_XFRM
                 rt->rt6i_genid =3D rt_genid(net);
+#endif
                 INIT_LIST_HEAD(&rt->rt6i_siblings);
                 rt->rt6i_nsiblings =3D 0;
         }
@@ -1041,12 +1043,15 @@ static struct dst_entry *ip6_dst_check(struct d=
st_entry *dst, u32 cookie)

         rt =3D (struct rt6_info *) dst;

+#ifdef CONFIG_XFRM
         /* All IPV6 dsts are created with ->obsolete set to the value
          * DST_OBSOLETE_FORCE_CHK which forces validation calls down
          * into this function always.
+        * Note: for IPv6, rt6i_genid is noly used when XFRM enabled.
          */
         if (rt->rt6i_genid !=3D rt_genid(dev_net(rt->dst.dev)))
                 return NULL;
+#endif

         if (rt->rt6i_node && (rt->rt6i_node->fn_sernum =3D=3D cookie))
                 return dst;








>
> Regards,
> Nicolas
>

--=20
=E6=B5=AE=E6=B2=89=E9=9A=8F=E6=B5=AA=E5=8F=AA=E8=AE=B0=E4=BB=8A=E6=9C=9D=
=E7=AC=91

--fan
