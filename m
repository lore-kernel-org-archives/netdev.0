From: Tom Herbert <therbert@google.com>
Subject: Re: [RFCv2 net-next 0/7] OVS conntrack support
Date: Mon, 2 Mar 2015 16:59:28 -0800
Message-ID: <CA+mtBx8QxrCYN1xyunOMmQM55zJFxZWOSqJ7d-znj=SUmUh8FQ@mail.gmail.com>
References: <1425333305-19702-1-git-send-email-joestringer@nicira.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Netdev List <netdev@vger.kernel.org>,
	Pablo Neira Ayuso <pablo@netfilter.org>,
	LKML <linux-kernel@vger.kernel.org>,
	Justin Pettit <jpettit@nicira.com>,
	Andy Zhou <azhou@nicira.com>, Thomas Graf <tgraf@suug.ch>,
	Patrick McHardy <kaber@trash.net>
To: Joe Stringer <joestringer@nicira.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1425333305-19702-1-git-send-email-joestringer@nicira.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Mar 2, 2015 at 1:54 PM, Joe Stringer <joestringer@nicira.com> wrote:
> The goal of this series is to allow OVS to send packets through the Linux
> kernel connection tracker, and subsequently match on fields populated by
> conntrack.
>
> Sending this out as another RFC change as this is the first time IP fragment
> support is included. Only IPv4 is added right now, as we'd like to get some
> feedback on that approach before we implement IPv6 frag support.
>
> Helper support is also yet to be addressed, for tracking a particular flow a la
> iptables CT targets. I think this is just a matter of having userspace specify
> the helper to use (eg via 8-bit field in conntrack action), and setting up the
> conntrack template accordingly when OVS first installs the flow containing a
> conntrack action.
>
> There are some additional related items that I intend to work on, which I do
> not see as prerequisite for this series:
> - OVS Connlabel support.
> - Allow OVS to register logging facilities for conntrack.
> - Conntrack per-zone configuration.
>
> The branch below has been updated with the corresponding userspace pieces:
> https://github.com/justinpettit/ovs/tree/conntrack
>
>
> RFCv2:
> - Support IPv4 fragments
> - Warn when ct->net is different from skb net in skb_has_valid_nfct().
> - Set OVS_CS_F_TRACKED when a flow cannot be identified ("invalid")
> - Continue processing packets when conntrack marks the flow invalid.
> - Use PF_INET6 family when sending IPv6 packets to conntrack.
> - Verify conn_* matches when deserializing metadata from netlink.
> - Only allow conntrack action on IPv4/IPv6 packets.
> - Remove explicit dependencies on conn_zone, conn_mark.
> - General tidyups
>
> RFCv1:
> - Rebase to net-next.
> - Add conn_zone field to the flow key.
> - Add explicit dependencies on conn_zone, conn_mark.
> - Refactor conntrack changes into net/openvswitch/ovs_conntrack.*.
> - Don't allow set_field() actions to change conn_state, conn_zone.
> - Add OVS_CS_F_* flags to indicate connection state.
> - Add "invalid" connection state.
>
>
> Andy Zhou (3):
>   net: refactor ip_fragment()
>   net: Refactor ip_defrag() APIs
>   openvswitch: Support fragmented IPv4 packets for conntrack
>
> Joe Stringer (2):
>   openvswitch: Serialize acts with original netlink len
>   openvswitch: Move MASKED* macros to datapath.h
>
> Justin Pettit (2):
>   openvswitch: Add conntrack action
>   openvswitch: Allow matching on conntrack mark
>
>  drivers/net/macvlan.c               |    2 +-
>  include/net/ip.h                    |   13 +-
>  include/uapi/linux/openvswitch.h    |   42 +++-
>  net/ipv4/ip_fragment.c              |   46 ++--
>  net/ipv4/ip_input.c                 |    5 +-
>  net/ipv4/ip_output.c                |  113 +++++----

This is a lot of change to core IP. It probably should be done in its
own patch set.

>  net/ipv4/netfilter/nf_defrag_ipv4.c |    2 +-
>  net/netfilter/ipvs/ip_vs_core.c     |    2 +-
>  net/openvswitch/Kconfig             |   11 +
>  net/openvswitch/Makefile            |    1 +
>  net/openvswitch/actions.c           |  140 +++++++++---
>  net/openvswitch/conntrack.c         |  427 +++++++++++++++++++++++++++++++++++
>  net/openvswitch/conntrack.h         |   91 ++++++++
>  net/openvswitch/datapath.c          |   60 +++--
>  net/openvswitch/datapath.h          |   10 +
>  net/openvswitch/flow.c              |    4 +
>  net/openvswitch/flow.h              |    4 +
>  net/openvswitch/flow_netlink.c      |   95 ++++++--
>  net/openvswitch/flow_netlink.h      |    4 +-
>  net/openvswitch/vport.c             |    1 +
>  net/packet/af_packet.c              |    2 +-
>  21 files changed, 938 insertions(+), 137 deletions(-)
>  create mode 100644 net/openvswitch/conntrack.c
>  create mode 100644 net/openvswitch/conntrack.h
>
> --
> 1.7.10.4
>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
