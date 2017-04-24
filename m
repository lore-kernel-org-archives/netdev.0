From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: [PATCH v3 net] net: ipv6: regenerate host route if moved to gc
 list
Date: Mon, 24 Apr 2017 13:37:00 -0600
Message-ID: <0ebdefd9-3f89-1876-ba03-1a8277ff79e2@cumulusnetworks.com>
References: <1493046549-17420-1-git-send-email-dsa@cumulusnetworks.com>
 <1493051946.6453.37.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, dvyukov@google.com, andreyknvl@google.com,
        mmanning@brocade.com, kafai@fb.com
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f43.google.com ([209.85.214.43]:37447 "EHLO
        mail-it0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S972348AbdDXThE (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 24 Apr 2017 15:37:04 -0400
Received: by mail-it0-f43.google.com with SMTP id x188so63116899itb.0
        for <netdev@vger.kernel.org>; Mon, 24 Apr 2017 12:37:04 -0700 (PDT)
In-Reply-To: <1493051946.6453.37.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 4/24/17 10:39 AM, Eric Dumazet wrote:
> 
> Very nice changelog !


Thanks. Given my aggressive brain cell recycling program, I needed to
write down the analysis.



>> diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
>> index 80ce478c4851..93f81d9cd85f 100644
>> --- a/net/ipv6/addrconf.c
>> +++ b/net/ipv6/addrconf.c
>> @@ -3271,14 +3271,25 @@ static void addrconf_gre_config(struct net_device *dev)
>>  static int fixup_permanent_addr(struct inet6_dev *idev,
>>  				struct inet6_ifaddr *ifp)
>>  {
>> -	if (!ifp->rt) {
>> -		struct rt6_info *rt;
>> +	/* rt6i_ref == 0 means the host route was removed from the
>> +	 * FIB, for example, if 'lo' device is taken down. In that
>> +	 * case regenerate the host route.
>> +	 */
>> +	if (!ifp->rt || !atomic_read(&ifp->rt->rt6i_ref)) {
>> +		struct rt6_info *rt, *prev;
>>  
>>  		rt = addrconf_dst_alloc(idev, &ifp->addr, false);
>>  		if (unlikely(IS_ERR(rt)))
>>  			return PTR_ERR(rt);
>>  
>> +		prev = ifp->rt;
> 
> I would feel more comfortable if this was moved after the spin_lock() ?

That's what I had in v2; it reads better to me even if it is not
technically required (all changes to ifp->rt happen under rtnl).

Martin you agree?

I'll send a v3 tomorrow -- allow more time for other comments.
