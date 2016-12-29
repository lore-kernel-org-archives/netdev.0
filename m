From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: [PATCH] net: fix incorrect original ingress device index in
 PKTINFO
Date: Wed, 28 Dec 2016 21:42:34 -0700
Message-ID: <c60a95e6-b02b-2108-c0fd-9dd6f128316f@cumulusnetworks.com>
References: <1482832344-24760-1-git-send-email-asuka.com@163.com>
 <20161227.140313.1837464529059496066.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, jmorris@namei.org, yoshfuji@linux-ipv6.org,
        kaber@trash.net, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>, asuka.com@163.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20161227.140313.1837464529059496066.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 12/27/16 12:03 PM, David Miller wrote:
> From: Wei Zhang <asuka.com@163.com>
> Date: Tue, 27 Dec 2016 17:52:24 +0800
> 
>> When we send a packet for our own local address on a non-loopback
>> interface (e.g. eth0), due to the change had been introduced from
>> commit 0b922b7a829c ("net: original ingress device index in PKTINFO"), the
>> original ingress device index would be set as the loopback interface.
>> However, the packet should be considered as if it is being arrived via the
>> sending interface (eth0), otherwise it would break the expectation of the
>> userspace application (e.g. the DHCPRELEASE message from dhcp_release
>> binary would be ignored by the dnsmasq daemon, since it come from lo which
>> is not the interface dnsmasq bind to)
>>

Add a Fixes line before the sign-off:

Fixes: 0b922b7a829c ("net: original ingress device index in PKTINFO")
>> Signed-off-by: Wei Zhang <asuka.com@163.com>
> 
> When you are fixing a problem introduced by another change, always CC:
> the author of that change as I have done so here.
> 
> David, please take a look at this, thanks.
> 
>> ---
>>  net/ipv4/ip_sockglue.c | 8 +++++++-
>>  1 file changed, 7 insertions(+), 1 deletion(-)
>>
>> diff --git a/net/ipv4/ip_sockglue.c b/net/ipv4/ip_sockglue.c
>> index b8a2d63..76d78a7 100644
>> --- a/net/ipv4/ip_sockglue.c
>> +++ b/net/ipv4/ip_sockglue.c
>> @@ -1202,8 +1202,14 @@ void ipv4_pktinfo_prepare(const struct sock *sk, struct sk_buff *skb)
>>  		 * which has interface index (iif) as the first member of the
>>  		 * underlying inet{6}_skb_parm struct. This code then overlays
>>  		 * PKTINFO_SKB_CB and in_pktinfo also has iif as the first
>> -		 * element so the iif is picked up from the prior IPCB
>> +		 * element so the iif is picked up from the prior IPCB except
>> +		 * iif is loopback interface which the packet should be
>> +		 * considered as if it is being arrived via the sending
>> +		 * interface

That comment change could use an adjustment (adjust to fit with in the 80 columns):

element so the iif is picked up from the prior IPCB. If iif
is the loopback interface, then return the sending interface
(e.g., process binds socket to eth0 for Tx which is redirected
to loopback in the rtable/dst).


>>  		 */
>> +		if (pktinfo->ipi_ifindex == LOOPBACK_IFINDEX)
>> +			pktinfo->ipi_ifindex = inet_iif(skb);
>> +
>>  		pktinfo->ipi_spec_dst.s_addr = fib_compute_spec_dst(skb);
>>  	} else {
>>  		pktinfo->ipi_ifindex = 0;


The actual change looks ok to me.

Acked-by: David Ahern <dsa@cumulusnetworks.com>
