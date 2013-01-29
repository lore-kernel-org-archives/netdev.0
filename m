From: Wanlong Gao <gaowanlong@cn.fujitsu.com>
Subject: Re: [PATCH V7 0/3] handle polling errors in vhost/vhost_net
Date: Tue, 29 Jan 2013 15:03:41 +0800
Message-ID: <5107744D.2090008@cn.fujitsu.com>
References: <1359371119-10208-1-git-send-email-jasowang@redhat.com>
Reply-To: gaowanlong@cn.fujitsu.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, mst@redhat.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Jason Wang <jasowang@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1359371119-10208-1-git-send-email-jasowang@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 01/28/2013 07:05 PM, Jason Wang wrote:
> This is an update version of last version to fix the handling of polling errors
> in vhost/vhost_net.
> 
> Currently, vhost and vhost_net ignore polling errors which can lead kernel
> crashing when it tries to remove itself from waitqueue after the polling
> failure. Fix this by:
> 
> - examing the POLLERR when setting backend and report erros to userspace
> - let tun always add to waitqueue in .poll() after the queue is created even if
>   it was detached.

Fixed my kernel oops here, thank you.


Tested-by: Wanlong Gao <gaowanlong@cn.fujitsu.com>


> 
> Changes from V6:
> - don't use RCU to protect the tfile->detached.
> 
> Changes from V5:
> - use rcu_dereference() instead of the wrong rtnl_dereference() in data path
> - test with CONFIG_PROVE_RCU
> 
> Changes from V4:
> - check the detached state by tfile->detached and protect it by RCU
> 
> Changes from V3:
> - make a smaller patch that doesn't touch the whole polling state and only check
> the polliner errors in backend setting.
> - add a patch that allows tuntap to do polling/reading/writing when detached
> which could simplify the work of its user.
> 
> Changes from v2:
> - check poll->wqh instead of the wrong assumption about POLLERR and waitqueue
> - drop the whole tx polling state check since it was replaced by the wqh
> checking
> - drop the buggy tuntap patch
> 
> Changes from v1:
> - restore the state before the ioctl when vhost_init_used() fails
> - log the error when meet polling errors in the data path
> - don't put into waitqueue when tun_chr_poll() return POLLERR
> 
> Jason Wang (3):
>   vhost_net: correct error handling in vhost_net_set_backend()
>   vhost_net: handle polling errors when setting backend
>   tuntap: allow polling/writing/reading when detached
> 
>  drivers/net/tun.c     |   25 ++++++++++++++++---------
>  drivers/vhost/net.c   |   41 ++++++++++++++++++++++++++++-------------
>  drivers/vhost/vhost.c |   18 +++++++++++++++---
>  drivers/vhost/vhost.h |    2 +-
>  4 files changed, 60 insertions(+), 26 deletions(-)
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/
> 
