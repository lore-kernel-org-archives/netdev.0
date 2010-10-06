From: John Fastabend <john.r.fastabend@intel.com>
Subject: Re: [net-next-2.6 PATCH] net: netif_set_real_num_rx_queues may cap
 num_rx_queues at init time
Date: Wed, 06 Oct 2010 07:52:01 -0700
Message-ID: <4CAC8D11.2060604@intel.com>
References: <20101004220042.3471.92774.stgit@jf-dev1-dcblab>	 <1286256926.2457.2.camel@edumazet-laptop>  <4CAB4D8F.8080108@intel.com> <1286296476.2307.5.camel@achroite.uk.solarflarecom.com> <4CAB6447.6040407@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"therbert@google.com" <therbert@google.com>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:61593 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932440Ab0JFOwD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 6 Oct 2010 10:52:03 -0400
In-Reply-To: <4CAB6447.6040407@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/5/2010 10:45 AM, John Fastabend wrote:
> On 10/5/2010 9:34 AM, Ben Hutchings wrote:
>> On Tue, 2010-10-05 at 09:08 -0700, John Fastabend wrote:
>>> On 10/4/2010 10:35 PM, Eric Dumazet wrote:
>>>> Le lundi 04 octobre 2010 =C3=A0 15:00 -0700, John Fastabend a =C3=A9=
crit :
>>>>> The logic for netif_set_real_num_rx_queues is the following,
>>>>>
>>>>> netif_set_real_num_rx_queues(dev, rxq)
>>>>> {
>>>>> 	...
>>>>> 	if (dev->reg_state =3D=3D NETREG_REGISTERED) {
>>>>> 		...
>>>>> 	} else {
>>>>> 		dev->num_rx_queues =3D rxq;
>>>>> 	}
>>>>>
>>>>> 	dev->real_num_rx_queues =3D rxq;
>>>>> 	return 0;
>>>>> }
>>>>>
>>>>> Some drivers init path looks like the following,
>>>>>
>>>>> alloc_etherdev_mq(priv_sz, max_num_queues_ever);
>>>>> ...
>>>>> netif_set_real_num_rx_queues(dev, queues_to_use_now);
>>>>> ...
>>>>> register_netdev(dev);
>>>>> ...
>>>>>
>>>>> Because netif_set_real_num_rx_queues sets num_rx_queues if the
>>>>> reg state is not NETREG_REGISTERED we end up with the incorrect
>>>>> max number of rx queues. This patch proposes to remove the else
>>>>> clause above so this does not occur.  Also just reading the
>>>>> function set_real_num it seems a bit unexpected that num_rx_queue=
s
>>>>> gets set.
>>>>>
>>>>
>>>> You dont tell why its "incorrect".
>>>>
>>>
>>> OK that is a poor description.
>>>
>>>> Why should we keep num_rx_queues > real_num_rx_queues ?
>>>>
>>>
>>> If we do not ever need them then we should not keep them I agree.
>>> But having netif_set_real_num_rx_queues set something other then
>>> 'real_num_rx_queues' does not seem right to me at least. Also
>>> netif_set_real_num_tx_queues and netif_set_real_num_rx_queues have
>>> different behavior. It would be nice if this weren't the case but
>>> they allocate queues in two places.
>> [...]
>>
>> I only did this to satisfy Eric's desire to reduce memory usage.
>> However, I believe that there are currently no drivers that dynamica=
lly
>> increase numbers of RX or TX queues.  Until there are, there is not =
much
>> point in removing this assignment to num_rx_queues.
>>
>> Ben.
>>
>=20
> ixgbe increases the real_num_[rx|tx]_queues when FCoE or DCB is enabl=
ed.
> Also many of the drivers could increase the number of queues if they =
were
> given more interrupt vectors at some point.


If I update the handful drivers that use netif_set_real_num_rx_queues()
before the netdevice is registered to explicitly set num_rx_queues this
would address Eric's concerns and fix drivers that really only want to =
set
real_num_rx_queue.

Any thoughts?

-- John
