From: Daniel Drake <dsd@gentoo.org>
Subject: Re: netif_tx_disable vs netif_stop_queue (possible races?)
Date: Sat, 10 Jun 2006 17:40:39 +0100
Message-ID: <448AF607.8000603@gentoo.org>
References: <E1FoYoi-0001gg-00@gondolin.me.apana.org.au> <448993C9.8040400@gentoo.org> <20060609233531.GA15756@gondor.apana.org.au> <448ABE2D.8040401@gentoo.org> <20060610125940.GA2983@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Herbert Xu <herbert@gondor.apana.org.au>, netdev@vger.kernel.org,
	david-b@pacbell.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mta09-winn.ispmail.ntl.com ([81.103.221.49]:32464 "EHLO
	mtaout03-winn.ispmail.ntl.com") by vger.kernel.org with ESMTP
	id S1030452AbWFJQjV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 10 Jun 2006 12:39:21 -0400
To: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
In-Reply-To: <20060610125940.GA2983@2ka.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Evgeniy Polyakov wrote:
> On Sat, Jun 10, 2006 at 01:42:21PM +0100, Daniel Drake (dsd@gentoo.org) wrote:
>> Herbert Xu wrote:
>>> Correct.  All callers of hard_start_xmit do so under RCU or equivalent
>>> locks so they must be complete by the time synchronize_net() returns.
>> Does this hold for other operations? Such as:
>>
>> - The netdev->set_mac_address function
>> - The wireless ioctl's (SIOCSIWESSID, etc)
>>
>> Are these also guaranteed to have returned after synchronize_net()?
> 
> None of above calls is protected with RCU (except set_mac_address()
> called through ioctl, which is performed under read_lock which disables
> preemtption), so they still can run after synchronize_net().
> 
> But if you are talking about synchronize_net() inside
> unregister_netdevice(), which is called from 
> usbnet_disconnect()->unregister_netdev(), than it is safe.

Are you referring to set_mac_address in the above statement, or both 
set_mac_address *and* the wireless ioctls?

I'm basically just looking to clarify that after unregister_netdev has 
completed, none of the following can be still in progress on any CPU, 
and none of the following can be triggered again:

1. hard_start_xmit handler
2. set_mac_address handler
3. WX ioctls

It's logical that this is the case, but the code doesn't make that very 
clear (and would certainly result in many potential ZD1211 races if this 
was not the case).

Daniel

