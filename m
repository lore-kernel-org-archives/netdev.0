From: Pravin Shelar <pshelar@nicira.com>
Subject: Re: [PATCH v2 net-next] openvswitch: include datapath actions with
 sampled-packet upcall to userspace
Date: Tue, 26 May 2015 14:30:42 -0700
Message-ID: <CALnjE+p3DutBRfUXOWOR3Dw_SmwbxuZcTftps15=hCxs+MWLJA@mail.gmail.com>
References: <1432336884-21720-1-git-send-email-neil.mckee@inmon.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>
To: Neil McKee <neil.mckee@inmon.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog105.obsmtp.com ([74.125.149.75]:36864 "HELO
	na3sys009aog105.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1751217AbbEZVan (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 May 2015 17:30:43 -0400
Received: by mail-ig0-f180.google.com with SMTP id au1so63829167igc.1
        for <netdev@vger.kernel.org>; Tue, 26 May 2015 14:30:42 -0700 (PDT)
In-Reply-To: <1432336884-21720-1-git-send-email-neil.mckee@inmon.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, May 22, 2015 at 4:21 PM, Neil McKee <neil.mckee@inmon.com> wrote:
> If new optional attribute OVS_USERSPACE_ATTR_ACTIONS is added to an
> OVS_ACTION_ATTR_USERSPACE action, then include the datapath actions
> in the upcall.
>
> This Directly associates the sampled packet with the path it takes
> through the virtual switch. Path information currently includes mangling,
> encapsulation and decapsulation actions for tunneling protocols GRE,
> VXLAN, Geneve, MPLS and QinQ, but this extension requires no further
> changes to accommodate datapath actions that may be added in the
> future.
>
> Adding path information enhances visibility into complex virtual
> networks.
>
> Signed-off-by: Neil McKee <neil.mckee@inmon.com>
> ---
>  include/uapi/linux/openvswitch.h |  4 ++++
>  net/openvswitch/actions.c        | 21 ++++++++++++++++-----
>  net/openvswitch/datapath.c       | 18 ++++++++++++++++++
>  net/openvswitch/datapath.h       |  2 ++
>  4 files changed, 40 insertions(+), 5 deletions(-)
>

> diff --git a/net/openvswitch/actions.c b/net/openvswitch/actions.c
> index b491c1c..b3f9b89 100644
> --- a/net/openvswitch/actions.c
> +++ b/net/openvswitch/actions.c
> @@ -608,7 +608,8 @@ static void do_output(struct datapath *dp, struct sk_buff *skb, int out_port)
>  }
>
>  static int output_userspace(struct datapath *dp, struct sk_buff *skb,
> -                           struct sw_flow_key *key, const struct nlattr *attr)
> +                           struct sw_flow_key *key, const struct nlattr *attr,
> +                           const struct nlattr *actions, int actions_len)
>  {
>         struct ovs_tunnel_info info;
>         struct dp_upcall_info upcall;
> @@ -619,6 +620,8 @@ static int output_userspace(struct datapath *dp, struct sk_buff *skb,
>         upcall.userdata = NULL;
>         upcall.portid = 0;
>         upcall.egress_tun_info = NULL;
> +       upcall.actions = NULL;
> +       upcall.actions_len = 0;
>
At this point its better to just memset this structure.

>         for (a = nla_data(attr), rem = nla_len(attr); rem > 0;
>                  a = nla_next(a, &rem)) {
> @@ -647,6 +650,13 @@ static int output_userspace(struct datapath *dp, struct sk_buff *skb,
...

> diff --git a/net/openvswitch/datapath.c b/net/openvswitch/datapath.c
> index 5bae724..e735c8f 100644
> --- a/net/openvswitch/datapath.c
> +++ b/net/openvswitch/datapath.c
> @@ -277,6 +277,8 @@ void ovs_dp_process_packet(struct sk_buff *skb, struct sw_flow_key *key)
>                 upcall.userdata = NULL;
>                 upcall.portid = ovs_vport_find_upcall_portid(p, skb);
>                 upcall.egress_tun_info = NULL;
> +               upcall.actions = NULL;
> +               upcall.actions_len = 0;

Here also memset should be used.

>                 error = ovs_dp_upcall(dp, skb, key, &upcall);
>                 if (unlikely(error))
>                         kfree_skb(skb);

...
> @@ -479,6 +485,18 @@ static int queue_userspace_packet(struct datapath *dp, struct sk_buff *skb,
>                 nla_nest_end(user_skb, nla);
>         }
>
> +       if (upcall_info->actions_len) {
> +               nla = nla_nest_start(user_skb, OVS_PACKET_ATTR_ACTIONS);
> +               err = ovs_nla_put_actions(upcall_info->actions,
> +                                         upcall_info->actions_len,
> +                                         user_skb);
> +               if (!err) {
> +                       nla_nest_end(user_skb, nla);
> +               } else {
> +                       nla_nest_cancel(user_skb, nla);
> +               }
> +       }
> +
There is no need to for curly bracket for the if-else block with
single statements.
