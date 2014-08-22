From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] hyperv: Add handling of IP header with option
 field in netvsc_set_hash()
Date: Thu, 21 Aug 2014 21:30:57 -0700 (PDT)
Message-ID: <20140821.213057.1438247518790500739.davem@davemloft.net>
References: <1408481635-29639-1-git-send-email-haiyangz@microsoft.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: olaf@aepfle.de, netdev@vger.kernel.org, jasowang@redhat.com,
 driverdev-devel@linuxdriverproject.org, linux-kernel@vger.kernel.org
To: haiyangz@microsoft.com
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
In-Reply-To: <1408481635-29639-1-git-send-email-haiyangz@microsoft.com>
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

From: Haiyang Zhang <haiyangz@microsoft.com>
Date: Tue, 19 Aug 2014 20:53:55 +0000

> @@ -200,12 +202,18 @@ static bool netvsc_set_hash(u32 *hash, struct sk_buff *skb)
>  	iphdr = ip_hdr(skb);
>  
>  	if (iphdr->version == 4) {
> -		if (iphdr->protocol == IPPROTO_TCP)
> +		data = (u8 *)&iphdr->saddr;
> +		if (iphdr->protocol == IPPROTO_TCP) {
>  			data_len = 12;
> -		else
> +			if (iphdr->ihl > 5) {
> +				memcpy(dbuf, &iphdr->saddr, 8);
> +				memcpy(&dbuf[8], &tcp_hdr(skb)->source, 4);

This is rediculous.

Make hash_comp() take a void pointer for the buffer.

Then your code is simply:

	be32 dbuf[2];

	dbuf[1] = iph->saddr;
	dbuf[2] = iph->daddr;
	dbuf[3] = *(be32 *)tcph->source;

	*hash = comp_hash(netvsc_hash_key, HASH_KEYLEN, dbuf, 12);

No special cases for IP options or any garbage like that.
