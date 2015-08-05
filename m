From: Pravin Shelar <pshelar@nicira.com>
Subject: Re: [PATCHv2 net-next 1/9] openvswitch: Serialize acts with original
 netlink len
Date: Wed, 5 Aug 2015 15:30:10 -0700
Message-ID: <CALnjE+pAbeO-tCYnbv6VrV_wp9vFrrDRevtk8xemU1vMufjPdA@mail.gmail.com>
References: <1438750199-9061-1-git-send-email-joestringer@nicira.com>
	<1438750199-9061-2-git-send-email-joestringer@nicira.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>, pablo <pablo@netfilter.org>,
	Patrick McHardy <kaber@trash.net>,
	Justin Pettit <jpettit@nicira.com>,
	Andy Zhou <azhou@nicira.com>, Jesse Gross <jesse@nicira.com>,
	Florian Westphal <fwestpha@redhat.com>,
	Hannes Sowa <hannes@redhat.com>,
	Thomas Graf <tgraf@noironetworks.com>
To: Joe Stringer <joestringer@nicira.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1438750199-9061-2-git-send-email-joestringer@nicira.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Aug 4, 2015 at 9:49 PM, Joe Stringer <joestringer@nicira.com> wrote:
> Previously, we used the kernel-internal netlink actions length to
> calculate the size of messages to serialize back to userspace.
> However,the sw_flow_actions may not be formatted exactly the same as the
> actions on the wire, so store the original actions length when
> de-serializing and re-use the original length when serializing.
>
> Signed-off-by: Joe Stringer <joestringer@nicira.com>
> Acked-by: Thomas Graf <tgraf@suug.ch>
> ---
>  net/openvswitch/datapath.c     | 2 +-
>  net/openvswitch/flow.h         | 1 +
>  net/openvswitch/flow_netlink.c | 1 +
>  3 files changed, 3 insertions(+), 1 deletion(-)
>
> diff --git a/net/openvswitch/datapath.c b/net/openvswitch/datapath.c
> index ffe984f..d5b5473 100644
> --- a/net/openvswitch/datapath.c
> +++ b/net/openvswitch/datapath.c
> @@ -713,7 +713,7 @@ static size_t ovs_flow_cmd_msg_size(const struct sw_flow_actions *acts,
>
>         /* OVS_FLOW_ATTR_ACTIONS */
>         if (should_fill_actions(ufid_flags))
> -               len += nla_total_size(acts->actions_len);
> +               len += nla_total_size(acts->orig_len);
>
>         return len
>                 + nla_total_size(sizeof(struct ovs_flow_stats)) /* OVS_FLOW_ATTR_STATS */
> diff --git a/net/openvswitch/flow.h b/net/openvswitch/flow.h
> index b62cdb3..082a87b 100644
> --- a/net/openvswitch/flow.h
> +++ b/net/openvswitch/flow.h
> @@ -144,6 +144,7 @@ struct sw_flow_id {
>
>  struct sw_flow_actions {
>         struct rcu_head rcu;
> +       size_t orig_len;        /* From flow_cmd_new netlink actions size */
>         u32 actions_len;
>         struct nlattr actions[];
>  };
> diff --git a/net/openvswitch/flow_netlink.c b/net/openvswitch/flow_netlink.c
> index a6eb77a..d536fb7 100644
> --- a/net/openvswitch/flow_netlink.c
> +++ b/net/openvswitch/flow_netlink.c
> @@ -1545,6 +1545,7 @@ static struct sw_flow_actions *nla_alloc_flow_actions(int size, bool log)
>                 return ERR_PTR(-ENOMEM);
>
>         sfa->actions_len = 0;
> +       sfa->orig_len = size;

This is getting updated every time datapath action buffer is expanded
(ref: reserve_sfa_size()). So it does not keep original userspace
action length.
