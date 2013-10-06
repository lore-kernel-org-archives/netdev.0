From: Oussama Ghorbel <ou.ghorbel@gmail.com>
Subject: Re: [PATCH] Fix the upper MTU limit in ipv6 GRE tunnel
Date: Sun, 6 Oct 2013 15:42:15 +0100
Message-ID: <CABfLueFYZkzpEpDJ7YcHJaXfm-=QcgnL3-Es8gybea2cAacQQw@mail.gmail.com>
References: <1380880333-3546-1-git-send-email-ou.ghorbel@gmail.com>
	<20131005140636.GA25076@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: Oussama Ghorbel <ou.ghorbel@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20131005140636.GA25076@order.stressinduktion.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Oct 5, 2013 at 3:06 PM, Hannes Frederic Sowa
<hannes@stressinduktion.org> wrote:
> On Fri, Oct 04, 2013 at 10:52:13AM +0100, Oussama Ghorbel wrote:
>> Unlike ipv4, the struct member hlen holds the length of the GRE and ipv6
>> headers. This length is also counted in dev->hard_header_len.
>> Perhaps, it's more clean to modify the hlen to count only the GRE header
>> without ipv6 header as the variable name suggest, but the simple way to fix
>> this without regression risk is simply modify the calculation of the limit
>> in ip6gre_tunnel_change_mtu function.
>> Verified in kernel version v3.11.
>>
>> Signed-off-by: Oussama Ghorbel <ou.ghorbel@gmail.com>
>> ---
>>  net/ipv6/ip6_gre.c |    3 +--
>>  1 file changed, 1 insertion(+), 2 deletions(-)
>>
>> diff --git a/net/ipv6/ip6_gre.c b/net/ipv6/ip6_gre.c
>> index 90747f1..41487ab 100644
>> --- a/net/ipv6/ip6_gre.c
>> +++ b/net/ipv6/ip6_gre.c
>> @@ -1175,9 +1175,8 @@ done:
>>
>>  static int ip6gre_tunnel_change_mtu(struct net_device *dev, int new_mtu)
>>  {
>> -     struct ip6_tnl *tunnel = netdev_priv(dev);
>>       if (new_mtu < 68 ||
>> -         new_mtu > 0xFFF8 - dev->hard_header_len - tunnel->hlen)
>> +         new_mtu > 0xFFF8 - dev->hard_header_len)
>>               return -EINVAL;
>>       dev->mtu = new_mtu;
>>       return 0;
>
> Hmmm...
>
> dev->hard_header_len is initialized to LL_MAX_HEADER + sizeof(struct ipv6hdr)
> + 4 but won't include the additional head space needed for GRE_SEQ, GRE_KEY
> etc. if at time of tunnel creation the routing table did not had a good guess
> for the outgoing device.
>
This hard_header_len initialization that you have shown above is taken
from ip6gre_tunnel_setup, however this same variable seems to be
reinitialized in ip6gre_tnl_link_config() which are called from
ip6gre_newlink()
The initialization  in ip6gre_tnl_link_config is done as the following:
static void ip6gre_tnl_link_config(struct ip6_tnl *t, int set_mtu)
{
...
int addend = sizeof(struct ipv6hdr) + 4;
...
/* Precalculate GRE options length */
if (t->parms.o_flags&(GRE_CSUM|GRE_KEY|GRE_SEQ)) {
if (t->parms.o_flags&GRE_CSUM)
addend += 4;
if (t->parms.o_flags&GRE_KEY)
addend += 4;
if (t->parms.o_flags&GRE_SEQ)
addend += 4;
}
...
dev->hard_header_len = rt->dst.dev->hard_header_len + addend;
...
t->hlen = addend;
..
}

Unless they are other reasons, the hard_header_len is taken into
account the GRE_KEY, GRE_SEQ ..

> To make this correct we would have to refactor the usage of the variables a
> bit as is done in ipv4/ip_tunnel.c. The safest thing would be to leave this
> check as-is currently although we exclude some allowed mtus.
>
> Perhaps you want to take a look how to achieve that? ;)
>
Why not, consistency is good ...

> Greetings,
>
>   Hannes
>

Thanks,
Oussama
