From: Andreas Steffen <andreas.steffen@strongsec.net>
Subject: [Openswan dev] Re: SPI generation by netlink_get_spi()
Date: Fri, 30 Jul 2004 15:40:25 +0200
Sender: dev-bounces@lists.openswan.org
Message-ID: <410A4FC9.1040201@strongsec.net>
References: <E1BpxdD-00036t-00@gondolin.me.apana.org.au>
	<4108F5F5.4020001@strongsec.net> <20040730115009.GA5689@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 8bit
Cc: "David S. Miller" <davem@redhat.com>
Return-path: <dev-bounces@lists.openswan.org>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20040730115009.GA5689@gondor.apana.org.au>
Cc: dev@lists.openswan.org
Cc: users@lists.strongswan.org
Cc: netdev@oss.sgi.com
List-Unsubscribe: <http://lists.openswan.org/mailman/listinfo/dev>,
	<mailto:dev-request@lists.openswan.org?subject=unsubscribe>
List-Archive: <http://lists.openswan.org/pipermail/dev>
List-Post: <mailto:dev@lists.openswan.org>
List-Help: <mailto:dev-request@lists.openswan.org?subject=help>
List-Subscribe: <http://lists.openswan.org/mailman/listinfo/dev>,
	<mailto:dev-request@lists.openswan.org?subject=subscribe>
Errors-To: dev-bounces@lists.openswan.org
List-Id: netdev.vger.kernel.org

Hi Herbert,

I successfully applied your patch to my 2.6.7 kernel. After kernel
recompilation and a system reboot, strongSwan can now handle two
identical Quick Modes in immediate succession without any problems.

Will your patch make it into the 2.6.8 kernel release?

Many thanks

Andreas

Herbert Xu wrote:
> On Thu, Jul 29, 2004 at 03:04:53PM +0200, Andreas Steffen wrote:
> 
>>: |    message ID:  65 7e 1a 0f
>>: | netlink_get_spi: allocated 0x9f4c9788 for esp.0@145.254.54.68
>>: | SPI  9f 4c 97 88
>>
>>The netlink interface of the 2.6 kernel is used to request an SPI for
>>the IPsec SA.
>>
>>Immediately after the first Quick Mode message the second pending Quick Mode
>>is inititated:
> 
> 
>>: |    message ID:  a1 01 a2 b2
>>: | netlink_get_spi: allocated 0x9f4c9788 for esp.0@145.254.54.68
>>: | SPI  9f 4c 97 88
>>
>>And here the error happens. The two Quick Mode negotiations have different
>>Message IDs (65 7e 1a 0f versus a1 01 a2 b2) which will cause two phase2
>>state objects to be created on the peer side but the generated SPI 9f 4c 97 
>>88
>>is the same. This will trigger the assertion passert(0) in 
>>kernel_pfkey.c:finish_pfkey_msg() in freeswan-2.0x because twice the same 
>>SADB_ADD command is executed for the outbound esp. Removing the assertion
>>as in Openswan does not help - several retrials will not succeed in setting
>>up the IPsec SA.
> 
> 
> Yes this is a kernel bug.
> 
> The issue is that two successive calls to netlink_get_spi is returning
> the same SA.  Since netlink_get_spi is meant to be a creation operation
> this is incorrect.
> 
> The netlink_get_spi operation is modelled off the PFKEY SADB_GETSPI
> command which is specified in RFC 2367.  The purpose of SADB_GETSPI
> is to create a new larval SA that can then be filled in by SADB_UPDATE.
> 
> Its semantics does not allow two SADB_GETSPI calls to return the same
> SA, even if there is no SADB_UPDATE call in between.
> 
> The reason the second netlink_get_spi is returning the same SA is
> because in find_acq(), the code is looking at all larval states as
> opposed to only larval states with an SPI of zero.
> 
> Since the only other caller of find_acq() -- xfrm_state_add() intentionally
> ignores all return values with a non-zero SPI, it is safe to not look at
> SAs with non-zero SPIs at all in find_acq().
> 
> The following patch does exactly that.
> 
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
> 
> In fact, the find_acq() call in xfrm_state_add() is a remnant from
> the days when we had xfrm_state_replace() instead of xfrm_state_add()
> and xfrm_state_update().  It can now be safely removed.
> 
> I'll post a separate patch for that.
> 
> Cheers,
> 
> 
> ------------------------------------------------------------------------
> 
> ===== net/ipv4/xfrm4_state.c 1.10 vs edited =====
> --- 1.10/net/ipv4/xfrm4_state.c	2004-07-09 20:19:08 +10:00
> +++ edited/net/ipv4/xfrm4_state.c	2004-07-30 21:26:21 +10:00
> @@ -74,11 +74,8 @@
>  		    proto == x->id.proto &&
>  		    saddr->a4 == x->props.saddr.a4 &&
>  		    reqid == x->props.reqid &&
> -		    x->km.state == XFRM_STATE_ACQ) {
> -			    if (!x0)
> -				    x0 = x;
> -			    if (x->id.spi)
> -				    continue;
> +		    x->km.state == XFRM_STATE_ACQ &&
> +		    !x->id.spi) {
>  			    x0 = x;
>  			    break;
>  		    }
> ===== net/ipv6/xfrm6_state.c 1.11 vs edited =====
> --- 1.11/net/ipv6/xfrm6_state.c	2004-05-27 18:57:44 +10:00
> +++ edited/net/ipv6/xfrm6_state.c	2004-07-30 21:27:07 +10:00
> @@ -81,11 +81,8 @@
>  		    proto == x->id.proto &&
>  		    !ipv6_addr_cmp((struct in6_addr *)saddr, (struct in6_addr *)x->props.saddr.a6) &&
>  		    reqid == x->props.reqid &&
> -		    x->km.state == XFRM_STATE_ACQ) {
> -			    if (!x0)
> -				    x0 = x;
> -			    if (x->id.spi)
> -				    continue;
> +		    x->km.state == XFRM_STATE_ACQ &&
> +		    !x->id.spi) {
>  			    x0 = x;
>  			    break;
>  		    }

=======================================================================
Andreas Steffen                   e-mail: andreas.steffen@strongsec.com
strongSec GmbH                    home:   http://www.strongsec.com
Alter Zürichweg 20                phone:  +41 1 730 80 64
CH-8952 Schlieren (Switzerland)   fax:    +41 1 730 80 65
==========================================[strong internet security]===
