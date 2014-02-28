From: Nikolay Aleksandrov <nikolay@redhat.com>
Subject: Re: Possible fix
Date: Fri, 28 Feb 2014 11:10:07 +0100
Message-ID: <5310607F.7030401@redhat.com>
References: <20140227151954.GA30946@redhat.com> <1393517857-11842-1-git-send-email-nikolay@redhat.com> <20140228072333.GP32371@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Dave Jones <davej@redhat.com>,
	Fan Du <fan.du@windriver.com>,
	"David S. Miller" <davem@davemloft.net>,
	Paul Moore <paul@paul-moore.com>,
	linux-security-module@vger.kernel.org
To: Steffen Klassert <steffen.klassert@secunet.com>
Return-path: <linux-security-module-owner@vger.kernel.org>
In-Reply-To: <20140228072333.GP32371@secunet.com>
Sender: linux-security-module-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 02/28/2014 08:23 AM, Steffen Klassert wrote:
> Ccing some security/selinux people.
> 
> On Thu, Feb 27, 2014 at 05:17:37PM +0100, Nikolay Aleksandrov wrote:
>> Hi,
>> I'm not familiar with the code but happened to see the bug, could you
>> try the following patch, I believe it should fix the issue.
>>
>> Thanks,
>>  Nik
>>
>> [PATCH net] net: af_key: fix sleeping under rcu
>>
>> There's a kmalloc with GFP_KERNEL in a helper
>> (pfkey_sadb2xfrm_user_sec_ctx) used in pfkey_compile_policy which is
>> called under rcu_read_lock. Adjust pfkey_sadb2xfrm_user_sec_ctx to have
>> a gfp argument and adjust the users.
>>
> 
> Looking at the git history, it seems that this bug is about nine
> years old. I guess noone is actually using this.
> 
> Also, we care for the security context only if we add a socket
> policy via the pfkey key manager. The security context is not
> handled if we do that with the netlink key manager
> (compare pfkey_compile_policy() and xfrm_compile_policy()).
> 
>> CC: Dave Jones <davej@redhat.com>
>> CC: Steffen Klassert <steffen.klassert@secunet.com>
>> CC: Fan Du <fan.du@windriver.com>
>> CC: David S. Miller <davem@davemloft.net>
>>
>> Signed-off-by: Nikolay Aleksandrov <nikolay@redhat.com>
>> ---
>> I'm not familiar with this code, but just happen to see the bug. I believe
>> this patch should take care of it.
>> I've left the already very long lines.
>>
>>  net/key/af_key.c | 13 +++++++------
>>  1 file changed, 7 insertions(+), 6 deletions(-)
>>
>> diff --git a/net/key/af_key.c b/net/key/af_key.c
>> index 1a04c1329362..1526023f99ed 100644
>> --- a/net/key/af_key.c
>> +++ b/net/key/af_key.c
>> @@ -433,12 +433,13 @@ static inline int verify_sec_ctx_len(const void *p)
>>  	return 0;
>>  }
>>  
>> -static inline struct xfrm_user_sec_ctx *pfkey_sadb2xfrm_user_sec_ctx(const struct sadb_x_sec_ctx *sec_ctx)
>> +static inline struct xfrm_user_sec_ctx *pfkey_sadb2xfrm_user_sec_ctx(const struct sadb_x_sec_ctx *sec_ctx,
>> +								     gfp_t gfp)
>>  {
>>  	struct xfrm_user_sec_ctx *uctx = NULL;
>>  	int ctx_size = sec_ctx->sadb_x_ctx_len;
>>  
>> -	uctx = kmalloc((sizeof(*uctx)+ctx_size), GFP_KERNEL);
>> +	uctx = kmalloc((sizeof(*uctx)+ctx_size), gfp);
>>  
>>  	if (!uctx)
>>  		return NULL;
>> @@ -1124,7 +1125,7 @@ static struct xfrm_state * pfkey_msg2xfrm_state(struct net *net,
>>  
>>  	sec_ctx = ext_hdrs[SADB_X_EXT_SEC_CTX - 1];
>>  	if (sec_ctx != NULL) {
>> -		struct xfrm_user_sec_ctx *uctx = pfkey_sadb2xfrm_user_sec_ctx(sec_ctx);
>> +		struct xfrm_user_sec_ctx *uctx = pfkey_sadb2xfrm_user_sec_ctx(sec_ctx, GFP_KERNEL);
>>  
>>  		if (!uctx)
>>  			goto out;
>> @@ -2231,7 +2232,7 @@ static int pfkey_spdadd(struct sock *sk, struct sk_buff *skb, const struct sadb_
>>  
>>  	sec_ctx = ext_hdrs[SADB_X_EXT_SEC_CTX - 1];
>>  	if (sec_ctx != NULL) {
>> -		struct xfrm_user_sec_ctx *uctx = pfkey_sadb2xfrm_user_sec_ctx(sec_ctx);
>> +		struct xfrm_user_sec_ctx *uctx = pfkey_sadb2xfrm_user_sec_ctx(sec_ctx, GFP_KERNEL);
>>  
>>  		if (!uctx) {
>>  			err = -ENOBUFS;
>> @@ -2335,7 +2336,7 @@ static int pfkey_spddelete(struct sock *sk, struct sk_buff *skb, const struct sa
>>  
>>  	sec_ctx = ext_hdrs[SADB_X_EXT_SEC_CTX - 1];
>>  	if (sec_ctx != NULL) {
>> -		struct xfrm_user_sec_ctx *uctx = pfkey_sadb2xfrm_user_sec_ctx(sec_ctx);
>> +		struct xfrm_user_sec_ctx *uctx = pfkey_sadb2xfrm_user_sec_ctx(sec_ctx, GFP_KERNEL);
>>  
>>  		if (!uctx)
>>  			return -ENOMEM;
>> @@ -3239,7 +3240,7 @@ static struct xfrm_policy *pfkey_compile_policy(struct sock *sk, int opt,
>>  		}
>>  		if ((*dir = verify_sec_ctx_len(p)))
>>  			goto out;
>> -		uctx = pfkey_sadb2xfrm_user_sec_ctx(sec_ctx);
>> +		uctx = pfkey_sadb2xfrm_user_sec_ctx(sec_ctx, GFP_ATOMIC);
>>  		*dir = security_xfrm_policy_alloc(&xp->security, uctx);
> 
> This would fix the allocation done in pfkey_sadb2xfrm_user_sec_ctx().
> But security_xfrm_policy_alloc() might call selinux_xfrm_alloc_user()
> which does a GFP_KERNEL allocation too. So I guess we also need to fix
> selinux.
> 
Right, I just saw that but fixing it at first glance doesn't seem so
trivial as we can't pass another argument from compile_policy without
changing xfrm_policy_alloc_security's prototype in struct
security_operations which AFAICT is doable with some adjustments, but not
sure if it's the right thing to do. Changing GFP_KERNEL to GFP_ATOMIC in
selinux_xfrm_alloc_user is also a possibility, but there're a many places
which use that and can sleep.
I would extend this patch, but currently don't have the time to search for
a nice solution. I can look more into it next week, or if you'd like to
take care of it, I wouldn't mind :-)

Cheers,
 Nik

