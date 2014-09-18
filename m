From: Pravin Shelar <pshelar@nicira.com>
Subject: Re: [PATCH net v2 2/2] openvswitch: restore OVS_FLOW_CMD_NEW notifications
Date: Thu, 18 Sep 2014 10:11:45 -0700
Message-ID: <CALnjE+pzShu94mJrSjgSoWz-CkJ6eUA-zMqVALEHiut4CedfHA@mail.gmail.com>
References: <CALnjE+qqv66Zkh==bJAxBSUEkh8H-9YMnox1yF+4_BwetqERmg@mail.gmail.com>
	<1411029064-15376-1-git-send-email-nicolas.dichtel@6wind.com>
	<1411029064-15376-2-git-send-email-nicolas.dichtel@6wind.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	"dev@openvswitch.org" <dev@openvswitch.org>,
	netdev <netdev@vger.kernel.org>,
	Samuel Gauthier <samuel.gauthier@6wind.com>
To: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog101.obsmtp.com ([74.125.149.67]:43195 "HELO
	na3sys009aog101.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1756669AbaIRRLp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Sep 2014 13:11:45 -0400
Received: by mail-ig0-f178.google.com with SMTP id r10so1196159igi.17
        for <netdev@vger.kernel.org>; Thu, 18 Sep 2014 10:11:45 -0700 (PDT)
In-Reply-To: <1411029064-15376-2-git-send-email-nicolas.dichtel@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Sep 18, 2014 at 1:31 AM, Nicolas Dichtel
<nicolas.dichtel@6wind.com> wrote:
> From: Samuel Gauthier <samuel.gauthier@6wind.com>
>
> Since commit fb5d1e9e127a ("openvswitch: Build flow cmd netlink reply only if needed."),
> the new flows are not notified to the listeners of OVS_FLOW_MCGROUP.
>
> This commit fixes the problem by using the genl function, ie
> genl_has_listerners() instead of netlink_has_listeners().
>
> Signed-off-by: Samuel Gauthier <samuel.gauthier@6wind.com>
> Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>

Thanks for the fix.
Acked-by: Pravin B Shelar <pshelar@nicira.com>

> ---
>
> v2: add patch 1/2
>
>  net/openvswitch/datapath.c | 9 +++++----
>  1 file changed, 5 insertions(+), 4 deletions(-)
>
> diff --git a/net/openvswitch/datapath.c b/net/openvswitch/datapath.c
> index 91d66b7e64ac..64dc864a417f 100644
> --- a/net/openvswitch/datapath.c
> +++ b/net/openvswitch/datapath.c
> @@ -78,11 +78,12 @@ static const struct genl_multicast_group ovs_dp_vport_multicast_group = {
>
>  /* Check if need to build a reply message.
>   * OVS userspace sets the NLM_F_ECHO flag if it needs the reply. */
> -static bool ovs_must_notify(struct genl_info *info,
> -                           const struct genl_multicast_group *grp)
> +static bool ovs_must_notify(struct genl_family *family, struct genl_info *info,
> +                           unsigned int group)
>  {
>         return info->nlhdr->nlmsg_flags & NLM_F_ECHO ||
> -               netlink_has_listeners(genl_info_net(info)->genl_sock, 0);
> +              genl_has_listeners(family, genl_info_net(info)->genl_sock,
> +                                 group);
>  }
>
>  static void ovs_notify(struct genl_family *family,
> @@ -763,7 +764,7 @@ static struct sk_buff *ovs_flow_cmd_alloc_info(const struct sw_flow_actions *act
>  {
>         struct sk_buff *skb;
>
> -       if (!always && !ovs_must_notify(info, &ovs_dp_flow_multicast_group))
> +       if (!always && !ovs_must_notify(&dp_flow_genl_family, info, 0))
>                 return NULL;
>
>         skb = genlmsg_new_unicast(ovs_flow_cmd_msg_size(acts), info, GFP_KERNEL);
> --
> 2.1.0
>
