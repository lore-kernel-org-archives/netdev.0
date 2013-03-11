From: Tom Tucker <tom-7bPotxP6k4+P2YhJcF5u+vpXobYPEAuW@public.gmane.org>
Subject: Re: [PATCH linux-next v3] SUNRPC: rpcrdma_register_default_external:
 Dynamically allocate ib_phys_buf
Date: Mon, 11 Mar 2013 18:02:09 -0500
Message-ID: <513E6271.3060107@opengridcomputing.com>
References: <4FA345DA4F4AE44899BD2B03EEEC2FA9286BA156@sacexcmbx05-prd.hq.netapp.com> <1363036508-24935-1-git-send-email-tim.gardner@canonical.com> <20130311212535.GG642@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Tim Gardner <tim.gardner-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Trond Myklebust <Trond.Myklebust-HgOvQuBEEgTQT0dZR+AlfA@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, Tom Tucker <tom-/Yg/VP3ZvrM@public.gmane.org>,
	Haggai Eran <haggaie-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Or Gerlitz <ogerlitz-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Shani Michaeli <shanim-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: "J. Bruce Fields" <bfields-uC3wQj2KruNg9hUCZPvPmw@public.gmane.org>
Return-path: <linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20130311212535.GG642-uC3wQj2KruNg9hUCZPvPmw@public.gmane.org>
Sender: linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 3/11/13 4:25 PM, J. Bruce Fields wrote:
> On Mon, Mar 11, 2013 at 03:15:08PM -0600, Tim Gardner wrote:
>> rpcrdma_register_default_external() is several frames into the call stack which
>> goes deeper yet. You run the risk of stack corruption by declaring such a large
>> automatic variable, so move the array of 'struct ib_phys_buf' objects into the
>> transport structure 'struct rpcrdma_xprt' (which is dynamically allocated) in
>> order to silence the frame-larger-than warning. Access to each struct
>> rpcrdma_xprt is serialized by XPRT_LOCKED in xprt_reserve_xprt(), so there is
>> no danger of multiple accessors to the array of struct ib_phys_buf objects.
>>
>> net/sunrpc/xprtrdma/verbs.c: In function 'rpcrdma_register_default_external':
>> net/sunrpc/xprtrdma/verbs.c:1774:1: warning: the frame size of 1056 bytes is larger than 1024 bytes [-Wframe-larger-than=]
>>
>> gcc version 4.6.3
>>
>> Cc: Trond Myklebust <Trond.Myklebust-HgOvQuBEEgTQT0dZR+AlfA@public.gmane.org>
>> Cc: "J. Bruce Fields" <bfields-uC3wQj2KruNg9hUCZPvPmw@public.gmane.org>
>> Cc: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
>> Cc: Tom Tucker <tom-/Yg/VP3ZvrM@public.gmane.org>
>> Cc: Haggai Eran <haggaie-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
>> Cc: Or Gerlitz <ogerlitz-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
>> Cc: Shani Michaeli <shanim-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
>> Cc: linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
>> Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
>> Signed-off-by: Tim Gardner <tim.gardner-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
>> ---
>> v1 - Use kmalloc() to dynamically allocate and free the array of 'struct
>> ib_phys_buf' objects
>>
>> v2 - Move the array of 'struct ib_phys_buf' objects into struct rpcrdma_req
>> and pass this request down through rpcrdma_register_external() and
>> rpcrdma_register_default_external(). This is less overhead then using
>> kmalloc() and requires no extra error checking as the allocation burden is
>> shifted to the transport client.
>>
>> v3 - Move the array of 'struct ib_phys_buf' objects into struct rpcrdma_xprt.
>> Pass a pointer to this transport structure into rpcrdma_register_default_external().
>> This is less overhead then using kmalloc() and requires no extra error checking
>> as the allocation burden is shifted to the transport client.
> Looks good to me; wish we could get it tested....

I will test it. Tim could you please send me a final version that you'd 
like tested as a single message?

Would someone (like Tim maybe ... hint hint) look at tearing out all those 
dead registration strategies? I don't think we need or will ever use 
bounce-buffers, memory windows, or mlnx fmr.  The only two that are used 
and tested are all-phys and FRMR (the default).

Tom

> In future if we do decide to also increase the size of that array we may
> need to allocate it separately from struct rpcrdma_xprt itself, which
> looks already fairly large without it; on x86_64:
>
> 	$ gdb net/sunrpc/xprtrdma/xprtrdma.ko
> 	...
> 	(gdb) p sizeof(struct rpcrdma_xprt)
> 	$1 = 2912
>
> But that shouldn't be a big deal to do.
>
> --b.
>
>>   net/sunrpc/xprtrdma/verbs.c     |   10 ++++++----
>>   net/sunrpc/xprtrdma/xprt_rdma.h |    5 ++++-
>>   2 files changed, 10 insertions(+), 5 deletions(-)
>>
>> diff --git a/net/sunrpc/xprtrdma/verbs.c b/net/sunrpc/xprtrdma/verbs.c
>> index 93726560..c7aa3da 100644
>> --- a/net/sunrpc/xprtrdma/verbs.c
>> +++ b/net/sunrpc/xprtrdma/verbs.c
>> @@ -1730,13 +1730,14 @@ rpcrdma_deregister_memwin_external(struct rpcrdma_mr_seg *seg,
>>   }
>>   
>>   static int
>> -rpcrdma_register_default_external(struct rpcrdma_mr_seg *seg,
>> -			int *nsegs, int writing, struct rpcrdma_ia *ia)
>> +rpcrdma_register_default_external(struct rpcrdma_xprt *r_xprt,
>> +			struct rpcrdma_mr_seg *seg, int *nsegs, int writing,
>> +			struct rpcrdma_ia *ia)
>>   {
>>   	int mem_priv = (writing ? IB_ACCESS_REMOTE_WRITE :
>>   				  IB_ACCESS_REMOTE_READ);
>>   	struct rpcrdma_mr_seg *seg1 = seg;
>> -	struct ib_phys_buf ipb[RPCRDMA_MAX_DATA_SEGS];
>> +	struct ib_phys_buf *ipb = r_xprt->ipb;
>>   	int len, i, rc = 0;
>>   
>>   	if (*nsegs > RPCRDMA_MAX_DATA_SEGS)
>> @@ -1827,7 +1828,8 @@ rpcrdma_register_external(struct rpcrdma_mr_seg *seg,
>>   
>>   	/* Default registration each time */
>>   	default:
>> -		rc = rpcrdma_register_default_external(seg, &nsegs, writing, ia);
>> +		rc = rpcrdma_register_default_external(r_xprt, seg, &nsegs,
>> +			writing, ia);
>>   		break;
>>   	}
>>   	if (rc)
>> diff --git a/net/sunrpc/xprtrdma/xprt_rdma.h b/net/sunrpc/xprtrdma/xprt_rdma.h
>> index cc1445d..d7b440f 100644
>> --- a/net/sunrpc/xprtrdma/xprt_rdma.h
>> +++ b/net/sunrpc/xprtrdma/xprt_rdma.h
>> @@ -269,7 +269,8 @@ struct rpcrdma_stats {
>>    * for convenience. This structure need not be visible externally.
>>    *
>>    * It is allocated and initialized during mount, and released
>> - * during unmount.
>> + * during unmount. Access to this structure is serialized by XPRT_LOCKED
>> + * in xprt_reserve_xprt().
>>    */
>>   struct rpcrdma_xprt {
>>   	struct rpc_xprt		xprt;
>> @@ -279,6 +280,8 @@ struct rpcrdma_xprt {
>>   	struct rpcrdma_create_data_internal rx_data;
>>   	struct delayed_work	rdma_connect;
>>   	struct rpcrdma_stats	rx_stats;
>> +	/* temp work array */
>> +	struct ib_phys_buf	ipb[RPCRDMA_MAX_DATA_SEGS];
>>   };
>>   
>>   #define rpcx_to_rdmax(x) container_of(x, struct rpcrdma_xprt, xprt)
>> -- 
>> 1.7.9.5
>>

--
To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
