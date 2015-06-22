From: Manfred Schlaegl <manfred.schlaegl@gmx.at>
Subject: Re: [PATCH] can: fix loss of frames due to wrong assumption in raw_rcv
Date: Mon, 22 Jun 2015 11:48:10 +0200
Message-ID: <5587D9DA.6000102@gmx.at>
References: <5585A104.1090201@gmx.at> <5585EC4D.40103@hartkopp.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 8bit
Cc: linux-can@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Manfred Schlaegl <manfred.schlaegl@ginzinger.com>,
	"David S. Miller" <davem@davemloft.net>
To: Oliver Hartkopp <socketcan@hartkopp.net>,
	Wolfgang Grandegger <wg@grandegger.com>,
	Marc Kleine-Budde <mkl@pengutronix.de>
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <5585EC4D.40103@hartkopp.net>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello Oliver,

On 2015-06-21 00:42, Oliver Hartkopp wrote:

>> 514ac99c64b22d83b52dfee3b8becaa69a92bc4a introduces a frame equality
>> check. Since the sk_buff pointer is not sufficient to do this (buffers
>> are reused), the check also compares time stamps.
>> In short: pointer+time stamp was assumed as unique key to a specific
>> frame.
>> The problem with this is, that the time stamp is an optional property
>> and not set per default.
>> In our case (flexcan) the time stamp is always zero, so the equality
>> check is reduced to equality of buffer pointers, resulting in a lot of
>> dropped frames.
> 
> The question is why your system did not generate a timestamp at the time of
> skb reception.
> 
> Usually when netif_rx(), netif_rx_ni() is invoked the timestamp is set in the
> following reception process.
> 
> flexcan.c only uses netif_receive_skb() - but all theses functions set the
> timestamp
> 
> 	net_timestamp_check(netdev_tstamp_prequeue, skb);
> 
> depending on netdev_tstamp_prequeue which is configured by
> 
> /proc/sys/net/core/netdev_tstamp_prequeue
> 
> See the idea of netdev_tstamp_prequeue here:
> 
> http://git.kernel.org/cgit/linux/kernel/git/torvalds/linux.git/commit/net/core/sysctl_net_core.c?id=3b098e2d7c693796cc4dffb07caa249fc0f70771
> 
Thank you for the background information!
I've also noticed your patch [PATCH - regression 4.1-rc8] can: fix loss of CAN frames in raw_rcv

> Can you tell me the output of /proc/sys/net/core/netdev_tstamp_prequeue on
> your machine?

/proc/sys/net/core/netdev_tstamp_prequeue is set to 1 (unmodified, default)

I tried to dig a little deeper in timestamping:
 1. (net/core/dev.c) I found that static_key_false(&netstamp_needed) is always 0, resulting that the timestamp is never set by net_timestamp_check in netif_receive_skb_internal.
 2. (net/core/dev.c) static_key_false(&netstamp_needed) is 0 because net_enable_timestamp is never called.
 3. (net/core/sock.c) net_enable_timestamp is never called because SK_FLAGS_TIMESTAMP is not set
 4. (net/core/sock.c) SK_FLAGS_TIMESTAMP is not set because neither of SOCK_TIMESTAMP or SOCK_TIMESTAMPING_RX_SOFTWARE is set 
 5. (net/core/sock.c) SOCK_TIMESTAMP or SOCK_TIMESTAMPING_RX_SOFTWARE is not set because timestamping is an optional feature (according to http://git.kernel.org/cgit/linux/kernel/git/torvalds/linux.git/tree/Documentation/networking/timestamping.txt?id=b953c0d234bc72e8489d3bf51a276c5c4ec85345) not enabled in my use case (even if netdev_tstamp_prequeue is set to 1)

So the original assumption for the was correct: The correctness of the skb equality check depends on a feature that is not enabled by default (respectively user configurable).
Do you agree with this?

> 
> Thanks again for your investigation!
Sure!

Best regards,
Manfred

--
To unsubscribe from this list: send the line "unsubscribe linux-can" in
