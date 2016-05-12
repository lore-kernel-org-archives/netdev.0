From: Vitaly Kuznetsov <vkuznets@redhat.com>
Subject: Re: Aw: [PATCH 0/6] hv_netvsc: avoid races on mtu change/set channels
Date: Thu, 12 May 2016 17:09:24 +0200
Message-ID: <87r3d7mhy3.fsf@vitty.brq.redhat.com>
References: <1463057378-21118-1-git-send-email-vkuznets@redhat.com>
 <trinity-ccc16f5c-6580-4594-a0d0-c7b07bf2f7a6-1463065112147@3capp-gmx-bs05>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Haiyang Zhang <haiyangz@microsoft.com>,
 linux-kernel@vger.kernel.org, devel@linuxdriverproject.org
To: "Lino Sanfilippo" <LinoSanfilippo@gmx.de>
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
In-Reply-To: <trinity-ccc16f5c-6580-4594-a0d0-c7b07bf2f7a6-1463065112147@3capp-gmx-bs05>
 (Lino Sanfilippo's message of "Thu, 12 May 2016 16:58:32 +0200")
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

"Lino Sanfilippo" <LinoSanfilippo@gmx.de> writes:

> Hi,
>
>>
>> MTU change and set channels operations are implemented as netvsc device
>> re-creation destroying internal structures (struct net_device stays). This
>> is really unfortunate but there is no support from Hyper-V host to do it
>> in a different way. Such re-creation is unsurprisingly racy, Haiyang
>> reported a crash when netvsc_change_mtu() is racing with
>> netvsc_link_change() but I was able to identify additional races upon
>> investigation. Both netvsc_set_channels() and netvsc_change_mtu() race
>> against:
>> 1) netvsc_link_change()
>> 2) netvsc_remove()
>> 3) netvsc_send()
>> 
>
> after having a look into this driver I got the impression that you are working around an
> unfortunate implementation of the shutdown sequence in the remove function:
> If you do unregister_netdev() first instead of resource cleanup then neither set_channels()
> nor change_mtu() can race with remove(). This is since after unregister_netdev() returns
> the netdev is not longer available from userspace and thus neither set_channels nor
> change_mtu can be called anymore (note that all of these functions are protected by the 
> rtnl_lock).

It's worse: before the patch series we get 'struct hv_device' (as it is
called from core VMBus code and we simply cannot get to 'struct
net_device' we need without traveling through 'struct
netvsc_device'. This structure is removed and re-created by both
netvsc_set_channels() and netvsc_change_mtu().

>
> To avoid the race between netvsc_change_mtu()/netvsc_set_channels() and netvsc_link_change()
> you have to stop the concerning worker thread (dwork) before you call netvsc_close() and
> restart it once the device is up again.

Yes, but we also need to guarantee this won't get rescheduled so we need
a flag for that. The appropriate flag is start_remove but only after we
move it from a structure we remove.

-- 
  Vitaly
