From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] ppp: fix race in ppp device destruction
Date: Fri, 06 Oct 2017 10:17:08 -0700 (PDT)
Message-ID: <20171006.101708.2248081297399135224.davem@davemloft.net>
References: <f197b94ec7e16902a9601fdf840d5a8e94c8e91a.1507302309.git.g.nault@alphalink.fr>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, bgalvani@redhat.com,
        linux-ppp@vger.kernel.org, paulus@samba.org, dsahern@gmail.com,
        gfree.wind@vip.163.com
To: g.nault@alphalink.fr
Return-path: <linux-ppp-owner@vger.kernel.org>
In-Reply-To: <f197b94ec7e16902a9601fdf840d5a8e94c8e91a.1507302309.git.g.nault@alphalink.fr>
Sender: linux-ppp-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Guillaume Nault <g.nault@alphalink.fr>
Date: Fri, 6 Oct 2017 17:05:49 +0200

> ppp_release() tries to ensure that netdevices are unregistered before
> decrementing the unit refcount and running ppp_destroy_interface().
> 
> This is all fine as long as the the device is unregistered by
> ppp_release(): the unregister_netdevice() call, followed by
> rtnl_unlock(), guarantee that the unregistration process completes
> before rtnl_unlock() returns.
> 
> However, the device may be unregistered by other means (like
> ppp_nl_dellink()). If this happens right before ppp_release() calling
> rtnl_lock(), then ppp_release() has to wait for the concurrent
> unregistration code to release the lock.
> But rtnl_unlock() releases the lock before completing the device
> unregistration process. This allows ppp_release() to proceed and
> eventually call ppp_destroy_interface() before the unregistration
> process completes. Calling free_netdev() on this partially unregistered
> device will BUG():
 ...
> We could set the ->needs_free_netdev flag on PPP devices and move the
> ppp_destroy_interface() logic in the ->priv_destructor() callback. But
> that'd be quite intrusive as we'd first need to unlink from the other
> channels and units that depend on the device (the ones that used the
> PPPIOCCONNECT and PPPIOCATTACH ioctls).
> 
> Instead, we can just let the netdevice hold a reference on its
> ppp_file. This reference is dropped in ->priv_destructor(), at the very
> end of the unregistration process, so that neither ppp_release() nor
> ppp_disconnect_channel() can call ppp_destroy_interface() in the interim.
> 
> Reported-by: Beniamino Galvani <bgalvani@redhat.com>
> Fixes: 8cb775bc0a34 ("ppp: fix device unregistration upon netns deletion")
> Signed-off-by: Guillaume Nault <g.nault@alphalink.fr>

Applied and queued up for -stable, thanks.
