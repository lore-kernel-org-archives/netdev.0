From: Karl Hiramoto <karl@hiramoto.org>
Subject: Re: PPPoE performance regression
Date: Wed, 13 Jun 2012 22:17:21 +0200
Message-ID: <4FD8F551.4020708@hiramoto.org>
References: <1339143949.24571.72.camel@dualcore.traverse>  <1339144110.13998.1.camel@i7.infradead.org>  <1339144954.24571.80.camel@dualcore.traverse>  <1339147045.13998.3.camel@i7.infradead.org>  <1339289425.2661.27.camel@laptop> <1339317136.2851.54.camel@shinybook.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Nathan Williams <nathan@traverse.com.au>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: David Woodhouse <dwmw2@infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hapkido.dreamhost.com ([66.33.216.122]:60253 "EHLO
	hapkido.dreamhost.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751113Ab2FMUTs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Jun 2012 16:19:48 -0400
Received: from homiemail-a34.g.dreamhost.com (caiajhbdccah.dreamhost.com [208.97.132.207])
	by hapkido.dreamhost.com (Postfix) with ESMTP id 458CF2191
	for <netdev@vger.kernel.org>; Wed, 13 Jun 2012 13:22:41 -0700 (PDT)
In-Reply-To: <1339317136.2851.54.camel@shinybook.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/10/12 10:32, David Woodhouse wrote:
>   On Sun, 2012-06-10 at 10:50 +1000, Nathan Williams wrote:
>>> When using iperf with UDP, we can get 20Mbps downstream, but only about
>>> 15Mbps throughput when using TCP on a short ADSL line (line sync at
>>> 25Mbps).  Using iperf to send UDP traffic upstream at the same time
>>> doesn't affect the downstream rate.
>> ...
>>
>> I found the change responsible for the performance problem and rebuilt
>> OpenWrt with the patch reversed on kernel 3.3.8 to confirm everything
>> still works.  So the TX buffer is getting full, which causes the netif
>> queue to be stopped and restarted after some skbs have been freed?
> The *Ethernet* netif queue, yes. But not the PPP netif queue, I believe.
> I think the PPP code keeps just blindly calling dev_queue_xmit() and
> throwing away packets when they're not accepted.
>
>> commit 137742cf9738f1b4784058ff79aec7ca85e769d4
>> Author: Karl Hiramoto <karl@hiramoto.org>
>> Date:   Wed Sep 2 23:26:39 2009 -0700
>>
>>      atm/br2684: netif_stop_queue() when atm device busy and
>> netif_wake_queue() when we can send packets again.
> Nice work; well done finding that. I've added Karl and DaveM, and the
> netdev@ list to Cc.
>
> (Btw, I assume the performance problem also goes away if you use PPPoA?
> I've made changes in the PPPoA code recently to *eliminate* excessive
> calls to netif_wake_queue(), and also to stop it from filling the ATM
> device queue. That was commit 9d02daf7 in 3.5-rc1, which is already in
> OpenWRT.)
>
> I was already looking vaguely at how we could limit the PPP queue depth
> for PPPoE and implement byte queue limits. Currently the PPP code just
> throws the packets at the Ethernet device and considers them 'gone',
> which is why it's hitting the ATM limits all the time. The patch you
> highlight is changing the behaviour in a case that should never *happen*
> with PPP. It's suffering massive queue bloat if it's filling the ATM
> queue, and we should fix *that*.

Agreed,  the issue is the PPP layer.     I've seen this issue with PPPoE 
before,  haven't had  the itch, time or interest to fix it though.   A 
workaround to help mitigate the issue may be to increase the TX queue 
length of the  br2684  interface, and the atm device if possible.   
You'll pay the price  of buffer bloat and latency.


--
Karl
