From: Pravin Shelar <pshelar@nicira.com>
Subject: Re: [PATCH net-next] openvswitch: include datapath actions with
 sampled-packet upcall to userspace
Date: Fri, 22 May 2015 10:53:39 -0700
Message-ID: <CALnjE+rxMdfZFe5nTGzJSpeH4a1+0Z3ka8Gur1jGmVNBPAcF+w@mail.gmail.com>
References: <1432150358-13108-1-git-send-email-neil.mckee@inmon.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>
To: Neil McKee <neil.mckee@inmon.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog101.obsmtp.com ([74.125.149.67]:44889 "HELO
	na3sys009aog101.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1756510AbbEVRxk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 May 2015 13:53:40 -0400
Received: by mail-ie0-f181.google.com with SMTP id a3so36668189ies.2
        for <netdev@vger.kernel.org>; Fri, 22 May 2015 10:53:40 -0700 (PDT)
In-Reply-To: <1432150358-13108-1-git-send-email-neil.mckee@inmon.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, May 20, 2015 at 12:32 PM, Neil McKee <neil.mckee@inmon.com> wrote:
> Directly associate a sampled packet with the path it takes through the virtual switch.
> Path information currently includes mangling, encapsulation and decapsulation actions
> for tunneling protocols GRE, VXLAN, Geneve, MPLS and QinQ, but this extension requires
> no further changes to accommodate datapath actions that may be added in the future.
>
> Adding path information enhances visibility into complex virtual networks.
>
> Signed-off-by: Neil McKee <neil.mckee@inmon.com>
> ---
>  net/openvswitch/actions.c  | 14 +++++++++-----
>  net/openvswitch/datapath.c | 18 ++++++++++++++++++
>  net/openvswitch/datapath.h |  2 ++
>  3 files changed, 29 insertions(+), 5 deletions(-)
>
> diff --git a/net/openvswitch/actions.c b/net/openvswitch/actions.c
> index b491c1c..ee5760d 100644
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
> +       upcall.actions = actions;
> +       upcall.actions_len = actions_len;
>
Rather than unconditionally passing actions to the upcall, there
should be attribute in ovs_userspace_attr to request the actions list.

>         for (a = nla_data(attr), rem = nla_len(attr); rem > 0;
>                  a = nla_next(a, &rem)) {
> @@ -654,7 +657,8 @@ static int output_userspace(struct datapath *dp, struct sk_buff *skb,
>  }
>
