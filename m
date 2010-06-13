From: John Fastabend <john.r.fastabend@intel.com>
Subject: Re: mpd client timeouts (bisected) 2.6.35-rc3
Date: Sun, 13 Jun 2010 13:36:30 -0700
Message-ID: <4C15414E.5090201@intel.com>
References: <20100612102802.GA1782@arch.tripp.de> <20100612.145835.123986343.davem@davemloft.net> <4C149147.3080808@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	yanmin_zhang@linux.intel.com, alex.shi@intel.com,
	tim.c.chen@intel.com
To: David Miller <davem@davemloft.net>,
	"markus@trippelsdorf.de" <markus@trippelsdorf.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4C149147.3080808@intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

John Fastabend wrote:
> David Miller wrote:
>> From: Markus Trippelsdorf <markus@trippelsdorf.de>
>> Date: Sat, 12 Jun 2010 12:28:02 +0200
>>
>>> Commit 597a264b1a9c7e36d1728f677c66c5c1f7e3b837:
>>> =BBnet: deliver skbs on inactive slaves to exact matches=AB
>>>
>>> causes large timeouts when mpd clients try to connect to a locally
>>> running mpd (music player demon) on my machine. This makes it=20
>>> impossible to control mpd.
>>>
>>> I bisected this down to the commit mentioned above.
>>> Reverting the commit from 2.6.35-rc3 also solves the problem.
>> John, find an easy and fast way to fix this or else I am
>> going to revert.
>>
>> Thanks.
>=20
> Looks like skbs are hitting loopback_xmit() with deliver_no_wcard set=
=2E  Then in=20
> the receive path these skbs are only delivered to exact matches.  Not=
 sure why=20
> this bit is set here, I'll track this down first thing tomorrow.
>=20
> Thanks,
> John.
> --

Needed to set the wcard bit in copy_skb_header otherwise it will not be=
 cleared=20
when called from skb_clone.  Which then hits the loopback device gets p=
ushed=20
into the rx path and is eventually dropped. The following patch fixes t=
his.=20
Hopefully, this is easy and fast enough for you Dave.


[PATCH] net: fix deliver_no_wcard regression on loopback device

deliver_no_wcard is not being set in skb_copy_header.
In the skb_cloned case it is not being cleared and
may cause the skb to be dropped when the loopback device
pushes it back up the stack.

Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
---

  net/core/skbuff.c |    1 +
  1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index 9f07e74..bcf2fa3 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -532,6 +532,7 @@ static void __copy_skb_header(struct sk_buff *new, =
const=20
struct sk_buff *old)
  	new->ip_summed		=3D old->ip_summed;
  	skb_copy_queue_mapping(new, old);
  	new->priority		=3D old->priority;
+	new->deliver_no_wcard	=3D old->deliver_no_wcard;
  #if defined(CONFIG_IP_VS) || defined(CONFIG_IP_VS_MODULE)
  	new->ipvs_property	=3D old->ipvs_property;
  #endif
