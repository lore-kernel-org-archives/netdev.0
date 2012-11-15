From: Pasi =?iso-8859-1?Q?K=E4rkk=E4inen?= <pasik@iki.fi>
Subject: Re: [PATCH 0/4] Implement persistent grant in
 xen-netfront/netback
Date: Thu, 15 Nov 2012 09:40:58 +0200
Message-ID: <20121115074057.GO8912@reaktio.net>
References: <1352962987-541-1-git-send-email-annie.li@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, xen-devel@lists.xensource.com,
	Ian.Campbell@citrix.com, konrad.wilk@oracle.com
To: Annie Li <annie.li@oracle.com>
Return-path: <xen-devel-bounces@lists.xen.org>
Content-Disposition: inline
In-Reply-To: <1352962987-541-1-git-send-email-annie.li@oracle.com>
List-Unsubscribe: <http://lists.xen.org/cgi-bin/mailman/options/xen-devel>,
	<mailto:xen-devel-request@lists.xen.org?subject=unsubscribe>
List-Post: <mailto:xen-devel@lists.xen.org>
List-Help: <mailto:xen-devel-request@lists.xen.org?subject=help>
List-Subscribe: <http://lists.xen.org/cgi-bin/mailman/listinfo/xen-devel>,
	<mailto:xen-devel-request@lists.xen.org?subject=subscribe>
Sender: xen-devel-bounces@lists.xen.org
Errors-To: xen-devel-bounces@lists.xen.org
List-Id: netdev.vger.kernel.org

Hello,

On Thu, Nov 15, 2012 at 03:03:07PM +0800, Annie Li wrote:
> This patch implements persistent grants for xen-netfront/netback. This
> mechanism maintains page pools in netback/netfront, these page pools is used to
> save grant pages which are mapped. This way improve performance which is wasted
> when doing grant operations.
> 
> Current netback/netfront does map/unmap grant operations frequently when
> transmitting/receiving packets, and grant operations costs much cpu clock. In
> this patch, netfront/netback maps grant pages when needed and then saves them
> into a page pool for future use. All these pages will be unmapped when
> removing/releasing the net device.
> 

Do you have performance numbers available already? with/without persistent grants? 


> In netfront, two pools are maintained for transmitting and receiving packets.
> When new grant pages are needed, the driver gets grant pages from this pool
> first. If no free grant page exists, it allocates new page, maps it and then
> saves it into the pool. The pool size for transmit/receive is exactly tx/rx
> ring size. The driver uses memcpy(not grantcopy) to copy data grant pages.
> Here, memcpy is copying the whole page size data. I tried to copy len size data
> from offset, but network does not seem work well. I am trying to find the root
> cause now.
> 
> In netback, it also maintains two page pools for tx/rx. When netback gets a
> request, it does a search first to find out whether the grant reference of
> this request is already mapped into its page pool. If the grant ref is mapped,
> the address of this mapped page is gotten and memcpy is used to copy data
> between grant pages. However, if the grant ref is not mapped, a new page is
> allocated, mapped with this grant ref, and then saved into page pool for
> future use. Similarly, memcpy replaces grant copy to copy data between grant
> pages. In this implementation, two arrays(gnttab_tx_vif,gnttab_rx_vif) are
> used to save vif pointer for every request because current netback is not
> per-vif based. This would be changed after implementing 1:1 model in netback.
> 

Btw is xen-netback/xen-netfront multiqueue support something you're planning to implement aswell? 
multiqueue allows single vif scaling to multiple vcpus/cores.


Thanks,

-- Pasi


> This patch supports both persistent-grant and non persistent grant. A new
> xenstore key "feature-persistent-grants" is used to represent this feature.
> 
> This patch is based on linux3.4-rc3. I hit netperf/netserver failure on
> linux latest version v3.7-rc1, v3.7-rc2 and v3.7-rc4. Not sure whether this
> netperf/netserver failure connects compound page commit in v3.7-rc1, but I did
> hit BUG_ON with debug patch from thread
> http://lists.xen.org/archives/html/xen-devel/2012-10/msg00893.html
> 
> 
> Annie Li (4):
>   xen/netback: implements persistent grant with one page pool.
>   xen/netback: Split one page pool into two(tx/rx) page pool.
>   Xen/netfront: Implement persistent grant in netfront.
>   fix code indent issue in xen-netfront.
> 
>  drivers/net/xen-netback/common.h    |   24 ++-
>  drivers/net/xen-netback/interface.c |   26 +++
>  drivers/net/xen-netback/netback.c   |  215 ++++++++++++++++++--
>  drivers/net/xen-netback/xenbus.c    |   14 ++-
>  drivers/net/xen-netfront.c          |  378 +++++++++++++++++++++++++++++------
>  5 files changed, 570 insertions(+), 87 deletions(-)
> 
> -- 
> 1.7.3.4
> 
> 
> _______________________________________________
> Xen-devel mailing list
> Xen-devel@lists.xen.org
> http://lists.xen.org/xen-devel
