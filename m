From: Roopa Prabhu <roopa@cumulusnetworks.com>
Subject: Re: vxlan: use after free error
Date: Mon, 29 May 2017 11:37:22 -0700
Message-ID: <CAJieiUgwRT8NbNdZ37HXJn9OYc78bpj=Zb9N5pQQQ_SLZhD1kg@mail.gmail.com>
References: <03ac7d79-02b7-4bee-d318-9731413bf97b@mellanox.com>
 <CAJieiUhNV7=r53mmsHTHAmA8g0PKoxszHyNMXwYKG4OsB20KjQ@mail.gmail.com> <b04f5f7e-dca1-b219-eb52-03f58fd3823e@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: "davem@davemloft.net" <davem@davemloft.net>,
        Jiri Benc <jbenc@redhat.com>, pravin shelar <pshelar@ovn.org>,
        Alexander Duyck <aduyck@mirantis.com>,
        Nicolas Dichtel <nicolas.dichtel@6wind.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        Balki Raman <ramanb@cumulusnetworks.com>
To: Mark Bloch <markb@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f180.google.com ([209.85.192.180]:33497 "EHLO
        mail-pf0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750880AbdE2ShY (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 29 May 2017 14:37:24 -0400
Received: by mail-pf0-f180.google.com with SMTP id e193so51377714pfh.0
        for <netdev@vger.kernel.org>; Mon, 29 May 2017 11:37:24 -0700 (PDT)
In-Reply-To: <b04f5f7e-dca1-b219-eb52-03f58fd3823e@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, May 28, 2017 at 11:28 PM, Mark Bloch <markb@mellanox.com> wrote:
> Hi Roopa,
>
> On 29/05/2017 05:50, Roopa Prabhu wrote:
>> On Sun, May 28, 2017 at 3:49 AM, Mark Bloch <markb@mellanox.com> wrote:

[snip]

>>
>> From: Balakrishnan Raman <ramanb@cumulusnetworks.com>
>>
>> Date: Sun, 28 May 2017 19:34:25 -0700
>>
>> Subject: [PATCH net-next] vxlan: remove vxlan device from socket's device
>>
>>  list in vxlan_stop
>>
>>
>> Signed-off-by: Balakrishnan Raman <ramanb@cumulusnetworks.com>
>>
>> Signed-off-by: Roopa Prabhu <roopa@cumulusnetworks.com>
>>
>> ---
>>
>>  drivers/net/vxlan.c | 13 ++++++++++++-
>>
>>  1 file changed, 12 insertions(+), 1 deletion(-)
>>
>>
>> diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
>>
>> index 328b471..26dac52 100644
>>
>> --- a/drivers/net/vxlan.c
>>
>> +++ b/drivers/net/vxlan.c
>>
>> @@ -2352,6 +2352,16 @@ static void vxlan_vs_add_dev(struct vxlan_sock
>> *vs, struct vxlan_dev *vxlan)
>>
>>         spin_unlock(&vn->sock_lock);
>>
>>  }
>>
>>
>> +static void vxlan_vs_del_dev(struct vxlan_dev *vxlan)
>>
>> +{
>>
>> +       struct vxlan_net *vn = net_generic(vxlan->net, vxlan_net_id);
>>
>> +
>>
>> +       spin_lock(&vn->sock_lock);
>>
>> +       if (!hlist_unhashed(&vxlan->hlist))
>
> We are calling this from vxlan_stop(), which means we did vxlan_open(), there
> we do vxlan_sock_add() and added the vxlan to the socket. so the check
> is unnecessary and we can just call hlist_del_init_rcu() directly.

What you say looks correct..., but does not hurt to leave this check in there..
given rest of the changes you are proposing below.

Looking at git blame, this check was added for OVS in dellink...but it
could have been because
 it was being called before stop in dellink.

>
>>
>> +               hlist_del_init_rcu(&vxlan->hlist);
>>
>> +       spin_unlock(&vn->sock_lock);
>>
>> +}
>>
>> +
>>
>>  /* Setup stats when device is created */
>>
>>  static int vxlan_init(struct net_device *dev)
>>
>>  {
>>
>> @@ -2443,6 +2453,7 @@ static int vxlan_stop(struct net_device *dev)
>>
>>         del_timer_sync(&vxlan->age_timer);
>>
>>
>>         vxlan_flush(vxlan, false);
>>
>> +       vxlan_vs_del_dev(vxlan);
>
> In my patch I've added the code inside vxlan_sock_release()
> after we do:
>         rcu_assign_pointer(vxlan->vn6_sock, NULL);
>         rcu_assign_pointer(vxlan->vn4_sock, NULL);
>         synchronize_net();
> this way we make sure we are done handling packets that may access the
> vxlan struct. seems cleaner to me, what do you think?

sure, that works. But, lets keep the function vxlan_vs_del_dev(vxlan)
for symmetry with
vxlan_vs_add_dev(vxlan) and call it from vxlan_sock_release().

>
>>
>>         vxlan_sock_release(vxlan);
>>
>>
>>         return ret;
>>
>>
>> @@ -3292,7 +3303,7 @@ static void vxlan_dellink(struct net_device
>> *dev, struct list_head *head)
>>
>>
>>         spin_lock(&vn->sock_lock);
>>
>>         if (!hlist_unhashed(&vxlan->hlist))
>>
>> -               hlist_del_rcu(&vxlan->hlist);
>>
>> +               hlist_del_init_rcu(&vxlan->hlist);
>>
>>         spin_unlock(&vn->sock_lock);
>>
>
> in vxlan_dellink() we call unregister_netdevice_queue(). which means if
> the interface is open, the kernel would stop it. (and we'll hit the code in vxlan_stop()).
> We can remove this entire block of code it seems.

That seems right. It does look redundant if we hit the same code via
vxlan_stop during dellink.

This code is also hit via the OVS path, and i don't see a problem with
your changes and analysis but i am not too familiar with the ovs call
path. I see that the relevant developers are CC'ed.

thanks.
