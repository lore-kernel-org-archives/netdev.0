From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Subject: Re: [PATCH net] bridge: shutdown bridge device before
	removing it
Date: Mon, 24 Apr 2017 14:01:10 +0300
Message-ID: <3d77b47d-c8c3-de57-946e-59096a88964e@cumulusnetworks.com>
References: <a8b2b2c876f416431dac031a0beb7ce079c7d0a9.1493018730.git.lucien.xin@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: "bridge@lists.linux-foundation.org" <bridge@lists.linux-foundation.org>,
	"David S. Miller" <davem@davemloft.net>
To: Xin Long <lucien.xin@gmail.com>, network dev <netdev@vger.kernel.org>
Return-path: <bridge-bounces@lists.linux-foundation.org>
In-Reply-To: <a8b2b2c876f416431dac031a0beb7ce079c7d0a9.1493018730.git.lucien.xin@gmail.com>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/bridge/>
List-Post: <mailto:bridge@lists.linux-foundation.org>
List-Help: <mailto:bridge-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=subscribe>
Sender: bridge-bounces@lists.linux-foundation.org
Errors-To: bridge-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

On 24/04/17 10:25, Xin Long wrote:
> During removing a bridge device, if the bridge is still up, a new mdb entry
> still can be added in br_multicast_add_group() after all mdb entries are
> removed in br_multicast_dev_del(). Like the path:
> 
>   mld_ifc_timer_expire ->
>     mld_sendpack -> ...
>       br_multicast_rcv ->
>         br_multicast_add_group
> 
> The new mp's timer will be set up. If the timer expires after the bridge
> is freed, it may cause use-after-free panic in br_multicast_group_expired.
> This can happen when ip link remove a bridge or destroy a netns with a
> bridge device inside.
> 
> As we can see in br_del_bridge, brctl is also supposed to remove a bridge
> device after it's shutdown.
> 
> This patch is to call dev_close at the beginning of br_dev_delete so that
> netif_running check in br_multicast_add_group can avoid this issue. But
> to keep consistent with before, it will not remove the IFF_UP check in
> br_del_bridge for brctl.
> 
> Reported-by: Jianwen Ji <jiji@redhat.com>
> Signed-off-by: Xin Long <lucien.xin@gmail.com>
> ---
>  net/bridge/br_if.c | 2 ++
>  1 file changed, 2 insertions(+)
> 

+CC bridge maintainers

I can see how this could happen, could you also provide the traceback ?

The patch looks good to me, actually I think it fixes another issue with
mcast stats where the percpu pointer can be accessed after it's freed if
an mcast packet can get sent via br->dev after the br_multicast_dev_del() call.
This is definitely stable material, if I'm not mistaken the issue is there since
the introduction of br_dev_delete:
commit e10177abf842
Author: Satish Ashok <sashok@cumulusnetworks.com>
Date:   Wed Jul 15 07:16:51 2015 -0700

    bridge: multicast: fix handling of temp and perm entries



Acked-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
