From: Steven Rostedt <rostedt@goodmis.org>
Subject: Re: [PATCH linux-3.10.y v2 1/3] sit: fix double free of
 fb_tunnel_dev on exit
Date: Fri, 31 Jan 2014 12:19:29 -0500
Message-ID: <20140131121929.51a58c72@gandalf.local.home>
References: <20140130171029.01cd80ca@gandalf.local.home>
	<1391156646-11981-1-git-send-email-nicolas.dichtel@6wind.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	stable@vger.kernel.org, williams@redhat.com, lclaudio@uudg.org,
	jkacur@redhat.com, willemb@google.com
To: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Return-path: <stable-owner@vger.kernel.org>
In-Reply-To: <1391156646-11981-1-git-send-email-nicolas.dichtel@6wind.com>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Just FYI.

Our full tier tests have completed with no issues due to the sit or
ip6_tunnel modules. These patches appear to have solved our problems.

Nicolas, Thanks again for posting these!

-- Steve


On Fri, 31 Jan 2014 09:24:04 +0100
Nicolas Dichtel <nicolas.dichtel@6wind.com> wrote:

> This problem was fixed upstream by commit 9434266f2c64 ("sit: fix use after free
> of fb_tunnel_dev").
> The upstream patch depends on upstream commit 5e6700b3bf98 ("sit: add support of
> x-netns"), which was not backported into 3.10 branch.
> 
> First, explain the problem: when the sit module is unloaded, sit_cleanup() is
> called.
> rmmod sit
> => sit_cleanup()
>   => rtnl_link_unregister()
>     => __rtnl_kill_links()
>       => for_each_netdev(net, dev) {
>         if (dev->rtnl_link_ops == ops)
>         	ops->dellink(dev, &list_kill);
>         }
> At this point, the FB device is deleted (and all sit tunnels).
>   => unregister_pernet_device()
>     => unregister_pernet_operations()
>       => ops_exit_list()
>         => sit_exit_net()
>           => sit_destroy_tunnels()
>           In this function, no tunnel is found.
>           => unregister_netdevice_queue(sitn->fb_tunnel_dev, &list);
> We delete the FB device a second time here!
> 
> Because we cannot simply remove the second deletion (sit_exit_net() must remove
> the FB device when a netns is deleted), we add an rtnl ops which delete all sit
> device excepting the FB device and thus we can keep the explicit deletion in
> sit_exit_net().
> 
