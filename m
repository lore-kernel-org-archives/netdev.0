From: Govindarajulu Varadarajan <_govind@gmx.com>
Subject: Re: [PATCH net] enic: fix rx skb checksum
Date: Fri, 19 Dec 2014 16:22:34 +0530 (IST)
Message-ID: <alpine.LNX.2.03.1412191548001.2860@ws.cisco>
References: <1418898522-13588-1-git-send-email-_govind@gmx.com> <1418920017.9773.80.camel@edumazet-glaptop2.roam.corp.google.com> <17951.1418924367@famine> <20141219110732.53264ef8@griffin>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: Jay Vosburgh <jay.vosburgh@canonical.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Govindarajulu Varadarajan <_govind@gmx.com>,
	davem@davemloft.net, netdev@vger.kernel.org, ssujith@cisco.com,
	benve@cisco.com, Stefan Assmann <sassmann@redhat.com>
To: Jiri Benc <jbenc@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.gmx.net ([212.227.17.21]:57575 "EHLO mout.gmx.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751681AbaLSKxA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 19 Dec 2014 05:53:00 -0500
In-Reply-To: <20141219110732.53264ef8@griffin>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 19 Dec 2014, Jiri Benc wrote:

> On Thu, 18 Dec 2014 09:39:27 -0800, Jay Vosburgh wrote:
>> 	I've actually been looking into this "hw csum failure" (as it
>> appears with OVS and VXLAN) the last couple of days, and, at least on
>> the sky2 hardware I have, the problem doesn't appear to be the
>> hardware's CHECKSUM_COMPLETE checksumming.
>
> With the enic driver, the problem _is_ the hardware checksumming.
>
> While debugging the "hw csum failure" messages, I verified the checksum
> returned by the hardware directly in the driver (in
> enic_rq_indicate_buf). It appears that for some packets (most notably
> ICMP ones), the hardware returns 0xffff. I did not see any other wrong
> value, in other words, the returned checksum was either correct, or
> 0xffff.
>

Hardware returns 0xffff for non tcp/udp packets. For tcp/udp packet it returns
pseudo checksum. Not the _whole_ pkt checksum.

With the following changes, I see this output:

diff --git a/drivers/net/ethernet/cisco/enic/enic_main.c b/drivers/net/ethernet/cisco/enic/enic_main.c
index e3dc629..0f2be67 100644
--- a/drivers/net/ethernet/cisco/enic/enic_main.c
+++ b/drivers/net/ethernet/cisco/enic/enic_main.c
@@ -1092,6 +1092,24 @@ static void enic_rq_indicate_buf(struct vnic_rq *rq,
  		}

  		if ((netdev->features & NETIF_F_RXCSUM) && !csum_not_calc) {
+			if (printk_ratelimit()) {
+				const struct iphdr *iph = (struct iphdr *)skb->data;
+				__u16 length_for_csum = 0;
+				__wsum pseudo_csum = 0;
+
+				length_for_csum = (be16_to_cpu(iph->tot_len) - (iph->ihl << 2));
+				pseudo_csum = csum_tcpudp_nofold(iph->saddr,
+								 iph->daddr,
+								 length_for_csum,
+								 iph->protocol, 0);
+
+				pr_info("saddr=%x, daddr=%x, length=%d, proto=%d\n",
+					iph->saddr, iph->daddr, length_for_csum, iph->protocol);
+				pr_info("hw_checksum = %x, pseudo_checksum_32=%x, pseudo_checksum_fold=%x\n",
+					htons(checksum),
+					pseudo_csum,
+					csum_fold(pseudo_csum));
+			}
  			skb->csum = htons(checksum);
  			skb->ip_summed = CHECKSUM_COMPLETE;
  		}


Output:

Dec 18 11:13:18 a163 kernel: enic: saddr=96d8690a, daddr=a3ba6a0a, length=40, proto=6
Dec 18 11:13:18 a163 kernel: enic: hw_checksum = c457, pseudo_checksum_32=3a930115, pseudo_checksum_fold=c457

Dec 18 11:13:18 a163 kernel: enic: saddr=a37410a, daddr=a3ba6a0a, length=32, proto=6
Dec 18 11:13:18 a163 kernel: enic: hw_checksum = 80f9, pseudo_checksum_32=adf1d114, pseudo_checksum_fold=80f9

Dec 18 11:13:18 a163 kernel: enic: saddr=a37410a, daddr=a3ba6a0a, length=32, proto=6
Dec 18 11:13:18 a163 kernel: enic: hw_checksum = 80f9, pseudo_checksum_32=adf1d114, pseudo_checksum_fold=80f9

Clearly hw is returning folded pseudo checksum.

> I have no idea whether the hardware verified the checksum for the
> 0xffff case and is just not returning the checksum or whether such
> packets come completely unverified.
>

Yes, hardware verifies the checksum and sets tcp_udp_csum_ok flag to 1.
If pkt verification fails or pkt is not tcp/udp, tcp_udp_csum_ok is 0. And we
send the pkt to stack with CHECKSUM_NONE.

> As for Govindarajulu's patch, I believe we can do better. First, its
> description does not match what I'm seeing (I see correct checksum
> provided in most cases) and second, the driver should provide
> CHECKSUM_COMPLETE whenever possible; and it seems to be possible.
>

Driver should use CHECKSUM_COMPLETE only if it can produce _whole_ pkt checksum.
as described in include/linux/skbuff.h:75

  * CHECKSUM_COMPLETE:
  *
  *   This is the most generic way. The device supplied checksum of the _whole_
  *   packet as seen by netif_rx() and fills out in skb->csum. Meaning, the
  *   hardware doesn't need to parse L3/L4 headers to implement this.
  *
  *   Note: Even if device supports only some protocols, but is able to produce
  *   skb->csum, it MUST use CHECKSUM_COMPLETE, not CHECKSUM_UNNECESSARY.

Since enic hw verifies checksum but does not provide us whole pkt checksum,
it should use CHECKSUM_UNNECESSARY. as described in include/linux/skbuff.h:47

  * CHECKSUM_UNNECESSARY:
  *
  *   The hardware you're dealing with doesn't calculate the full checksum
  *   (as in CHECKSUM_COMPLETE), but it does parse headers and verify checksums
  *   for specific protocols. For such packets it will set CHECKSUM_UNNECESSARY
  *   if their checksums are okay. skb->csum is still undefined in this case

Am I correct?

>> 	I've also not tested it on enic hardware.  Govindarajulu, would
>> you be able to test this against the unmodified enic driver and see if
>> it resolves the problem for you?
>

I think Jay Vosburgh's patch and my patch are addressing two different issues.

I am trying to fix "Do not set CHECKSUM_COMPLETE, when driver does not have
checksum of whole pkt."

Is my understanding correct?

Thanks

> I'm quite sure it does not, the skb->csum field is incorrect even
> before the skb enters the stack.
>
> Jiri
>
> -- 
> Jiri Benc
>
