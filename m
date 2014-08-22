From: Haiyang Zhang <haiyangz@microsoft.com>
Subject: RE: [PATCH net-next] hyperv: Add handling of IP header with option
 field in netvsc_set_hash()
Date: Fri, 22 Aug 2014 21:06:10 +0000
Message-ID: <0d7d4fd9cf1448f3a92b07b241d21a7e@DFM-DB3MBX15-06.exchange.corp.microsoft.com>
References: <1408481635-29639-1-git-send-email-haiyangz@microsoft.com>
 <20140821.213057.1438247518790500739.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "olaf@aepfle.de" <olaf@aepfle.de>,
 "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
 "jasowang@redhat.com" <jasowang@redhat.com>,
 "driverdev-devel@linuxdriverproject.org"
 <driverdev-devel@linuxdriverproject.org>,
 "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
In-Reply-To: <20140821.213057.1438247518790500739.davem@davemloft.net>
Content-Language: en-US
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



> -----Original Message-----
> From: David Miller [mailto:davem@davemloft.net]
> Sent: Friday, August 22, 2014 12:31 AM
> To: Haiyang Zhang
> Cc: netdev@vger.kernel.org; KY Srinivasan; olaf@aepfle.de;
> jasowang@redhat.com; linux-kernel@vger.kernel.org; driverdev-
> devel@linuxdriverproject.org
> Subject: Re: [PATCH net-next] hyperv: Add handling of IP header with
> option field in netvsc_set_hash()
> 
> From: Haiyang Zhang <haiyangz@microsoft.com>
> Date: Tue, 19 Aug 2014 20:53:55 +0000
> 
> > @@ -200,12 +202,18 @@ static bool netvsc_set_hash(u32 *hash, struct
> sk_buff *skb)
> >  	iphdr = ip_hdr(skb);
> >
> >  	if (iphdr->version == 4) {
> > -		if (iphdr->protocol == IPPROTO_TCP)
> > +		data = (u8 *)&iphdr->saddr;
> > +		if (iphdr->protocol == IPPROTO_TCP) {
> >  			data_len = 12;
> > -		else
> > +			if (iphdr->ihl > 5) {
> > +				memcpy(dbuf, &iphdr->saddr, 8);
> > +				memcpy(&dbuf[8], &tcp_hdr(skb)->source, 4);
> 
> This is rediculous.
> 
> Make hash_comp() take a void pointer for the buffer.
> 
> Then your code is simply:
> 
> 	be32 dbuf[2];
> 
> 	dbuf[1] = iph->saddr;
> 	dbuf[2] = iph->daddr;
> 	dbuf[3] = *(be32 *)tcph->source;
> 
> 	*hash = comp_hash(netvsc_hash_key, HASH_KEYLEN, dbuf, 12);
> 
> No special cases for IP options or any garbage like that.

I have submitted a revised patch with the suggested changes.

Thanks,
- Haiyang
