From: Eric Dumazet <edumazet@google.com>
Subject: Re: [PATCH] net: rtnl: avoid uninitialized data in IFLA_VF_VLAN_LIST handling
Date: Fri, 30 Sep 2016 09:23:55 -0700
Message-ID: <CANn89iK2FQufz4NCan1y0dQME2RUOzc3NXXhqYd418ctHNc6fA@mail.gmail.com>
References: <20160930161416.18660-1-arnd@arndb.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S. Miller" <davem@davemloft.net>,
        Roopa Prabhu <roopa@cumulusnetworks.com>,
        Nicolas Dichtel <nicolas.dichtel@6wind.com>,
        Nikolay Aleksandrov <nikolay@cumulusnetworks.com>,
        Jiri Pirko <jiri@mellanox.com>,
        Brenden Blanco <bblanco@plumgrid.com>,
        Hannes Frederic Sowa <hannes@stressinduktion.org>,
        Nogah Frankel <nogahf@mellanox.com>,
        netdev <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160930161416.18660-1-arnd@arndb.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Sep 30, 2016 at 9:13 AM, Arnd Bergmann <arnd@arndb.de> wrote:
> With the newly added support for IFLA_VF_VLAN_LIST netlink messages,
> we get a warning about potential uninitialized variable use in
> the parsing of the user input when enabling the -Wmaybe-uninitialized
> warning:
>
> net/core/rtnetlink.c: In function 'do_setvfinfo':
> net/core/rtnetlink.c:1756:9: error: 'ivvl$' may be used uninitialized in this function [-Werror=maybe-uninitialized]
>
> I have not been able to prove whether it is possible to arrive in
> this code with an empty IFLA_VF_VLAN_LIST block, but if we do,
> then ndo_set_vf_vlan gets called with uninitialized arguments.
>
> This adds an explicit check for an empty list, making it obvious
> to the reader and the compiler that this cannot happen.
>
> Fixes: 79aab093a0b5 ("net: Update API for VF vlan protocol 802.1ad support")
> Signed-off-by: Arnd Bergmann <arnd@arndb.de>
> ---
>  net/core/rtnetlink.c | 3 +++
>  1 file changed, 3 insertions(+)
>
> diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
> index 3ac8946bf244..b06d2f46b83e 100644
> --- a/net/core/rtnetlink.c
> +++ b/net/core/rtnetlink.c
> @@ -1753,6 +1753,9 @@ static int do_setvfinfo(struct net_device *dev, struct nlattr **tb)
>
>                         len++;
>                 }
> +               if (len == 0)
> +                       return -EINVAL;
> +
>                 err = ops->ndo_set_vf_vlan(dev, ivvl[0]->vf, ivvl[0]->vlan,
>                                            ivvl[0]->qos, ivvl[0]->vlan_proto);
>                 if (err < 0)
> --
> 2.9.0
>

So, if I read this code, we build an array, but call ndo_set_vf_vlan()
only using first element ?

Looks like the bug should be fixed in a different way.
