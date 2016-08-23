From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: net: Zeroing the structure ethtool_wolinfo in ethtool_get_wol()
Date: Tue, 23 Aug 2016 07:21:36 -0700
Message-ID: <1471962096.14381.15.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1471959668-18209-1-git-send-email-luis.henriques@canonical.com>
         <1471959668-18209-2-git-send-email-luis.henriques@canonical.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Avijit Kanti Das <avijitnsec@codeaurora.org>,
        "David S . Miller" <davem@davemloft.net>,
        Ben Hutchings <ben@decadent.org.uk>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Luis Henriques <luis.henriques@canonical.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1471959668-18209-2-git-send-email-luis.henriques@canonical.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2016-08-23 at 14:41 +0100, Luis Henriques wrote:
> From: Avijit Kanti Das <avijitnsec@codeaurora.org>
> 
> memset() the structure ethtool_wolinfo that has padded bytes
> but the padded bytes have not been zeroed out.
> 
> Change-Id: If3fd2d872a1b1ab9521d937b86a29fc468a8bbfe
> Signed-off-by: Avijit Kanti Das <avijitnsec@codeaurora.org>
> ---
>  net/core/ethtool.c | 4 +++-
>  1 file changed, 3 insertions(+), 1 deletion(-)
> 
> diff --git a/net/core/ethtool.c b/net/core/ethtool.c
> index 977489820eb9..6bf6362e8114 100644
> --- a/net/core/ethtool.c
> +++ b/net/core/ethtool.c
> @@ -1435,11 +1435,13 @@ static int ethtool_reset(struct net_device *dev, char __user *useraddr)
>  
>  static int ethtool_get_wol(struct net_device *dev, char __user *useraddr)
>  {
> -	struct ethtool_wolinfo wol = { .cmd = ETHTOOL_GWOL };
> +	struct ethtool_wolinfo wol;
>  
>  	if (!dev->ethtool_ops->get_wol)
>  		return -EOPNOTSUPP;
>  
> +	memset(&wol, 0, sizeof(struct ethtool_wolinfo));
> +	wol.cmd = ETHTOOL_GWOL;
>  	dev->ethtool_ops->get_wol(dev, &wol);
>  
>  	if (copy_to_user(useraddr, &wol, sizeof(wol)))

This would suggest a compiler bug to me.

I checked that my compiler does properly put zeros there, even in the
padding area.

If we can not rely on such constructs, we have hundreds of similar
patches to submit.

    3c1c:	48 c7 84 24 84 00 00 	movq   $0x0,0x84(%rsp)
    3c23:	00 00 00 00 00 
    3c28:	48 c7 84 24 8c 00 00 	movq   $0x0,0x8c(%rsp)
    3c2f:	00 00 00 00 00 
    3c34:	c7 84 24 94 00 00 00 	movl   $0x0,0x94(%rsp)
    3c3b:	00 00 00 00 
    3c3f:	c7 84 24 84 00 00 00 	movl   $0x5,0x84(%rsp)
    3c46:	05 00 00 00 
    3c4a:	4d 8b b5 18 02 00 00 	mov    0x218(%r13),%r14
    3c51:	49 8b 46 28          	mov    0x28(%r14),%rax
    3c55:	48 85 c0             	test   %rax,%rax
    3c58:	0f 84 9f 0d 00 00    	je     49fd <dev_ethtool+0x1d3d>
    3c5e:	48 8d b4 24 84 00 00 	lea    0x84(%rsp),%rsi
    3c65:	00 
    3c66:	4c 89 ef             	mov    %r13,%rdi
    3c69:	41 bc f2 ff ff ff    	mov    $0xfffffff2,%r12d
    3c6f:	ff d0                	callq  *%rax
    3c71:	be 0e 03 00 00       	mov    $0x30e,%esi
    3c76:	48 c7 c7 00 00 00 00 	mov    $0x0,%rdi
			3c79: R_X86_64_32S	.rodata.str1.8
    3c7d:	e8 00 00 00 00       	callq  3c82 <dev_ethtool+0xfc2>
			3c7e: R_X86_64_PC32	__might_fault-0x4
    3c82:	48 8d b4 24 84 00 00 	lea    0x84(%rsp),%rsi
    3c89:	00 
    3c8a:	ba 14 00 00 00       	mov    $0x14,%edx
    3c8f:	48 89 df             	mov    %rbx,%rdi
    3c92:	e8 00 00 00 00       	callq  3c97 <dev_ethtool+0xfd7>
			3c93: R_X86_64_PC32	_copy_to_user-0x4
    3c97:	48 85 c0             	test   %rax,%rax
