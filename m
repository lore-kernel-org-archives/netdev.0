From: Haiyang Zhang <haiyangz@microsoft.com>
Subject: RE: [PATCH net 4/4] hv_netvsc: avoid deadlocks between rtnl lock and
 netvsc_inject_disable()
Date: Thu, 11 Aug 2016 15:38:41 +0000
Message-ID: <DM5PR03MB2538FDC44BA03431F1D8272CCA1E0@DM5PR03MB2538.namprd03.prod.outlook.com>
References: <1470913137-29167-1-git-send-email-vkuznets@redhat.com>
 <1470913137-29167-5-git-send-email-vkuznets@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "devel@linuxdriverproject.org" <devel@linuxdriverproject.org>,
 "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Vitaly Kuznetsov <vkuznets@redhat.com>, "netdev@vger.kernel.org"
 <netdev@vger.kernel.org>
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
In-Reply-To: <1470913137-29167-5-git-send-email-vkuznets@redhat.com>
Content-Language: en-US
List-Unsubscribe: <http://driverdev.linuxdriverproject.org/mailman/options/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=unsubscribe>
List-Archive: <http://driverdev.linuxdriverproject.org/pipermail/driverdev-devel/>
List-Post: <mailto:driverdev-devel@linuxdriverproject.org>
List-Help: <mailto:driverdev-devel-request@linuxdriverproject.org?subject=help>
List-Subscribe: <http://driverdev.linuxdriverproject.org/mailman/listinfo/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=subscribe>
Errors-To: driverdev-devel-bounces@linuxdriverproject.org
Sender: "devel" <driverdev-devel-bounces@linuxdriverproject.org>
List-Id: netdev.vger.kernel.org



> -----Original Message-----
> From: Vitaly Kuznetsov [mailto:vkuznets@redhat.com]
> Sent: Thursday, August 11, 2016 6:59 AM
> To: netdev@vger.kernel.org
> Cc: devel@linuxdriverproject.org; linux-kernel@vger.kernel.org; Haiyang
> Zhang <haiyangz@microsoft.com>; KY Srinivasan <kys@microsoft.com>
> Subject: [PATCH net 4/4] hv_netvsc: avoid deadlocks between rtnl lock and
> netvsc_inject_disable()
> 
> Here is a deadlock scenario:
> - netvsc_vf_up() schedules netvsc_notify_peers() work and quits.
> - netvsc_vf_down() runs before netvsc_notify_peers() gets executed. As it
>   is being executed from netdev notifier chain we hold rtnl lock when we
>   get here.
> - we enter netvsc_inject_disable() and loop and wait till
>   netvsc_notify_peers() drops vf_use_cnt.
> - netvsc_notify_peers() starts on some other CPU but netdev_notify_peers()
>   will hang on rtnl_lock().
> - deadlock!
> 
> Similar deadlocks are possible between netvsc_vf_{up,down}() and
> netvsc_unregister_vf() as it also waits till vf_use_cnt drops to zero.
> Instead of introducing additional synchronization I suggest we drop
> gwrk.dwrk completely and call NETDEV_NOTIFY_PEERS directly. As we're
> acting under rtnl lock this is legitimate.
> 
> Signed-off-by: Vitaly Kuznetsov <vkuznets@redhat.com>

Acked-by: Haiyang Zhang <haiyangz@microsoft.com>
