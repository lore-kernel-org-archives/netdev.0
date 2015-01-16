From: Pravin Shelar <pshelar@nicira.com>
Subject: Re: [PATCH net-next v12 5/5] openvswitch: Add support for unique flow IDs.
Date: Fri, 16 Jan 2015 00:07:01 -0800
Message-ID: <CALnjE+o5kXhDK+uaE4ajF2MAWwgG21rhYNgpD70rWLQc9AQqHg@mail.gmail.com>
References: <1421358507-5992-1-git-send-email-joestringer@nicira.com>
	<1421358507-5992-6-git-send-email-joestringer@nicira.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>,
	"dev@openvswitch.org" <dev@openvswitch.org>
To: Joe Stringer <joestringer@nicira.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1421358507-5992-6-git-send-email-joestringer@nicira.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Jan 15, 2015 at 1:48 PM, Joe Stringer <joestringer@nicira.com> wrote:
> Previously, flows were manipulated by userspace specifying a full,
> unmasked flow key. This adds significant burden onto flow
> serialization/deserialization, particularly when dumping flows.
>
> This patch adds an alternative way to refer to flows using a
> variable-length "unique flow identifier" (UFID). At flow setup time,
> userspace may specify a UFID for a flow, which is stored with the flow
> and inserted into a separate table for lookup, in addition to the
> standard flow table. Flows created using a UFID must be fetched or
> deleted using the UFID.
>
> All flow dump operations may now be made more terse with OVS_UFID_F_*
> flags. For example, the OVS_UFID_F_OMIT_KEY flag allows responses to
> omit the flow key from a datapath operation if the flow has a
> corresponding UFID. This significantly reduces the time spent assembling
> and transacting netlink messages. With all OVS_UFID_F_OMIT_* flags
> enabled, the datapath only returns the UFID and statistics for each flow
> during flow dump, increasing ovs-vswitchd revalidator performance by 40%
> or more.
>
> Signed-off-by: Joe Stringer <joestringer@nicira.com>
Patch looks pretty good now. I have one comment below.

> +#define MAX_UFID_LENGTH 16 /* 128 bits */
> +
> +struct sw_flow_id {
> +       u32 ufid_len;
> +       union {
> +               u32 ufid[MAX_UFID_LENGTH / 4];
> +               struct sw_flow_key flow_key;
> +       };
> +};
> +
>  struct sw_flow_actions {
>         struct rcu_head rcu;
>         u32 actions_len;
> @@ -213,13 +223,15 @@ struct flow_stats {
>
>  struct sw_flow {
>         struct rcu_head rcu;
> -       struct hlist_node hash_node[2];
> -       u32 hash;
> +       struct {
> +               struct hlist_node node[2];
> +               u32 hash;
> +       } flow_table, ufid_table;
>         int stats_last_writer;          /* NUMA-node id of the last writer on
>                                          * 'stats[0]'.
>                                          */
>         struct sw_flow_key key;
> -       struct sw_flow_key unmasked_key;
> +       struct sw_flow_id *id;
>         struct sw_flow_mask *mask;
>         struct sw_flow_actions __rcu *sf_acts;
>         struct flow_stats __rcu *stats[]; /* One for each NUMA node.  First one
> @@ -243,6 +255,16 @@ struct arp_eth_header {
>         unsigned char       ar_tip[4];          /* target IP address        */
>  } __packed;
>
In last round we agreed on following struct flow-id which saves around
four hundred bytes per flow and kmalloc per flow add operation for
common case. Is there any reason for not doing it?

struct {
     u32 ufid_len;
     union {
         u32 ufid[MAX_UFID_LENGTH / 4];
         struct sw_flow_key *unmasked_key;
     }
} id;
