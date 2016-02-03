From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: [PATCH v3] net:Add sysctl_max_skb_frags
Date: Wed, 3 Feb 2016 09:43:16 -0800
Message-ID: <CAKgT0UdGeOJ+NyegQ6vPCdXF39NoiFXQdTjAOoFaokteNWiygw@mail.gmail.com>
References: <568F87AC.60405@oracle.com>
	<1454488017-8822-1-git-send-email-hans.westgaard.ry@oracle.com>
	<CAKgT0UftR3pTOGO91GaUijPCTq8POQcNChRqyy1b1TYsM3n4Uw@mail.gmail.com>
	<1454515628.7627.245.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Hans Westgaard Ry <hans.westgaard.ry@oracle.com>,
	"David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>,
	Tom Herbert <tom@herbertland.com>,
	Pablo Neira Ayuso <pablo@netfilter.org>,
	Eric Dumazet <edumazet@google.com>,
	Florian Westphal <fw@strlen.de>, Jiri Pirko <jiri@resnulli.us>,
	Alexander Duyck <alexander.h.duyck@redhat.com>,
	Michal Hocko <mhocko@suse.com>,
	=?UTF-8?Q?Linus_L=C3=BCssing?= <linus.luessing@c0d3.blue>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Tejun Heo <tj@kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Alexey Kodanev <alexey.kodanev@oracle.com>,
	=?UTF-8?B?SMOla29uIEJ1Z2dl?= <haakon.bugge@oracle.com>,
	open list <linux-kernel@vger.kernel.org>,
	"open list
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1454515628.7627.245.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Feb 3, 2016 at 8:07 AM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Wed, 2016-02-03 at 07:58 -0800, Alexander Duyck wrote:
>> > +++ b/net/core/sysctl_net_core.c
>>
>> I really don't think these changes belong in the core. Below you only
>> modify the TCP code path so this more likely belongs in the TCP path
>> unless you are going to guarantee that all other code paths obey the
>> sysctl.  It probably belongs in net/ipv4/sysctl_net_ipv4.c
>
>
> Alexander, this is a v3.

Well I guess that means that a v4 might be needed.  I get that others
have reviewed it but obviously their opinions differed from mine as I
have a few objections to parts of this patch.

> We rejected prior attempts doing exactly what you suggest.

Okay so it sounds like there are some other opinions on this then that
I am not aware of.

> Think about GRO : These people also need to use the same sysctl in GRO
> to limit number of frags.

Okay, well without the GRO changes this patch set is incomplete then.

> Limiting the stuff at the egress is useless in forwarding setups.
> It will be too late as they'll need to linearize -> huge performance
> drop.
>
> This is why we wanted a global setup so that these guys can tweak the
> default limit.
>
> Please read netdev history about this stuff.

Read the history.  I still say it is best if we don't accept a partial
solution.  If we are going to introduce the sysctl as a core item it
should function as a core item and not as something that belongs to
TCP only.

Also I wasn't saying to go the gso_max_size route.  As I commented I
think that probably needs to be fixed as well.  Maybe turned into a
sysctl as is being proposed here since I have found scenarios such as
tunnels where the gso_max_size may not be observed.

> Plan of action :
>
> 1) This patch, adding a core sysctl.
> 2) Use it in TCP (already done in this patch)
> 3) Use it in GRO

What you are talking about is a TCP offloads, one on the transmit side
and one on the receive side.  The name max_skb_frags implies that this
value it is going to cover ALL users of fragments and it doesn't.

If you are going to try and pass this off as a core how about covering
other cases such as __ip_append_data(), skb_append_datato_frags() and
the rest of the functions out there that will totally ignore this
current change and still put together a frame with MAX_SKB_FRAGS
instead of the sysctl value?

In addition it makes sense to have things setup so that you have both
the sysctl and the device value.  Then if someone wants to they can
leave the value set large and just let the one NIC sit there and
linearize frames because NETIF_F_SG gets cleared in netif_skb_features
if the number of frags used exceeds the value for max_frags reported
in the netdev.

- Alex
