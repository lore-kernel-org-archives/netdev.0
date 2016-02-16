From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [net-next PATCH v2 1/1] net_sched fix: reclassification needs
 to consider ether protocol changes
Date: Tue, 16 Feb 2016 16:20:56 +0100
Message-ID: <56C33E58.9090007@iogearbox.net>
References: <1455626225-16382-1-git-send-email-jhs@emojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Jamal Hadi Salim <jhs@mojatatu.com>, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:56398 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750897AbcBPPVA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Feb 2016 10:21:00 -0500
In-Reply-To: <1455626225-16382-1-git-send-email-jhs@emojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02/16/2016 01:37 PM, Jamal Hadi Salim wrote:
> From: Jamal Hadi Salim <jhs@mojatatu.com>
>
> actions could change the etherproto in particular with ethernet
> tunnelled data. Typically such actions, after peeling the outer heade=
r,
> will ask for the packet to be  reclassified. We then need to restart
> the classification with the new proto header.
>
> Example setup used to catch this:
> sudo tc qdisc add dev $ETH ingress
> sudo $TC filter add dev $ETH parent ffff: pref 1 protocol 802.1Q \
> u32 match u32 0 0 flowid 1:1 \
> action vlan pop reclassify
>
> Fixes: 3b3ae880266d ("net: sched: consolidate tc_classify{,_compat}")
> Signed-off-by: Jamal Hadi Salim <jhs@mojatatu.com>
> ---
>   net/sched/sch_api.c | 7 ++++---
>   1 file changed, 4 insertions(+), 3 deletions(-)
>
> diff --git a/net/sched/sch_api.c b/net/sched/sch_api.c
> index b5c2cf2..22ab634 100644
> --- a/net/sched/sch_api.c
> +++ b/net/sched/sch_api.c
> @@ -1818,13 +1818,14 @@ done:
>   int tc_classify(struct sk_buff *skb, const struct tcf_proto *tp,
>   		struct tcf_result *res, bool compat_mode)
>   {
> -	__be16 protocol =3D tc_skb_protocol(skb);
>   #ifdef CONFIG_NET_CLS_ACT
> -	const struct tcf_proto *old_tp =3D tp;
>   	int limit =3D 0;
> +#endif
> +	const struct tcf_proto *old_tp =3D tp;
> +	__be16 protocol;
>
>   reclassify:
> -#endif
> +	protocol =3D tc_skb_protocol(skb);
>   	for (; tp; tp =3D rcu_dereference_bh(tp->next)) {
>   		int err;
>

But, how is that better than the one-liner I suggested to you in
my earlier mail?

With this patch, I now get :

   CC      net/sched/sch_api.o
net/sched/sch_api.c: In function =91tc_classify=92:
net/sched/sch_api.c:1827:1: warning: label =91reclassify=92 defined but=
 not used [-Wunused-label]
  reclassify:
  ^
net/sched/sch_api.c:1824:26: warning: unused variable =91old_tp=92 [-Wu=
nused-variable]
   const struct tcf_proto *old_tp =3D tp;
                           ^
Thanks,
Daniel
