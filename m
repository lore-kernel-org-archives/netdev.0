From: James Chapman <jchapman@katalix.com>
Subject: Re: [PATCH 3/5 2.6.21-rc7] l2tp: pppol2tp core
Date: Thu, 26 Apr 2007 23:11:02 +0100
Message-ID: <46312376.3030407@katalix.com>
References: <200704231601.l3NG13TN030167@quickie.katalix.com> <462E29D9.8000600@trash.net> <462E57D9.3030606@katalix.com> <4630C23C.8090409@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from s36.avahost.net ([74.53.95.194]:45584 "EHLO s36.avahost.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755092AbXDZWLH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 26 Apr 2007 18:11:07 -0400
In-Reply-To: <4630C23C.8090409@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Patrick McHardy wrote:
> James Chapman wrote:
>> Patrick McHardy wrote:
>>
>>> Still the ugly old_data_ready/old_sk_destruct and pppol2tp_fget hacks.
>>
>> I added comments in the code about why I think pppol2tp_fget is needed.
>> This driver handles PPP-over-L2TP sockets. These are attached to a plain
>> UDP (L2TP) socket. When a pppol2tp socket is created, it is provided
>> with the fd of the UDP (L2TP) tunnel socket. The tunnel socket is
>> created by l2tpd, which passes the fd to pppd when it forks pppd for
>> each session in the tunnel. Since it is pppd that does the connect on
>> the pppol2tp socket (this driver) it needs to get the UDP socket via the
>> passed fd/pid. Is there another way to do this?
> 
> AFAICT the only reason why you need this is for receiving data from
> the socket by overloading sk_data_ready, so the need for this should
> go away with using encapsulation sockets.

For each session, the driver needs to locate the tunnel socket somehow. 
Before this driver gets its first request, userspace l2tpd has exchanged 
several L2TP messages with its peer over its tunnel UDP socket. It has 
set options on the socket for whether to use UDP checksums and has 
determined the MTU of the path. Ephemeral UDP ports may also be being 
used for the tunnel. I could pass all of these parameters from l2tpd to 
pppd, and then include them in the struct pppol2tp_addr which comes in 
the connect() request. But would that be cleaner than the current 
implementation? Also, I think it is good to implicitely tie each session 
to its tunnel socket and arrange that the kernel driver can cleanup all 
sessions in the tunnel should the tunnel socket go away (via sk_destruct).

I can't think of another way for the session to get a reference to its 
tunnel socket within the driver.

>>> What prevents you from using encapsulation sockets 
>>
>> It would break L2TP/IPSec. There isn't a way to stack encapsulations.
> 
> Thats not true. After decapsulating+decrypting ESP in UDP packets a
> new socket lookup is done and this one can be another encapsulation
> socket.

I hadn't realized that. So I should add a new UDP_ENCAP_L2TP encap type 
in the generic UDP code and arrange for it to call into the pppol2tp 
driver rather than use the data_ready hook?

>>> to get rid of this
>>> stuff and have ppp_generic filter out non-data frames for userspace
>>> as for other ppp drivers?
>> Not sure what you mean. ppp_generic is doing that.
> 
> I might have misunderstood the code, I'm talking about this:
> 
> +static void pppol2tp_data_ready(struct sock *sk, int len)
> +{
> ...
> +       skb = skb_dequeue(&sk->sk_receive_queue);
> +       if (skb != NULL) {
> +               if (pppol2tp_recv_core(sk, skb)) {
> 
> +                       skb_queue_head(&sk->sk_receive_queue, skb);
> +                       tunnel->old_data_ready(sk, len);
> 
> 
> This will requeue the UDP packets for userspace to read them
> directly, right? It also seems to block processing of further
> packets until userspace read it since its still at the head
> of the receive queue.

The above is sending up to userspace any packets that the driver can't 
deal with. These might be data packets with tunnel_id / session_id that 
the driver can't match to a session context for handling, or packets 
with a bad header. They might also be L2TP control packets, which are 
always passed up to userspace l2tpd. For L2TP data packets where a valid 
session context can be found, the PPP frame is passed to ppp_generic via 
ppp_input().

I'll work on adding an L2TP encap type and use the UDP encap scheme in 
the receive path to avoid using sk_data_ready. Meanwhile, please get 
back to me about pppol2tp_fget.

Thanks again for your comments - they're much appreciated.

-- 
James Chapman
Katalix Systems Ltd
http://www.katalix.com
Catalysts for your Embedded Linux software development

