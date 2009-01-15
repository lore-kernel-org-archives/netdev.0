From: Yang Hongyang <yanghy@cn.fujitsu.com>
Subject: Re: [PATCHv2]IPv6:remove duplicate check when setsockopt with IPV6_PKTINFO
 option
Date: Thu, 15 Jan 2009 08:50:11 +0800
Message-ID: <496E8843.8000906@cn.fujitsu.com>
References: <20090114034711.GA8361@gondor.apana.org.au> <496D61FE.7080500@cn.fujitsu.com> <496D651B.2000106@cn.fujitsu.com> <496D77B8.2000001@cn.fujitsu.com> <496DA1D1.2050005@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: Shan Wei <shanwei@cn.fujitsu.com>,
	Wei Yongjun <yjwei@cn.fujitsu.com>, netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:55349 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1752513AbZAOAuM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 14 Jan 2009 19:50:12 -0500
In-Reply-To: <496DA1D1.2050005@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Actually the condition (optlen == 0) is included in (optlen < sizeof(struct in6_pktinfo)),
so we do not need to check it separately.
We don't need to check (optval==NULL) either,because copy_from_user() will do the job.

Signed-off-by: Yang Hongyang<yanghy@cn.fujitsu.com>

---
 net/ipv6/ipv6_sockglue.c |    4 +---
 1 files changed, 1 insertions(+), 3 deletions(-)

diff --git a/net/ipv6/ipv6_sockglue.c b/net/ipv6/ipv6_sockglue.c
index 40f3246..1c203b6 100644
--- a/net/ipv6/ipv6_sockglue.c
+++ b/net/ipv6/ipv6_sockglue.c
@@ -399,9 +399,7 @@ sticky_done:
 	{
 		struct in6_pktinfo pkt;
 
-		if (optlen == 0)
-			goto e_inval;
-		else if (optlen < sizeof(struct in6_pktinfo) || optval == NULL)
+		if (optlen < sizeof(struct in6_pktinfo))
 			goto e_inval;
 
 		if (copy_from_user(&pkt, optval, sizeof(struct in6_pktinfo))) {
-- 
1.6.0.3

Shan Wei wrote:
> Yang Hongyang said:
>> Wei Yongjun wrote:
>>> Yang Hongyang wrote:
>>>> Herbert Xu wrote:
>>>>  
>>>>> Yang Hongyang <yanghy@cn.fujitsu.com> wrote:
>>>>>    
>>>>>> Actually the condition (optlen == 0) is included in (optlen <
>>>>>> sizeof(struct in6_pktinfo)),
>>>>>> so we do not need to check it separately.
>>>>>>       
>>>>> You don't need to check optval == NULL either since that's the
>>>>> job of copy_from_user.
>>>>>     
>>>> If optval==NULL, what we should return?EINVAL or EFAULT?
>>>> If it is EINVAL,then we should check it .otherwise it's the job of
>>>> copy_from_user
>>>>   
>>> I think if optval==NULL, the in6_pktinfo which is set should be remove.
>>> So, you should handle optval==NULL. Not just return error.
>> There's no RFC defines the behavior above,but:
>>   RFC3542 said The application can remove any sticky Routing header or sticky 
>> Destination options header or sticky Hop-by-Hop options header by calling 
>> setsockopt() with a zero option length.
>>
>> So,do we need to allow remove any sticky pktinfo option by calling 
>> setsockopt() with a zero option length?
>>
> 
> Can remove the option using seting in6_pktinfo struct wiht 
> ipi6_ifindex=0,ipi6_ifindex=IN6ADDR_ANY_INIT.
> 
> If no RFC definition, not to reset with optlen=0,
> for example IPV6_TCLASS, PV6_2292DSTOPTS.
> 


-- 
Regards
Yang Hongyang
