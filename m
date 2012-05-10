From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: [PATCH] xfrm: take iphdr size into account for esp payload
 size calculation
Date: Thu, 10 May 2012 14:18:57 +0200
Message-ID: <20120510121857.GJ1021@secunet.com>
References: <1336602952-10479-1-git-send-email-bpoirier@suse.de>
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
In-Reply-To: <1336602952-10479-1-git-send-email-bpoirier@suse.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, May 09, 2012 at 06:35:52PM -0400, Benjamin Poirier wrote:
> 
> According to what is done, mainly in esp_output(), net_header_len aka
> sizeof(struct iphdr) must be taken into account before doing the alignment
> calculation.

Why do you need to take the ip header into account here? Your patch breaks
pmtu discovery, at least on tunnel mode with aes-sha1 (aes blocksize 16 bytes).

With your patch applied:

tracepath -n 192.168.1.2
 1?: [LOCALHOST]     pmtu 1442
 1:  send failed
 1:  send failed
     Resume: pmtu 1442

Without your patch:

tracepath -n 192.168.1.2
 1?: [LOCALHOST]     pmtu 1438
 1:  192.168.1.2       0.736ms reached
 1:  192.168.1.2       0.390ms reached
     Resume: pmtu 1438 hops 1 back 64 

Your patch increases the mtu by 4 bytes. Be aware that adding
one byte of payload may increase the packet size up to 16 bytes
in the case of aes, as we have to pad the encryption payload
always to a multiple of the cipher blocksize.

> -
> -	switch (x->props.mode) {
> -	case XFRM_MODE_TUNNEL:
> -		break;
> -	default:
> -	case XFRM_MODE_TRANSPORT:
> -		/* The worst case */
> -		mtu -= blksize - 4;
> -		mtu += min_t(u32, blksize - 4, rem);
> -		break;

Btw. why we are doing the calculation above for transport mode?
