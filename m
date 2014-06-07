From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH] ip_vti: Fix 'ip tunnel add' with 'key' parameters
Date: Sun, 08 Jun 2014 01:55:22 +0400
Message-ID: <53938A4A.9010105@cogentembedded.com>
References: <20140608012518.39affaff049874520ae5a0cc@qrator.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Dmitry Popov <ixaphire@qrator.net>,
	"David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>,
	Steffen Klassert <steffen.klassert@secunet.com>,
	Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20140608012518.39affaff049874520ae5a0cc@qrator.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

hello.

On 06/08/2014 01:25 AM, Dmitry Popov wrote:

> ip tunnel add remote 10.2.2.1 local 10.2.2.2 mode vti ikey 1 okey 2
> translates to p->iflags = VTI_ISVTI|GRE_KEY and p->i_key = 1, but GRE_KEY !=
> TUNNEL_KEY, so ip_tunnel_ioctl would set i_key to 0 (same story with o_key)
> making us unable to create vti tunnels with [io]key via ip tunnel.

> We cannot simply translate GRE_KEY to TUNNEL_KEY (as GRE module does) because
> vti_tunnels with same local/remote addresses but different ikeys will be treated
> as different then. So, imo the best option here is to move p->i_flags&*_KEY
> check for vti tunnels from ip_tunnel.c to ip_vti.c and to think about [io]_mark
> field for ip_tunnel_parm in the future.

> Signed-off-by: Dmitry Popov <ixaphire@qrator.net>
> ---
>   net/ipv4/ip_tunnel.c | 10 ++++++----
>   net/ipv4/ip_vti.c    |  8 +++++++-
>   2 files changed, 13 insertions(+), 5 deletions(-)

> diff --git a/net/ipv4/ip_tunnel.c b/net/ipv4/ip_tunnel.c
> index 2acc233..0a03ad1 100644
> --- a/net/ipv4/ip_tunnel.c
> +++ b/net/ipv4/ip_tunnel.c
> @@ -747,10 +747,12 @@ int ip_tunnel_ioctl(struct net_device *dev, struct ip_tunnel_parm *p, int cmd)
>   			goto done;
>   		if (p->iph.ttl)
>   			p->iph.frag_off |= htons(IP_DF);
> -		if (!(p->i_flags&TUNNEL_KEY))
> -			p->i_key = 0;
> -		if (!(p->o_flags&TUNNEL_KEY))
> -			p->o_key = 0;
> +		if (!(p->i_flags&VTI_ISVTI)) {
> +			if (!(p->i_flags&TUNNEL_KEY))
> +				p->i_key = 0;
> +			if (!(p->o_flags&TUNNEL_KEY))

    Please surround & with spaces for consistency; this also would follow the 
general kernel coding style.

[...]

WBR, Sergei
