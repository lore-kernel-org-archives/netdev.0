From: Fan Du <fan.du@windriver.com>
Subject: Re: [PATCH net-next v3] net: split rt_genid for ipv4 and ipv6
Date: Fri, 26 Jul 2013 13:49:35 +0800
Message-ID: <51F20DEF.2090108@windriver.com>
References: <1374745632-1624-1-git-send-email-fan.du@windriver.com> <20130725181314.GA24007@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <davem@davemloft.net>, <yoshfuji@linux-ipv6.org>,
	<jmorris@namei.org>, <steffen.klassert@secunet.com>,
	netdev <netdev@vger.kernel.org>
To: <nicolas.dichtel@6wind.com>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:33573 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751404Ab3GZFtg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Jul 2013 01:49:36 -0400
In-Reply-To: <20130725181314.GA24007@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 2013=E5=B9=B407=E6=9C=8826=E6=97=A5 02:13, Hannes Frederic Sowa wrot=
e:
> On Thu, Jul 25, 2013 at 05:47:12PM +0800, Fan Du wrote:
>> +/* For callers who don't really care about whether it's IPv4 or IPv=
6 */
>> +static inline void rt_genid_bump_all(struct net *net)
>> +{
>> +	atomic_inc(&net->ipv4.rt_genid);
>> +#if IS_ENABLED(CONFIG_IPV6)
>> +	atomic_inc(&net->ipv6.rt_genid);
>> +#endif
>
> You could get away with the ifdef if you just do
> 	rt_genid_bump_ipv4(net);
> 	rt_genid_bump_ipv6(net);

Ok, will fix this.

>
> Somewhere something does break selinux:
>
>    CC      security/selinux/hooks.o
> In file included from security/selinux/hooks.c:93:0:
> security/selinux/include/xfrm.h: In function =E2=80=98selinux_xfrm_no=
tify_policyload=E2=80=99:
> security/selinux/include/xfrm.h:54:2: error: implicit declaration of =
function =E2=80=98rt_genid_bump=E2=80=99 [-Werror=3Dimplicit-function-d=
eclaration]
>    rt_genid_bump(&init_net);
>    ^
> Seems like you have overlooked the rt_genid_bump in
> security/selinux/include/xfrm.h, which should be a rt_genid_bump_all
>

Thanks for report this, my side CONFIG_SECURITY_NETWORK_XFRM is not set=
 before. :(


> Off-topic:
> Is it correct that selinux_xfrm_notify_policyload only bumps genid fo=
r
> init_net?
>

This was introduced in ee8372dd1989287c5eedb69d44bac43f69e496f1
"xfrm: invalidate dst on policy insertion/deletion" by Nicolas.

I take a look at SELINUX xfrm part, my limited understanding SELINUX XF=
RM rule
should take global effect on all net name space in current implementati=
on.

diff --git a/security/selinux/include/xfrm.h b/security/selinux/include=
/xfrm.h
index 65f67cb..4f72d2c 100644
--- a/security/selinux/include/xfrm.h
+++ b/security/selinux/include/xfrm.h
@@ -50,8 +50,14 @@ int selinux_xfrm_decode_session(struct sk_buff *skb,=
 u32 *sid, int ckall);

  static inline void selinux_xfrm_notify_policyload(void)
  {
+       struct net *net;
+
         atomic_inc(&flow_cache_genid);
-       rt_genid_bump(&init_net);
+       rtnl_lock();
+       for_each_net(net) {
+               rt_genid_bump_all(net);
+       }
+       rtnl_unlock();
  }
  #else
  static inline int selinux_xfrm_enabled(void)


Let me know if I miss something inside it. Thanks.


> Otherwise I don't see any problems arising from this patch because of
> the rt_genid split.
>
> Greetings,
>
>    Hannes
>
>

--=20
=E6=B5=AE=E6=B2=89=E9=9A=8F=E6=B5=AA=E5=8F=AA=E8=AE=B0=E4=BB=8A=E6=9C=9D=
=E7=AC=91

--fan
