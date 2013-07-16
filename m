From: Pravin Shelar <pshelar@nicira.com>
Subject: Re: [PATCH net] vxlan: add necessary locking on device removal
Date: Tue, 16 Jul 2013 13:29:08 -0700
Message-ID: <CALnjE+q65PHMBycfmE2L2DDYuVU_8HrAKJJUtzzjVDVkT+sinA@mail.gmail.com>
References: <CALnjE+rO7Npw=rU_VL7T1pPDdFBKXB3KpVbpf_jQ0cJ6+ah1nQ@mail.gmail.com>
	<20130713101818.0d4fa8e0@nehalam.linuxnetplumber.net>
	<CALnjE+oDwU46NiK-AyB-dJZVrWT-pot_v+obv+MxgZU0xNwbRw@mail.gmail.com>
	<20130716.112820.260966128083756999.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: stephen@networkplumber.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog124.obsmtp.com ([74.125.149.151]:39485 "HELO
	na3sys009aog124.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S933582Ab3GPU3K (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Jul 2013 16:29:10 -0400
Received: by mail-qc0-f170.google.com with SMTP id s1so655523qcw.29
        for <netdev@vger.kernel.org>; Tue, 16 Jul 2013 13:29:08 -0700 (PDT)
In-Reply-To: <20130716.112820.260966128083756999.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jul 16, 2013 at 11:28 AM, David Miller <davem@davemloft.net> wrote:
> From: Pravin Shelar <pshelar@nicira.com>
> Date: Sat, 13 Jul 2013 12:21:52 -0700
>
>> On Sat, Jul 13, 2013 at 10:18 AM, Stephen Hemminger
>> <stephen@networkplumber.org> wrote:
>>> The socket management is now done in workqueue (outside of RTNL)
>>> and protected by vn->sock_lock. There were two possible bugs, first
>>> the vxlan device was removed from the VNI hash table per socket without
>>> holding lock. And there was a race when device is created and the workqueue
>>> could run after deletion.
>>>
>>> Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>
>>>
>>> --- a/drivers/net/vxlan.c       2013-07-08 16:31:50.080744429 -0700
>>> +++ b/drivers/net/vxlan.c       2013-07-10 20:15:47.337653899 -0700
>>> @@ -1767,9 +1767,15 @@ static int vxlan_newlink(struct net *net
>>>
>>>  static void vxlan_dellink(struct net_device *dev, struct list_head *head)
>>>  {
>>> +       struct vxlan_net *vn = net_generic(dev_net(dev), vxlan_net_id);
>>>         struct vxlan_dev *vxlan = netdev_priv(dev);
>>>
>>> +       flush_workqueue(vxlan_wq);
>>> +
>> Doesn't this create dependency on sock_work thread while holding RTNL.
>> If so it can result in deadlock.
>
> What exact deadlock do you perceive?  I don't see any code path in the
> sock_work handler (vxlan_sock_work) which takes the RTNL mutex.
>
> So we should be able to safely flush any pending sock_work jobs from
> vxlan_dellink().  The fact that vxlan_dellink() runs with the RTNL
> mutex shouldn't cause any issues.

commit 1c51a9159ddefa51 (vxlan: fix race caused by dropping
rtnl_unlock) moved sock-create to sock_work workq. Thats why I thought
sock_work takes RTNL. but if it is not taking RTNL in any case, they
why vxlan sock create is deferred to sock_work?
