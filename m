From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH] [net] net/mlx5e: fix another -Wmaybe-uninitialized warning
Date: Thu, 12 Jan 2017 17:04:43 +0100
Message-ID: <2981112.7jTLlX72ae@wuerfel>
References: <20170111211451.2705705-1-arnd@arndb.de> <46a85790-2cfe-a8d9-f764-4f736fbd1af7@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: Saeed Mahameed <saeedm@mellanox.com>,
        Hadar Hen Zion <hadarh@mellanox.com>,
        "David S . Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Or Gerlitz <ogerlitz@mellanox.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <46a85790-2cfe-a8d9-f764-4f736fbd1af7@mellanox.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thursday, January 12, 2017 5:21:49 PM CET Or Gerlitz wrote:
> On 1/11/2017 11:14 PM, Arnd Bergmann wrote:
> > As found by Olof's build bot, today's mainline kernel gained a harmless
> > warning about a potential uninitalied variable reference:
> >
> > drivers/net/ethernet/mellanox/mlx5/core/en_tc.c: In function 'parse_tc_fdb_actions':
> > drivers/net/ethernet/mellanox/mlx5/core/en_tc.c:769:13: warning: 'out_dev' may be used uninitialized in this function [-Wmaybe-uninitialized]
> > drivers/net/ethernet/mellanox/mlx5/core/en_tc.c:811:21: note: 'out_dev' was declared here
> >
> > This was introduced through the addition of an 'IS_ERR/PTR_ERR' pair that
> > gcc is unfortunately unable to completely figure out. Replacing it with
> > PTR_ERR_OR_ZERO makes the code more understandable to gcc so it no longer
> > warns.
> 
> can you elaborate on this a little further?


The problem is

static int mlx5e_route_lookup_ipv4(struct net_device **out_dev, ...)
{
       ...
       if (IS_ERR(rt))
              return PTR_ERR(rt);
       *out_dev = ...;
       ...
}

static int mlx5e_create_encap_header_ipv4(...)
{
       ...
       err = mlx5e_route_lookup_ipv4(..., out_dev, ...);
       if (err)
               goto out;

       e->out_dev = *out_dev;
       ...
}

I've seen several examples of this, the problem every time is
that gcc cannot tell that if(IS_ERR()) in the first function is
equivalent to if(err) in the second, so it assumes that 'out_dev'
is used here after the first 'return PTR_ERR(rt)'.

The PTR_ERR_OR_ZERO() case by comparison is fairly easy to detect
by gcc, so it can't get that wrong here.

> > Hadar Hen Zion already attempted to fix the warning earlier by adding
> > fake initializations, but that ended up just making the code worse without
> > fully addressing all warnings, so I'm reverting it now that it is no longer needed.
> 
> ok, so if your approach eliminates the warning on out_dev and also on 
> the variables for which Hadar added the faked initializers, I guess we 
> should be fine with this change (saw your reply on my other comment), 

Ok.

> just another question:
> 
> > In order to avoid pulling a variable declaration into the #ifdef, I'm
> > removing it in favor of a more readable 'if()' statement here that has the same effect.
> 
> When I build here without CONFIG_INET in my system, the build goes fine 
> with this approach. However, we're pretty sure that in the past we got 
> 0-day report from the kbuild test robot where he was unhappy that we 
> make the ip_route_output_key call without being wrapped with that #if 
> IS_ENABLED(CONFIG_INET) -- so, we don't want to go there again... thoughts?

I went back and forth between the two versions, either leaving the #if
in place, or using the if(IS_ENABLED()) check to be really sure that
we can't get compile error here.

I did check that ip_route_output_key() is always declared, but now
I see that net/route.h might not always be included from en_tc.c
if CONFIG_INET is disabled (I don't see how it gets included, but
it obviously is when CONFIG_INET is turned on).

Adding an explicit include of that file should probably avoid the
case you ran into earlier, but for I agree it's safer to not rely
on that here for a bugfix, and just leave the #ifdef. Do you want to
modify it yourself, or should I spin a new version with that?

	Arnd
