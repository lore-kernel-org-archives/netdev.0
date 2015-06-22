From: Oliver Hartkopp <socketcan@hartkopp.net>
Subject: Re: [PATCH] can: fix loss of frames due to wrong assumption in raw_rcv
Date: Mon, 22 Jun 2015 12:24:42 +0200
Message-ID: <5587E26A.1070000@hartkopp.net>
References: <5585A104.1090201@gmx.at> <5585EC4D.40103@hartkopp.net> <5587D9DA.6000102@gmx.at>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-can@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Manfred Schlaegl <manfred.schlaegl@ginzinger.com>,
	"David S. Miller" <davem@davemloft.net>
To: Manfred Schlaegl <manfred.schlaegl@gmx.at>,
	Wolfgang Grandegger <wg@grandegger.com>,
	Marc Kleine-Budde <mkl@pengutronix.de>
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <5587D9DA.6000102@gmx.at>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello Manfred,

On 22.06.2015 11:48, Manfred Schlaegl wrote:

>> Can you tell me the output of /proc/sys/net/core/netdev_tstamp_prequeue on
>> your machine?
>
> /proc/sys/net/core/netdev_tstamp_prequeue is set to 1 (unmodified, default)
>
> I tried to dig a little deeper in timestamping:
>   1. (net/core/dev.c) I found that static_key_false(&netstamp_needed) is always 0, resulting that the timestamp is never set by net_timestamp_check in netif_receive_skb_internal.
>   2. (net/core/dev.c) static_key_false(&netstamp_needed) is 0 because net_enable_timestamp is never called.
>   3. (net/core/sock.c) net_enable_timestamp is never called because SK_FLAGS_TIMESTAMP is not set
>   4. (net/core/sock.c) SK_FLAGS_TIMESTAMP is not set because neither of SOCK_TIMESTAMP or SOCK_TIMESTAMPING_RX_SOFTWARE is set
>   5. (net/core/sock.c) SOCK_TIMESTAMP or SOCK_TIMESTAMPING_RX_SOFTWARE is not set because timestamping is an optional feature (according to http://git.kernel.org/cgit/linux/kernel/git/torvalds/linux.git/tree/Documentation/networking/timestamping.txt?id=b953c0d234bc72e8489d3bf51a276c5c4ec85345) not enabled in my use case (even if netdev_tstamp_prequeue is set to 1)
>
> So the original assumption for the was correct: The correctness of the skb equality check depends on a feature that is not enabled by default (respectively user configurable).
> Do you agree with this?

Yes.

But the point becomes an issue when there's no userspace application that 
requires timestamps.

I did my testing wile having at least one "candump" instances running, which 
enables timestamping. So when there's no one requesting timestamps the check 
in can_rcv does not perform properly.

Therefor my patch grabs your idea to set the timestamps for CAN skbs 
unconditionally. But there were some more places in the code where we need to 
take care about that.

Regards,
Oliver


--
To unsubscribe from this list: send the line "unsubscribe linux-can" in
