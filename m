From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: [patch/RFC]: Asynchronous IPsec processing.
Date: Sat, 30 Apr 2005 17:36:53 +0400
Message-ID: <20050430173653.0b060eb4@zanzibar.2ka.mipt.ru>
References: <20050429144103.A23268@2ka.mipt.ru>
Reply-To: johnpol@2ka.mipt.ru
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, Herbert Xu <herbert@gondor.apana.org.au>,
        Patrick
 McHardy <kaber@trash.net>,
        "David S. Miller" <davem@davemloft.net>,
        Jamal
 Hadi Salim <hadi@cyberus.ca>
Return-path: <netdev-bounce@oss.sgi.com>
To: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
In-Reply-To: <20050429144103.A23268@2ka.mipt.ru>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 29 Apr 2005 14:41:03 +0400
Evgeniy Polyakov <johnpol@2ka.mipt.ru> wrote:

> Hello.
> 
> I've created POC code to perform asynchronous IPsec [ESP]
> processing. Please comment about bugs in the following patch.
> It of course very dirty - but it is only begining, 
> I just want to know if approach is right.
> Patch was tested with several ssh session and some 
> traffic like find / and tcpdump over them.

Some ideas behind it follow.
Due to struct dst_entry stackability
we can return NET_XMIT_SUCCESS (0) from not the last dst->output(),
which is ip_output_xmit(), which queues skb and returns 0, but from
xfrm's output method, which calls transformation function like esp_output()
or ah_output(), before transformaton take place and defer it's processing,
when later we will call dst_output() again, thus emulating it's original
call from the network stack, with skb->dst being set to the next 
struct dst_entry like it was done in synchronous IPsec, the most
likely it will be ip_queue_xmit() - the latest transport output method.
So after original dst_output() is finished in it's middle,
skb will be flying aroung for some time 
until some callback calls dst_output() again with appropriate skb->dst.
Above logic is implemented with cloned skbs and dst entry being held,
but I have some suspicions about xfrm state in that processing.

Patch was tested on SMP with netperf TCP strem test too, and it does not
crash for quite long time, but then some bug occured - netconsole
did not show it, but in real console was something from receive path
(net_receive_*) so it probably was not that change.
Patch is against 2.6.12-rc2.

It was created to allow asynchronous crypto processing deferring and
thus to be able to use hardware crypto acceleration which
is supported in the existing asynchronous crypto layers for linux kernel.

Comments?

	Evgeniy Polyakov

Only failure makes us experts. -- Theo de Raadt
