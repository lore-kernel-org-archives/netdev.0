From: Andreas Schultz <aschultz@tpip.net>
Subject: Re: [PATCH net v2] fix return of iptunnel_xmit
Date: Thu, 8 Oct 2015 17:33:54 +0200
Message-ID: <56168CE2.6060208@tpip.net>
References: <1444299114-21345-1-git-send-email-aschultz@tpip.net>
 <20151008170849.22bc8632@griffin>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Pravin B Shelar <pshelar@nicira.com>,
	"David S. Miller" <davem@davemloft.net>
To: Jiri Benc <jbenc@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.tpip.net ([92.43.49.48]:50206 "EHLO mail.tpip.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S934107AbbJHPd7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 8 Oct 2015 11:33:59 -0400
In-Reply-To: <20151008170849.22bc8632@griffin>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/08/2015 05:08 PM, Jiri Benc wrote:
> On Thu,  8 Oct 2015 12:11:54 +0200, Andreas Schultz wrote:
>> All users of iptunnel_xmit expect the return value to be the error
>> code from ip_output_local, but currently the return value is length
>> of the send data on success or zero on error.
>> Change iptunnel_xmit returns to match the callers expectation.
>
> That's not true. All users pass the returned value to
> iptunnel_xmit_stats() where it is used to increase tx_bytes.

Yes, but iptunnel_xmit_stats() basically has three different counters:

  1. count packets and bytes when err > 0
  2. count tx_errors when err < 0
  3. count tx_dropped when err == 0

Case 2 got lost in cset 0e6fbc5b6c6218987c93b8c7ca60cf786062899d, since
the return value of iptunnel_xmit() can only be >= 0.

I tried to find out if ip_local_out_sk() can ever return a negative
value. If it can't then iptunnel_xmit_stats() could be simplified and
tipc_udp_send_msg should be fixed.

I've reread my change, and it I do have messed up the non-error case.
pkt_len should be returned when ip_local_out_sk returns NET_XMIT_SUCCESS
or NET_XMIT_CN, 0 when err > 0 and err when err < 0.

Like this:

diff --git a/net/ipv4/ip_tunnel_core.c b/net/ipv4/ip_tunnel_core.c
index 84dce6a..5cced3b 100644
--- a/net/ipv4/ip_tunnel_core.c
+++ b/net/ipv4/ip_tunnel_core.c
@@ -80,9 +80,12 @@ int iptunnel_xmit(struct sock *sk, struct rtable *rt, struct sk_buff *skb,
                           skb_shinfo(skb)->gso_segs ?: 1);

         err = ip_local_out_sk(sk, skb);
-       if (unlikely(net_xmit_eval(err)))
-               pkt_len = 0;
-       return pkt_len;
+       if (likely(net_xmit_eval(err) == 0))
+               return pkt_len;
+       if (err < 0)
+               return err;
+
+       return 0;
  }
  EXPORT_SYMBOL_GPL(iptunnel_xmit);

Andreas

>
> The only exception is tipc_udp_send_msg which should be fixed instead.
>
>   Jiri
>
