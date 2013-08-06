From: Joe Stringer <joe-Q1GJJQv1iO6lP80pJB477g@public.gmane.org>
Subject: Re: [PATCH v2.35 5/6] lib: Push MPLS tags in the OpenFlow
	1.3 ordering
Date: Tue, 6 Aug 2013 11:04:31 +0900
Message-ID: <CAOftzPjviFrD5c3ZHM6n6-Ud+REyiuaXgNzea7TFNrYZADqdXQ@mail.gmail.com>
References: <1374289623-17056-1-git-send-email-horms@verge.net.au>
	<1374289623-17056-6-git-send-email-horms@verge.net.au>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============0882345905=="
Cc: "dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org" <dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>, Ravi K <rkerur-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Isaku Yamahata <yamahata-jCdQPDEk3idL9jVzuh4AOg@public.gmane.org>
To: Ben Pfaff <blp-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>
Return-path: <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
In-Reply-To: <1374289623-17056-6-git-send-email-horms-/R6kz+dDXgpPR4JQBCEnsQ@public.gmane.org>
List-Unsubscribe: <http://openvswitch.org/mailman/options/dev>,
	<mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=unsubscribe>
List-Archive: <http://openvswitch.org/pipermail/dev>
List-Post: <mailto:dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
List-Help: <mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=help>
List-Subscribe: <http://openvswitch.org/mailman/listinfo/dev>,
	<mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=subscribe>
Sender: dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
Errors-To: dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
List-Id: netdev.vger.kernel.org

--===============0882345905==
Content-Type: multipart/alternative; boundary=001a11c3f2e2b8d4df04e33dd9f6

--001a11c3f2e2b8d4df04e33dd9f6
Content-Type: text/plain; charset=ISO-8859-1

Hi Ben,

I realise that you've agreed to let Jesse review the datapath patch first,
but I wondered if I could get a little broad feedback on the approach on
the userspace side.

The general background to this patch is that we aim to keep the datapath
interface for MPLS actions simple. As such, when pushing an MPLS tag, this
is done immediately after the ethernet header regardless of the presence of
VLANs (As per OF1.3 spec). We can then implement OF1.2 behaviour by popping
any existing VLAN tags before applying MPLS actions, then pushing the tags
back on afterwards. This is all done on the odp actions translation side.

The patches leading up to this one allow us to store which protocol
inserted the MPLS action in the ofpact->compat field, and we translate VLAN
actions differently based on this value. There may be alternative
approaches, for instance having a per-bridge "MPLS behaviour" configuration
flag, set when the OpenFlow connection is established.

I'm wondering if this general approach is the preferred method, and as an
extension, what are your thoughts on how these patches add the new
'vlan_tci' field into 'struct xlate_in' and apply VLAN actions twice
(before and/or after MPLS actions). This provides a mechanism to support
both OF1.2 and OF1.3 behaviours within the scope of current VLAN support,
but may or may not fit in well with future ideas for QinQ (ie,
double-stacked 0x8100 tags) or 802.1ad support.

Cheers,
Joe

On Sat, Jul 20, 2013 at 12:07 PM, Simon Horman <horms-/R6kz+dDXgpPR4JQBCEnsQ@public.gmane.org> wrote:

> From: Joe Stringer <joe-Q1GJJQv1iO6lP80pJB477g@public.gmane.org>
>
> This patch modifies the push_mpls behaviour to follow the OpenFlow 1.3
> specification in the presence of VLAN tagged packets. From the spec:
>
> "Newly pushed tags should always be inserted as the outermost tag in the
> outermost valid location for that tag. When a new VLAN tag is pushed, it
> should be the outermost tag inserted, immediately after the Ethernet
> header and before other tags. Likewise, when a new MPLS tag is pushed,
> it should be the outermost tag inserted, immediately after the Ethernet
> header and before other tags."
>
> When the push_mpls action was inserted using OpenFlow 1.2, we implement
> the previous behaviour by inserting VLAN actions around the MPLS action
> in the odp translation; Pop VLAN tags before committing MPLS actions,
> and push the expected VLAN tag afterwards. The trigger condition for
> this is based on the ofpact->compat field.
>
> Signed-off-by: Joe Stringer <joe-Q1GJJQv1iO6lP80pJB477g@public.gmane.org>
> Signed-off-by: Simon Horman <horms-/R6kz+dDXgpPR4JQBCEnsQ@public.gmane.org>
> ---
>  lib/flow.c                   |    2 +-
>  lib/packets.c                |   10 +-
>  lib/packets.h                |    2 +-
>  ofproto/ofproto-dpif-xlate.c |   10 +-
>  tests/ofproto-dpif.at        |  237
> ++++++++++++++++++++++++++++++++++++++++++
>  5 files changed, 253 insertions(+), 8 deletions(-)
>
> diff --git a/lib/flow.c b/lib/flow.c
> index d899d26..3dc4489 100644
> --- a/lib/flow.c
> +++ b/lib/flow.c
> @@ -1035,7 +1035,7 @@ flow_compose(struct ofpbuf *b, const struct flow
> *flow)
>      }
>
>      if (eth_type_mpls(flow->dl_type)) {
> -        b->l2_5 = b->l3;
> +        b->l2_5 = (char*)b->l2 + ETH_HEADER_LEN;
>          push_mpls(b, flow->dl_type, flow->mpls_lse);
>      }
>  }
> diff --git a/lib/packets.c b/lib/packets.c
> index 7fe6513..3bc155f 100644
> --- a/lib/packets.c
> +++ b/lib/packets.c
> @@ -240,11 +240,11 @@ eth_mpls_depth(const struct ofpbuf *packet)
>
>  /* Set ethertype of the packet. */
>  void
> -set_ethertype(struct ofpbuf *packet, ovs_be16 eth_type)
> +set_ethertype(struct ofpbuf *packet, ovs_be16 eth_type, bool inner)
>  {
>      struct eth_header *eh = packet->data;
>
> -    if (eh->eth_type == htons(ETH_TYPE_VLAN)) {
> +    if (inner && eh->eth_type == htons(ETH_TYPE_VLAN)) {
>          ovs_be16 *p;
>          p = (ovs_be16 *)((char *)(packet->l2_5 ? packet->l2_5 :
> packet->l3) - 2);
>          *p = eth_type;
> @@ -351,8 +351,8 @@ push_mpls(struct ofpbuf *packet, ovs_be16 ethtype,
> ovs_be32 lse)
>
>      if (!is_mpls(packet)) {
>          /* Set ethtype and MPLS label stack entry. */
> -        set_ethertype(packet, ethtype);
> -        packet->l2_5 = packet->l3;
> +        set_ethertype(packet, ethtype, false);
> +        packet->l2_5 = (char*)packet->l2 + ETH_HEADER_LEN;
>      }
>
>      /* Push new MPLS shim header onto packet. */
> @@ -373,7 +373,7 @@ pop_mpls(struct ofpbuf *packet, ovs_be16 ethtype)
>          size_t len;
>          mh = packet->l2_5;
>          len = (char*)packet->l2_5 - (char*)packet->l2;
> -        set_ethertype(packet, ethtype);
> +        set_ethertype(packet, ethtype, true);
>          if (mh->mpls_lse & htonl(MPLS_BOS_MASK)) {
>              packet->l2_5 = NULL;
>          } else {
> diff --git a/lib/packets.h b/lib/packets.h
> index e852761..923fd53 100644
> --- a/lib/packets.h
> +++ b/lib/packets.h
> @@ -142,7 +142,7 @@ void eth_pop_vlan(struct ofpbuf *);
>
>  uint16_t eth_mpls_depth(const struct ofpbuf *packet);
>
> -void set_ethertype(struct ofpbuf *packet, ovs_be16 eth_type);
> +void set_ethertype(struct ofpbuf *packet, ovs_be16 eth_type, bool inner);
>
>  const char *eth_from_hex(const char *hex, struct ofpbuf **packetp);
>  void eth_format_masked(const uint8_t eth[ETH_ADDR_LEN],
> diff --git a/ofproto/ofproto-dpif-xlate.c b/ofproto/ofproto-dpif-xlate.c
> index 8a0c32e..457a1d1 100644
> --- a/ofproto/ofproto-dpif-xlate.c
> +++ b/ofproto/ofproto-dpif-xlate.c
> @@ -1912,6 +1912,12 @@ tunnel_ecn_ok(struct xlate_ctx *ctx)
>      return true;
>  }
>
> +static bool
> +mpls_compat_behaviour(enum ofputil_action_code compat)
> +{
> +    return (compat != OFPUTIL_OFPAT13_PUSH_MPLS);
> +}
> +
>  static void
>  vlan_tci_restore(struct xlate_in *xin, ovs_be16 *tci_ptr, ovs_be16
> orig_tci)
>  {
> @@ -2089,7 +2095,9 @@ do_xlate_actions(const struct ofpact *ofpacts,
> size_t ofpacts_len,
>
>              /* Save and pop any existing VLAN tags if running in OF1.2
> mode. */
>              ctx->xin->vlan_tci = *vlan_tci;
> -            flow->vlan_tci = htons(0);
> +            if (mpls_compat_behaviour(a->compat)) {
> +                flow->vlan_tci = htons(0);
> +            }
>              vlan_tci = &ctx->xin->vlan_tci;
>              break;
>
> diff --git a/tests/ofproto-dpif.at b/tests/ofproto-dpif.at
> index 62531da..5e85ab2 100644
> --- a/tests/ofproto-dpif.at
> +++ b/tests/ofproto-dpif.at
> @@ -1017,6 +1017,243 @@ NXST_FLOW reply:
>  OVS_VSWITCHD_STOP
>  AT_CLEANUP
>
> +AT_SETUP([ofproto-dpif - OF1.3+ VLAN+MPLS handling])
> +OVS_VSWITCHD_START([dnl
> +   add-port br0 p1 -- set Interface p1 type=dummy
> +])
> +ON_EXIT([kill `cat ovs-ofctl.pid`])
> +
> +AT_CAPTURE_FILE([ofctl_monitor.log])
> +AT_DATA([flows.txt], [dnl
> +cookie=0xa dl_src=40:44:44:44:55:44
> actions=push_mpls:0x8847,load:10->OXM_OF_MPLS_LABEL[[]],load:3->OXM_OF_MPLS_TC[[]],controller
> +cookie=0xa dl_src=40:44:44:44:55:45
> actions=push_vlan:0x8100,mod_vlan_vid:99,push_mpls:0x8847,load:10->OXM_OF_MPLS_LABEL[[]],load:3->OXM_OF_MPLS_TC[[]],controller
> +cookie=0xa dl_src=40:44:44:44:55:46
> actions=push_vlan:0x8100,mod_vlan_vid:99,push_mpls:0x8847,load:10->OXM_OF_MPLS_LABEL[[]],load:3->OXM_OF_MPLS_TC[[]],controller
> +cookie=0xa dl_src=40:44:44:44:55:47
> actions=push_vlan:0x8100,load:99->OXM_OF_VLAN_VID[[]],push_mpls:0x8847,load:10->OXM_OF_MPLS_LABEL[[]],load:3->OXM_OF_MPLS_TC[[]],controller
> +cookie=0xa dl_src=40:44:44:44:55:48
> actions=push_vlan:0x8100,load:99->OXM_OF_VLAN_VID[[]],push_mpls:0x8847,load:10->OXM_OF_MPLS_LABEL[[]],load:3->OXM_OF_MPLS_TC[[]],controller
> +cookie=0xa dl_src=40:44:44:44:55:49
> actions=push_mpls:0x8847,load:10->OXM_OF_MPLS_LABEL[[]],load:3->OXM_OF_MPLS_TC[[]],push_vlan:0x8100,mod_vlan_vid:99,controller
> +cookie=0xa dl_src=40:44:44:44:55:50
> actions=push_mpls:0x8847,load:10->OXM_OF_MPLS_LABEL[[]],load:3->OXM_OF_MPLS_TC[[]],push_vlan:0x8100,mod_vlan_vid:99,controller
> +cookie=0xa dl_src=40:44:44:44:55:51
> actions=push_mpls:0x8847,load:10->OXM_OF_MPLS_LABEL[[]],load:3->OXM_OF_MPLS_TC[[]],push_vlan:0x8100,load:99->OXM_OF_VLAN_VID[[]],mod_vlan_pcp:1,controller
> +cookie=0xa dl_src=40:44:44:44:55:52
> actions=push_mpls:0x8847,load:10->OXM_OF_MPLS_LABEL[[]],load:3->OXM_OF_MPLS_TC[[]],push_vlan:0x8100,load:99->OXM_OF_VLAN_VID[[]],mod_vlan_pcp:1,controller
> +])
> +AT_CHECK([ovs-ofctl --protocols=OpenFlow13 add-flows br0 flows.txt])
> +
> +dnl Modified MPLS controller action.
> +dnl The input packet has a VLAN tag, but because we push an MPLS tag in
> +dnl OF1.3 mode, we can no longer see it.
> +AT_CHECK([ovs-ofctl monitor br0 65534 -P nxm --detach --pidfile 2>
> ofctl_monitor.log])
> +
> +for i in 1 2 3; do
> +    ovs-appctl netdev-dummy/receive p1
> 'in_port(1),eth(src=40:44:44:44:55:44,dst=50:54:00:00:00:07),eth_type(0x8100),vlan(vid=88,pcp=7),encap(eth_type(0x0800),ipv4(src=192.168.0.1,dst=192.168.0.2,proto=6,tos=0,ttl=64,frag=no))'
> +done
> +OVS_WAIT_UNTIL([test `wc -l < ofctl_monitor.log` -ge 6])
> +ovs-appctl -t ovs-ofctl exit
> +
> +AT_CHECK([cat ofctl_monitor.log], [0], [dnl
> +NXT_PACKET_IN (xid=0x0): cookie=0xa total_len=64 in_port=1 (via action)
> data_len=64 (unbuffered)
>
> +mpls,metadata=0,in_port=0,vlan_tci=0x0000,dl_src=40:44:44:44:55:44,dl_dst=50:54:00:00:00:07,mpls_label=10,mpls_tc=3,mpls_ttl=64,mpls_bos=1
> +dnl
> +NXT_PACKET_IN (xid=0x0): cookie=0xa total_len=64 in_port=1 (via action)
> data_len=64 (unbuffered)
>
> +mpls,metadata=0,in_port=0,vlan_tci=0x0000,dl_src=40:44:44:44:55:44,dl_dst=50:54:00:00:00:07,mpls_label=10,mpls_tc=3,mpls_ttl=64,mpls_bos=1
> +dnl
> +NXT_PACKET_IN (xid=0x0): cookie=0xa total_len=64 in_port=1 (via action)
> data_len=64 (unbuffered)
>
> +mpls,metadata=0,in_port=0,vlan_tci=0x0000,dl_src=40:44:44:44:55:44,dl_dst=50:54:00:00:00:07,mpls_label=10,mpls_tc=3,mpls_ttl=64,mpls_bos=1
> +])
> +
> +dnl Modified MPLS controller action.
> +dnl In this test, we push a VLAN tag, then an MPLS tag in OF1.3 mode, so
> we
> +dnl can only see the MPLS tag in the result.
> +AT_CHECK([ovs-ofctl monitor br0 65534 -P nxm --detach --pidfile 2>
> ofctl_monitor.log])
> +
> +for i in 1 2 3; do
> +    ovs-appctl netdev-dummy/receive p1
> 'in_port(1),eth(src=40:44:44:44:55:45,dst=50:54:00:00:00:07),eth_type(0x0800),ipv4(src=192.168.0.1,dst=192.168.0.2,proto=6,tos=0,ttl=64,frag=no)'
> +done
> +OVS_WAIT_UNTIL([test `wc -l < ofctl_monitor.log` -ge 6])
> +ovs-appctl -t ovs-ofctl exit
> +
> +AT_CHECK([cat ofctl_monitor.log], [0], [dnl
> +NXT_PACKET_IN (xid=0x0): cookie=0xa total_len=68 in_port=1 (via action)
> data_len=68 (unbuffered)
>
> +mpls,metadata=0,in_port=0,vlan_tci=0x0000,dl_src=40:44:44:44:55:45,dl_dst=50:54:00:00:00:07,mpls_label=10,mpls_tc=3,mpls_ttl=64,mpls_bos=1
> +dnl
> +NXT_PACKET_IN (xid=0x0): cookie=0xa total_len=68 in_port=1 (via action)
> data_len=68 (unbuffered)
>
> +mpls,metadata=0,in_port=0,vlan_tci=0x0000,dl_src=40:44:44:44:55:45,dl_dst=50:54:00:00:00:07,mpls_label=10,mpls_tc=3,mpls_ttl=64,mpls_bos=1
> +dnl
> +NXT_PACKET_IN (xid=0x0): cookie=0xa total_len=68 in_port=1 (via action)
> data_len=68 (unbuffered)
>
> +mpls,metadata=0,in_port=0,vlan_tci=0x0000,dl_src=40:44:44:44:55:45,dl_dst=50:54:00:00:00:07,mpls_label=10,mpls_tc=3,mpls_ttl=64,mpls_bos=1
> +])
> +
> +dnl Modified MPLS controller action.
> +dnl In this test, the input packet is vlan-tagged; we update this tag then
> +dnl push an MPLS tag in OF1.3 mode. As such, we can only see the MPLS tag
> in
> +dnl the result.
> +AT_CHECK([ovs-ofctl monitor br0 65534 -P nxm --detach --pidfile 2>
> ofctl_monitor.log])
> +
> +for i in 1 2 3; do
> +    ovs-appctl netdev-dummy/receive p1
> 'in_port(1),eth(src=40:44:44:44:55:46,dst=50:54:00:00:00:07),eth_type(0x8100),vlan(vid=88,pcp=7),encap(eth_type(0x0800),ipv4(src=192.168.0.1,dst=192.168.0.2,proto=6,tos=0,ttl=64,frag=no))'
> +done
> +OVS_WAIT_UNTIL([test `wc -l < ofctl_monitor.log` -ge 6])
> +ovs-appctl -t ovs-ofctl exit
> +
> +AT_CHECK([cat ofctl_monitor.log], [0], [dnl
> +NXT_PACKET_IN (xid=0x0): cookie=0xa total_len=64 in_port=1 (via action)
> data_len=64 (unbuffered)
>
> +mpls,metadata=0,in_port=0,vlan_tci=0x0000,dl_src=40:44:44:44:55:46,dl_dst=50:54:00:00:00:07,mpls_label=10,mpls_tc=3,mpls_ttl=64,mpls_bos=1
> +dnl
> +NXT_PACKET_IN (xid=0x0): cookie=0xa total_len=64 in_port=1 (via action)
> data_len=64 (unbuffered)
>
> +mpls,metadata=0,in_port=0,vlan_tci=0x0000,dl_src=40:44:44:44:55:46,dl_dst=50:54:00:00:00:07,mpls_label=10,mpls_tc=3,mpls_ttl=64,mpls_bos=1
> +dnl
> +NXT_PACKET_IN (xid=0x0): cookie=0xa total_len=64 in_port=1 (via action)
> data_len=64 (unbuffered)
>
> +mpls,metadata=0,in_port=0,vlan_tci=0x0000,dl_src=40:44:44:44:55:46,dl_dst=50:54:00:00:00:07,mpls_label=10,mpls_tc=3,mpls_ttl=64,mpls_bos=1
> +])
> +
> +dnl Modified MPLS controller action.
> +dnl In this test, we push a VLAN tag, then an MPLS tag in OF1.3 mode, so
> we
> +dnl can only see the MPLS tag in the result.
> +AT_CHECK([ovs-ofctl monitor br0 65534 -P nxm --detach --pidfile 2>
> ofctl_monitor.log])
> +
> +for i in 1 2 3; do
> +    ovs-appctl netdev-dummy/receive p1
> 'in_port(1),eth(src=40:44:44:44:55:47,dst=50:54:00:00:00:07),eth_type(0x0800),ipv4(src=192.168.0.1,dst=192.168.0.2,proto=6,tos=0,ttl=64,frag=no)'
> +done
> +OVS_WAIT_UNTIL([test `wc -l < ofctl_monitor.log` -ge 6])
> +ovs-appctl -t ovs-ofctl exit
> +
> +AT_CHECK([cat ofctl_monitor.log], [0], [dnl
> +NXT_PACKET_IN (xid=0x0): cookie=0xa total_len=68 in_port=1 (via action)
> data_len=68 (unbuffered)
>
> +mpls,metadata=0,in_port=0,vlan_tci=0x0000,dl_src=40:44:44:44:55:47,dl_dst=50:54:00:00:00:07,mpls_label=10,mpls_tc=3,mpls_ttl=64,mpls_bos=1
> +dnl
> +NXT_PACKET_IN (xid=0x0): cookie=0xa total_len=68 in_port=1 (via action)
> data_len=68 (unbuffered)
>
> +mpls,metadata=0,in_port=0,vlan_tci=0x0000,dl_src=40:44:44:44:55:47,dl_dst=50:54:00:00:00:07,mpls_label=10,mpls_tc=3,mpls_ttl=64,mpls_bos=1
> +dnl
> +NXT_PACKET_IN (xid=0x0): cookie=0xa total_len=68 in_port=1 (via action)
> data_len=68 (unbuffered)
>
> +mpls,metadata=0,in_port=0,vlan_tci=0x0000,dl_src=40:44:44:44:55:47,dl_dst=50:54:00:00:00:07,mpls_label=10,mpls_tc=3,mpls_ttl=64,mpls_bos=1
> +])
> +
> +dnl Modified MPLS controller action.
> +dnl In this test, the input packet is vlan-tagged; we update this tag then
> +dnl push an MPLS tag in OF1.3 mode. As such, we can only see the MPLS tag
> in
> +dnl the result.
> +AT_CHECK([ovs-ofctl monitor br0 65534 -P nxm --detach --pidfile 2>
> ofctl_monitor.log])
> +
> +for i in 1 2 3; do
> +    ovs-appctl netdev-dummy/receive p1
> 'in_port(1),eth(src=40:44:44:44:55:48,dst=50:54:00:00:00:07),eth_type(0x8100),vlan(vid=88,pcp=7),encap(eth_type(0x0800),ipv4(src=192.168.0.1,dst=192.168.0.2,proto=6,tos=0,ttl=64,frag=no))'
> +done
> +OVS_WAIT_UNTIL([test `wc -l < ofctl_monitor.log` -ge 6])
> +ovs-appctl -t ovs-ofctl exit
> +
> +AT_CHECK([cat ofctl_monitor.log], [0], [dnl
> +NXT_PACKET_IN (xid=0x0): cookie=0xa total_len=64 in_port=1 (via action)
> data_len=64 (unbuffered)
>
> +mpls,metadata=0,in_port=0,vlan_tci=0x0000,dl_src=40:44:44:44:55:48,dl_dst=50:54:00:00:00:07,mpls_label=10,mpls_tc=3,mpls_ttl=64,mpls_bos=1
> +dnl
> +NXT_PACKET_IN (xid=0x0): cookie=0xa total_len=64 in_port=1 (via action)
> data_len=64 (unbuffered)
>
> +mpls,metadata=0,in_port=0,vlan_tci=0x0000,dl_src=40:44:44:44:55:48,dl_dst=50:54:00:00:00:07,mpls_label=10,mpls_tc=3,mpls_ttl=64,mpls_bos=1
> +dnl
> +NXT_PACKET_IN (xid=0x0): cookie=0xa total_len=64 in_port=1 (via action)
> data_len=64 (unbuffered)
>
> +mpls,metadata=0,in_port=0,vlan_tci=0x0000,dl_src=40:44:44:44:55:48,dl_dst=50:54:00:00:00:07,mpls_label=10,mpls_tc=3,mpls_ttl=64,mpls_bos=1
> +])
> +
> +dnl Modified MPLS controller action.
> +dnl In this test, we push the MPLS tag before pushing a VLAN tag, so we
> see
> +dnl both of these in the final flow.
> +AT_CHECK([ovs-ofctl monitor br0 65534 -P nxm --detach --pidfile 2>
> ofctl_monitor.log])
> +
> +for i in 1 2 3; do
> +    ovs-appctl netdev-dummy/receive p1
> 'in_port(1),eth(src=40:44:44:44:55:49,dst=50:54:00:00:00:07),eth_type(0x0800),ipv4(src=192.168.0.1,dst=192.168.0.2,proto=6,tos=0,ttl=64,frag=no)'
> +done
> +OVS_WAIT_UNTIL([test `wc -l < ofctl_monitor.log` -ge 6])
> +ovs-appctl -t ovs-ofctl exit
> +
> +AT_CHECK([cat ofctl_monitor.log], [0], [dnl
> +NXT_PACKET_IN (xid=0x0): cookie=0xa total_len=68 in_port=1 (via action)
> data_len=68 (unbuffered)
>
> +mpls,metadata=0,in_port=0,dl_vlan=99,dl_vlan_pcp=0,dl_src=40:44:44:44:55:49,dl_dst=50:54:00:00:00:07,mpls_label=10,mpls_tc=3,mpls_ttl=64,mpls_bos=1
> +dnl
> +NXT_PACKET_IN (xid=0x0): cookie=0xa total_len=68 in_port=1 (via action)
> data_len=68 (unbuffered)
>
> +mpls,metadata=0,in_port=0,dl_vlan=99,dl_vlan_pcp=0,dl_src=40:44:44:44:55:49,dl_dst=50:54:00:00:00:07,mpls_label=10,mpls_tc=3,mpls_ttl=64,mpls_bos=1
> +dnl
> +NXT_PACKET_IN (xid=0x0): cookie=0xa total_len=68 in_port=1 (via action)
> data_len=68 (unbuffered)
>
> +mpls,metadata=0,in_port=0,dl_vlan=99,dl_vlan_pcp=0,dl_src=40:44:44:44:55:49,dl_dst=50:54:00:00:00:07,mpls_label=10,mpls_tc=3,mpls_ttl=64,mpls_bos=1
> +])
> +
> +dnl Modified MPLS controller action.
> +dnl In this test, the input packet in vlan-tagged, which should be
> stripped
> +dnl before we push the MPLS and VLAN tags.
> +AT_CHECK([ovs-ofctl monitor br0 65534 -P nxm --detach --pidfile 2>
> ofctl_monitor.log])
> +
> +for i in 1 2 3; do
> +    ovs-appctl netdev-dummy/receive p1
> 'in_port(1),eth(src=40:44:44:44:55:50,dst=50:54:00:00:00:07),eth_type(0x8100),vlan(vid=88,pcp=7),encap(eth_type(0x0800),ipv4(src=192.168.0.1,dst=192.168.0.2,proto=6,tos=0,ttl=64,frag=no))'
> +done
> +OVS_WAIT_UNTIL([test `wc -l < ofctl_monitor.log` -ge 6])
> +ovs-appctl -t ovs-ofctl exit
> +
> +AT_CHECK([cat ofctl_monitor.log], [0], [dnl
> +NXT_PACKET_IN (xid=0x0): cookie=0xa total_len=68 in_port=1 (via action)
> data_len=68 (unbuffered)
>
> +mpls,metadata=0,in_port=0,dl_vlan=99,dl_vlan_pcp=0,dl_src=40:44:44:44:55:50,dl_dst=50:54:00:00:00:07,mpls_label=10,mpls_tc=3,mpls_ttl=64,mpls_bos=1
> +dnl
> +NXT_PACKET_IN (xid=0x0): cookie=0xa total_len=68 in_port=1 (via action)
> data_len=68 (unbuffered)
>
> +mpls,metadata=0,in_port=0,dl_vlan=99,dl_vlan_pcp=0,dl_src=40:44:44:44:55:50,dl_dst=50:54:00:00:00:07,mpls_label=10,mpls_tc=3,mpls_ttl=64,mpls_bos=1
> +dnl
> +NXT_PACKET_IN (xid=0x0): cookie=0xa total_len=68 in_port=1 (via action)
> data_len=68 (unbuffered)
>
> +mpls,metadata=0,in_port=0,dl_vlan=99,dl_vlan_pcp=0,dl_src=40:44:44:44:55:50,dl_dst=50:54:00:00:00:07,mpls_label=10,mpls_tc=3,mpls_ttl=64,mpls_bos=1
> +])
> +
> +dnl Modified MPLS controller action.
> +dnl In this test, we push the MPLS tag before pushing a VLAN tag, so we
> see
> +dnl both of these in the final flow.
> +AT_CHECK([ovs-ofctl monitor br0 65534 -P nxm --detach --pidfile 2>
> ofctl_monitor.log])
> +
> +for i in 1 2 3; do
> +    ovs-appctl netdev-dummy/receive p1
> 'in_port(1),eth(src=40:44:44:44:55:51,dst=50:54:00:00:00:07),eth_type(0x0800),ipv4(src=192.168.0.1,dst=192.168.0.2,proto=6,tos=0,ttl=64,frag=no)'
> +done
> +OVS_WAIT_UNTIL([test `wc -l < ofctl_monitor.log` -ge 6])
> +ovs-appctl -t ovs-ofctl exit
> +
> +AT_CHECK([cat ofctl_monitor.log], [0], [dnl
> +NXT_PACKET_IN (xid=0x0): cookie=0xa total_len=68 in_port=1 (via action)
> data_len=68 (unbuffered)
>
> +mpls,metadata=0,in_port=0,dl_vlan=99,dl_vlan_pcp=1,dl_src=40:44:44:44:55:51,dl_dst=50:54:00:00:00:07,mpls_label=10,mpls_tc=3,mpls_ttl=64,mpls_bos=1
> +dnl
> +NXT_PACKET_IN (xid=0x0): cookie=0xa total_len=68 in_port=1 (via action)
> data_len=68 (unbuffered)
>
> +mpls,metadata=0,in_port=0,dl_vlan=99,dl_vlan_pcp=1,dl_src=40:44:44:44:55:51,dl_dst=50:54:00:00:00:07,mpls_label=10,mpls_tc=3,mpls_ttl=64,mpls_bos=1
> +dnl
> +NXT_PACKET_IN (xid=0x0): cookie=0xa total_len=68 in_port=1 (via action)
> data_len=68 (unbuffered)
>
> +mpls,metadata=0,in_port=0,dl_vlan=99,dl_vlan_pcp=1,dl_src=40:44:44:44:55:51,dl_dst=50:54:00:00:00:07,mpls_label=10,mpls_tc=3,mpls_ttl=64,mpls_bos=1
> +])
> +
> +dnl Modified MPLS controller action.
> +dnl In this test, the input packet in vlan-tagged, which should be
> stripped
> +dnl before we push the MPLS and VLAN tags.
> +AT_CHECK([ovs-ofctl monitor br0 65534 -P nxm --detach --pidfile 2>
> ofctl_monitor.log])
> +
> +for i in 1 2 3; do
> +    ovs-appctl netdev-dummy/receive p1
> 'in_port(1),eth(src=40:44:44:44:55:52,dst=50:54:00:00:00:07),eth_type(0x8100),vlan(vid=88,pcp=7),encap(eth_type(0x0800),ipv4(src=192.168.0.1,dst=192.168.0.2,proto=6,tos=0,ttl=64,frag=no))'
> +done
> +OVS_WAIT_UNTIL([test `wc -l < ofctl_monitor.log` -ge 6])
> +ovs-appctl -t ovs-ofctl exit
> +
> +AT_CHECK([cat ofctl_monitor.log], [0], [dnl
> +NXT_PACKET_IN (xid=0x0): cookie=0xa total_len=68 in_port=1 (via action)
> data_len=68 (unbuffered)
>
> +mpls,metadata=0,in_port=0,dl_vlan=99,dl_vlan_pcp=1,dl_src=40:44:44:44:55:52,dl_dst=50:54:00:00:00:07,mpls_label=10,mpls_tc=3,mpls_ttl=64,mpls_bos=1
> +dnl
> +NXT_PACKET_IN (xid=0x0): cookie=0xa total_len=68 in_port=1 (via action)
> data_len=68 (unbuffered)
>
> +mpls,metadata=0,in_port=0,dl_vlan=99,dl_vlan_pcp=1,dl_src=40:44:44:44:55:52,dl_dst=50:54:00:00:00:07,mpls_label=10,mpls_tc=3,mpls_ttl=64,mpls_bos=1
> +dnl
> +NXT_PACKET_IN (xid=0x0): cookie=0xa total_len=68 in_port=1 (via action)
> data_len=68 (unbuffered)
>
> +mpls,metadata=0,in_port=0,dl_vlan=99,dl_vlan_pcp=1,dl_src=40:44:44:44:55:52,dl_dst=50:54:00:00:00:07,mpls_label=10,mpls_tc=3,mpls_ttl=64,mpls_bos=1
> +])
> +
> +AT_CHECK([ovs-appctl time/warp 5000], [0], [ignore])
> +AT_CHECK([ovs-ofctl dump-flows br0 | ofctl_strip | sort], [0], [dnl
> + cookie=0xa, n_packets=3, n_bytes=180, dl_src=40:44:44:44:55:44
> actions=push_mpls:0x8847,load:0xa->OXM_OF_MPLS_LABEL[[]],load:0x3->OXM_OF_MPLS_TC[[]],CONTROLLER:65535
> + cookie=0xa, n_packets=3, n_bytes=180, dl_src=40:44:44:44:55:45
> actions=mod_vlan_vid:99,push_mpls:0x8847,load:0xa->OXM_OF_MPLS_LABEL[[]],load:0x3->OXM_OF_MPLS_TC[[]],CONTROLLER:65535
> + cookie=0xa, n_packets=3, n_bytes=180, dl_src=40:44:44:44:55:46
> actions=mod_vlan_vid:99,push_mpls:0x8847,load:0xa->OXM_OF_MPLS_LABEL[[]],load:0x3->OXM_OF_MPLS_TC[[]],CONTROLLER:65535
> + cookie=0xa, n_packets=3, n_bytes=180, dl_src=40:44:44:44:55:47
> actions=load:0x63->OXM_OF_VLAN_VID[[]],push_mpls:0x8847,load:0xa->OXM_OF_MPLS_LABEL[[]],load:0x3->OXM_OF_MPLS_TC[[]],CONTROLLER:65535
> + cookie=0xa, n_packets=3, n_bytes=180, dl_src=40:44:44:44:55:48
> actions=load:0x63->OXM_OF_VLAN_VID[[]],push_mpls:0x8847,load:0xa->OXM_OF_MPLS_LABEL[[]],load:0x3->OXM_OF_MPLS_TC[[]],CONTROLLER:65535
> + cookie=0xa, n_packets=3, n_bytes=180, dl_src=40:44:44:44:55:49
> actions=push_mpls:0x8847,load:0xa->OXM_OF_MPLS_LABEL[[]],load:0x3->OXM_OF_MPLS_TC[[]],mod_vlan_vid:99,CONTROLLER:65535
> + cookie=0xa, n_packets=3, n_bytes=180, dl_src=40:44:44:44:55:50
> actions=push_mpls:0x8847,load:0xa->OXM_OF_MPLS_LABEL[[]],load:0x3->OXM_OF_MPLS_TC[[]],mod_vlan_vid:99,CONTROLLER:65535
> + cookie=0xa, n_packets=3, n_bytes=180, dl_src=40:44:44:44:55:51
> actions=push_mpls:0x8847,load:0xa->OXM_OF_MPLS_LABEL[[]],load:0x3->OXM_OF_MPLS_TC[[]],load:0x63->OXM_OF_VLAN_VID[[]],mod_vlan_pcp:1,CONTROLLER:65535
> + cookie=0xa, n_packets=3, n_bytes=180, dl_src=40:44:44:44:55:52
> actions=push_mpls:0x8847,load:0xa->OXM_OF_MPLS_LABEL[[]],load:0x3->OXM_OF_MPLS_TC[[]],load:0x63->OXM_OF_VLAN_VID[[]],mod_vlan_pcp:1,CONTROLLER:65535
> +NXST_FLOW reply:
> +])
> +
> +OVS_VSWITCHD_STOP
> +AT_CLEANUP
> +
>  AT_SETUP([ofproto-dpif - fragment handling])
>  OVS_VSWITCHD_START
>  ADD_OF_PORTS([br0], [1], [2], [3], [4], [5], [6], [90])
> --
> 1.7.10.4
>
>

--001a11c3f2e2b8d4df04e33dd9f6
Content-Type: text/html; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

<div dir=3D"ltr"><div>Hi Ben,</div><div><br></div><div>I realise that you&#=
39;ve agreed to let Jesse review the datapath patch first, but I wondered i=
f I could get a little broad feedback on the approach on the userspace side=
.</div>

<br><div>The general background to this patch is that we aim to keep the da=
tapath interface for MPLS actions simple. As such, when pushing an MPLS tag=
, this is done immediately after the ethernet header regardless of the pres=
ence of VLANs (As per OF1.3 spec). We can then implement OF1.2 behaviour by=
 popping any existing VLAN tags before applying MPLS actions, then pushing =
the tags back on afterwards. This is all done on the odp actions translatio=
n side.</div>


<div><br></div><div>The patches leading up to this one allow us to store wh=
ich protocol inserted the MPLS action in the ofpact-&gt;compat field, and w=
e translate VLAN actions differently based on this value. There may be alte=
rnative approaches, for instance having a per-bridge &quot;MPLS behaviour&q=
uot; configuration flag, set when the OpenFlow connection is established.</=
div>


<div><br></div><div>I&#39;m wondering if this general approach is the prefe=
rred method, and as an extension, what are your thoughts on how these patch=
es add the new &#39;vlan_tci&#39; field into &#39;struct xlate_in&#39; and =
apply VLAN actions twice (before and/or after MPLS actions). This provides =
a mechanism to support both OF1.2 and OF1.3 behaviours within the scope of =
current VLAN support, but may or may not fit in well with future ideas for =
QinQ (ie, double-stacked 0x8100 tags) or 802.1ad support.</div>

<div><br></div><div>Cheers,</div><div>Joe</div><div class=3D"gmail_extra"><=
br><div class=3D"gmail_quote">On Sat, Jul 20, 2013 at 12:07 PM, Simon Horma=
n <span dir=3D"ltr">&lt;<a href=3D"mailto:horms-/R6kz+dDXgpPR4JQBCEnsQ@public.gmane.org" target=3D"_bl=
ank">horms-/R6kz+dDXgpPR4JQBCEnsQ@public.gmane.org</a>&gt;</span> wrote:<br>


<blockquote class=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;border-left:1p=
x #ccc solid;padding-left:1ex">From: Joe Stringer &lt;<a href=3D"mailto:joe=
@wand.net.nz" target=3D"_blank">joe-Q1GJJQv1iO6lP80pJB477g@public.gmane.org</a>&gt;<br>
<br>
This patch modifies the push_mpls behaviour to follow the OpenFlow 1.3<br>
specification in the presence of VLAN tagged packets. From the spec:<br>
<br>
&quot;Newly pushed tags should always be inserted as the outermost tag in t=
he<br>
outermost valid location for that tag. When a new VLAN tag is pushed, it<br=
>
should be the outermost tag inserted, immediately after the Ethernet<br>
header and before other tags. Likewise, when a new MPLS tag is pushed,<br>
it should be the outermost tag inserted, immediately after the Ethernet<br>
header and before other tags.&quot;<br>
<br>
When the push_mpls action was inserted using OpenFlow 1.2, we implement<br>
the previous behaviour by inserting VLAN actions around the MPLS action<br>
in the odp translation; Pop VLAN tags before committing MPLS actions,<br>
and push the expected VLAN tag afterwards. The trigger condition for<br>
this is based on the ofpact-&gt;compat field.<br>
<br>
Signed-off-by: Joe Stringer &lt;<a href=3D"mailto:joe-Q1GJJQv1iO6lP80pJB477g@public.gmane.org" target=
=3D"_blank">joe-Q1GJJQv1iO6lP80pJB477g@public.gmane.org</a>&gt;<br>
Signed-off-by: Simon Horman &lt;<a href=3D"mailto:horms-/R6kz+dDXgpPR4JQBCEnsQ@public.gmane.org" targe=
t=3D"_blank">horms-/R6kz+dDXgpPR4JQBCEnsQ@public.gmane.org</a>&gt;<br>
---<br>
=A0lib/flow.c =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 | =A0 =A02 +-<br>
=A0lib/packets.c =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0| =A0 10 +-<br>
=A0lib/packets.h =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0| =A0 =A02 +-<br>
=A0ofproto/ofproto-dpif-xlate.c | =A0 10 +-<br>
=A0tests/<a href=3D"http://ofproto-dpif.at" target=3D"_blank">ofproto-dpif.=
at</a> =A0 =A0 =A0 =A0| =A0237 ++++++++++++++++++++++++++++++++++++++++++<b=
r>
=A05 files changed, 253 insertions(+), 8 deletions(-)<br>
<br>
diff --git a/lib/flow.c b/lib/flow.c<br>
index d899d26..3dc4489 100644<br>
--- a/lib/flow.c<br>
+++ b/lib/flow.c<br>
@@ -1035,7 +1035,7 @@ flow_compose(struct ofpbuf *b, const struct flow *flo=
w)<br>
=A0 =A0 =A0}<br>
<br>
=A0 =A0 =A0if (eth_type_mpls(flow-&gt;dl_type)) {<br>
- =A0 =A0 =A0 =A0b-&gt;l2_5 =3D b-&gt;l3;<br>
+ =A0 =A0 =A0 =A0b-&gt;l2_5 =3D (char*)b-&gt;l2 + ETH_HEADER_LEN;<br>
=A0 =A0 =A0 =A0 =A0push_mpls(b, flow-&gt;dl_type, flow-&gt;mpls_lse);<br>
=A0 =A0 =A0}<br>
=A0}<br>
diff --git a/lib/packets.c b/lib/packets.c<br>
index 7fe6513..3bc155f 100644<br>
--- a/lib/packets.c<br>
+++ b/lib/packets.c<br>
@@ -240,11 +240,11 @@ eth_mpls_depth(const struct ofpbuf *packet)<br>
<br>
=A0/* Set ethertype of the packet. */<br>
=A0void<br>
-set_ethertype(struct ofpbuf *packet, ovs_be16 eth_type)<br>
+set_ethertype(struct ofpbuf *packet, ovs_be16 eth_type, bool inner)<br>
=A0{<br>
=A0 =A0 =A0struct eth_header *eh =3D packet-&gt;data;<br>
<br>
- =A0 =A0if (eh-&gt;eth_type =3D=3D htons(ETH_TYPE_VLAN)) {<br>
+ =A0 =A0if (inner &amp;&amp; eh-&gt;eth_type =3D=3D htons(ETH_TYPE_VLAN)) =
{<br>
=A0 =A0 =A0 =A0 =A0ovs_be16 *p;<br>
=A0 =A0 =A0 =A0 =A0p =3D (ovs_be16 *)((char *)(packet-&gt;l2_5 ? packet-&gt=
;l2_5 : packet-&gt;l3) - 2);<br>
=A0 =A0 =A0 =A0 =A0*p =3D eth_type;<br>
@@ -351,8 +351,8 @@ push_mpls(struct ofpbuf *packet, ovs_be16 ethtype, ovs_=
be32 lse)<br>
<br>
=A0 =A0 =A0if (!is_mpls(packet)) {<br>
=A0 =A0 =A0 =A0 =A0/* Set ethtype and MPLS label stack entry. */<br>
- =A0 =A0 =A0 =A0set_ethertype(packet, ethtype);<br>
- =A0 =A0 =A0 =A0packet-&gt;l2_5 =3D packet-&gt;l3;<br>
+ =A0 =A0 =A0 =A0set_ethertype(packet, ethtype, false);<br>
+ =A0 =A0 =A0 =A0packet-&gt;l2_5 =3D (char*)packet-&gt;l2 + ETH_HEADER_LEN;=
<br>
=A0 =A0 =A0}<br>
<br>
=A0 =A0 =A0/* Push new MPLS shim header onto packet. */<br>
@@ -373,7 +373,7 @@ pop_mpls(struct ofpbuf *packet, ovs_be16 ethtype)<br>
=A0 =A0 =A0 =A0 =A0size_t len;<br>
=A0 =A0 =A0 =A0 =A0mh =3D packet-&gt;l2_5;<br>
=A0 =A0 =A0 =A0 =A0len =3D (char*)packet-&gt;l2_5 - (char*)packet-&gt;l2;<b=
r>
- =A0 =A0 =A0 =A0set_ethertype(packet, ethtype);<br>
+ =A0 =A0 =A0 =A0set_ethertype(packet, ethtype, true);<br>
=A0 =A0 =A0 =A0 =A0if (mh-&gt;mpls_lse &amp; htonl(MPLS_BOS_MASK)) {<br>
=A0 =A0 =A0 =A0 =A0 =A0 =A0packet-&gt;l2_5 =3D NULL;<br>
=A0 =A0 =A0 =A0 =A0} else {<br>
diff --git a/lib/packets.h b/lib/packets.h<br>
index e852761..923fd53 100644<br>
--- a/lib/packets.h<br>
+++ b/lib/packets.h<br>
@@ -142,7 +142,7 @@ void eth_pop_vlan(struct ofpbuf *);<br>
<br>
=A0uint16_t eth_mpls_depth(const struct ofpbuf *packet);<br>
<br>
-void set_ethertype(struct ofpbuf *packet, ovs_be16 eth_type);<br>
+void set_ethertype(struct ofpbuf *packet, ovs_be16 eth_type, bool inner);<=
br>
<br>
=A0const char *eth_from_hex(const char *hex, struct ofpbuf **packetp);<br>
=A0void eth_format_masked(const uint8_t eth[ETH_ADDR_LEN],<br>
diff --git a/ofproto/ofproto-dpif-xlate.c b/ofproto/ofproto-dpif-xlate.c<br=
>
index 8a0c32e..457a1d1 100644<br>
--- a/ofproto/ofproto-dpif-xlate.c<br>
+++ b/ofproto/ofproto-dpif-xlate.c<br>
@@ -1912,6 +1912,12 @@ tunnel_ecn_ok(struct xlate_ctx *ctx)<br>
=A0 =A0 =A0return true;<br>
=A0}<br>
<br>
+static bool<br>
+mpls_compat_behaviour(enum ofputil_action_code compat)<br>
+{<br>
+ =A0 =A0return (compat !=3D OFPUTIL_OFPAT13_PUSH_MPLS);<br>
+}<br>
+<br>
=A0static void<br>
=A0vlan_tci_restore(struct xlate_in *xin, ovs_be16 *tci_ptr, ovs_be16 orig_=
tci)<br>
=A0{<br>
@@ -2089,7 +2095,9 @@ do_xlate_actions(const struct ofpact *ofpacts, size_t=
 ofpacts_len,<br>
<br>
=A0 =A0 =A0 =A0 =A0 =A0 =A0/* Save and pop any existing VLAN tags if runnin=
g in OF1.2 mode. */<br>
=A0 =A0 =A0 =A0 =A0 =A0 =A0ctx-&gt;xin-&gt;vlan_tci =3D *vlan_tci;<br>
- =A0 =A0 =A0 =A0 =A0 =A0flow-&gt;vlan_tci =3D htons(0);<br>
+ =A0 =A0 =A0 =A0 =A0 =A0if (mpls_compat_behaviour(a-&gt;compat)) {<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0flow-&gt;vlan_tci =3D htons(0);<br>
+ =A0 =A0 =A0 =A0 =A0 =A0}<br>
=A0 =A0 =A0 =A0 =A0 =A0 =A0vlan_tci =3D &amp;ctx-&gt;xin-&gt;vlan_tci;<br>
=A0 =A0 =A0 =A0 =A0 =A0 =A0break;<br>
<br>
diff --git a/tests/<a href=3D"http://ofproto-dpif.at" target=3D"_blank">ofp=
roto-dpif.at</a> b/tests/<a href=3D"http://ofproto-dpif.at" target=3D"_blan=
k">ofproto-dpif.at</a><br>
index 62531da..5e85ab2 100644<br>
--- a/tests/<a href=3D"http://ofproto-dpif.at" target=3D"_blank">ofproto-dp=
if.at</a><br>
+++ b/tests/<a href=3D"http://ofproto-dpif.at" target=3D"_blank">ofproto-dp=
if.at</a><br>
@@ -1017,6 +1017,243 @@ NXST_FLOW reply:<br>
=A0OVS_VSWITCHD_STOP<br>
=A0AT_CLEANUP<br>
<br>
+AT_SETUP([ofproto-dpif - OF1.3+ VLAN+MPLS handling])<br>
+OVS_VSWITCHD_START([dnl<br>
+ =A0 add-port br0 p1 -- set Interface p1 type=3Ddummy<br>
+])<br>
+ON_EXIT([kill `cat ovs-ofctl.pid`])<br>
+<br>
+AT_CAPTURE_FILE([ofctl_monitor.log])<br>
+AT_DATA([flows.txt], [dnl<br>
+cookie=3D0xa dl_src=3D40:44:44:44:55:44 actions=3Dpush_mpls:0x8847,load:10=
-&gt;OXM_OF_MPLS_LABEL[[]],load:3-&gt;OXM_OF_MPLS_TC[[]],controller<br>
+cookie=3D0xa dl_src=3D40:44:44:44:55:45 actions=3Dpush_vlan:0x8100,mod_vla=
n_vid:99,push_mpls:0x8847,load:10-&gt;OXM_OF_MPLS_LABEL[[]],load:3-&gt;OXM_=
OF_MPLS_TC[[]],controller<br>
+cookie=3D0xa dl_src=3D40:44:44:44:55:46 actions=3Dpush_vlan:0x8100,mod_vla=
n_vid:99,push_mpls:0x8847,load:10-&gt;OXM_OF_MPLS_LABEL[[]],load:3-&gt;OXM_=
OF_MPLS_TC[[]],controller<br>
+cookie=3D0xa dl_src=3D40:44:44:44:55:47 actions=3Dpush_vlan:0x8100,load:99=
-&gt;OXM_OF_VLAN_VID[[]],push_mpls:0x8847,load:10-&gt;OXM_OF_MPLS_LABEL[[]]=
,load:3-&gt;OXM_OF_MPLS_TC[[]],controller<br>
+cookie=3D0xa dl_src=3D40:44:44:44:55:48 actions=3Dpush_vlan:0x8100,load:99=
-&gt;OXM_OF_VLAN_VID[[]],push_mpls:0x8847,load:10-&gt;OXM_OF_MPLS_LABEL[[]]=
,load:3-&gt;OXM_OF_MPLS_TC[[]],controller<br>
+cookie=3D0xa dl_src=3D40:44:44:44:55:49 actions=3Dpush_mpls:0x8847,load:10=
-&gt;OXM_OF_MPLS_LABEL[[]],load:3-&gt;OXM_OF_MPLS_TC[[]],push_vlan:0x8100,m=
od_vlan_vid:99,controller<br>
+cookie=3D0xa dl_src=3D40:44:44:44:55:50 actions=3Dpush_mpls:0x8847,load:10=
-&gt;OXM_OF_MPLS_LABEL[[]],load:3-&gt;OXM_OF_MPLS_TC[[]],push_vlan:0x8100,m=
od_vlan_vid:99,controller<br>
+cookie=3D0xa dl_src=3D40:44:44:44:55:51 actions=3Dpush_mpls:0x8847,load:10=
-&gt;OXM_OF_MPLS_LABEL[[]],load:3-&gt;OXM_OF_MPLS_TC[[]],push_vlan:0x8100,l=
oad:99-&gt;OXM_OF_VLAN_VID[[]],mod_vlan_pcp:1,controller<br>
+cookie=3D0xa dl_src=3D40:44:44:44:55:52 actions=3Dpush_mpls:0x8847,load:10=
-&gt;OXM_OF_MPLS_LABEL[[]],load:3-&gt;OXM_OF_MPLS_TC[[]],push_vlan:0x8100,l=
oad:99-&gt;OXM_OF_VLAN_VID[[]],mod_vlan_pcp:1,controller<br>
+])<br>
+AT_CHECK([ovs-ofctl --protocols=3DOpenFlow13 add-flows br0 flows.txt])<br>
+<br>
+dnl Modified MPLS controller action.<br>
+dnl The input packet has a VLAN tag, but because we push an MPLS tag in<br=
>
+dnl OF1.3 mode, we can no longer see it.<br>
+AT_CHECK([ovs-ofctl monitor br0 65534 -P nxm --detach --pidfile 2&gt; ofct=
l_monitor.log])<br>
+<br>
+for i in 1 2 3; do<br>
+ =A0 =A0ovs-appctl netdev-dummy/receive p1 &#39;in_port(1),eth(src=3D40:44=
:44:44:55:44,dst=3D50:54:00:00:00:07),eth_type(0x8100),vlan(vid=3D88,pcp=3D=
7),encap(eth_type(0x0800),ipv4(src=3D192.168.0.1,dst=3D192.168.0.2,proto=3D=
6,tos=3D0,ttl=3D64,frag=3Dno))&#39;<br>



+done<br>
+OVS_WAIT_UNTIL([test `wc -l &lt; ofctl_monitor.log` -ge 6])<br>
+ovs-appctl -t ovs-ofctl exit<br>
+<br>
+AT_CHECK([cat ofctl_monitor.log], [0], [dnl<br>
+NXT_PACKET_IN (xid=3D0x0): cookie=3D0xa total_len=3D64 in_port=3D1 (via ac=
tion) data_len=3D64 (unbuffered)<br>
+mpls,metadata=3D0,in_port=3D0,vlan_tci=3D0x0000,dl_src=3D40:44:44:44:55:44=
,dl_dst=3D50:54:00:00:00:07,mpls_label=3D10,mpls_tc=3D3,mpls_ttl=3D64,mpls_=
bos=3D1<br>
+dnl<br>
+NXT_PACKET_IN (xid=3D0x0): cookie=3D0xa total_len=3D64 in_port=3D1 (via ac=
tion) data_len=3D64 (unbuffered)<br>
+mpls,metadata=3D0,in_port=3D0,vlan_tci=3D0x0000,dl_src=3D40:44:44:44:55:44=
,dl_dst=3D50:54:00:00:00:07,mpls_label=3D10,mpls_tc=3D3,mpls_ttl=3D64,mpls_=
bos=3D1<br>
+dnl<br>
+NXT_PACKET_IN (xid=3D0x0): cookie=3D0xa total_len=3D64 in_port=3D1 (via ac=
tion) data_len=3D64 (unbuffered)<br>
+mpls,metadata=3D0,in_port=3D0,vlan_tci=3D0x0000,dl_src=3D40:44:44:44:55:44=
,dl_dst=3D50:54:00:00:00:07,mpls_label=3D10,mpls_tc=3D3,mpls_ttl=3D64,mpls_=
bos=3D1<br>
+])<br>
+<br>
+dnl Modified MPLS controller action.<br>
+dnl In this test, we push a VLAN tag, then an MPLS tag in OF1.3 mode, so w=
e<br>
+dnl can only see the MPLS tag in the result.<br>
+AT_CHECK([ovs-ofctl monitor br0 65534 -P nxm --detach --pidfile 2&gt; ofct=
l_monitor.log])<br>
+<br>
+for i in 1 2 3; do<br>
+ =A0 =A0ovs-appctl netdev-dummy/receive p1 &#39;in_port(1),eth(src=3D40:44=
:44:44:55:45,dst=3D50:54:00:00:00:07),eth_type(0x0800),ipv4(src=3D192.168.0=
.1,dst=3D192.168.0.2,proto=3D6,tos=3D0,ttl=3D64,frag=3Dno)&#39;<br>
+done<br>
+OVS_WAIT_UNTIL([test `wc -l &lt; ofctl_monitor.log` -ge 6])<br>
+ovs-appctl -t ovs-ofctl exit<br>
+<br>
+AT_CHECK([cat ofctl_monitor.log], [0], [dnl<br>
+NXT_PACKET_IN (xid=3D0x0): cookie=3D0xa total_len=3D68 in_port=3D1 (via ac=
tion) data_len=3D68 (unbuffered)<br>
+mpls,metadata=3D0,in_port=3D0,vlan_tci=3D0x0000,dl_src=3D40:44:44:44:55:45=
,dl_dst=3D50:54:00:00:00:07,mpls_label=3D10,mpls_tc=3D3,mpls_ttl=3D64,mpls_=
bos=3D1<br>
+dnl<br>
+NXT_PACKET_IN (xid=3D0x0): cookie=3D0xa total_len=3D68 in_port=3D1 (via ac=
tion) data_len=3D68 (unbuffered)<br>
+mpls,metadata=3D0,in_port=3D0,vlan_tci=3D0x0000,dl_src=3D40:44:44:44:55:45=
,dl_dst=3D50:54:00:00:00:07,mpls_label=3D10,mpls_tc=3D3,mpls_ttl=3D64,mpls_=
bos=3D1<br>
+dnl<br>
+NXT_PACKET_IN (xid=3D0x0): cookie=3D0xa total_len=3D68 in_port=3D1 (via ac=
tion) data_len=3D68 (unbuffered)<br>
+mpls,metadata=3D0,in_port=3D0,vlan_tci=3D0x0000,dl_src=3D40:44:44:44:55:45=
,dl_dst=3D50:54:00:00:00:07,mpls_label=3D10,mpls_tc=3D3,mpls_ttl=3D64,mpls_=
bos=3D1<br>
+])<br>
+<br>
+dnl Modified MPLS controller action.<br>
+dnl In this test, the input packet is vlan-tagged; we update this tag then=
<br>
+dnl push an MPLS tag in OF1.3 mode. As such, we can only see the MPLS tag =
in<br>
+dnl the result.<br>
+AT_CHECK([ovs-ofctl monitor br0 65534 -P nxm --detach --pidfile 2&gt; ofct=
l_monitor.log])<br>
+<br>
+for i in 1 2 3; do<br>
+ =A0 =A0ovs-appctl netdev-dummy/receive p1 &#39;in_port(1),eth(src=3D40:44=
:44:44:55:46,dst=3D50:54:00:00:00:07),eth_type(0x8100),vlan(vid=3D88,pcp=3D=
7),encap(eth_type(0x0800),ipv4(src=3D192.168.0.1,dst=3D192.168.0.2,proto=3D=
6,tos=3D0,ttl=3D64,frag=3Dno))&#39;<br>



+done<br>
+OVS_WAIT_UNTIL([test `wc -l &lt; ofctl_monitor.log` -ge 6])<br>
+ovs-appctl -t ovs-ofctl exit<br>
+<br>
+AT_CHECK([cat ofctl_monitor.log], [0], [dnl<br>
+NXT_PACKET_IN (xid=3D0x0): cookie=3D0xa total_len=3D64 in_port=3D1 (via ac=
tion) data_len=3D64 (unbuffered)<br>
+mpls,metadata=3D0,in_port=3D0,vlan_tci=3D0x0000,dl_src=3D40:44:44:44:55:46=
,dl_dst=3D50:54:00:00:00:07,mpls_label=3D10,mpls_tc=3D3,mpls_ttl=3D64,mpls_=
bos=3D1<br>
+dnl<br>
+NXT_PACKET_IN (xid=3D0x0): cookie=3D0xa total_len=3D64 in_port=3D1 (via ac=
tion) data_len=3D64 (unbuffered)<br>
+mpls,metadata=3D0,in_port=3D0,vlan_tci=3D0x0000,dl_src=3D40:44:44:44:55:46=
,dl_dst=3D50:54:00:00:00:07,mpls_label=3D10,mpls_tc=3D3,mpls_ttl=3D64,mpls_=
bos=3D1<br>
+dnl<br>
+NXT_PACKET_IN (xid=3D0x0): cookie=3D0xa total_len=3D64 in_port=3D1 (via ac=
tion) data_len=3D64 (unbuffered)<br>
+mpls,metadata=3D0,in_port=3D0,vlan_tci=3D0x0000,dl_src=3D40:44:44:44:55:46=
,dl_dst=3D50:54:00:00:00:07,mpls_label=3D10,mpls_tc=3D3,mpls_ttl=3D64,mpls_=
bos=3D1<br>
+])<br>
+<br>
+dnl Modified MPLS controller action.<br>
+dnl In this test, we push a VLAN tag, then an MPLS tag in OF1.3 mode, so w=
e<br>
+dnl can only see the MPLS tag in the result.<br>
+AT_CHECK([ovs-ofctl monitor br0 65534 -P nxm --detach --pidfile 2&gt; ofct=
l_monitor.log])<br>
+<br>
+for i in 1 2 3; do<br>
+ =A0 =A0ovs-appctl netdev-dummy/receive p1 &#39;in_port(1),eth(src=3D40:44=
:44:44:55:47,dst=3D50:54:00:00:00:07),eth_type(0x0800),ipv4(src=3D192.168.0=
.1,dst=3D192.168.0.2,proto=3D6,tos=3D0,ttl=3D64,frag=3Dno)&#39;<br>
+done<br>
+OVS_WAIT_UNTIL([test `wc -l &lt; ofctl_monitor.log` -ge 6])<br>
+ovs-appctl -t ovs-ofctl exit<br>
+<br>
+AT_CHECK([cat ofctl_monitor.log], [0], [dnl<br>
+NXT_PACKET_IN (xid=3D0x0): cookie=3D0xa total_len=3D68 in_port=3D1 (via ac=
tion) data_len=3D68 (unbuffered)<br>
+mpls,metadata=3D0,in_port=3D0,vlan_tci=3D0x0000,dl_src=3D40:44:44:44:55:47=
,dl_dst=3D50:54:00:00:00:07,mpls_label=3D10,mpls_tc=3D3,mpls_ttl=3D64,mpls_=
bos=3D1<br>
+dnl<br>
+NXT_PACKET_IN (xid=3D0x0): cookie=3D0xa total_len=3D68 in_port=3D1 (via ac=
tion) data_len=3D68 (unbuffered)<br>
+mpls,metadata=3D0,in_port=3D0,vlan_tci=3D0x0000,dl_src=3D40:44:44:44:55:47=
,dl_dst=3D50:54:00:00:00:07,mpls_label=3D10,mpls_tc=3D3,mpls_ttl=3D64,mpls_=
bos=3D1<br>
+dnl<br>
+NXT_PACKET_IN (xid=3D0x0): cookie=3D0xa total_len=3D68 in_port=3D1 (via ac=
tion) data_len=3D68 (unbuffered)<br>
+mpls,metadata=3D0,in_port=3D0,vlan_tci=3D0x0000,dl_src=3D40:44:44:44:55:47=
,dl_dst=3D50:54:00:00:00:07,mpls_label=3D10,mpls_tc=3D3,mpls_ttl=3D64,mpls_=
bos=3D1<br>
+])<br>
+<br>
+dnl Modified MPLS controller action.<br>
+dnl In this test, the input packet is vlan-tagged; we update this tag then=
<br>
+dnl push an MPLS tag in OF1.3 mode. As such, we can only see the MPLS tag =
in<br>
+dnl the result.<br>
+AT_CHECK([ovs-ofctl monitor br0 65534 -P nxm --detach --pidfile 2&gt; ofct=
l_monitor.log])<br>
+<br>
+for i in 1 2 3; do<br>
+ =A0 =A0ovs-appctl netdev-dummy/receive p1 &#39;in_port(1),eth(src=3D40:44=
:44:44:55:48,dst=3D50:54:00:00:00:07),eth_type(0x8100),vlan(vid=3D88,pcp=3D=
7),encap(eth_type(0x0800),ipv4(src=3D192.168.0.1,dst=3D192.168.0.2,proto=3D=
6,tos=3D0,ttl=3D64,frag=3Dno))&#39;<br>



+done<br>
+OVS_WAIT_UNTIL([test `wc -l &lt; ofctl_monitor.log` -ge 6])<br>
+ovs-appctl -t ovs-ofctl exit<br>
+<br>
+AT_CHECK([cat ofctl_monitor.log], [0], [dnl<br>
+NXT_PACKET_IN (xid=3D0x0): cookie=3D0xa total_len=3D64 in_port=3D1 (via ac=
tion) data_len=3D64 (unbuffered)<br>
+mpls,metadata=3D0,in_port=3D0,vlan_tci=3D0x0000,dl_src=3D40:44:44:44:55:48=
,dl_dst=3D50:54:00:00:00:07,mpls_label=3D10,mpls_tc=3D3,mpls_ttl=3D64,mpls_=
bos=3D1<br>
+dnl<br>
+NXT_PACKET_IN (xid=3D0x0): cookie=3D0xa total_len=3D64 in_port=3D1 (via ac=
tion) data_len=3D64 (unbuffered)<br>
+mpls,metadata=3D0,in_port=3D0,vlan_tci=3D0x0000,dl_src=3D40:44:44:44:55:48=
,dl_dst=3D50:54:00:00:00:07,mpls_label=3D10,mpls_tc=3D3,mpls_ttl=3D64,mpls_=
bos=3D1<br>
+dnl<br>
+NXT_PACKET_IN (xid=3D0x0): cookie=3D0xa total_len=3D64 in_port=3D1 (via ac=
tion) data_len=3D64 (unbuffered)<br>
+mpls,metadata=3D0,in_port=3D0,vlan_tci=3D0x0000,dl_src=3D40:44:44:44:55:48=
,dl_dst=3D50:54:00:00:00:07,mpls_label=3D10,mpls_tc=3D3,mpls_ttl=3D64,mpls_=
bos=3D1<br>
+])<br>
+<br>
+dnl Modified MPLS controller action.<br>
+dnl In this test, we push the MPLS tag before pushing a VLAN tag, so we se=
e<br>
+dnl both of these in the final flow.<br>
+AT_CHECK([ovs-ofctl monitor br0 65534 -P nxm --detach --pidfile 2&gt; ofct=
l_monitor.log])<br>
+<br>
+for i in 1 2 3; do<br>
+ =A0 =A0ovs-appctl netdev-dummy/receive p1 &#39;in_port(1),eth(src=3D40:44=
:44:44:55:49,dst=3D50:54:00:00:00:07),eth_type(0x0800),ipv4(src=3D192.168.0=
.1,dst=3D192.168.0.2,proto=3D6,tos=3D0,ttl=3D64,frag=3Dno)&#39;<br>
+done<br>
+OVS_WAIT_UNTIL([test `wc -l &lt; ofctl_monitor.log` -ge 6])<br>
+ovs-appctl -t ovs-ofctl exit<br>
+<br>
+AT_CHECK([cat ofctl_monitor.log], [0], [dnl<br>
+NXT_PACKET_IN (xid=3D0x0): cookie=3D0xa total_len=3D68 in_port=3D1 (via ac=
tion) data_len=3D68 (unbuffered)<br>
+mpls,metadata=3D0,in_port=3D0,dl_vlan=3D99,dl_vlan_pcp=3D0,dl_src=3D40:44:=
44:44:55:49,dl_dst=3D50:54:00:00:00:07,mpls_label=3D10,mpls_tc=3D3,mpls_ttl=
=3D64,mpls_bos=3D1<br>
+dnl<br>
+NXT_PACKET_IN (xid=3D0x0): cookie=3D0xa total_len=3D68 in_port=3D1 (via ac=
tion) data_len=3D68 (unbuffered)<br>
+mpls,metadata=3D0,in_port=3D0,dl_vlan=3D99,dl_vlan_pcp=3D0,dl_src=3D40:44:=
44:44:55:49,dl_dst=3D50:54:00:00:00:07,mpls_label=3D10,mpls_tc=3D3,mpls_ttl=
=3D64,mpls_bos=3D1<br>
+dnl<br>
+NXT_PACKET_IN (xid=3D0x0): cookie=3D0xa total_len=3D68 in_port=3D1 (via ac=
tion) data_len=3D68 (unbuffered)<br>
+mpls,metadata=3D0,in_port=3D0,dl_vlan=3D99,dl_vlan_pcp=3D0,dl_src=3D40:44:=
44:44:55:49,dl_dst=3D50:54:00:00:00:07,mpls_label=3D10,mpls_tc=3D3,mpls_ttl=
=3D64,mpls_bos=3D1<br>
+])<br>
+<br>
+dnl Modified MPLS controller action.<br>
+dnl In this test, the input packet in vlan-tagged, which should be strippe=
d<br>
+dnl before we push the MPLS and VLAN tags.<br>
+AT_CHECK([ovs-ofctl monitor br0 65534 -P nxm --detach --pidfile 2&gt; ofct=
l_monitor.log])<br>
+<br>
+for i in 1 2 3; do<br>
+ =A0 =A0ovs-appctl netdev-dummy/receive p1 &#39;in_port(1),eth(src=3D40:44=
:44:44:55:50,dst=3D50:54:00:00:00:07),eth_type(0x8100),vlan(vid=3D88,pcp=3D=
7),encap(eth_type(0x0800),ipv4(src=3D192.168.0.1,dst=3D192.168.0.2,proto=3D=
6,tos=3D0,ttl=3D64,frag=3Dno))&#39;<br>



+done<br>
+OVS_WAIT_UNTIL([test `wc -l &lt; ofctl_monitor.log` -ge 6])<br>
+ovs-appctl -t ovs-ofctl exit<br>
+<br>
+AT_CHECK([cat ofctl_monitor.log], [0], [dnl<br>
+NXT_PACKET_IN (xid=3D0x0): cookie=3D0xa total_len=3D68 in_port=3D1 (via ac=
tion) data_len=3D68 (unbuffered)<br>
+mpls,metadata=3D0,in_port=3D0,dl_vlan=3D99,dl_vlan_pcp=3D0,dl_src=3D40:44:=
44:44:55:50,dl_dst=3D50:54:00:00:00:07,mpls_label=3D10,mpls_tc=3D3,mpls_ttl=
=3D64,mpls_bos=3D1<br>
+dnl<br>
+NXT_PACKET_IN (xid=3D0x0): cookie=3D0xa total_len=3D68 in_port=3D1 (via ac=
tion) data_len=3D68 (unbuffered)<br>
+mpls,metadata=3D0,in_port=3D0,dl_vlan=3D99,dl_vlan_pcp=3D0,dl_src=3D40:44:=
44:44:55:50,dl_dst=3D50:54:00:00:00:07,mpls_label=3D10,mpls_tc=3D3,mpls_ttl=
=3D64,mpls_bos=3D1<br>
+dnl<br>
+NXT_PACKET_IN (xid=3D0x0): cookie=3D0xa total_len=3D68 in_port=3D1 (via ac=
tion) data_len=3D68 (unbuffered)<br>
+mpls,metadata=3D0,in_port=3D0,dl_vlan=3D99,dl_vlan_pcp=3D0,dl_src=3D40:44:=
44:44:55:50,dl_dst=3D50:54:00:00:00:07,mpls_label=3D10,mpls_tc=3D3,mpls_ttl=
=3D64,mpls_bos=3D1<br>
+])<br>
+<br>
+dnl Modified MPLS controller action.<br>
+dnl In this test, we push the MPLS tag before pushing a VLAN tag, so we se=
e<br>
+dnl both of these in the final flow.<br>
+AT_CHECK([ovs-ofctl monitor br0 65534 -P nxm --detach --pidfile 2&gt; ofct=
l_monitor.log])<br>
+<br>
+for i in 1 2 3; do<br>
+ =A0 =A0ovs-appctl netdev-dummy/receive p1 &#39;in_port(1),eth(src=3D40:44=
:44:44:55:51,dst=3D50:54:00:00:00:07),eth_type(0x0800),ipv4(src=3D192.168.0=
.1,dst=3D192.168.0.2,proto=3D6,tos=3D0,ttl=3D64,frag=3Dno)&#39;<br>
+done<br>
+OVS_WAIT_UNTIL([test `wc -l &lt; ofctl_monitor.log` -ge 6])<br>
+ovs-appctl -t ovs-ofctl exit<br>
+<br>
+AT_CHECK([cat ofctl_monitor.log], [0], [dnl<br>
+NXT_PACKET_IN (xid=3D0x0): cookie=3D0xa total_len=3D68 in_port=3D1 (via ac=
tion) data_len=3D68 (unbuffered)<br>
+mpls,metadata=3D0,in_port=3D0,dl_vlan=3D99,dl_vlan_pcp=3D1,dl_src=3D40:44:=
44:44:55:51,dl_dst=3D50:54:00:00:00:07,mpls_label=3D10,mpls_tc=3D3,mpls_ttl=
=3D64,mpls_bos=3D1<br>
+dnl<br>
+NXT_PACKET_IN (xid=3D0x0): cookie=3D0xa total_len=3D68 in_port=3D1 (via ac=
tion) data_len=3D68 (unbuffered)<br>
+mpls,metadata=3D0,in_port=3D0,dl_vlan=3D99,dl_vlan_pcp=3D1,dl_src=3D40:44:=
44:44:55:51,dl_dst=3D50:54:00:00:00:07,mpls_label=3D10,mpls_tc=3D3,mpls_ttl=
=3D64,mpls_bos=3D1<br>
+dnl<br>
+NXT_PACKET_IN (xid=3D0x0): cookie=3D0xa total_len=3D68 in_port=3D1 (via ac=
tion) data_len=3D68 (unbuffered)<br>
+mpls,metadata=3D0,in_port=3D0,dl_vlan=3D99,dl_vlan_pcp=3D1,dl_src=3D40:44:=
44:44:55:51,dl_dst=3D50:54:00:00:00:07,mpls_label=3D10,mpls_tc=3D3,mpls_ttl=
=3D64,mpls_bos=3D1<br>
+])<br>
+<br>
+dnl Modified MPLS controller action.<br>
+dnl In this test, the input packet in vlan-tagged, which should be strippe=
d<br>
+dnl before we push the MPLS and VLAN tags.<br>
+AT_CHECK([ovs-ofctl monitor br0 65534 -P nxm --detach --pidfile 2&gt; ofct=
l_monitor.log])<br>
+<br>
+for i in 1 2 3; do<br>
+ =A0 =A0ovs-appctl netdev-dummy/receive p1 &#39;in_port(1),eth(src=3D40:44=
:44:44:55:52,dst=3D50:54:00:00:00:07),eth_type(0x8100),vlan(vid=3D88,pcp=3D=
7),encap(eth_type(0x0800),ipv4(src=3D192.168.0.1,dst=3D192.168.0.2,proto=3D=
6,tos=3D0,ttl=3D64,frag=3Dno))&#39;<br>



+done<br>
+OVS_WAIT_UNTIL([test `wc -l &lt; ofctl_monitor.log` -ge 6])<br>
+ovs-appctl -t ovs-ofctl exit<br>
+<br>
+AT_CHECK([cat ofctl_monitor.log], [0], [dnl<br>
+NXT_PACKET_IN (xid=3D0x0): cookie=3D0xa total_len=3D68 in_port=3D1 (via ac=
tion) data_len=3D68 (unbuffered)<br>
+mpls,metadata=3D0,in_port=3D0,dl_vlan=3D99,dl_vlan_pcp=3D1,dl_src=3D40:44:=
44:44:55:52,dl_dst=3D50:54:00:00:00:07,mpls_label=3D10,mpls_tc=3D3,mpls_ttl=
=3D64,mpls_bos=3D1<br>
+dnl<br>
+NXT_PACKET_IN (xid=3D0x0): cookie=3D0xa total_len=3D68 in_port=3D1 (via ac=
tion) data_len=3D68 (unbuffered)<br>
+mpls,metadata=3D0,in_port=3D0,dl_vlan=3D99,dl_vlan_pcp=3D1,dl_src=3D40:44:=
44:44:55:52,dl_dst=3D50:54:00:00:00:07,mpls_label=3D10,mpls_tc=3D3,mpls_ttl=
=3D64,mpls_bos=3D1<br>
+dnl<br>
+NXT_PACKET_IN (xid=3D0x0): cookie=3D0xa total_len=3D68 in_port=3D1 (via ac=
tion) data_len=3D68 (unbuffered)<br>
+mpls,metadata=3D0,in_port=3D0,dl_vlan=3D99,dl_vlan_pcp=3D1,dl_src=3D40:44:=
44:44:55:52,dl_dst=3D50:54:00:00:00:07,mpls_label=3D10,mpls_tc=3D3,mpls_ttl=
=3D64,mpls_bos=3D1<br>
+])<br>
+<br>
+AT_CHECK([ovs-appctl time/warp 5000], [0], [ignore])<br>
+AT_CHECK([ovs-ofctl dump-flows br0 | ofctl_strip | sort], [0], [dnl<br>
+ cookie=3D0xa, n_packets=3D3, n_bytes=3D180, dl_src=3D40:44:44:44:55:44 ac=
tions=3Dpush_mpls:0x8847,load:0xa-&gt;OXM_OF_MPLS_LABEL[[]],load:0x3-&gt;OX=
M_OF_MPLS_TC[[]],CONTROLLER:65535<br>
+ cookie=3D0xa, n_packets=3D3, n_bytes=3D180, dl_src=3D40:44:44:44:55:45 ac=
tions=3Dmod_vlan_vid:99,push_mpls:0x8847,load:0xa-&gt;OXM_OF_MPLS_LABEL[[]]=
,load:0x3-&gt;OXM_OF_MPLS_TC[[]],CONTROLLER:65535<br>
+ cookie=3D0xa, n_packets=3D3, n_bytes=3D180, dl_src=3D40:44:44:44:55:46 ac=
tions=3Dmod_vlan_vid:99,push_mpls:0x8847,load:0xa-&gt;OXM_OF_MPLS_LABEL[[]]=
,load:0x3-&gt;OXM_OF_MPLS_TC[[]],CONTROLLER:65535<br>
+ cookie=3D0xa, n_packets=3D3, n_bytes=3D180, dl_src=3D40:44:44:44:55:47 ac=
tions=3Dload:0x63-&gt;OXM_OF_VLAN_VID[[]],push_mpls:0x8847,load:0xa-&gt;OXM=
_OF_MPLS_LABEL[[]],load:0x3-&gt;OXM_OF_MPLS_TC[[]],CONTROLLER:65535<br>
+ cookie=3D0xa, n_packets=3D3, n_bytes=3D180, dl_src=3D40:44:44:44:55:48 ac=
tions=3Dload:0x63-&gt;OXM_OF_VLAN_VID[[]],push_mpls:0x8847,load:0xa-&gt;OXM=
_OF_MPLS_LABEL[[]],load:0x3-&gt;OXM_OF_MPLS_TC[[]],CONTROLLER:65535<br>
+ cookie=3D0xa, n_packets=3D3, n_bytes=3D180, dl_src=3D40:44:44:44:55:49 ac=
tions=3Dpush_mpls:0x8847,load:0xa-&gt;OXM_OF_MPLS_LABEL[[]],load:0x3-&gt;OX=
M_OF_MPLS_TC[[]],mod_vlan_vid:99,CONTROLLER:65535<br>
+ cookie=3D0xa, n_packets=3D3, n_bytes=3D180, dl_src=3D40:44:44:44:55:50 ac=
tions=3Dpush_mpls:0x8847,load:0xa-&gt;OXM_OF_MPLS_LABEL[[]],load:0x3-&gt;OX=
M_OF_MPLS_TC[[]],mod_vlan_vid:99,CONTROLLER:65535<br>
+ cookie=3D0xa, n_packets=3D3, n_bytes=3D180, dl_src=3D40:44:44:44:55:51 ac=
tions=3Dpush_mpls:0x8847,load:0xa-&gt;OXM_OF_MPLS_LABEL[[]],load:0x3-&gt;OX=
M_OF_MPLS_TC[[]],load:0x63-&gt;OXM_OF_VLAN_VID[[]],mod_vlan_pcp:1,CONTROLLE=
R:65535<br>



+ cookie=3D0xa, n_packets=3D3, n_bytes=3D180, dl_src=3D40:44:44:44:55:52 ac=
tions=3Dpush_mpls:0x8847,load:0xa-&gt;OXM_OF_MPLS_LABEL[[]],load:0x3-&gt;OX=
M_OF_MPLS_TC[[]],load:0x63-&gt;OXM_OF_VLAN_VID[[]],mod_vlan_pcp:1,CONTROLLE=
R:65535<br>



+NXST_FLOW reply:<br>
+])<br>
+<br>
+OVS_VSWITCHD_STOP<br>
+AT_CLEANUP<br>
+<br>
=A0AT_SETUP([ofproto-dpif - fragment handling])<br>
=A0OVS_VSWITCHD_START<br>
=A0ADD_OF_PORTS([br0], [1], [2], [3], [4], [5], [6], [90])<br>
<span><font color=3D"#888888">--<br>
1.7.10.4<br>
<br>
</font></span></blockquote></div><br></div></div>

--001a11c3f2e2b8d4df04e33dd9f6--

--===============0882345905==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline


--===============0882345905==--
