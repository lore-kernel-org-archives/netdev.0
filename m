From: Joe Stringer <joestringer@nicira.com>
Subject: Re: [PATCH net-next 1/9] openvswitch: Scrub packet in ovs_vport_receive()
Date: Thu, 30 Jul 2015 16:16:49 -0700
Message-ID: <CANr6G5wRS1zg4oLdS5L4gM7iCS11BHb7+8uUN1fh5Oa9F4_BBw@mail.gmail.com>
References: <1438279963-29563-1-git-send-email-joestringer@nicira.com>
 <1438279963-29563-2-git-send-email-joestringer@nicira.com> <20150730184010.GC11177@pox.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Netdev List <netdev@vger.kernel.org>,
	Linux Kernel <linux-kernel@vger.kernel.org>,
	Pablo Neira Ayuso <pablo@netfilter.org>,
	Patrick McHardy <kaber@trash.net>,
	Justin Pettit <jpettit@nicira.com>,
	Pravin Shelar <pshelar@nicira.com>,
	Andy Zhou <azhou@nicira.com>, Jesse Gross <jesse@nicira.com>,
	Florian Westphal <fwestpha@redhat.com>,
	Hannes Sowa <hannes@redhat.com>
To: Thomas Graf <tgraf@suug.ch>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20150730184010.GC11177@pox.localdomain>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 30 July 2015 at 11:40, Thomas Graf <tgraf@suug.ch> wrote:
> On 07/30/15 at 11:12am, Joe Stringer wrote:
>> Signed-off-by: Joe Stringer <joestringer@nicira.com>
>
> Can you write a few lines on why this is needed? I have flows which
> use the mark to communicate with netfilter through internal ports.

The problem I was seeing is when packets come from a different
namespace on the localhost, they still have conntrack data associated.
This doesn't make sense, so the intention is to perform nf_reset().
However, it seems like we should actually be doing a bit more - at
least the skb_dst_drop() and perhaps some of the other stuff in
skb_scrub_packet().

Do you want to retain the mark when transitioning between namespaces?

Perhaps something like the below incremental would be sufficient:

diff --git a/net/openvswitch/vport.c b/net/openvswitch/vport.c
index 8a63df6..82844e6 100644
--- a/net/openvswitch/vport.c
+++ b/net/openvswitch/vport.c
@@ -475,7 +475,9 @@ void ovs_vport_receive(struct vport *vport, struct
sk_buff *skb,
        struct sw_flow_key key;
        int error;

-       if (!skb->sk || (sock_net(skb->sk) != read_pnet(&vport->dp->net)))
+       if (!skb->sk)
+               skb_scrub_packet(skb, false);
+       else if (sock_net(skb->sk) != read_pnet(&vport->dp->net))
                skb_scrub_packet(skb, true);

        stats = this_cpu_ptr(vport->percpu_stats);
