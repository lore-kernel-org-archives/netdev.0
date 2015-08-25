From: Pravin Shelar <pshelar@nicira.com>
Subject: Re: [PATCHv5 net-next 05/10] openvswitch: Add conntrack action
Date: Tue, 25 Aug 2015 12:22:58 -0700
Message-ID: <CALnjE+rA2k+VgYiA5ErYx_zW0NHaTTYXyBmg5mcRwo2NYy=ugQ@mail.gmail.com>
References: <1440462740-23358-1-git-send-email-joestringer@nicira.com>
	<1440462740-23358-6-git-send-email-joestringer@nicira.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>, pablo <pablo@netfilter.org>,
	Florian Westphal <fwestpha@redhat.com>,
	Hannes Sowa <hannes@redhat.com>, Thomas Graf <tgraf@suug.ch>,
	Justin Pettit <jpettit@nicira.com>,
	Jesse Gross <jesse@nicira.com>,
	netfilter-devel@vger.kernel.org, Andy Zhou <azhou@nicira.com>
To: Joe Stringer <joestringer@nicira.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1440462740-23358-6-git-send-email-joestringer@nicira.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Aug 24, 2015 at 5:32 PM, Joe Stringer <joestringer@nicira.com> wrote:
> Expose the kernel connection tracker via OVS. Userspace components can
> make use of the CT action to populate the connection state (ct_state)
> field for a flow. This state can be subsequently matched.
>
> Exposed connection states are OVS_CS_F_*:
> - NEW (0x01) - Beginning of a new connection.
> - ESTABLISHED (0x02) - Part of an existing connection.
> - RELATED (0x04) - Related to an established connection.
> - INVALID (0x20) - Could not track the connection for this packet.
> - REPLY_DIR (0x40) - This packet is in the reply direction for the flow.
> - TRACKED (0x80) - This packet has been sent through conntrack.
>
> When the CT action is executed by itself, it will send the packet
> through the connection tracker and populate the ct_state field with one
> or more of the connection state flags above. The CT action will always
> set the TRACKED bit.
>
> When the COMMIT flag is passed to the conntrack action, this specifies
> that information about the connection should be stored. This allows
> subsequent packets for the same (or related) connections to be
> correlated with this connection. Sending subsequent packets for the
> connection through conntrack allows the connection tracker to consider
> the packets as ESTABLISHED, RELATED, and/or REPLY_DIR.
>
> The CT action may optionally take a zone to track the flow within. This
> allows connections with the same 5-tuple to be kept logically separate
> from connections in other zones. If the zone is specified, then the
> "ct_zone" match field will be subsequently populated with the zone id.
>
> IP fragments are handled by transparently assembling them as part of the
> CT action. The maximum received unit (MRU) size is tracked so that
> refragmentation can occur during output.
>
> IP frag handling contributed by Andy Zhou.
>
> Signed-off-by: Joe Stringer <joestringer@nicira.com>
> Signed-off-by: Justin Pettit <jpettit@nicira.com>
> Signed-off-by: Andy Zhou <azhou@nicira.com>

Patch looks good except one issue.

When I turn off conntrack support (
CONFIG_OPENVSWITCH_CONNTRACK) I got compilation error:

net/openvswitch/datapath.o: In function `ovs_ct_fill_key':

/home/pravin/linux/net-next/net/openvswitch/conntrack.h:69: multiple
definition of `ovs_ct_fill_key'

net/openvswitch/actions.o:/home/pravin/linux/net-next/net/openvswitch/conntrack.h:69:
first defined here

net/openvswitch/dp_notify.o: In function `ovs_ct_fill_key':

/home/pravin/linux/net-next/net/openvswitch/conntrack.h:69: multiple
definition of `ovs_ct_fill_key'

net/openvswitch/actions.o:/home/pravin/linux/net-next/net/openvswitch/conntrack.h:69:
first defined here
