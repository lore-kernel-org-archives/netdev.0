From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 2/2] xfrm: Fix unaligned access in
 xfrm_notify_sa() for DELSA
Date: Wed, 21 Oct 2015 06:10:43 -0700 (PDT)
Message-ID: <20151021.061043.723408372175418569.davem@davemloft.net>
References: <cover.1445286755.git.sowmini.varadhan@oracle.com>
	<65f37efeff5af105c89493dda4f38c61e4cd495f.1445286755.git.sowmini.varadhan@oracle.com>
	<20151021065704.GM7701@secunet.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sowmini.varadhan@oracle.com, linux-crypto@vger.kernel.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	herbert@gondor.apana.org.au, dhowells@redhat.com,
	zohar@linux.vnet.ibm.com, David.Woodhouse@intel.com
To: steffen.klassert@secunet.com
Return-path: <linux-crypto-owner@vger.kernel.org>
In-Reply-To: <20151021065704.GM7701@secunet.com>
Sender: linux-crypto-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Steffen Klassert <steffen.klassert@secunet.com>
Date: Wed, 21 Oct 2015 08:57:04 +0200

> On Mon, Oct 19, 2015 at 05:23:29PM -0400, Sowmini Varadhan wrote:
>> On sparc, deleting established SAs (e.g., by restarting ipsec
>> at the peer) results in unaligned access messages via
>> xfrm_del_sa -> km_state_notify -> xfrm_send_state_notify().
>> Use an aligned pointer to xfrm_usersa_info for this case.
>> 
>> Signed-off-by: Sowmini Varadhan <sowmini.varadhan@oracle.com>
>> ---
>>  net/xfrm/xfrm_user.c |    2 +-
>>  1 files changed, 1 insertions(+), 1 deletions(-)
>> 
>> diff --git a/net/xfrm/xfrm_user.c b/net/xfrm/xfrm_user.c
>> index a8de9e3..158ef4a 100644
>> --- a/net/xfrm/xfrm_user.c
>> +++ b/net/xfrm/xfrm_user.c
>> @@ -2659,7 +2659,7 @@ static int xfrm_notify_sa(struct xfrm_state *x, const struct km_event *c)
>>  		if (attr == NULL)
>>  			goto out_free_skb;
>>  
>> -		p = nla_data(attr);
>> +		p = PTR_ALIGN(nla_data(attr), __alignof__(*p));
> 
> Hm, this breaks userspace notifications on 64-bit systems.
> Userspace expects this to be aligned to 4, with your patch
> it is aligned to 8 on 64-bit.

That's correct, netlink attributes are fundamentally only 4 byte
aligned and this cannot be changed.  nla_data() is exactly
where the attribute must be placed, aligned or not.

The only workaround is, when designing netlink attributes.  Various
netlink libraries have workarounds for accessing, for example, 64-bit
stats which are going to be unaligned in netlink messages.
