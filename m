From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: ipv6: fix headroom calculation in udp6_ufo_fragment
Date: Fri, 13 Dec 2013 14:34:53 +0100
Message-ID: <20131213133453.GB7332@order.stressinduktion.org>
References: <D00A5DFD97C44C4D820FC3A847C5D5750730630F@IRVEXCHMB14.corp.ad.broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: 'Pravin B Shelar' <pshelar@nicira.com>,
	'Saran Neti' <Saran.Neti@telus.com>,
	"'David S. Miller'" <davem@davemloft.net>,
	'Greg Kroah-Hartman' <gregkh@linuxfoundation.org>,
	"Mark Brown (broonie@linaro.org)" <broonie@linaro.org>,
	"'netdev@vger.kernel.org'" <netdev@vger.kernel.org>,
	"'stable@vger.kernel.org'" <stable@vger.kernel.org>
To: Mark Hambleton <mark.hambleton@broadcom.com>
Return-path: <stable-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <D00A5DFD97C44C4D820FC3A847C5D5750730630F@IRVEXCHMB14.corp.ad.broadcom.com>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Dec 13, 2013 at 01:01:59PM +0000, Mark Hambleton wrote:
> Hi, 
> 
> Following a recent commit to LTS and upstream  I see the following warning emitted on an ARM32 build:
> 
> net/ipv6/udp_offload.c: In function 'udp6_ufo_fragment':
> net/ipv6/udp_offload.c:88:22: error: comparison between pointer and integer [-Werror]
>   if (skb->mac_header < (tnl_hlen + frag_hdr_sz)) {
>                       ^
> cc1: all warnings being treated as errors
> make[2]: *** [net/ipv6/udp_offload.o] Error 1
> make[1]: *** [net/ipv6] Error 2
> 
>  The commit made the following changes:
> 
> -       if (skb_headroom(skb) < (tnl_hlen + frag_hdr_sz)) {
> +       if (skb->mac_header < (tnl_hlen + frag_hdr_sz)) {
> 
> Now, because of some defines in skbuff.h :
> 
> #if BITS_PER_LONG > 32
> #define NET_SKBUFF_DATA_USES_OFFSET 1
> #endif
> 
> #ifdef NET_SKBUFF_DATA_USES_OFFSET
> typedef unsigned int sk_buff_data_t;
> #else
> typedef unsigned char *sk_buff_data_t;
> #endif
> 
> On an ARM32 system sk_buff_data_t would be a pointer (long being 32 bits), meaning that skb->mac_header is a pointer and that  you are comparing a pointer against a length, which doesn't look like it is correct to me?
> 
> I can see how this works when NET_SKBUFF_DATA_USES_OFFSET is defined, but is there a way to do this that works for both cases?

Sorry, I don't know which version the LTS kernel is. Upstream does not use
sk_buff_data_t for mac_header any more.

Something like that might help:

(skb_mac_header(skb) < skb->head + tnl_hlen + frag_hdr_sz)
