From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: [PATCH] xfrm: take iphdr size into account for esp payload
 size calculation
Date: Fri, 11 May 2012 12:39:35 +0200
Message-ID: <20120511103935.GA1841@secunet.com>
References: <1336602952-10479-1-git-send-email-bpoirier@suse.de>
 <20120510121857.GJ1021@secunet.com>
 <20120511010249.GA23584@d2.synalogic.ca>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>, linux-kernel@vger.kernel.org
To: Benjamin Poirier <bpoirier@suse.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20120511010249.GA23584@d2.synalogic.ca>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, May 10, 2012 at 09:02:49PM -0400, Benjamin Poirier wrote:
> 
> The value returned by this function is tuned for tcp segment size:
> 1) from tcp_mtu_to_mss()
> mss = pmtu - tcp_hlen - net_hlen
> 2) frame structure for transport mode
> mtu = mss + tcp_hlen + esp_header_len(esp_payload_len) + ah_len + net_hlen

I think you can simplify the calculations here, this
calculation should not depend on any special layer 4
protocol.

> 
> The "mtu" parameter of esp4_get_mtu is in fact mtu - ah_len.
> The return value of esp4_get_mtu is put into pmtu.
> 
> If we put 1 and 2 together we have:
> pmtu = mtu - ah_len - esp_header_len(esp_payload_len)
> with esp_payload_len = mss + tcp_hlen
> 
> This formula expands to:
> pmtu = mtu - ah_len - (header_len + align(align(pmtu - net_hlen + 2, blksize),
> 	esp->padlen) - (pmtu - net_hlen) + alen)
> 
> and simplifies to:
> pmtu = (mtu - ah_len - net_hlen - header_len - alen) & ~(max(blksize,
> 	esp->padlen) - 1) + (net_hlen - 2)
> 
> which, in the context of esp4_get_mtu, becomes:
> ((mtu - x->props.header_len - crypto_aead_authsize(esp->aead) - sizeof(struct
> iphdr)) & ~(align - 1)) + (sizeof(struct iphdr) - 2)
> 
> This is the same formula as before, except for sizeof(struct iphdr) which was
> missing.
> 

Well, makes sense. I use transport mode very rarely, so I never noticed this.
But I was sure that it worked correct in tunnel mode. 

Thanks.
