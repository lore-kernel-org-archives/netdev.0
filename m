From: Paul Moore <paul@paul-moore.com>
Subject: Re: Possible fix
Date: Fri, 28 Feb 2014 17:10:47 -0500
Message-ID: <8608950.OLpq4oFFJB@sifl>
References: <20140227151954.GA30946@redhat.com> <20140228072333.GP32371@secunet.com> <5310607F.7030401@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: netdev@vger.kernel.org, Dave Jones <davej@redhat.com>,
	Fan Du <fan.du@windriver.com>,
	"David S. Miller" <davem@davemloft.net>,
	linux-security-module@vger.kernel.org
To: Nikolay Aleksandrov <nikolay@redhat.com>,
	Steffen Klassert <steffen.klassert@secunet.com>
Return-path: <linux-security-module-owner@vger.kernel.org>
In-Reply-To: <5310607F.7030401@redhat.com>
Sender: linux-security-module-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Friday, February 28, 2014 11:10:07 AM Nikolay Aleksandrov wrote:
> On 02/28/2014 08:23 AM, Steffen Klassert wrote:
> > On Thu, Feb 27, 2014 at 05:17:37PM +0100, Nikolay Aleksandrov wrote:
> >> Hi,
> >> I'm not familiar with the code but happened to see the bug, could you
> >> try the following patch, I believe it should fix the issue.
> >> 
> >> Thanks,
> >> 
> >>  Nik
> >> 
> >> [PATCH net] net: af_key: fix sleeping under rcu
> >> 
> >> There's a kmalloc with GFP_KERNEL in a helper
> >> (pfkey_sadb2xfrm_user_sec_ctx) used in pfkey_compile_policy which is
> >> called under rcu_read_lock. Adjust pfkey_sadb2xfrm_user_sec_ctx to have
> >> a gfp argument and adjust the users.
> > 
> > Looking at the git history, it seems that this bug is about nine
> > years old. I guess noone is actually using this.

Most (all?) of the labeled IPsec users use the netlink interface and not pfkey 
so it isn't surprising that this has gone unnoticed for some time.

> >> diff --git a/net/key/af_key.c b/net/key/af_key.c
> >> index 1a04c1329362..1526023f99ed 100644
> >> --- a/net/key/af_key.c
> >> +++ b/net/key/af_key.c
> >> @@ -3239,7 +3240,7 @@ static struct xfrm_policy
> >> *pfkey_compile_policy(struct sock *sk, int opt,>> 
> >>  		}
> >>  		if ((*dir = verify_sec_ctx_len(p)))
> >>  		
> >>  			goto out;
> >> 
> >> -		uctx = pfkey_sadb2xfrm_user_sec_ctx(sec_ctx);
> >> +		uctx = pfkey_sadb2xfrm_user_sec_ctx(sec_ctx, GFP_ATOMIC);
> >> 
> >>  		*dir = security_xfrm_policy_alloc(&xp->security, uctx);
> > 
> > This would fix the allocation done in pfkey_sadb2xfrm_user_sec_ctx().
> > But security_xfrm_policy_alloc() might call selinux_xfrm_alloc_user()
> > which does a GFP_KERNEL allocation too. So I guess we also need to fix
> > selinux.

Yes, exactly.

> Right, I just saw that but fixing it at first glance doesn't seem so
> trivial as we can't pass another argument from compile_policy without
> changing xfrm_policy_alloc_security's prototype in struct
> security_operations which AFAICT is doable with some adjustments, but not
> sure if it's the right thing to do. Changing GFP_KERNEL to GFP_ATOMIC in
> selinux_xfrm_alloc_user is also a possibility, but there're a many places
> which use that and can sleep.

I would recommend adding a gfp_t argument to security_xfrm_policy_alloc() and 
passing GFP_ATOMIC in pfkey_compile_policy().

> I would extend this patch, but currently don't have the time to search for
> a nice solution. I can look more into it next week, or if you'd like to
> take care of it, I wouldn't mind :-)

It has been this way for a while so I think another day or two isn't going to 
cause any major harm.  If you are going to put a patch together that's great, 
CC me and I'll review/ACK it, but if you don't want to bother let me know and 
I'll work on a patch.

Thanks,
-Paul

-- 
paul moore
www.paul-moore.com

