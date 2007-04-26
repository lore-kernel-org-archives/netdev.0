From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 3/5 2.6.21-rc7] l2tp: pppol2tp core
Date: Thu, 26 Apr 2007 17:16:12 +0200
Message-ID: <4630C23C.8090409@trash.net>
References: <200704231601.l3NG13TN030167@quickie.katalix.com> <462E29D9.8000600@trash.net> <462E57D9.3030606@katalix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: James Chapman <jchapman@katalix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:59148 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S964821AbXDZPRX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Apr 2007 11:17:23 -0400
In-Reply-To: <462E57D9.3030606@katalix.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

James Chapman wrote:
> Patrick McHardy wrote:
> 
>> Still the ugly old_data_ready/old_sk_destruct and pppol2tp_fget hacks.
> 
> 
> I added comments in the code about why I think pppol2tp_fget is needed.
> This driver handles PPP-over-L2TP sockets. These are attached to a plain
> UDP (L2TP) socket. When a pppol2tp socket is created, it is provided
> with the fd of the UDP (L2TP) tunnel socket. The tunnel socket is
> created by l2tpd, which passes the fd to pppd when it forks pppd for
> each session in the tunnel. Since it is pppd that does the connect on
> the pppol2tp socket (this driver) it needs to get the UDP socket via the
> passed fd/pid. Is there another way to do this?


AFAICT the only reason why you need this is for receiving data from
the socket by overloading sk_data_ready, so the need for this should
go away with using encapsulation sockets.

>> What prevents you from using encapsulation sockets 
> 
> 
> It would break L2TP/IPSec. There isn't a way to stack encapsulations.


Thats not true. After decapsulating+decrypting ESP in UDP packets a
new socket lookup is done and this one can be another encapsulation
socket.

>> to get rid of this
>> stuff and have ppp_generic filter out non-data frames for userspace
>> as for other ppp drivers?
> 
> Not sure what you mean. ppp_generic is doing that.


I might have misunderstood the code, I'm talking about this:

+static void pppol2tp_data_ready(struct sock *sk, int len)
+{
...
+       skb = skb_dequeue(&sk->sk_receive_queue);
+       if (skb != NULL) {
+               if (pppol2tp_recv_core(sk, skb)) {

+                       skb_queue_head(&sk->sk_receive_queue, skb);
+                       tunnel->old_data_ready(sk, len);


This will requeue the UDP packets for userspace to read them
directly, right? It also seems to block processing of further
packets until userspace read it since its still at the head
of the receive queue.

>>> +/* Used by sort()
>>> + */
>>> +static void pppol2tp_seq_swap(void *a, void *b, int size)
>>> +[...]
>>
>>
>> Why is this needed? Can't userspace sort them itself in case it really
>> needs some defined ordering?
> 
> 
> Personal preference. I don't think it's a lot of code, but I don't have
> a problem removing it.


Please, it seems a bit silly to allocate extra memory and go through
the trouble of sorting the entries just for nicer /proc output.

>>> +static void pppol2tp_seq_tunnel_show(struct seq_file *m, void *v)
>>> +{
>>> +    struct pppol2tp_tunnel *tunnel = v;
>>> +
>>> +    seq_printf(m, "\nTUNNEL '%s', %c %d MAGIC %s\n",
>>> +           tunnel->name,
>>> +           (tunnel == tunnel->sock->sk_user_data) ? 'Y':'N',
>>> +           atomic_read(&tunnel->ref_count) - 1,
>>> +           (tunnel->magic == L2TP_TUNNEL_MAGIC) ? "OK" : "BAD");
>>> +    seq_printf(m, " %08x %llu/%llu/%llu %llu/%llu/%llu\n",
>>> +           tunnel->debug,
>>> +           tunnel->stats.tx_packets, tunnel->stats.tx_bytes,
>>> +           tunnel->stats.tx_errors,
>>> +           tunnel->stats.rx_packets, tunnel->stats.rx_bytes,
>>> +           tunnel->stats.rx_errors);
>>
>>
>>
>> Still no return value checks.
> 
> 
> Are they needed now that I changed the seq file handling such that a new
> buffer should be provided per tunnel and per session. I looked for
> examples of seq_printf and almost all don't use the return value.


You're right, that seems to be OK.
