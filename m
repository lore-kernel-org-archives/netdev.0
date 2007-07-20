From: Krishna Kumar2 <krkumar2@in.ibm.com>
Subject: [ofa-general] Re: [PATCH 03/10] dev.c changes.
Date: Fri, 20 Jul 2007 17:22:05 +0530
Message-ID: <OF316A971D.F3CBB5DC-ON6525731E.003F6683-6525731E.004131B7@in.ibm.com>
References: <46A09A85.7020500@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: jagana@us.ibm.com, johnpol@2ka.mipt.ru, herbert@gondor.apana.org.au,
	gaagaan@gmail.com, Robert.Olsson@data.slu.se,
	kumarkr@linux.ibm.com, rdreier@cisco.com,
	peter.p.waskiewicz.jr@intel.com, hadi@cyberus.ca,
	mcarlson@broadcom.com, jeff@garzik.org,
	general@lists.openfabrics.org, mchan@broadcom.com, tgraf@suug.ch,
	netdev@vger.kernel.org, davem@davemloft.net, sri@us.ibm.com
To: Patrick McHardy <kaber@trash.net>
Return-path: <general-bounces@lists.openfabrics.org>
In-Reply-To: <46A09A85.7020500@trash.net>
List-Unsubscribe: <http://lists.openfabrics.org/cgi-bin/mailman/listinfo/general>,
	<mailto:general-request@lists.openfabrics.org?subject=unsubscribe>
List-Archive: <http://lists.openfabrics.org/pipermail/general>
List-Post: <mailto:general@lists.openfabrics.org>
List-Help: <mailto:general-request@lists.openfabrics.org?subject=help>
List-Subscribe: <http://lists.openfabrics.org/cgi-bin/mailman/listinfo/general>,
	<mailto:general-request@lists.openfabrics.org?subject=subscribe>
Sender: general-bounces@lists.openfabrics.org
Errors-To: general-bounces@lists.openfabrics.org
List-Id: netdev.vger.kernel.org

Hi Patrick,

Patrick McHardy <kaber@trash.net> wrote on 07/20/2007 04:50:37 PM:

> > I have a TODO comment in net-sysfs.c which is to catch this case.
> >
>
> I noticed that. Still wondering why it is important at all though.

I saw another mail of yours on the marc list on this same topic (which
still hasn't come to me in the mail), so I will answer both :

> Is there any downside in using batching with smaller queue sizes?

I think there is, but as yet I don't have any data (and 16 is probably
higher
than reqd) to show it. If the queue size is very small (like 4), the extra
processing to maintain this list may take more cycles than the performance
gains for sending out few skbs, esp since most xmits will send out 1 skb
and
skb batching takes places less often (when tx lock fails or queue gets
full).

OTOH, there might be a gain to even send out 2 skbs, the problem is in
doing
the extra processing before xmit and not at the time of xmit.

Does this sound OK ? If so, I will add the code to implement the TODO for
tx_queue_len checking too.

> > Without going into GSO, it is wasting some 32 bytes on i386 since most
> > drivers don't export this API.
>
> 32 bytes? I count 16, - 4 for the pointer, so its 12 bytes of waste.
> If you'd use it for gso_skb it would come down to 8 bytes. struct
> net_device is a pig already, and there are better ways to reduce this
> than starting to allocating single members with a few bytes IMO.

Sorry, I wanted to say 12 bytes on 32 bit system but mixed it up and
said 32 bytes. So I guess static allocation is better then, and it will
also help in performance as memory access is not required (offsetof
should work).

> Yes, packets can be holding references to various stuff and
> these should be released on device down. As I said above I
> don't really like the allocation, but even if you want to
> keep it, just do the purging and dev_deactivate and keep the
> freeing in unregister_netdev (actually I guess it should be
> free_netdev to handle register_netdevice errors).

Right, that makes it clean to do (and avoid stale packets on down).
I will make both these changes now.

Thanks for these suggestions,

- KK
