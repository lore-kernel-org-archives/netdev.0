From: Alexey Dobriyan <adobriyan@sw.ru>
Subject: Re: [PATCH 03/15] [SUNRPC]: Use proc_create() to setup ->proc_fops first
Date: Fri, 29 Feb 2008 12:32:32 +0300
Message-ID: <20080229093232.GK7469@localhost.sw.ru>
References: <47C6932C.90907@cn.fujitsu.com> <20080228.140222.07061140.davem@davemloft.net> <47C79793.8060108@cn.fujitsu.com> <47C7C3C5.3000905@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Wang Chen <wangchen@cn.fujitsu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:42873 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751172AbYB2Jc4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 29 Feb 2008 04:32:56 -0500
Content-Disposition: inline
In-Reply-To: <47C7C3C5.3000905@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Feb 29, 2008 at 04:35:17PM +0800, Wang Chen wrote:
> Wang Chen said the following on 2008-2-29 13:26:
> > David Miller said the following on 2008-2-29 6:02:
> >> From: Wang Chen <wangchen@cn.fujitsu.com>
> >> Date: Thu, 28 Feb 2008 18:55:40 +0800
> >>
> >>> Use proc_create() to make sure that ->proc_fops be setup before gluing
> >>> PDE to main tree.
> >>>
> >>> Signed-off-by: Wang Chen <wangchen@cn.fujitsu.com>
> >> Applied.
> >>
> >>> @@ -229,9 +229,8 @@ do_register(const char *name, void *data, const struct file_operations *fops)
> >>>  	rpc_proc_init();
> >>>  	dprintk("RPC:       registering /proc/net/rpc/%s\n", name);
> >>>  
> >>> -	ent = create_proc_entry(name, 0, proc_net_rpc);
> >>> +	ent = proc_create(name, 0, proc_net_rpc, fops);
> >>>  	if (ent) {
> >>> -		ent->proc_fops = fops;
> >>>  		ent->data = data;
> >>>  	}
> >>>  	return ent;
> >> For this case it appears that ent->data has the same kind of
> >> visibility problem that ent->proc_fops does.
> >>
> > 
> > Thanks Dave, I will check whether ->data also has the visibility problem.
> > 
> 
> I have looked at the proc_create().
> The reason for why we need to setup pde->proc_fops in proc_create() before
> the pde be visible, is that proc_fops will be setuped in proc_register() and
> and NULL of proc_fops will make proc_register() give pde an improper fops.
> 
> But, ->data and ->owner will not be affected by this instance.
> So, it's safe to setup ->data and ->owner after visibility of pde.

->owner is buggy, believed to be unnecessary and will thus die so don't
bother with it. ;-)

->data looks safe to setup separately while module is loading:
before ->data will be used by code which is unprepared to it being NULL,
VFS will pin module, which can't be done during module load.

I think the existence of proc_create_data() depends entirely on
cases which do all the above from code that is not module_init hook.
Does anyone know some?

