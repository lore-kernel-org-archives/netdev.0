From: Paul Moore <paul.moore@hp.com>
Subject: Re: [PATCH 1/3] Networking: use CAP_NET_ADMIN when deciding to call request_module
Date: Thu, 13 Aug 2009 14:45:37 -0400
Message-ID: <200908131445.37263.paul.moore@hp.com>
References: <20090813134451.29186.41664.stgit@paris.rdu.redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, selinux@tycho.nsa.gov,
	netdev@vger.kernel.org, linux-security-module@vger.kernel.org,
	sds@tycho.nsa.gov, davem@davemloft.net,
	shemminger@linux-foundation.org, kees@ubuntu.com,
	morgan@kernel.org, casey@schaufler-ca.com, dwalsh@redhat.com
To: Eric Paris <eparis@redhat.com>
Return-path: <linux-security-module-owner@vger.kernel.org>
In-Reply-To: <20090813134451.29186.41664.stgit@paris.rdu.redhat.com>
Content-Disposition: inline
Sender: linux-security-module-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thursday 13 August 2009 09:44:51 am Eric Paris wrote:
> The networking code checks CAP_SYS_MODULE before using request_module() to
> try to load a kernel module.  While this seems reasonable it's actually
> weakening system security since we have to allow CAP_SYS_MODULE for things
> like /sbin/ip and bluetoothd which need to be able to trigger module loads.
> CAP_SYS_MODULE actually grants those binaries the ability to directly load
> any code into the kernel.  We should instead be protecting modprobe and the
> modules on disk, rather than granting random programs the ability to load
> code directly into the kernel.  Instead we are going to gate those
> networking checks on CAP_NET_ADMIN which still limits them to root but
> which does not grant those processes the ability to load arbitrary code
> into the kernel.
>
> Signed-off-by: Eric Paris <eparis@redhat.com>

Sounds and looks reasonable to me.

Acked-by: Paul Moore <paul.moore@hp.com>

> ---
>
>  drivers/staging/comedi/comedi_fops.c |    8 ++++----
>  net/core/dev.c                       |    2 +-
>  net/ipv4/tcp_cong.c                  |    4 ++--
>  3 files changed, 7 insertions(+), 7 deletions(-)
>
> diff --git a/drivers/staging/comedi/comedi_fops.c
> b/drivers/staging/comedi/comedi_fops.c index 42e4bc4..f54bb9b 100644
> --- a/drivers/staging/comedi/comedi_fops.c
> +++ b/drivers/staging/comedi/comedi_fops.c
> @@ -1772,12 +1772,12 @@ static int comedi_open(struct inode *inode, struct
> file *file) mutex_lock(&dev->mutex);
>  	if (dev->attached)
>  		goto ok;
> -	if (!capable(CAP_SYS_MODULE) && dev->in_request_module) {
> +	if (!capable(CAP_NET_ADMIN) && dev->in_request_module) {
>  		DPRINTK("in request module\n");
>  		mutex_unlock(&dev->mutex);
>  		return -ENODEV;
>  	}
> -	if (capable(CAP_SYS_MODULE) && dev->in_request_module)
> +	if (capable(CAP_NET_ADMIN) && dev->in_request_module)
>  		goto ok;
>
>  	dev->in_request_module = 1;
> @@ -1790,8 +1790,8 @@ static int comedi_open(struct inode *inode, struct
> file *file)
>
>  	dev->in_request_module = 0;
>
> -	if (!dev->attached && !capable(CAP_SYS_MODULE)) {
> -		DPRINTK("not attached and not CAP_SYS_MODULE\n");
> +	if (!dev->attached && !capable(CAP_NET_ADMIN)) {
> +		DPRINTK("not attached and not CAP_NET_ADMIN\n");
>  		mutex_unlock(&dev->mutex);
>  		return -ENODEV;
>  	}
> diff --git a/net/core/dev.c b/net/core/dev.c
> index 09fb03f..2604db9 100644
> --- a/net/core/dev.c
> +++ b/net/core/dev.c
> @@ -1031,7 +1031,7 @@ void dev_load(struct net *net, const char *name)
>  	dev = __dev_get_by_name(net, name);
>  	read_unlock(&dev_base_lock);
>
> -	if (!dev && capable(CAP_SYS_MODULE))
> +	if (!dev && capable(CAP_NET_ADMIN))
>  		request_module("%s", name);
>  }
>
> diff --git a/net/ipv4/tcp_cong.c b/net/ipv4/tcp_cong.c
> index e92beb9..6428b34 100644
> --- a/net/ipv4/tcp_cong.c
> +++ b/net/ipv4/tcp_cong.c
> @@ -116,7 +116,7 @@ int tcp_set_default_congestion_control(const char
> *name) spin_lock(&tcp_cong_list_lock);
>  	ca = tcp_ca_find(name);
>  #ifdef CONFIG_MODULES
> -	if (!ca && capable(CAP_SYS_MODULE)) {
> +	if (!ca && capable(CAP_NET_ADMIN)) {
>  		spin_unlock(&tcp_cong_list_lock);
>
>  		request_module("tcp_%s", name);
> @@ -246,7 +246,7 @@ int tcp_set_congestion_control(struct sock *sk, const
> char *name)
>
>  #ifdef CONFIG_MODULES
>  	/* not found attempt to autoload module */
> -	if (!ca && capable(CAP_SYS_MODULE)) {
> +	if (!ca && capable(CAP_NET_ADMIN)) {
>  		rcu_read_unlock();
>  		request_module("tcp_%s", name);
>  		rcu_read_lock();
>
> --
> To unsubscribe from this list: send the line "unsubscribe
> linux-security-module" in the body of a message to
> majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

-- 
paul moore
linux @ hp

