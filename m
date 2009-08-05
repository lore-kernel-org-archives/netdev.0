From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH 1/1] veth: don't free priv->status until dev->destructor
 (v2)
Date: Wed, 5 Aug 2009 10:10:05 -0700
Message-ID: <20090805101005.6a02f0ae@nehalam>
References: <20090626162418.GA24828@us.ibm.com>
	<20090724124614.6acc5054@nehalam>
	<m1zlaeu5jk.fsf@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "Serge E. Hallyn" <serue@us.ibm.com>,
	Linux Containers <containers@lists.osdl.org>,
	Sachin Sant <sachinp@in.ibm.com>,
	netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>, matthltc@us.ibm.com,
	lkml <linux-kernel@vger.kernel.org>
To: ebiederm@xmission.com (Eric W. Biederman)
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S934765AbZHERKN@vger.kernel.org>
In-Reply-To: <m1zlaeu5jk.fsf@fess.ebiederm.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 04 Aug 2009 23:40:47 -0700
ebiederm@xmission.com (Eric W. Biederman) wrote:

> Stephen Hemminger <shemminger@vyatta.com> writes:
> 
> > On Fri, 26 Jun 2009 11:24:18 -0500
> > "Serge E. Hallyn" <serue@us.ibm.com> wrote:
> >
> >> Based on the commit msg on ae0e8e82205c903978a79ebf5e31c670b61fa5b4, it looks
> >
> >>  	ether_setup(dev);
> >> @@ -306,7 +320,7 @@ static void veth_setup(struct net_device *dev)
> >>  	dev->netdev_ops = &veth_netdev_ops;
> >>  	dev->ethtool_ops = &veth_ethtool_ops;
> >>  	dev->features |= NETIF_F_LLTX;
> >> -	dev->destructor = free_netdev;
> >> +	dev->destructor = veth_dev_free;
> >>
> >
> > This is still going to oops if sysfs statistics referenced
> > after module unload because module is unloaded (code is gone)
> > and veth_dev_free no longer exists.
> 
> Has anyone actually seen that cause an oops?
> 
> The reason I am asking is that as I read the code we cannot have
> this problem.  At worst the destructor callback is delayed until:
> 
> veth_exit
>   rtnl_link_unregister
>     rtnl_unlock
>       netdev_run_todo
>         dev->destructor
> 
> 
> Similarly even if the sysfs filehandle is open we have called:
> 
> netdev_unregister_kobject
>   ...
>     sysfs_addrm_finish
>       sysfs_deactivate
> 
> Which guarantees that sysfs_get_active_two will fail and all
> subsequent actions on that file will fail.
> 
> Eric

Sysfs must be safer than it used to be. 
