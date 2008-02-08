From: Max Krasnyansky <maxk@qualcomm.com>
Subject: Re: [Bugme-new] [Bug 9888] New: tun device without protocol info
 header fails under IPv6
Date: Thu, 07 Feb 2008 20:58:04 -0800
Message-ID: <47ABE15C.3090606@qualcomm.com>
References: <bug-9888-10286@http.bugzilla.kernel.org/> <20080204145304.f4921bf4.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: steve.zabele@baesystems.com, bugme-daemon@bugzilla.kernel.org,
	netdev@vger.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from warlock.qualcomm.com ([129.46.50.49]:37090 "EHLO
	warlock.qualcomm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933012AbYBHFd2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Feb 2008 00:33:28 -0500
Received: from ithilien.qualcomm.com (ithilien.qualcomm.com [129.46.51.59])
	by warlock.qualcomm.com (8.14.2/8.13.6/1.0) with ESMTP id m185BY06006673
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=FAIL)
	for <netdev@vger.kernel.org>; Thu, 7 Feb 2008 21:11:34 -0800 (PST)
In-Reply-To: <20080204145304.f4921bf4.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Andrew Morton wrote:
> On Mon,  4 Feb 2008 13:46:13 -0800 (PST)
> bugme-daemon@bugzilla.kernel.org wrote:
>>
>> Open a tun device as type TUN, set the TUN_NO_PI flag, and try sending an IPv6
>> packet. The packet appears at the interface under tcpdumps, but propagates no
>> further. This is because the default protocol info used for tun devices where
>> the TUN_NO_PI flag is set assumes IPv4 as can be seen by the initialization at
>> the top of the tun_get_user function in drivers/net/tun.c file given by
>>
>>         struct tun_pi pi = { 0, __constant_htons(ETH_P_IP) };
>>
>> This can easily be fixed by adding a quick check at the top of tun_get_user.
>> Basically the code that used to read
>>
>>         if (!(tun->flags & TUN_NO_PI)) {
>>                 if ((len -= sizeof(pi)) > count)
>>                         return -EINVAL;
>>
>>                 if(memcpy_fromiovec((void *)&pi, iv, sizeof(pi)))
>>                         return -EFAULT;
>>         }
>>
>> when changed to read
>>
>>         if (!(tun->flags & TUN_NO_PI)) {
>>                 if ((len -= sizeof(pi)) > count)
>>                         return -EINVAL;
>>
>>                 if(memcpy_fromiovec((void *)&pi, iv, sizeof(pi)))
>>                         return -EFAULT;
>>         }
>>         else {
>>           /* Fixup default pi if IPv6 rather than IPv4 */
>>           if (((tun->flags & TUN_TYPE_MASK) == TUN_TUN_DEV) &&
>>               (*(char *)(iv->iov_base)      == 0x60)) {
>>             pi.proto = __constant_htons(ETH_P_IPV6);
>>           }
>>         }
>>
>> fixes the problem. 
>>
>> How do we get this in as part of the maintained codebase??
>>
> 
> Please email a tested patch prepared as described in
> 
> 	Documentation/SubmittingPatches
> 	Documentation/SubmitChecklist
> 	http://www.zip.com.au/~akpm/linux/patches/stuff/tpp.txt
> 
> to
> 
> 	Maxim Krasnyansky <maxk@qualcomm.com>
> 	"David S. Miller" <davem@davemloft.net>
> 	Andrew Morton <akpm@linux-foundation.org>
> 	netdev@vger.kernel.org

btw I'd be ok with this fix. But I guess the questions is why not use 
struct tun_pi in the apps instead ?

Max





