From: Martin Bouzek <martin.bouzek@radas-atc.cz>
Subject: Re: Minor IPSec bug + solution
Date: 17 Sep 2004 11:26:13 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1095413173.2708.106.camel@mabouzek>
References: <E1C83f1-0002X7-00@gondolin.me.apana.org.au>
Reply-To: martin.bouzek@radas-atc.cz
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Linux Kernel <linux-kernel@vger.kernel.org>, davem@davemloft.net,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <E1C83f1-0002X7-00@gondolin.me.apana.org.au>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 2004-09-16 at 23:19, Herbert Xu wrote:
> Martin Bouzek <martin.bouzek@radas-atc.cz> wrote:
> > 
> > I was setting up an VPN via IPSec in kernel 2.6.x on IPv4 and found the
> > following bug. It is not possible to set up an IPComp/ESP tunnel with
> > IPComp set as mandatory. The following setup works fine for me:
> 
> You can never set IPComp as mandatory because ipcomp_output() will not
> compress anything that is incompressible.

Sure. I receive IP-IP packets and they are checked with the same rules
as IPComp.

> 
> > function. For tunnels it returns 
> > 
> > tmpl->optional && !xfrm_state_addr_cmp(tmpl, x, family);
> 
> The check is correct as it is.  Internal states must never match any
> required transform.

Well, I am not expierienced with the networking kernel code,
nevertheless I still think the check is not correct. 

As I understand it, xfrm_state_addr_cmp returns 0 when tmpl->saddr is
0.0.0.0 (ipv4) or when tmpl->saddr.a4 == x->props.saddr.a4, that is why
there is the "!" before it. The "xfrm_state_ok" itself returns nonzero
if the tmpl matches the state. In such case the "xfrm_policy_ok" will 
return index to next state in sec_path. If no matching state is found
the "xfrm_policy_ok" returns -1 (if not tmpl->optional) and in such case
"__xfrm_policy_check" returns 0 and packet is rejected.

So the following happens for me when packet is received for mandatory
IPComp tunnel:

With my setup the pol->xfrm_nr is 1 and sp->len is 1 (in
"__xfrm_policy_check" context). "xfrm_policy_ok" is called and it calls
the "xfrm_state_ok". x->tunnel_users is 2 - so the 
"tmpl->optional && !xfrm_state_addr_cmp(tmpl, x, family)" is returned.
Because tmpl->optional is set to 0 (required IPComp),
xfrm_state_addr_cmp is not called at all and "xfrm_state_ok" returns 0.
Because sp->x[idx].xvec->props.mode is set, "xfrm_policy_ok" returns -1
(again tmpl->optional is 0). And so "__xfrm_policy_check" returns 0 and
packet is droped.

If you are still not convinced, please look at the xfrm_state_ok and the
part for non-tunnel. It clearly returns 1 when the tmpl and x matches.

Moreover with
"tmpl->optional || !xfrm_state_addr_cmp(tmpl, x, family);" in
"xfrm_state_ok" I can set up the mandatory IPComp without problems.
I am not sure there are not any side effects, but it seems ok to me.

Regards

Martin Bouzek
- martin.bouzek@radas-atc.cz
