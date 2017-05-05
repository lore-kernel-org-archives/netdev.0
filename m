From: Vitaly Kuznetsov <vkuznets@redhat.com>
Subject: Re: [PATCH] xen-netfront: avoid crashing on resume after a failure in talk_to_netback()
Date: Fri, 05 May 2017 16:40:10 +0200
Message-ID: <87lgqb74fp.fsf@vitty.brq.redhat.com>
References: <20170504122304.11735-1-vkuznets@redhat.com>
        <20170504.112150.391662736580694835.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Cc: xen-devel@lists.xenproject.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, boris.ostrovsky@oracle.com,
        jgross@suse.com
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170504.112150.391662736580694835.davem@davemloft.net> (David
        Miller's message of "Thu, 04 May 2017 11:21:50 -0400 (EDT)")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller <davem@davemloft.net> writes:

> From: Vitaly Kuznetsov <vkuznets@redhat.com>
> Date: Thu,  4 May 2017 14:23:04 +0200
>
>> Unavoidable crashes in netfront_resume() and netback_changed() after a
>> previous fail in talk_to_netback() (e.g. when we fail to read MAC from
>> xenstore) were discovered. The failure path in talk_to_netback() does
>> unregister/free for netdev but we don't reset drvdata and we try accessing
>> it again after resume.
>> 
>> Reset drvdata in netback_changed() the same way we reset it in
>> netfront_probe() and check for NULL in both netfront_resume() and
>> netback_changed() to properly handle the situation.
>> 
>> Signed-off-by: Vitaly Kuznetsov <vkuznets@redhat.com>
>
> The circumstances under which netfront_probe() NULLs out the device
> private is different than what you propose here, which is to do it
> on a live device in netback_changed() whilst mutliple susbsytems
> have a reference to this device and can call into the driver still.
>
> It is only legal to do this in the probe function because such
> references and execution possibilities do not exist at that point.
>
> What really needs to happen is that the xenbus_driver must be told to
> unregister this xen device and stop making calls into the driver for
> it before you release the netdev state.
>
> That is the only reasonable way to fix this bug.

True,

after looking at the issue again I realized that removing half of the
device in talk_to_netback() is a mistake - we should either treat errors
as fatal and remove the device completely or leave netdev in place
hoping that it'll magically got fixed later. I'm leaning towards the
former, I tried and the following simple patch does the job:

diff --git a/drivers/net/xen-netfront.c b/drivers/net/xen-netfront.c
index 6ffc482..7b61adb 100644
--- a/drivers/net/xen-netfront.c
+++ b/drivers/net/xen-netfront.c
@@ -1934,8 +1934,7 @@ static int talk_to_netback(struct xenbus_device *dev,
        xennet_disconnect_backend(info);
        xennet_destroy_queues(info);
  out:
-       unregister_netdev(info->netdev);
-       xennet_free_netdev(info->netdev);
+       device_unregister(&dev->dev);
        return err;
 }

In case noone is against this big hammer I can send this as v2.

Thank you for your feedback, David!

-- 
  Vitaly
