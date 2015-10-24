From: Yuchung Cheng <ycheng@google.com>
Subject: Re: [PATCH RFC net-next 0/2] tcp: Redundant Data Bundling (RDB)
Date: Fri, 23 Oct 2015 23:11:00 -0700
Message-ID: <CAK6E8=eSYoxo6BLPh=jpmfudcRSJ3uT3YhZ0n-XP_dnxKCNH3A@mail.gmail.com>
References: <1445633413-3532-1-git-send-email-bro.devel+kernel@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>,
	Jonathan Corbet <corbet@lwn.net>,
	Eric Dumazet <edumazet@google.com>,
	Neal Cardwell <ncardwell@google.com>,
	Tom Herbert <tom@herbertland.com>,
	Paolo Abeni <pabeni@redhat.com>, Erik Kline <ek@google.com>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Al Viro <viro@zeniv.linux.org.uk>,
	Jiri Pirko <jiri@resnulli.us>,
	Alexander Duyck <alexander.h.duyck@redhat.com>,
	Florian Westphal <fw@strlen.de>,
	Daniel Lee <Longinus00@gmail.com>,
	Marcelo Ricardo Leitner <mleitner@redhat.com>,
	Daniel Borkmann <daniel@iogearbox.net>,
	Willem de Bruijn <willemb@google.com>,
	=?UTF-8?Q?Linus_L=C3=BCssing?= <linus.luessing@c0d3.blue>,
	linux-doc@vger.kernel.org,
	"linux-kernel@vger.kernel.org"
To: =?UTF-8?Q?Bendik_R=C3=B8nning_Opstad?= <bro.devel@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1445633413-3532-1-git-send-email-bro.devel+kernel@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Oct 23, 2015 at 1:50 PM, Bendik R=C3=B8nning Opstad
<bro.devel@gmail.com> wrote:
>
> This is a request for comments.
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
> show that, by imposing restrictions on the bundling rate, it can be m=
ade
> not to negatively affect competing traffic in an unfair manner.
>
> Note: Current patch set depends on a recently submitted patch for
> tcp_skb_cb (tcp: refactor struct tcp_skb_cb: http://patchwork.ozlabs.=
org/patch/510674)
>
> These patches have been tested with as set of packetdrill scripts loc=
ated at
> https://github.com/bendikro/packetdrill/tree/master/gtests/net/packet=
drill/tests/linux/rdb
> (The tests require patching packetdrill with a new socket option:
> https://github.com/bendikro/packetdrill/commit/9916b6c53e33dd04329d29=
b7d8baf703b2c2ac1b)
>
> Detailed info about the RDB mechanism can be found at
> http://mlab.no/blog/2015/10/redundant-data-bundling-in-tcp, as well a=
s in the paper

What's the difference between RDB and TCP repacketization
(http://flylib.com/books/en/3.223.1.226/1/) ?

Reading the blog page, I am concerned the amount of
change (esp on fast path) just to bundle new writes during timeout &
retransmit, for a specific type of application? why not just send X
packets with total bytes < MSS on timeout..

> "Latency and Fairness Trade-Off for Thin Streams using Redundant Data
> Bundling in TCP"[2].
>
> [1] http://home.ifi.uio.no/paalh/students/BendikOpstad.pdf
> [2] http://home.ifi.uio.no/bendiko/rdb_fairness_tradeoff.pdf
>
>
> Bendik R=C3=B8nning Opstad (2):
>   tcp: Add DPIFL thin stream detection mechanism
>   tcp: Add Redundant Data Bundling (RDB)
>
>  Documentation/networking/ip-sysctl.txt |  23 +++
>  include/linux/skbuff.h                 |   1 +
>  include/linux/tcp.h                    |   9 +-
>  include/net/tcp.h                      |  34 ++++
>  include/uapi/linux/tcp.h               |   1 +
>  net/core/skbuff.c                      |   3 +-
>  net/ipv4/Makefile                      |   3 +-
>  net/ipv4/sysctl_net_ipv4.c             |  35 ++++
>  net/ipv4/tcp.c                         |  19 ++-
>  net/ipv4/tcp_input.c                   |   3 +
>  net/ipv4/tcp_output.c                  |  11 +-
>  net/ipv4/tcp_rdb.c                     | 281 +++++++++++++++++++++++=
++++++++++
>  12 files changed, 415 insertions(+), 8 deletions(-)
>  create mode 100644 net/ipv4/tcp_rdb.c
>
> --
> 1.9.1
>
