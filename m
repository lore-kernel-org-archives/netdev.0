From: Ursula Braun <ubraun@linux.vnet.ibm.com>
Subject: Re: [PATCH] qeth: Move away from using neighbour entries in
 qeth_l3_fill_header()
Date: Thu, 02 Feb 2012 14:44:51 +0100
Message-ID: <1328190291.15969.3.camel@br9gv9yg.de.ibm.com>
References: <OF3D0DFDEF.D4DC17E5-ONC1257998.00496C84-C1257998.0049A282@de.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Ursula Braun1 <ursula.braun@de.ibm.com>, netdev@vger.kernel.org,
	elelueck@de.ibm.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from e06smtp15.uk.ibm.com ([195.75.94.111]:54159 "EHLO
	e06smtp15.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753376Ab2BBNpZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Feb 2012 08:45:25 -0500
Received: from /spool/local
	by e06smtp15.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <ubraun@linux.vnet.ibm.com>;
	Thu, 2 Feb 2012 13:45:19 -0000
Received: from d06av05.portsmouth.uk.ibm.com (d06av05.portsmouth.uk.ibm.com [9.149.37.229])
	by d06nrmr1407.portsmouth.uk.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q12DiqZI2228230
	for <netdev@vger.kernel.org>; Thu, 2 Feb 2012 13:44:52 GMT
Received: from d06av05.portsmouth.uk.ibm.com (loopback [127.0.0.1])
	by d06av05.portsmouth.uk.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q12Diq8d003339
	for <netdev@vger.kernel.org>; Thu, 2 Feb 2012 06:44:52 -0700
In-Reply-To: <OF3D0DFDEF.D4DC17E5-ONC1257998.00496C84-C1257998.0049A282@de.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Dave,

I have tested your qeth patch on top of net-next with ipv4 and ipv6
traffic successfully. I just had to add includes for net/route.h and
net/ip6_fib.h.

Regards, Ursula Braun, IBM Germany, Linux on System z development

> From:
> David Miller <davem@davemloft.net>
> To:
> Einar EL Lueck/Germany/IBM@IBMDE
> Cc:
> Ursula Braun1/Germany/IBM@IBMDE, netdev@vger.kernel.org
> Date:
> 01/02/2012 21:49
> Subject:
> [PATCH] qeth: Move away from using neighbour entries in 
> qeth_l3_fill_header()
> 
> 
> 
> 
> We've moving to a model where dst_entry objects to not have
> a reference to the associated neighbour entry, instead such
> neighbours must be looked up on-demand.
> 
> Here in qeth_l3_fill_header() it's actually much simpler to
> use the information in the route itself.  The code is
> already conditionalized upon protocol type.
> 
> Signed-off-by: David S. Miller <davem@davemloft.net>
> --
> If one of you could test this against net-next, I'd appreciate
> it.  I plan to make similar changes to the other dst_get_neighbour*()
> call in this driver.
> 
> Thanks!
> 
> diff --git a/drivers/s390/net/qeth_l3_main.c 
> b/drivers/s390/net/qeth_l3_main.c
> index 9648e4e..6d95c38 100644
> --- a/drivers/s390/net/qeth_l3_main.c
> +++ b/drivers/s390/net/qeth_l3_main.c
> @@ -2832,7 +2832,6 @@ static void qeth_l3_fill_af_iucv_hdr(struct 
> qeth_card *card,
>  static void qeth_l3_fill_header(struct qeth_card *card, struct qeth_hdr 
> *hdr,
>                                  struct sk_buff *skb, int ipv, int 
> cast_type)
>  {
> -                struct neighbour *n = NULL;
>                  struct dst_entry *dst;
> 
>                  memset(hdr, 0, sizeof(struct qeth_hdr));
> @@ -2855,33 +2854,29 @@ static void qeth_l3_fill_header(struct qeth_card 
> *card, struct qeth_hdr *hdr,
> 
>                  rcu_read_lock();
>                  dst = skb_dst(skb);
> -                if (dst)
> -                                n = dst_get_neighbour_noref(dst);
>                  if (ipv == 4) {
> +                                struct rtable *rt = (struct rtable *) 
> dst;
> +                                __be32 *pkey = &ip_hdr(skb)->daddr;
> +
> +                                if (rt->rt_gateway)
> +                                                pkey = &rt->rt_gateway;
> +
>                                  /* IPv4 */
>                                  hdr->hdr.l3.flags = 
> qeth_l3_get_qeth_hdr_flags4(cast_type);
>                                  memset(hdr->hdr.l3.dest_addr, 0, 12);
> -                                if (n) {
> -                                                *((u32 *) 
> (&hdr->hdr.l3.dest_addr[12])) =
> -                                                    *((u32 *) 
> n->primary_key);
> -                                } else {
> -                                                /* fill in destination 
> address used in ip header */
> -                                                *((u32 *) 
> (&hdr->hdr.l3.dest_addr[12])) =
> -                                ip_hdr(skb)->daddr;
> -                                }
> +                                *((__be32 *) 
> (&hdr->hdr.l3.dest_addr[12])) = *pkey;
>                  } else if (ipv == 6) {
> +                                struct rt6_info *rt = (struct rt6_info *) 
> dst;
> +                                struct in6_addr *pkey = 
> &ipv6_hdr(skb)->daddr;
> +
> +                                if (!ipv6_addr_any(&rt->rt6i_gateway))
> +                                                pkey = &rt->rt6i_gateway;
> +
>                                  /* IPv6 */
>                                  hdr->hdr.l3.flags = 
> qeth_l3_get_qeth_hdr_flags6(cast_type);
>                                  if (card->info.type == 
> QETH_CARD_TYPE_IQD)
>                                                  hdr->hdr.l3.flags &= 
> ~QETH_HDR_PASSTHRU;
> -                                if (n) {
> - memcpy(hdr->hdr.l3.dest_addr,
> -                                                       n->primary_key, 
> 16);
> -                                } else {
> -                                                /* fill in destination 
> address used in ip header */
> - memcpy(hdr->hdr.l3.dest_addr,
> - &ipv6_hdr(skb)->daddr, 16);
> -                                }
> +                                memcpy(hdr->hdr.l3.dest_addr, pkey, 16);
>                  } else {
>                                  /* passthrough */
>                                  if ((skb->dev->type == ARPHRD_IEEE802_TR) 
> &&
> 
> 
