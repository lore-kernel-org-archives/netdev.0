From: Andreas Schultz <aschultz@tpip.net>
Subject: Re: [PATCH net-next v4 4/7] gtp: consolidate gtp socket rx path
Date: Thu, 23 Feb 2017 10:19:51 +0100 (CET)
Message-ID: <754038178.195270.1487841591136.JavaMail.zimbra@tpip.net>
References: <20170221101855.23940-1-aschultz@tpip.net> <20170221101855.23940-5-aschultz@tpip.net> <CALx6S34-H9rzbJjJRGkRqswnOFK7pKg0gMU+JkgK=Nh77dWoiQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: pablo <pablo@netfilter.org>, netdev <netdev@vger.kernel.org>,
        laforge <laforge@gnumonks.org>,
        osmocom-net-gprs <osmocom-net-gprs@lists.osmocom.org>,
        timo lindhorst <timo.lindhorst@travelping.com>
To: Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.tpip.net ([92.43.49.48]:52627 "EHLO mail.tpip.net"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750952AbdBWJT5 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 23 Feb 2017 04:19:57 -0500
In-Reply-To: <CALx6S34-H9rzbJjJRGkRqswnOFK7pKg0gMU+JkgK=Nh77dWoiQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Tom,

----- On Feb 22, 2017, at 6:41 PM, Tom Herbert tom@herbertland.com wrote:

> On Tue, Feb 21, 2017 at 2:18 AM, Andreas Schultz <aschultz@tpip.net> wrote:
>> Add network device to gtp context in preparation for splitting
>> the TEID from the network device.
>>
>> Use this to rework the socker rx path. Move the common RX part
>> of v0 and v1 into a helper. Also move the final rx part into
>> that helper as well.
>>
> Andeas,
> 
> How are these GTP kernel patches being tested?

We rn each version in a test setup with a ePDG and a SGW that
connects to a full GGSN/P-GW instance (based on erGW).
We also run performance test (less often) with a commercial
test software.

> Is it possible to > create some sort of GTP network device
> that separates out just the datapath for development in the
> same way that VXLAN did this?

We had this discussion about another patch:
(http://marc.info/?l=linux-netdev&m=148611438811696&w=2)

Currently the kernel module only supports the GGSN/P-GW side
of the GTP tunnel. This is because we check the UE IP address
in the GTP socket and use the destination IP in the network
interface to find the PDP context.

For a deployment in a real EPC, doing it the other way makes no
sense with the current code. However for a test setup it makes
perfect sense (either to use it as a driver to test other GTP
nodes or to test out own implementation).

So, I hope that we can integrate this soonish.

libgtpnl contains two tools that be used for testing. gtp-link
creates a network device and GTP sockets and keeps them alive.
gtp-tunnel can then be used add PDP context to that. The only
missing part for a bidirectional test setup is the above
mentioned patch with the direction flag and support for that
in the libgtpnl tools.

Adding static tunnel support into the kernel module in any form
makes IMHO no sense. GTP as defined by 3GPP always need a control
instance and there are much better options for static tunnel
encapsulations.

Andreas

> 
> Tom
> 
>> Signed-off-by: Andreas Schultz <aschultz@tpip.net>
>> ---
>>  drivers/net/gtp.c | 80 ++++++++++++++++++++++++++++++-------------------------
>>  1 file changed, 44 insertions(+), 36 deletions(-)
>>
>> diff --git a/drivers/net/gtp.c b/drivers/net/gtp.c
>> index 961fb3c..fc0fff5 100644
>> --- a/drivers/net/gtp.c
>> +++ b/drivers/net/gtp.c
>> @@ -58,6 +58,8 @@ struct pdp_ctx {
>>         struct in_addr          ms_addr_ip4;
>>         struct in_addr          sgsn_addr_ip4;
>>
>> +       struct net_device       *dev;
>> +
>>         atomic_t                tx_seq;
>>         struct rcu_head         rcu_head;
>>  };
>> @@ -175,6 +177,40 @@ static bool gtp_check_src_ms(struct sk_buff *skb, struct
>> pdp_ctx *pctx,
>>         return false;
>>  }
>>
>> +static int gtp_rx(struct pdp_ctx *pctx, struct sk_buff *skb, unsigned int
>> hdrlen,
>> +                 bool xnet)
>> +{
>> +       struct pcpu_sw_netstats *stats;
>> +
>> +       if (!gtp_check_src_ms(skb, pctx, hdrlen)) {
>> +               netdev_dbg(pctx->dev, "No PDP ctx for this MS\n");
>> +               return 1;
>> +       }
>> +
>> +       /* Get rid of the GTP + UDP headers. */
>> +       if (iptunnel_pull_header(skb, hdrlen, skb->protocol, xnet))
>> +               return -1;
>> +
>> +       netdev_dbg(pctx->dev, "forwarding packet from GGSN to uplink\n");
>> +
>> +       /* Now that the UDP and the GTP header have been removed, set up the
>> +        * new network header. This is required by the upper layer to
>> +        * calculate the transport header.
>> +        */
>> +       skb_reset_network_header(skb);
>> +
>> +       skb->dev = pctx->dev;
>> +
>> +       stats = this_cpu_ptr(pctx->dev->tstats);
>> +       u64_stats_update_begin(&stats->syncp);
>> +       stats->rx_packets++;
>> +       stats->rx_bytes += skb->len;
>> +       u64_stats_update_end(&stats->syncp);
>> +
>> +       netif_rx(skb);
>> +       return 0;
>> +}
>> +
>>  /* 1 means pass up to the stack, -1 means drop and 0 means decapsulated. */
>>  static int gtp0_udp_encap_recv(struct gtp_dev *gtp, struct sk_buff *skb,
>>                                bool xnet)
>> @@ -201,13 +237,7 @@ static int gtp0_udp_encap_recv(struct gtp_dev *gtp, struct
>> sk_buff *skb,
>>                 return 1;
>>         }
>>
>> -       if (!gtp_check_src_ms(skb, pctx, hdrlen)) {
>> -               netdev_dbg(gtp->dev, "No PDP ctx for this MS\n");
>> -               return 1;
>> -       }
>> -
>> -       /* Get rid of the GTP + UDP headers. */
>> -       return iptunnel_pull_header(skb, hdrlen, skb->protocol, xnet);
>> +       return gtp_rx(pctx, skb, hdrlen, xnet);
>>  }
>>
>>  static int gtp1u_udp_encap_recv(struct gtp_dev *gtp, struct sk_buff *skb,
>> @@ -250,13 +280,7 @@ static int gtp1u_udp_encap_recv(struct gtp_dev *gtp, struct
>> sk_buff *skb,
>>                 return 1;
>>         }
>>
>> -       if (!gtp_check_src_ms(skb, pctx, hdrlen)) {
>> -               netdev_dbg(gtp->dev, "No PDP ctx for this MS\n");
>> -               return 1;
>> -       }
>> -
>> -       /* Get rid of the GTP + UDP headers. */
>> -       return iptunnel_pull_header(skb, hdrlen, skb->protocol, xnet);
>> +       return gtp_rx(pctx, skb, hdrlen, xnet);
>>  }
>>
>>  static void gtp_encap_destroy(struct sock *sk)
>> @@ -290,10 +314,9 @@ static void gtp_encap_disable(struct gtp_dev *gtp)
>>   */
>>  static int gtp_encap_recv(struct sock *sk, struct sk_buff *skb)
>>  {
>> -       struct pcpu_sw_netstats *stats;
>>         struct gtp_dev *gtp;
>> +       int ret = 0;
>>         bool xnet;
>> -       int ret;
>>
>>         gtp = rcu_dereference_sk_user_data(sk);
>>         if (!gtp)
>> @@ -319,33 +342,17 @@ static int gtp_encap_recv(struct sock *sk, struct sk_buff
>> *skb)
>>         switch (ret) {
>>         case 1:
>>                 netdev_dbg(gtp->dev, "pass up to the process\n");
>> -               return 1;
>> +               break;
>>         case 0:
>> -               netdev_dbg(gtp->dev, "forwarding packet from GGSN to uplink\n");
>>                 break;
>>         case -1:
>>                 netdev_dbg(gtp->dev, "GTP packet has been dropped\n");
>>                 kfree_skb(skb);
>> -               return 0;
>> +               ret = 0;
>> +               break;
>>         }
>>
>> -       /* Now that the UDP and the GTP header have been removed, set up the
>> -        * new network header. This is required by the upper layer to
>> -        * calculate the transport header.
>> -        */
>> -       skb_reset_network_header(skb);
>> -
>> -       skb->dev = gtp->dev;
>> -
>> -       stats = this_cpu_ptr(gtp->dev->tstats);
>> -       u64_stats_update_begin(&stats->syncp);
>> -       stats->rx_packets++;
>> -       stats->rx_bytes += skb->len;
>> -       u64_stats_update_end(&stats->syncp);
>> -
>> -       netif_rx(skb);
>> -
>> -       return 0;
>> +       return ret;
>>  }
>>
>>  static int gtp_dev_init(struct net_device *dev)
>> @@ -951,6 +958,7 @@ static int ipv4_pdp_add(struct gtp_dev *gtp, struct
>> genl_info *info)
>>         if (pctx == NULL)
>>                 return -ENOMEM;
>>
>> +       pctx->dev = gtp->dev;
>>         ipv4_pdp_fill(pctx, info);
>>         atomic_set(&pctx->tx_seq, 0);
>>
>> --
>> 2.10.2
