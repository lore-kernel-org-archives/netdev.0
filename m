From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH net] net: do not process device backlog during unregistration
Date: Sun, 28 Jun 2015 14:06:54 -0500
Message-ID: <876167wt2p.fsf@x220.int.ebiederm.org>
References: <1435420971-19263-1-git-send-email-ja@ssi.bg>
Mime-Version: 1.0
Content-Type: text/plain
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	"Vittorio G \(VittGam\)" <linuxbugs@vittgam.net>
To: Julian Anastasov <ja@ssi.bg>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out03.mta.xmission.com ([166.70.13.233]:57150 "EHLO
	out03.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752508AbbF1TMX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 28 Jun 2015 15:12:23 -0400
In-Reply-To: <1435420971-19263-1-git-send-email-ja@ssi.bg> (Julian Anastasov's
	message of "Sat, 27 Jun 2015 19:02:51 +0300")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Julian Anastasov <ja@ssi.bg> writes:

> commit 381c759d9916 ("ipv4: Avoid crashing in ip_error")
> fixes a problem where processed packet comes from device
> with destroyed inetdev (dev->ip_ptr). This is not expected
> because inetdev_destroy is called in NETDEV_UNREGISTER
> phase and packets should not be processed after
> dev_close_many() and synchronize_net(). But backlog
> processing is deactivated later after NETDEV_UNREGISTER_FINAL
> phase which allows CPUs to initiate processing for new
> packets during and after the NETDEV_UNREGISTER phase.
>
> Fix it by moving flush_backlog after the device driver
> is stopped and before the synchronize_net() call. This
> allows dev->ip_ptr to be always valid during packet
> processing.

Do you have any evidence that there are other places that care
besides the location in ip_error?

If not this patch should be a canidate for net-next which is currently
closed until after the merge window.

The testing is difficult and I was never able to reproduce the actual
crash.  So I do not know how much evidence should come from testing.

That said this patch actually appears wrong.  Nothing in the veth driver
that I can see will cause packets from the other side to not be
transmitted when only one side is closed.

Further even assuming that dev_close_many actually works and causes no
new packets to be processed there is the larger problem of calling
flush_backlog before syncrhonize_net.   Things happening in rcu
criticial sections (aka enqueuing packets to the backlog) are not
expected to stop until after the end of the critical section
and we are not out of the critical section until after synchronize_net.

So while this work looks interesting, I don't think this is a fix for
a serious bug, and I don't think you have yet created a correct patch.

Eric

> Reported-by: Vittorio Gambaletta <linuxbugs@vittgam.net>
> Fixes: 6e583ce5242f ("net: eliminate refcounting in backlog queue")
> Signed-off-by: Julian Anastasov <ja@ssi.bg>
> ---
>  net/core/dev.c | 3 +--
>  1 file changed, 1 insertion(+), 2 deletions(-)
>
> Tested by reverting commit 381c759d9916 and using the
> test commands provided by Eric Biederman:
>
> http://marc.info/?l=linux-netdev&m=143239231905533&w=2
>
> Problem does not occur every time. SMP may be needed
> to reproduce.
>
> diff --git a/net/core/dev.c b/net/core/dev.c
> index aa82f9a..67132b3 100644
> --- a/net/core/dev.c
> +++ b/net/core/dev.c
> @@ -6027,6 +6027,7 @@ static void rollback_registered_many(struct list_head *head)
>  		unlist_netdevice(dev);
>  
>  		dev->reg_state = NETREG_UNREGISTERING;
> +		on_each_cpu(flush_backlog, dev, 1);
>  	}
>  
>  	synchronize_net();
> @@ -6650,8 +6651,6 @@ void netdev_run_todo(void)
>  
>  		dev->reg_state = NETREG_UNREGISTERED;
>  
> -		on_each_cpu(flush_backlog, dev, 1);
> -
>  		netdev_wait_allrefs(dev);
>  
>  		/* paranoia */
