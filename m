From: Joe Stringer <joestringer@nicira.com>
Subject: Re: [RFC net-next 18/22] openvswitch: Make tunnel set action attach a
 metadata dst
Date: Mon, 13 Jul 2015 15:55:10 -0700
Message-ID: <CANr6G5zNyGsx590AqAjYmYeXu0bktnqzO0d-=Yh2_u+iq=LCww@mail.gmail.com>
References: <cover.1436537414.git.tgraf@suug.ch> <db45b60a2ab4aa0d6dde363558ebe3e46edb0e81.1436537414.git.tgraf@suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: roopa@cumulusnetworks.com, rshearma@brocade.com,
	ebiederm@xmission.com, hannes@stressinduktion.org,
	Pravin Shelar <pshelar@nicira.com>,
	Jesse Gross <jesse@nicira.com>,
	David Miller <davem@davemloft.net>, daniel@iogearbox.net,
	tom@herbertland.com, edumazet@google.com, jiri@resnulli.us,
	marcelo.leitner@gmail.com, stephen@networkplumber.org,
	Justin Pettit <jpettit@nicira.com>,
	Patrick McHardy <kaber@trash.net>,
	Linux Netdev List <netdev@vger.kernel.org>,
	"dev@openvswitch.org" <dev@openvswitch.org>
To: Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yk0-f173.google.com ([209.85.160.173]:33524 "EHLO
	mail-yk0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752808AbbGMWza (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Jul 2015 18:55:30 -0400
Received: by ykeo3 with SMTP id o3so207822949yke.0
        for <netdev@vger.kernel.org>; Mon, 13 Jul 2015 15:55:30 -0700 (PDT)
In-Reply-To: <db45b60a2ab4aa0d6dde363558ebe3e46edb0e81.1436537414.git.tgraf@suug.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Thomas,

On 10 July 2015 at 07:19, Thomas Graf <tgraf@suug.ch> wrote:
> diff --git a/net/openvswitch/flow_netlink.c b/net/openvswitch/flow_netlink.c
> index ecfa530..05fe46b 100644
> --- a/net/openvswitch/flow_netlink.c
> +++ b/net/openvswitch/flow_netlink.c
> @@ -1548,11 +1548,45 @@ static struct sw_flow_actions *nla_alloc_flow_actions(int size, bool log)
>         return sfa;
>  }
>
> +static void ovs_nla_free_set_action(const struct nlattr *a)
> +{
> +       const struct nlattr *ovs_key = nla_data(a);
> +       struct ovs_tunnel_info *ovs_tun;
> +
> +       switch (nla_type(ovs_key)) {
> +       case OVS_KEY_ATTR_TUNNEL_INFO:
> +               ovs_tun = nla_data(ovs_key);
> +               dst_release((struct dst_entry *)ovs_tun->tun_dst);
> +               break;
> +       }
> +}
> +
> +void ovs_nla_free_flow_actions(struct sw_flow_actions *sf_acts)
> +{
> +       const struct nlattr *a;
> +       int rem;
> +
> +       nla_for_each_attr(a, sf_acts->actions, sf_acts->actions_len, rem) {
> +               switch (nla_type(a)) {
> +               case OVS_ACTION_ATTR_SET:
> +                       ovs_nla_free_set_action(a);
> +                       break;
> +               }
> +       }
> +
> +       kfree(sf_acts);
> +}

It doesn't look like flow_free() is using this new function to
properly free the actions. Also, some of the error cases that hit this
code have sf_acts=NULL.
