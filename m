From: Alexei Starovoitov <alexei.starovoitov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [for-next 4/6] net/mlx5: FPGA, Add basic support for Innova
Date: Thu, 25 May 2017 20:07:08 -0700
Message-ID: <20170526030701.du4345mbprhcwjyi@ast-mbp>
References: <20170523114404.20387-1-saeedm@mellanox.com>
 <20170523114404.20387-5-saeedm@mellanox.com>
 <20170524165059.42lmrwzzcxvi2sf7@ast-mbp>
 <AM4PR0501MB1940885C2F1CEF4DDE4EA8D1DBFF0@AM4PR0501MB1940.eurprd05.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Saeed Mahameed <saeedm-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
        "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
        Doug Ledford <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
        "netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        "linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        "jsorensen-b10kYP2dOMg@public.gmane.org" <jsorensen-b10kYP2dOMg@public.gmane.org>
To: Ilan Tayari <ilant-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <AM4PR0501MB1940885C2F1CEF4DDE4EA8D1DBFF0-dp/nxUn679gfNUYDR5dMTsDSnupUy6xnnBOFsp37pqbUKgpGm//BTAC/G2K4zDHf@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Thu, May 25, 2017 at 05:20:04AM +0000, Ilan Tayari wrote:
> 
> If you do want this, then splitting some of the logic to a
> separate kernel object will not gain anything useful (logic would stay
> the same), and just pollute the exported symbol table and open up the door
> for issues of inter-module compatibility and so on.

in other words instead of properly designing inter-module api
you just want to add everything into one giant 'driver'
because it's easier to do so. Understandable, but it leads
to unmaintainable device infrastructure long term.

> Furthermore, the next patchset will introduce IPSec offload capabilities
> Which are declared in netdev->hw_features. Those cannot be modified
> after the netdevice is created, so all the extra logic has to be 
> integrated into the mlx5 ethernet driver. This is another reason why
> a separate driver is a bad idea.

that increases my concerns even more.
ipsec offload is a new feature for new hw, yet you're trying to
hide it in the mlx5 'driver'.

mlx5 already supports cx4/cx4-lx/cx5 and not even released cx6.
All of them have different feature sets.
The only common piece is driver/fw cmd interface and _some_ aspects
of rx/tx descriptors. Everything else is different.
cx4-lx doesn't have infiniband and rdma, yet there is a ton of code
in the driver that deals with it.
cx5 has fancy storage interfaces for nvme, etc I don't think they
are part of the mlx5 'driver' yet. Are you going to dump them
in there as well?
Take a look at the simplest feature-wise cx4-lx. It has
eswitch which is full l2 switch with mac table, drop policy,
counters and such. Yet kernel knows nothing about it.
Everything is hidden in mlx5 'driver' with its own special
interfaces to manage it.
Now you want to hide fpga with custom logic behind mlx5 'driver'
and manage it through mlx5 interfaces?
That's not acceptable.
mlx fpga got to have generic kernel representation that intel
and other fpga vendors can use.

mlx5 driver has to be modularized and since it's not too late
cx6 support has to be removed from it.
Thankfully only few cx6 pci ids were added to mlx5, but driver
knows nothing about cx6 features, so we can properly design it.

Since driver/fw interface is common between cx4+ this part
can be moved into mlx_core.ko or done as library
the way chelsio did it in libcxgb.

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
