From: Pravin Shelar <pshelar@nicira.com>
Subject: Re: [PATCHv4 net-next 06/10] openvswitch: Allow matching on conntrack mark
Date: Wed, 19 Aug 2015 13:47:37 -0700
Message-ID: <CALnjE+r9_WHdHNZOBaNDGApPD1mJsGorU5HfqQ2eJfsL+hPAeA@mail.gmail.com>
References: <1439941188-19293-1-git-send-email-joestringer@nicira.com>
	<1439941188-19293-7-git-send-email-joestringer@nicira.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>, pablo <pablo@netfilter.org>,
	Florian Westphal <fwestpha@redhat.com>,
	Hannes Sowa <hannes@redhat.com>, Thomas Graf <tgraf@suug.ch>,
	Justin Pettit <jpettit@nicira.com>,
	Jesse Gross <jesse@nicira.com>
To: Joe Stringer <joestringer@nicira.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1439941188-19293-7-git-send-email-joestringer@nicira.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Aug 18, 2015 at 4:39 PM, Joe Stringer <joestringer@nicira.com> wrote:
> Allow matching and setting the conntrack mark field. As with conntrack
> state and zone, these are populated when the CT action is executed,
> and are made available for matching via RECIRC. To write to this field,
> a value and optional mark can be passed as part of the conntrack action.
>
> E.g.: actions:ct(zone=0),ct(zone=1,mark=1)
>
> This will perform conntrack lookup in zone 0, then lookup in zone 1,
> then modify the mark for the entry in zone 1. The conntrack entry itself
> must be committed using the "commit" flag in the conntrack action flags
> for this change to persist.
>
> Signed-off-by: Justin Pettit <jpettit@nicira.com>
> Signed-off-by: Joe Stringer <joestringer@nicira.com>
> ---
> v1-v3: No change.
> v4: Only allow setting conntrack mark via ct action.
>     Documentation tweaks.
> ---
>  include/uapi/linux/openvswitch.h |  5 ++++
>  net/openvswitch/actions.c        |  1 +
>  net/openvswitch/conntrack.c      | 61 ++++++++++++++++++++++++++++++++++++++--
>  net/openvswitch/conntrack.h      |  1 +
>  net/openvswitch/flow.h           |  1 +
>  net/openvswitch/flow_netlink.c   | 15 +++++++++-
>  6 files changed, 80 insertions(+), 4 deletions(-)
>
> diff --git a/include/uapi/linux/openvswitch.h b/include/uapi/linux/openvswitch.h
> index 55f5997..7a185b5 100644
> --- a/include/uapi/linux/openvswitch.h
> +++ b/include/uapi/linux/openvswitch.h
> @@ -325,6 +325,7 @@ enum ovs_key_attr {
>                                  * the accepted length of the array. */
>         OVS_KEY_ATTR_CT_STATE,  /* u8 bitmask of OVS_CS_F_* */
>         OVS_KEY_ATTR_CT_ZONE,   /* u16 connection tracking zone. */
> +       OVS_KEY_ATTR_CT_MARK,   /* u32 connection tracking mark */
>
>  #ifdef __KERNEL__
>         OVS_KEY_ATTR_TUNNEL_INFO,  /* struct ip_tunnel_info */
> @@ -613,11 +614,15 @@ struct ovs_action_hash {
>   * enum ovs_ct_attr - Attributes for %OVS_ACTION_ATTR_CT action.
>   * @OVS_CT_ATTR_FLAGS: u32 connection tracking flags.
>   * @OVS_CT_ATTR_ZONE: u16 connection tracking zone.
> + * @OVS_CT_ATTR_MARK: u32 value followed by u32 mask. For each bit set in the
> + * mask, the corresponding bit in the value is copied to the connection
> + * tracking mark field in the connection.
>   */
>  enum ovs_ct_attr {
>         OVS_CT_ATTR_UNSPEC,
>         OVS_CT_ATTR_FLAGS,      /* u8 bitmask of OVS_CT_F_*. */
>         OVS_CT_ATTR_ZONE,       /* u16 zone id. */
> +       OVS_CT_ATTR_MARK,       /* mark to associate with this connection. */
>         __OVS_CT_ATTR_MAX
>  };
>
ovs_ct_action_to_attr() is not updated to return complete datapath
action back to userpsace. same issue exist in set label patch.
