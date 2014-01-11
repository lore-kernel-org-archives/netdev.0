From: Daniel Borkmann <dborkman@redhat.com>
Subject: Re: [PATCH v3 net-next] net: vxlan: when lower dev unregisters remove
 vxlan dev as well
Date: Sat, 11 Jan 2014 09:46:58 +0100
Message-ID: <52D10502.1000308@redhat.com>
References: <1389393317-26563-1-git-send-email-dborkman@redhat.com> <CAHA+R7NB8sz1-W=QEmGxQkRyUmcMM6BzE7pZNU0W2_jzDfJjNw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: Cong Wang <cwang@twopensource.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:38338 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751033AbaAKIrH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 11 Jan 2014 03:47:07 -0500
In-Reply-To: <CAHA+R7NB8sz1-W=QEmGxQkRyUmcMM6BzE7pZNU0W2_jzDfJjNw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/11/2014 01:49 AM, Cong Wang wrote:
> On Fri, Jan 10, 2014 at 2:35 PM, Daniel Borkmann <dborkman@redhat.com> wrote:
>> @@ -2673,13 +2712,14 @@ static __net_init int vxlan_init_net(struct net *net)
>>   static __net_exit void vxlan_exit_net(struct net *net)
>>   {
>>          struct vxlan_net *vn = net_generic(net, vxlan_net_id);
>> -       struct vxlan_dev *vxlan;
>> -       LIST_HEAD(list);
>> +       struct vxlan_dev *vxlan, *next;
>> +       LIST_HEAD(list_kill);
>>
>>          rtnl_lock();
>> -       list_for_each_entry(vxlan, &vn->vxlan_list, next)
>> -               unregister_netdevice_queue(vxlan->dev, &list);
>> -       unregister_netdevice_many(&list);
>> +       list_for_each_entry_safe(vxlan, next, &vn->vxlan_list, next)
>> +               vxlan_dellink(vxlan->dev, &list_kill);
>> +       unregister_netdevice_many(&list_kill);
>> +       list_del(&list_kill);
>
> The last list_del() looks suspicous... Since list_kill is a local list head,
> why do we need to delete the head at the end??

Cong, maybe I'm missing something, but we're doing this rtnl_dellink()
and elsewehere, e.g. commit 226bd341147 ("net: use batched device unregister
in veth and macvlan").
