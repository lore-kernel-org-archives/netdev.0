From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH net-next v2 10/13] r8152: support IPv6
Date: Sun, 09 Mar 2014 18:56:14 -0400 (EDT)
Message-ID: <20140309.185614.1584225198974026118.davem@davemloft.net>
References: <1394002168-3193-1-git-send-email-hayeswang@realtek.com>
	<1394002168-3193-11-git-send-email-hayeswang@realtek.com>
	<1394394475.15968.25.camel@deadeye.wl.decadent.org.uk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: hayeswang-Rasf1IRRPZFBDgjK7y7TUQ@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	nic_swsd-Rasf1IRRPZFBDgjK7y7TUQ@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: ben-/+tVBieCtBitmTQ+vhA3Yw@public.gmane.org
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1394394475.15968.25.camel-nDn/Rdv9kqW9Jme8/bJn5UCKIB8iOfG2tUK59QYPAWc@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Ben Hutchings <ben-/+tVBieCtBitmTQ+vhA3Yw@public.gmane.org>
Date: Sun, 09 Mar 2014 19:47:55 +0000

> On Wed, 2014-03-05 at 14:49 +0800, Hayes Wang wrote:
>> Support hw IPv6 checksum for TCP and UDP packets.
>> 
>> Note that the hw has the limitation of the range of the transport
>> offset. Besides, the TCP Pseudo Header of the IPv6 TSO of the hw
>> bases on the Microsoft document which excludes the packet length.
>> 
>> Signed-off-by: Hayes Wang <hayeswang-Rasf1IRRPZFBDgjK7y7TUQ@public.gmane.org>
>> ---
>>  drivers/net/usb/r8152.c | 107 ++++++++++++++++++++++++++++++++++++++++++++++--
>>  1 file changed, 104 insertions(+), 3 deletions(-)
>> 
>> diff --git a/drivers/net/usb/r8152.c b/drivers/net/usb/r8152.c
>> index 8f6d0f8..8e208f30 100644
>> --- a/drivers/net/usb/r8152.c
>> +++ b/drivers/net/usb/r8152.c
> [...]
>> +static int msdn_giant_send_check(struct sk_buff *skb)
>> +{
>> +	const struct ipv6hdr *ipv6h;
>> +	struct tcphdr *th;
>> +
>> +	ipv6h = ipv6_hdr(skb);
>> +	th = tcp_hdr(skb);
>> +
>> +	th->check = 0;
>> +	th->check = ~tcp_v6_check(0, &ipv6h->saddr, &ipv6h->daddr, 0);
> [...]
> 
> I think you need to call skb_cow_head() before editing the header here.

This made me notice that several drivers open-code this:

		if (skb_header_cloned(skb) &&
		    pskb_expand_head(skb, 0, 0, GFP_ATOMIC))
			goto drop;

If someone is looking for a quick cleanup, transforming these
to use skb_cow_head() would be nice.  That way other driver
authors will be less likely to copy the expanded code.
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
