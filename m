From: Brian Haley <brian.haley@hp.com>
Subject: Re: [PATCH v2 net-next] sockopt: Change getsockopt() of SO_BINDTODEVICE
 to return an interface name
Date: Sat, 17 Nov 2012 16:58:05 -0500
Message-ID: <50A8086D.80207@hp.com>
References: <50A6A8FB.3050901@hp.com> <50A71B50.3030603@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Pavel Emelyanov <xemul@parallels.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g1t0028.austin.hp.com ([15.216.28.35]:40590 "EHLO
	g1t0028.austin.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752275Ab2KQV6J (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 17 Nov 2012 16:58:09 -0500
In-Reply-To: <50A71B50.3030603@parallels.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/17/2012 12:06 AM, Pavel Emelyanov wrote:
>> @@ -4165,6 +4180,8 @@ static int dev_ifname(struct net *net, struct ifreq __user
>> *arg)
>>
>>  	strcpy(ifr.ifr_name, dev->name);
>>  	rcu_read_unlock();
>> +	if (read_seqretry(&devnet_rename_seq, seq))
>> +		goto retry;
> 
> I believe it makes sense to make the seqcount protection as a separate patch
> with description of what may happen.

I asked about that before and Dave said he "wanted all the races resolved".  At
best I could make this a series...

>> +retry:
>> +	seq = read_seqbegin(&devnet_rename_seq);
>> +	rcu_read_lock();
>> +	dev = dev_get_by_index_rcu(net, sk->sk_bound_dev_if);
> 
> The sk->sk_bound_dev_if might have changed to 0 while we did read_seqretry (or
> did the len check above, but the race window is smaller) and this code will
> report -ENODEV instead of zero lenght.

If there are two threads twiddling with the same socket like this the
application is broken in my mind.

-Brian
