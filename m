From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] bonding: attempt to better support longer hw
 addresses
Date: Wed, 05 Apr 2017 18:45:54 -0700 (PDT)
Message-ID: <20170405.184554.1608171595937690317.davem@davemloft.net>
References: <20170404213242.50079-1-jarod@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, j.vosburgh@gmail.com,
        vfalico@gmail.com, andy@greyhouse.net, netdev@vger.kernel.org
To: jarod@redhat.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170404213242.50079-1-jarod@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jarod Wilson <jarod@redhat.com>
Date: Tue,  4 Apr 2017 17:32:42 -0400

> People are using bonding over Infiniband IPoIB connections, and who knows
> what else. Infiniband has a hardware address length of 20 octets
> (INFINIBAND_ALEN), and the network core defines a MAX_ADDR_LEN of 32.
> Various places in the bonding code are currently hard-wired to 6 octets
> (ETH_ALEN), such as the 3ad code, which I've left untouched here. Besides,
> only alb is currently possible on Infiniband links right now anyway, due
> to commit 1533e7731522, so the alb code is where most of the changes are.
> 
> One major component of this change is the addition of a bond_hw_addr_copy
> function that takes a length argument, instead of using ether_addr_copy
> everywhere that hardware addresses need to be copied about. The other
> major component of this change is converting the bonding code from using
> struct sockaddr for address storage to struct sockaddr_storage, as the
> former has an address storage space of only 14, while the latter is 128
> minus a few, which is necessary to support bonding over device with up to
> MAX_ADDR_LEN octet hardware addresses. Additionally, this probably fixes
> up some memory corruption issues with the current code, where it's
> possible to write an infiniband hardware address into a sockaddr declared
> on the stack.
> 
> Lightly tested on a dual mlx4 IPoIB setup, which properly shows a 20-octet
> hardware address now:
 ...
> CC: Jay Vosburgh <j.vosburgh@gmail.com>
> CC: Veaceslav Falico <vfalico@gmail.com>
> CC: Andy Gospodarek <andy@greyhouse.net>
> CC: netdev@vger.kernel.org
> Signed-off-by: Jarod Wilson <jarod@redhat.com>

Applied, but:

> +static inline void bond_hw_addr_copy(u8 *dst, const u8 *src, unsigned int len)
> +{
> +	if (len == ETH_ALEN) {
> +		ether_addr_copy(dst, src);
> +		return;
> +	}
> +
> +	memcpy(dst, src, len);
> +}

I wonder how much value there is in trying to conditionally use
ether_addr_copy().  Unless some of these calls are in the data
plane, just a straight memcpy() all the time is fine and much
simpler.

Thanks.
