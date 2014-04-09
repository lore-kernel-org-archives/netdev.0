From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 3/3] Drivers: net: hyperv: Address UDP checksum issues
Date: Wed, 09 Apr 2014 13:01:11 -0400 (EDT)
Message-ID: <20140409.130111.1002891296248446198.davem@davemloft.net>
References: <1396986332-12098-1-git-send-email-kys@microsoft.com>
 <1396986371-12137-1-git-send-email-kys@microsoft.com>
 <1396986371-12137-4-git-send-email-kys@microsoft.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: olaf@aepfle.de, netdev@vger.kernel.org, jasowang@redhat.com,
 linux-kernel@vger.kernel.org, apw@canonical.com, devel@linuxdriverproject.org
To: kys@microsoft.com
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
In-Reply-To: <1396986371-12137-4-git-send-email-kys@microsoft.com>
List-Unsubscribe: <http://driverdev.linuxdriverproject.org/mailman/options/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=unsubscribe>
List-Archive: <http://driverdev.linuxdriverproject.org/pipermail/driverdev-devel>
List-Post: <mailto:driverdev-devel@linuxdriverproject.org>
List-Help: <mailto:driverdev-devel-request@linuxdriverproject.org?subject=help>
List-Subscribe: <http://driverdev.linuxdriverproject.org/mailman/listinfo/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=subscribe>
Errors-To: driverdev-devel-bounces@linuxdriverproject.org
Sender: driverdev-devel-bounces@linuxdriverproject.org
List-Id: netdev.vger.kernel.org

From: "K. Y. Srinivasan" <kys@microsoft.com>
Date: Tue,  8 Apr 2014 12:46:11 -0700

>  	} else if (net_trans_info & INFO_UDP) {
> -		csum_info->transmit.udp_checksum = 1;
> +		/* UDP checksum offload is not supported on ws2008r2.
> +		 * Furthermore, on ws2012 and ws2012r2, there are some
> +		 * issues with udp checksum offload from Linux guests.
> +		 * (these are host issues).
> +		 * For now compute the checksum here.
> +		 */
> +		struct udphdr *uh = udp_hdr(skb);
> +		u16 udp_len = ntohs(uh->len);
> +
> +		uh->check = 0;
> +		uh->check = csum_tcpudp_magic(ip_hdr(skb)->saddr,
> +					      ip_hdr(skb)->daddr,
> +					      udp_len, IPPROTO_UDP,
> +					      csum_partial(uh, udp_len, 0));
> +		if (uh->check == 0)
> +			uh->check = CSUM_MANGLED_0;
> +
> +		csum_info->transmit.udp_checksum = 0;

You absolutely cannot mangle packet header contents without first
COW'ing the SKB to make sure it's writable.

Otherwise network taps like tcpdump, and any other entity with a reference
to the packet, can see inconsistent state.
