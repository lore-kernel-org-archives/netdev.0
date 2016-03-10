From: Yuchung Cheng <ycheng@google.com>
Subject: Re: [PATCH v6 net-next 0/2] tcp: Redundant Data Bundling (RDB)
Date: Wed, 9 Mar 2016 16:20:22 -0800
Message-ID: <CAK6E8=eKu_0ReSDLYdyajxMyX2MaN=wDLHvq=u_tyNnMRS31sw@mail.gmail.com>
References: <1445633413-3532-1-git-send-email-bro.devel+kernel@gmail.com> <1457028388-18226-1-git-send-email-bro.devel+kernel@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Neal Cardwell <ncardwell@google.com>,
	Andreas Petlund <apetlund@simula.no>,
	Carsten Griwodz <griff@simula.no>,
	=?UTF-8?Q?P=C3=A5l_Halvorsen?= <paalh@simula.no>,
	Jonas Markussen <jonassm@ifi.uio.no>,
	Kristian Evensen <kristian.evensen@gmail.com>,
	Kenneth Klette Jonassen <kennetkl@ifi.uio.no>
To: =?UTF-8?Q?Bendik_R=C3=B8nning_Opstad?= <bro.devel@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f41.google.com ([74.125.82.41]:36840 "EHLO
	mail-wm0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754008AbcCJAVE convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Mar 2016 19:21:04 -0500
Received: by mail-wm0-f41.google.com with SMTP id n186so7969628wmn.1
        for <netdev@vger.kernel.org>; Wed, 09 Mar 2016 16:21:03 -0800 (PST)
In-Reply-To: <1457028388-18226-1-git-send-email-bro.devel+kernel@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Mar 3, 2016 at 10:06 AM, Bendik R=C3=B8nning Opstad
<bro.devel@gmail.com> wrote:
>
> Redundant Data Bundling (RDB) is a mechanism for TCP aimed at reducin=
g
> the latency for applications sending time-dependent data.
> Latency-sensitive applications or services, such as online games and
> remote desktop, produce traffic with thin-stream characteristics,
> characterized by small packets and a relatively high ITT. By bundling
> already sent data in packets with new data, RDB alleviates head-of-li=
ne
> blocking by reducing the need to retransmit data segments when packet=
s
> are lost. RDB is a continuation on the work on latency improvements f=
or
> TCP in Linux, previously resulting in two thin-stream mechanisms in t=
he
> Linux kernel
> (https://github.com/torvalds/linux/blob/master/Documentation/networki=
ng/tcp-thin.txt).
>
> The RDB implementation has been thoroughly tested, and shows
> significant latency reductions when packet loss occurs[1]. The tests
> show that, by imposing restrictions on the bundling rate, it can be
> made not to negatively affect competing traffic in an unfair manner.
>
> Note: Current patch set depends on the patch "tcp: refactor struct tc=
p_skb_cb"
> (http://patchwork.ozlabs.org/patch/510674)
>
> These patches have also been tested with as set of packetdrill script=
s
> located at
> https://github.com/bendikro/packetdrill/tree/master/gtests/net/packet=
drill/tests/linux/rdb
> (The tests require patching packetdrill with a new socket option:
> https://github.com/bendikro/packetdrill/commit/9916b6c53e33dd04329d29=
b7d8baf703b2c2ac1b)
>
> Detailed info about the RDB mechanism can be found at
> http://mlab.no/blog/2015/10/redundant-data-bundling-in-tcp, as well a=
s
> in the paper "Latency and Fairness Trade-Off for Thin Streams using
> Redundant Data Bundling in TCP"[2].
>
> [1] http://home.ifi.uio.no/paalh/students/BendikOpstad.pdf
> [2] http://home.ifi.uio.no/bendiko/rdb_fairness_tradeoff.pdf
I read the paper. I think the underlying idea is neat. but the
implementation is little heavy-weight that requires changes on fast
path (tcp_write_xmit) and space in skb control blocks. ultimately this
patch is meant for a small set of specific applications.

In my mental model (please correct me if I am wrong), losses on these
thin streams would mostly resort to RTOs instead of fast recovery, due
to the bursty nature of Internet losses. The HOLB comes from RTO only
retransmit the first (tiny) unacked packet while a small of new data is
readily available. But since Linux congestion control is packet-based,
and loss cwnd is 1, the new data needs to wait until the 1st packet is
acked which is for another RTT.

Instead what if we only perform RDB on the (first and recurring) RTO
retransmission?

PS. I don't understand how (old) RDB can masquerade the losses by
skipping DUPACKs. Perhaps an example helps. Suppose we send 4 packets
and the last 3 were (s)acked. We perform RDB to send a packet that has
previous 4 payloads + 1 new byte. The sender still gets the loss
information?

>
> Changes:
>
> v6 (PATCH):
>  * tcp-Add-Redundant-Data-Bundling-RDB:
>    * Renamed rdb_ack_event() to tcp_rdb_ack_event() (Thanks DaveM)
>    * Minor doc changes
>
>  * tcp-Add-DPIFL-thin-stream-detection-mechanism:
>    * Minor doc changes
>
> v5 (PATCH):
>  * tcp-Add-Redundant-Data-Bundling-RDB:
>    * Removed two unnecessary EXPORT_SYMOBOLs (Thanks Eric)
>    * Renamed skb_append_data() to tcp_skb_append_data() (Thanks Eric)
>    * Fixed bugs in additions to ipv4_table (sysctl_net_ipv4.c)
>    * Merged the two if tests for max payload of RDB packet in
>      rdb_can_bundle_test()
>    * Renamed rdb_check_rtx_queue_loss() to rdb_detect_loss()
>      and restructured to reduce indentation.
>    * Improved docs
>    * Revised commit message to be more detailed.
>
>  * tcp-Add-DPIFL-thin-stream-detection-mechanism:
>    * Fixed bug in additions to ipv4_table (sysctl_net_ipv4.c)
>
> v4 (PATCH):
>  * tcp-Add-Redundant-Data-Bundling-RDB:
>    * Moved skb_append_data() to tcp_output.c and call this
>      function from tcp_collapse_retrans() as well.
>    * Merged functionality of create_rdb_skb() into
>      tcp_transmit_rdb_skb()
>    * Removed one parameter from rdb_can_bundle_test()
>
> v3 (PATCH):
>  * tcp-Add-Redundant-Data-Bundling-RDB:
>    * Changed name of sysctl variable from tcp_rdb_max_skbs to
>      tcp_rdb_max_packets after comment from Eric Dumazet about
>      not exposing internal (kernel) names like skb.
>    * Formatting and function docs fixes
>
> v2 (RFC/PATCH):
>  * tcp-Add-DPIFL-thin-stream-detection-mechanism:
>    * Change calculation in tcp_stream_is_thin_dpifl based on
>      feedback from Eric Dumazet.
>
>  * tcp-Add-Redundant-Data-Bundling-RDB:
>    * Removed setting nonagle in do_tcp_setsockopt (TCP_RDB)
>      to reduce complexity as commented by Neal Cardwell.
>    * Cleaned up loss detection code in rdb_check_rtx_queue_loss
>
> v1 (RFC/PATCH)
>
>
> Bendik R=C3=B8nning Opstad (2):
>   tcp: Add DPIFL thin stream detection mechanism
>   tcp: Add Redundant Data Bundling (RDB)
>
>  Documentation/networking/ip-sysctl.txt |  23 ++++
>  include/linux/skbuff.h                 |   1 +
>  include/linux/tcp.h                    |   3 +-
>  include/net/tcp.h                      |  36 ++++++
>  include/uapi/linux/tcp.h               |   1 +
>  net/core/skbuff.c                      |   2 +-
>  net/ipv4/Makefile                      |   3 +-
>  net/ipv4/sysctl_net_ipv4.c             |  34 +++++
>  net/ipv4/tcp.c                         |  16 ++-
>  net/ipv4/tcp_input.c                   |   3 +
>  net/ipv4/tcp_output.c                  |  48 ++++---
>  net/ipv4/tcp_rdb.c                     | 228 +++++++++++++++++++++++=
++++++++++
>  12 files changed, 375 insertions(+), 23 deletions(-)
>  create mode 100644 net/ipv4/tcp_rdb.c
>
> --
> 1.9.1
>
