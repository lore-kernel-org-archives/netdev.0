From: Jiri Pirko <jpirko@redhat.com>
Subject: Re: [PATCH] pktgen: Clone skb to avoid corruption of skbs in
 ndo_start_xmit methods
Date: Tue, 19 Jul 2011 22:29:23 +0200
Message-ID: <20110719202922.GA2352@minipsycho>
References: <1311105179-26408-1-git-send-email-nhorman@tuxdriver.com>
 <1311105738.3113.11.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Neil Horman <nhorman@tuxdriver.com>, netdev@vger.kernel.org,
	Alexey Dobriyan <adobriyan@gmail.com>,
	"David S. Miller" <davem@davemloft.net>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:61752 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751092Ab1GSU3d (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 19 Jul 2011 16:29:33 -0400
Content-Disposition: inline
In-Reply-To: <1311105738.3113.11.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Tue, Jul 19, 2011 at 10:02:18PM CEST, eric.dumazet@gmail.com wrote:
>Le mardi 19 juillet 2011 =E0 15:52 -0400, Neil Horman a =E9crit :
>> This oops was reported recently when running a pktgen script that ca=
lled for a
>> transmitted skb to be cloned and sent 100 times using the clone_skb =
command to a
>> bridge device with several attached interface:
>>=20
>...
>
>> Turns out the pktgen driver doesn't actually clone skbs, but rather =
shares them,
>> increasing the reference count of the skb for each send operation.  =
This works
>> for most drivers because most drivers don't store or care about any =
state in the
>> skb itself, but several do.  For instance, the above tun/tap driver =
and other
>> soft drivers (vlans, bonding/bridging), all requeue frames to a phys=
ical device,
>> meaning the skb next and prev pointers will be set.  Other drivers a=
lso care
>> about skb state.  The virtio_net driver for instance uses the skb->c=
b space to
>> store a vnet header and several converged adapters adjust the data p=
ointer of an
>> skb to prepend a device control header to the skb.  Drivers expect s=
kbs
>> submitted for i/o to be in their control and unshared with other use=
rs, an
>> assumption which pktgen is violating, the result being multiple skb =
users
>> corrupting one antohers state and producing oopses like the one abov=
e.  The
>> solution is to make pktgen clone the skb for each transmit so as to =
ensure the
>> drivers assumptions about private exclusive access to the skb is mai=
ntained.
>>=20
>> Tested successfully by myself
>> Signed-off-by: Neil Horman <nhorman@tuxdriver.com>
>> Reported-by: Jiri Pirko <jpirko@redhat.com>
>> CC: Eric Dumazet <eric.dumazet@gmail.com>
>> CC: Alexey Dobriyan <adobriyan@gmail.com>
>> CC: David S. Miller <davem@davemloft.net>
>> ---
>
>This will kill pktgen performance ?
>
>pktgen is only for sysadmins, and very skilled ones :)

You are right, but it may not cause panic, right? In case this patch
would cause significant performance regression, how about to just forbi=
d
pktgen to run on soft-netdevs ?

Jirka

>
>BTW you forgot to CC pktgen author, Robert Olsson
>
>
>
>--
>To unsubscribe from this list: send the line "unsubscribe netdev" in
>the body of a message to majordomo@vger.kernel.org
>More majordomo info at  http://vger.kernel.org/majordomo-info.html
