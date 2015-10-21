From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: [PATCH net-next 2/2] xfrm: Fix unaligned access in
 xfrm_notify_sa() for DELSA
Date: Wed, 21 Oct 2015 08:57:04 +0200
Message-ID: <20151021065704.GM7701@secunet.com>
References: <cover.1445286755.git.sowmini.varadhan@oracle.com>
 <65f37efeff5af105c89493dda4f38c61e4cd495f.1445286755.git.sowmini.varadhan@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <linux-crypto@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	<netdev@vger.kernel.org>, <herbert@gondor.apana.org.au>,
	<dhowells@redhat.com>, <davem@davemloft.net>,
	<zohar@linux.vnet.ibm.com>, <David.Woodhouse@intel.com>
To: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Return-path: <linux-crypto-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <65f37efeff5af105c89493dda4f38c61e4cd495f.1445286755.git.sowmini.varadhan@oracle.com>
Sender: linux-crypto-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Oct 19, 2015 at 05:23:29PM -0400, Sowmini Varadhan wrote:
> On sparc, deleting established SAs (e.g., by restarting ipsec
> at the peer) results in unaligned access messages via
> xfrm_del_sa -> km_state_notify -> xfrm_send_state_notify().
> Use an aligned pointer to xfrm_usersa_info for this case.
> 
> Signed-off-by: Sowmini Varadhan <sowmini.varadhan@oracle.com>
> ---
>  net/xfrm/xfrm_user.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
> 
> diff --git a/net/xfrm/xfrm_user.c b/net/xfrm/xfrm_user.c
> index a8de9e3..158ef4a 100644
> --- a/net/xfrm/xfrm_user.c
> +++ b/net/xfrm/xfrm_user.c
> @@ -2659,7 +2659,7 @@ static int xfrm_notify_sa(struct xfrm_state *x, const struct km_event *c)
>  		if (attr == NULL)
>  			goto out_free_skb;
>  
> -		p = nla_data(attr);
> +		p = PTR_ALIGN(nla_data(attr), __alignof__(*p));

Hm, this breaks userspace notifications on 64-bit systems.
Userspace expects this to be aligned to 4, with your patch
it is aligned to 8 on 64-bit.

Without your patch I get the correct notification when deleting a SA:

ip x m

Deleted src 172.16.0.2 dst 172.16.0.1
        proto esp spi 0x00000002 reqid 2 mode tunnel
        replay-window 32
        auth-trunc hmac(sha1) 0x31323334353637383930 96
        enc cbc(aes) 0x31323334353637383930313233343536
        sel src 10.0.0.0/24 dst 192.168.0.0/24

With your patch I get for the same SA:

ip x m

Deleted src 50.0.0.0 dst 0.0.0.0
        proto 0 reqid 0 mode transport
        replay-window 0 flag decap-dscp
        auth-trunc hmac(sha1) 0x31323334353637383930 96
        enc cbc(aes) 0x31323334353637383930313233343536
        sel src 0.0.0.0/0 dst 0.234.255.255/0 proto igmp
