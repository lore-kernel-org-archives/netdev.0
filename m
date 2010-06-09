From: "Xin, Xiaohui" <xiaohui.xin@intel.com>
Subject: RE: [RFC PATCH v7 11/19] Use callback to deal with
 skb_release_data() specially.
Date: Wed, 9 Jun 2010 15:30:37 +0800
Message-ID: <F2E9EB7348B8264F86B6AB8151CE2D791100848EA1@shsmsx502.ccr.corp.intel.com>
References: <1275732899-5423-1-git-send-email-xiaohui.xin@intel.com>
	 <1275732899-5423-2-git-send-email-xiaohui.xin@intel.com>
	 <1275732899-5423-3-git-send-email-xiaohui.xin@intel.com>
	 <1275732899-5423-4-git-send-email-xiaohui.xin@intel.com>
	 <1275732899-5423-5-git-send-email-xiaohui.xin@intel.com>
	 <1275732899-5423-6-git-send-email-xiaohui.xin@intel.com>
	 <1275732899-5423-7-git-send-email-xiaohui.xin@intel.com>
	 <1275732899-5423-8-git-send-email-xiaohui.xin@intel.com>
	 <1275732899-5423-9-git-send-email-xiaohui.xin@intel.com>
	 <1275732899-5423-10-git-send-email-xiaohui.xin@intel.com>
	 <1275732899-5423-11-git-send-email-xiaohui.xin@intel.com>
 <1275749773.5238.244.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"kvm@vger.kernel.org" <kvm@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"mst@redhat.com" <mst@redhat.com>, "mingo@elte.hu" <mingo@elte.hu>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"herbert@gondor.apana.org.au" <herbert@gondor.apana.org.au>,
	"jdike@linux.intel.com" <jdike@linux.intel.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <kvm-owner@vger.kernel.org>
In-Reply-To: <1275749773.5238.244.camel@edumazet-laptop>
Content-Language: en-US
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

>-----Original Message-----
>From: Eric Dumazet [mailto:eric.dumazet@gmail.com]
>Sent: Saturday, June 05, 2010 10:56 PM
>To: Xin, Xiaohui
>Cc: netdev@vger.kernel.org; kvm@vger.kernel.org; linux-kernel@vger.ker=
nel.org;
>mst@redhat.com; mingo@elte.hu; davem@davemloft.net; herbert@gondor.apa=
na.org.au;
>jdike@linux.intel.com
>Subject: Re: [RFC PATCH v7 11/19] Use callback to deal with skb_releas=
e_data() specially.
>
>Le samedi 05 juin 2010 =E0 18:14 +0800, xiaohui.xin@intel.com a =E9cri=
t :
>> From: Xin Xiaohui <xiaohui.xin@intel.com>
>>
>> If buffer is external, then use the callback to destruct
>> buffers.
>>
>> Signed-off-by: Xin Xiaohui <xiaohui.xin@intel.com>
>> Signed-off-by: Zhao Yu <yzhao81new@gmail.com>
>> Reviewed-by: Jeff Dike <jdike@linux.intel.com>
>> ---
>>  net/core/skbuff.c |   11 +++++++++++
>>  1 files changed, 11 insertions(+), 0 deletions(-)
>>
>> diff --git a/net/core/skbuff.c b/net/core/skbuff.c
>> index 37587f0..418457c 100644
>> --- a/net/core/skbuff.c
>> +++ b/net/core/skbuff.c
>> @@ -385,6 +385,11 @@ static void skb_clone_fraglist(struct sk_buff *=
skb)
>>
>>  static void skb_release_data(struct sk_buff *skb)
>>  {
>> +	/* check if the skb has external buffers, we have use destructor_a=
rg
>> +	 * here to indicate
>> +	 */
>> +	struct skb_external_page *ext_page =3D skb_shinfo(skb)->destructor=
_arg;
>> +
>
>Oh well. This is v7 of your series, and nobody complained yet ?
>
>This is a new cache miss on a _critical_ path.

Ok, I would remove the declaration here to avoid the new cache miss.

>
>
>>  	if (!skb->cloned ||
>>  	    !atomic_sub_return(skb->nohdr ? (1 << SKB_DATAREF_SHIFT) + 1 :=
 1,
>>  			       &skb_shinfo(skb)->dataref)) {
>> @@ -397,6 +402,12 @@ static void skb_release_data(struct sk_buff *sk=
b)
>>  		if (skb_has_frags(skb))
>>  			skb_drop_fraglist(skb);
>>
>> +		/* if the skb has external buffers, use destructor here,
>> +		 * since after that skb->head will be kfree, in case skb->head
>> +		 * from external buffer cannot use kfree to destroy.
>> +		 */
>
>Why not deferring here the access to skb_shinfo(skb)->destructor_arg ?

And references skb_shinfo(skb)->destructor_arg here.

>
>> +		if (dev_is_mpassthru(skb->dev) && ext_page && ext_page->dtor)
>> +			ext_page->dtor(ext_page);
>>  		kfree(skb->head);
>>  	}
>>  }
>
>if (dev_is_mpassthru(skb->dev)) {
>	struct skb_external_page *ext_page =3D
>				skb_shinfo(skb)->destructor_arg;
>	if (ext_page && ext_page->dtor)
>		ext_page->dtor(ext_page);
>}
>
>destructor_arg should me moved before frags[] if you really want to us=
e it.

Thanks for the patch. But why destructor_arg before frags[] is better t=
han after frags[]?
skb_release_data() will reference both of them........

>
>diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
>index bf243fc..b136d90 100644
>--- a/include/linux/skbuff.h
>+++ b/include/linux/skbuff.h
>@@ -202,10 +202,11 @@ struct skb_shared_info {
>         */
>        atomic_t        dataref;
>
>-       skb_frag_t      frags[MAX_SKB_FRAGS];
>        /* Intermediate layers must ensure that destructor_arg
>         * remains valid until skb destructor */
>        void *          destructor_arg;
>+
>+       skb_frag_t      frags[MAX_SKB_FRAGS];
> };
>
> /* We divide dataref into two halves.  The higher 16 bits hold refere=
nces
>
>

