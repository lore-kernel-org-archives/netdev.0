From: "David S. Miller" <davem@davemloft.net>
Subject: Re: generic 802.11 stack
Date: Tue, 7 Sep 2004 10:32:03 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040907103203.52199758.davem@davemloft.net>
References: <200408312111.02438.vda@port.imtp.ilyichevsk.odessa.ua>
	<200409062132.49356.sam@errno.com>
	<20040906234701.511a8940.davem@davemloft.net>
	<200409072022.14330.vkondra@mail.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Vladimir Kondratiev <vkondra@mail.ru>
In-Reply-To: <200409072022.14330.vkondra@mail.ru>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 7 Sep 2004 20:22:07 +0300
Vladimir Kondratiev <vkondra@mail.ru> wrote:

> I'd like to evaluate possibility to use your stack for real driver. 80211 have 
> some specifics thus we need to answer following questions:
> 
> - some devices handles almost all MAC in firmware; some - handle control frame 
> exchange in firmware, rest - on host; some use other separation of work 
> between host and firmware. So, quite flexible mechanism to specify offloading 
> of parts of .11 stack to firmware required. What is best way? 
> netdev->features?

Use function pointers for the handlers that can be overridden by the
driver, or something similar like that.

Start with "pure %100 software" stack, then once that is fully functional
work back to add the necessary hooks to support partial software stacks.

> - there are cases when PHY information needed, to make decisions (like select 
> AP from list), or for information purposes (sniffer). What is your vision how 
> to do this? I.e. provide some standard PHY header before MAC header, out of 
> band (use cb?)

This should be stored in the 802.11 specific information struct which
I allocate for each generic device which registers with the 802.11
layer.  There should be a standard 802.11 stack interface the driver
can use the pass the information in so that the details of the layout
inside of the 802.11 device information structure need not be exported
publicly.

> - there is PHY level information that may be needed for Tx:
> modulation;rate;retry policy and rates;Tx power;protection(RTS/CTS, CTS to 
> self). Same question as above: how to provide it?

Same way.

> - there is some interesting information that may come from Tx status, like 
> success indication, last rate, retry count, energy in channel after packet, 
> actual backoff time.

Feed it back into the software stack with some kind of function call.

> - is it feasible to do rate scaling in generic way in stack? Or should it be 
> done always in the driver?

I believe so.

> - Since WME and TGe introduction, NICs will likely to have multiple Tx queues. 
> It would be wise for driver to use multiple Tx queues and start/stop them 
> separately, like have all functions netif_start_queue() etc. have additional 
> parameter - queue number. Will it fit into your stack?

We can represent this using multiple generic netdev objects, perhaps.
Or we can finally start supporting multiple queues in the generic device
struct.  I like the latter idea better, and it allows us to do other things
as well.
