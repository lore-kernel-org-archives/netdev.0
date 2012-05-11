From: Benjamin Poirier <bpoirier@suse.de>
Subject: Re: [PATCH] xfrm: take iphdr size into account for esp payload size
 calculation
Date: Thu, 10 May 2012 21:02:49 -0400
Message-ID: <20120511010249.GA23584@d2.synalogic.ca>
References: <1336602952-10479-1-git-send-email-bpoirier@suse.de>
 <20120510121857.GJ1021@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>, linux-kernel@vger.kernel.org
To: Steffen Klassert <steffen.klassert@secunet.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20120510121857.GJ1021@secunet.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 2012/05/10 14:18, Steffen Klassert wrote:
> On Wed, May 09, 2012 at 06:35:52PM -0400, Benjamin Poirier wrote:
> > 
> > According to what is done, mainly in esp_output(), net_header_len aka
> > sizeof(struct iphdr) must be taken into account before doing the alignment
> > calculation.
> 
> Why do you need to take the ip header into account here?

The value returned by this function is tuned for tcp segment size:
1) from tcp_mtu_to_mss()
mss = pmtu - tcp_hlen - net_hlen
2) frame structure for transport mode
mtu = mss + tcp_hlen + esp_header_len(esp_payload_len) + ah_len + net_hlen

The "mtu" parameter of esp4_get_mtu is in fact mtu - ah_len.
The return value of esp4_get_mtu is put into pmtu.

If we put 1 and 2 together we have:
pmtu = mtu - ah_len - esp_header_len(esp_payload_len)
with esp_payload_len = mss + tcp_hlen

This formula expands to:
pmtu = mtu - ah_len - (header_len + align(align(pmtu - net_hlen + 2, blksize),
	esp->padlen) - (pmtu - net_hlen) + alen)

and simplifies to:
pmtu = (mtu - ah_len - net_hlen - header_len - alen) & ~(max(blksize,
	esp->padlen) - 1) + (net_hlen - 2)

which, in the context of esp4_get_mtu, becomes:
((mtu - x->props.header_len - crypto_aead_authsize(esp->aead) - sizeof(struct
iphdr)) & ~(align - 1)) + (sizeof(struct iphdr) - 2)

This is the same formula as before, except for sizeof(struct iphdr) which was
missing.

> Your patch breaks
> pmtu discovery, at least on tunnel mode with aes-sha1 (aes blocksize 16 bytes).
> 
> With your patch applied:
> 
> tracepath -n 192.168.1.2
>  1?: [LOCALHOST]     pmtu 1442
>  1:  send failed
>  1:  send failed
>      Resume: pmtu 1442
> 
> Without your patch:
> 
> tracepath -n 192.168.1.2
>  1?: [LOCALHOST]     pmtu 1438
>  1:  192.168.1.2       0.736ms reached
>  1:  192.168.1.2       0.390ms reached
>      Resume: pmtu 1438 hops 1 back 64 
> 
> Your patch increases the mtu by 4 bytes. Be aware that adding
> one byte of payload may increase the packet size up to 16 bytes
> in the case of aes, as we have to pad the encryption payload
> always to a multiple of the cipher blocksize.

Thanks for testing. My own testing had been limited to rsync'ing large
files.

The problem with tunnel mode in v1 of the patch was twofold.
First, we don't play games with mss and tcp_hlen. esp_payload_len = pmtu
directly, instead of esp_payload_len = pmtu - net_hlen.
Second, in the tunnel case, header_len already includes net_hlen, see
esp_init_state().
The net result is that the formula for tunnel mode was already correct.

> 
> > -
> > -	switch (x->props.mode) {
> > -	case XFRM_MODE_TUNNEL:
> > -		break;
> > -	default:
> > -	case XFRM_MODE_TRANSPORT:
> > -		/* The worst case */
> > -		mtu -= blksize - 4;
> > -		mtu += min_t(u32, blksize - 4, rem);
> > -		break;
> 
> Btw. why we are doing the calculation above for transport mode?
