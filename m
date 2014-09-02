From: Pravin Shelar <pshelar@nicira.com>
Subject: Re: [PATCH] openvswitch: fix a memory leak
Date: Tue, 2 Sep 2014 13:18:40 -0700
Message-ID: <CALnjE+pJs4c9P0Xy5N_Dt0Jb7sKLyOWnxRq-52=m-gCZD-eUVw@mail.gmail.com>
References: <1409662348-2475-1-git-send-email-roy.qing.li@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>,
	"dev@openvswitch.org" <dev@openvswitch.org>
To: roy.qing.li@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog113.obsmtp.com ([74.125.149.209]:45356 "HELO
	na3sys009aog113.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1754125AbaIBUSl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Sep 2014 16:18:41 -0400
Received: by mail-ig0-f170.google.com with SMTP id h3so4236235igd.1
        for <netdev@vger.kernel.org>; Tue, 02 Sep 2014 13:18:40 -0700 (PDT)
In-Reply-To: <1409662348-2475-1-git-send-email-roy.qing.li@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Sep 2, 2014 at 5:52 AM,  <roy.qing.li@gmail.com> wrote:
> From: Li RongQing <roy.qing.li@gmail.com>
>
> The user_skb maybe be leaked if the operation on it failed and codes
> skipped into the label "out:" without calling genlmsg_unicast.
>
> Cc: Pravin Shelar <pshelar@nicira.com>
> Signed-off-by: Li RongQing <roy.qing.li@gmail.com>

Looks good.
Acked-by: Pravin B Shelar <pshelar@nicira.com>

> ---
>  net/openvswitch/datapath.c |    4 +++-
>  1 file changed, 3 insertions(+), 1 deletion(-)
>
> diff --git a/net/openvswitch/datapath.c b/net/openvswitch/datapath.c
> index 7228ec3..35d866f 100644
> --- a/net/openvswitch/datapath.c
> +++ b/net/openvswitch/datapath.c
> @@ -404,7 +404,7 @@ static int queue_userspace_packet(struct datapath *dp, struct sk_buff *skb,
>  {
>         struct ovs_header *upcall;
>         struct sk_buff *nskb = NULL;
> -       struct sk_buff *user_skb; /* to be queued to userspace */
> +       struct sk_buff *user_skb = NULL; /* to be queued to userspace */
>         struct nlattr *nla;
>         struct genl_info info = {
>                 .dst_sk = ovs_dp_get_net(dp)->genl_sock,
> @@ -494,9 +494,11 @@ static int queue_userspace_packet(struct datapath *dp, struct sk_buff *skb,
>         ((struct nlmsghdr *) user_skb->data)->nlmsg_len = user_skb->len;
>
>         err = genlmsg_unicast(ovs_dp_get_net(dp), user_skb, upcall_info->portid);
> +       user_skb = NULL;
>  out:
>         if (err)
>                 skb_tx_error(skb);
> +       kfree_skb(user_skb);
>         kfree_skb(nskb);
>         return err;
>  }
> --
> 1.7.10.4
>
