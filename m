From: Christian Borntraeger <borntraeger-tA70FqPdS9bQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH resent] virtio_net: Fix stalled inbound
	trafficon early packets
Date: Tue, 11 Dec 2007 14:16:12 +0100
Message-ID: <200712111416.12655.borntraeger@de.ibm.com>
References: <200712111242.28843.borntraeger@de.ibm.com>
	<475E8716.2010500@qumranet.com> <475E892D.9060400@qumranet.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============0620887152=="
Cc: kvm-devel <kvm-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, virtualization-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: dor.laor-atKUWr5tajBWk0Htik3J/w@public.gmane.org
Return-path: <kvm-devel-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
In-Reply-To: <475E892D.9060400-atKUWr5tajBWk0Htik3J/w@public.gmane.org>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/kvm-devel>,
	<mailto:kvm-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=kvm-devel>
List-Post: <mailto:kvm-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
List-Help: <mailto:kvm-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/kvm-devel>,
	<mailto:kvm-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=subscribe>
Sender: kvm-devel-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
Errors-To: kvm-devel-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
List-Id: netdev.vger.kernel.org

--===============0620887152==
Content-Type: multipart/alternative; boundary="Boundary-01=_c2oXHNwSHqi0wml"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

--Boundary-01=_c2oXHNwSHqi0wml
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit

Dor Laor wrote:
> Christian Borntraeger wrote:
>>
>> Hello Rusty,
>>
>> while implementing and testing virtio on s390 I found a problem in
>> virtio_net: The current virtio_net driver has a startup race, which
>> prevents any incoming traffic:
>>
>> If try_fill_recv submits buffers to the host system data might be
>> filled in and an interrupt is sent, before napi_enable finishes.
>> In that case the interrupt will kick skb_recv_done which will then
>> call netif_rx_schedule. netif_rx_schedule checks, if NAPI_STATE_SCHED
>> is set - which is not as we did not run napi_enable. No poll routine
>> is scheduled. Furthermore, skb_recv_done returns false, we disables
>> interrupts for this device.
>>
>> One solution is the enable napi before inbound buffer are available.
>>
> But then you might get recv interrupt without a buffer.

If I look at the current implementation (lguest) no interrupt is sent if
there is not buffer available, no?
On the other hand, if the host does send an interrupt when no buffer is
available, this is also no problem. Looking at virtnet_poll, it seems it
can cope with an empty ring. 

> The way other physical NICs doing it is by dis/en/abling interrupt 
> using registers (look at e1000).
> I suggest we can export add_status and use the original code but
> before enabling napi add a call to add_status(dev, 
> VIRTIO_CONFIG_DEV_OPEN).
> The host won't trigger an irq until it sees the above.

That would also work. We already have VRING_AVAIL_F_NO_INTERRUPT in
virtio_ring.c - maybe we can use that. Its hidden in callback and
restart handling, what about adding an explicit startup?
>
> BTW: Rusty is on vacation and that's probably the reason he didn't 
> respond.
> Regards,
> Dor.

Ok, didnt know that. At the moment I can live with my private patch
while we work on a final solution. Meanwhile I will try to debug virtio
on SMP guests - I still see some strange races on our test system. (But
block and net is now working on s390 and can cope with medium load. )

Christian



--Boundary-01=_c2oXHNwSHqi0wml
Content-Type: text/html;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit

<html><head><meta name="qrichtext" content="1" /></head><body style="font-size:10pt;font-family:Courier New">
<p>Dor Laor wrote:</p>
<p>&gt; Christian Borntraeger wrote:</p>
<p>&gt;&gt;</p>
<p>&gt;&gt; Hello Rusty,</p>
<p>&gt;&gt;</p>
<p>&gt;&gt; while implementing and testing virtio on s390 I found a problem in</p>
<p>&gt;&gt; virtio_net: The current virtio_net driver has a startup race, which</p>
<p>&gt;&gt; prevents any incoming traffic:</p>
<p>&gt;&gt;</p>
<p>&gt;&gt; If try_fill_recv submits buffers to the host system data might be</p>
<p>&gt;&gt; filled in and an interrupt is sent, before napi_enable finishes.</p>
<p>&gt;&gt; In that case the interrupt will kick skb_recv_done which will then</p>
<p>&gt;&gt; call netif_rx_schedule. netif_rx_schedule checks, if NAPI_STATE_SCHED</p>
<p>&gt;&gt; is set - which is not as we did not run napi_enable. No poll routine</p>
<p>&gt;&gt; is scheduled. Furthermore, skb_recv_done returns false, we disables</p>
<p>&gt;&gt; interrupts for this device.</p>
<p>&gt;&gt;</p>
<p>&gt;&gt; One solution is the enable napi before inbound buffer are available.</p>
<p>&gt;&gt;</p>
<p>&gt; But then you might get recv interrupt without a buffer.</p>
<p></p>
<p>If I look at the current implementation (lguest) no interrupt is sent if</p>
<p>there is not buffer available, no?</p>
<p>On the other hand, if the host does send an interrupt when no buffer is</p>
<p>available, this is also no problem. Looking at virtnet_poll, it seems it</p>
<p>can cope with an empty ring. </p>
<p></p>
<p>&gt; The way other physical NICs doing it is by dis/en/abling interrupt </p>
<p>&gt; using registers (look at e1000).</p>
<p>&gt; I suggest we can export add_status and use the original code but</p>
<p>&gt; before enabling napi add a call to add_status(dev, </p>
<p>&gt; VIRTIO_CONFIG_DEV_OPEN).</p>
<p>&gt; The host won't trigger an irq until it sees the above.</p>
<p></p>
<p>That would also work. We already have VRING_AVAIL_F_NO_INTERRUPT in</p>
<p>virtio_ring.c - maybe we can use that. Its hidden in callback and</p>
<p>restart handling, what about adding an explicit startup?</p>
<p>&gt;</p>
<p>&gt; BTW: Rusty is on vacation and that's probably the reason he didn't </p>
<p>&gt; respond.</p>
<p>&gt; Regards,</p>
<p>&gt; Dor.</p>
<p></p>
<p>Ok, didnt know that. At the moment I can live with my private patch</p>
<p>while we work on a final solution. Meanwhile I will try to debug virtio</p>
<p>on SMP guests - I still see some strange races on our test system. (But</p>
<p>block and net is now working on s390 and can cope with medium load. )</p>
<p></p>
<p>Christian</p>
<p></p>
<p></p>
<p></p>
</body></html>
--Boundary-01=_c2oXHNwSHqi0wml--


--===============0620887152==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

-------------------------------------------------------------------------
SF.Net email is sponsored by:
Check out the new SourceForge.net Marketplace.
It's the best place to buy or sell services for
just about anything Open Source.
http://sourceforge.net/services/buy/index.php
--===============0620887152==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
kvm-devel mailing list
kvm-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
https://lists.sourceforge.net/lists/listinfo/kvm-devel

--===============0620887152==--
