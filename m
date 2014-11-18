From: Cong Wang <cwang@twopensource.com>
Subject: Re: [PATCH] [net]ip_tunnel: the lack of vti_link_ops' dellink() cause
 kernel panic
Date: Tue, 18 Nov 2014 15:19:21 -0800
Message-ID: <CAHA+R7N7x5eMKFtyWpOcM_FGJ+9h-K+wLEwzpZya1kiztUo8RQ@mail.gmail.com>
References: <1416307059-32732-1-git-send-email-lucien.xin@gmail.com>
	<CAHA+R7NKdS_j2MC+-Bcw=hFERODiMw1Z6ju6yw5TvXXHbTXK5A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: network dev <netdev@vger.kernel.org>
To: Xin Long <lucien.xin@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f180.google.com ([209.85.216.180]:57799 "EHLO
	mail-qc0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932188AbaKRXTW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Nov 2014 18:19:22 -0500
Received: by mail-qc0-f180.google.com with SMTP id i8so8469242qcq.11
        for <netdev@vger.kernel.org>; Tue, 18 Nov 2014 15:19:21 -0800 (PST)
In-Reply-To: <CAHA+R7NKdS_j2MC+-Bcw=hFERODiMw1Z6ju6yw5TvXXHbTXK5A@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Nov 18, 2014 at 2:12 PM, Cong Wang <cwang@twopensource.com> wrote:
> On Tue, Nov 18, 2014 at 2:37 AM, Xin Long <lucien.xin@gmail.com> wrote:
>> Now the vti_link_ops do not point the .dellink, rtnl_newlink will invoke
>> the default function, unregister_netdevice_queue, which will cause the
>> dev to unregister later. so when we delete a vti device, the net_device
>> will be removed, but the tunnel still in the tunnel list. then, we add
>> a new vti, in ip_tunnel_find():
>>
>>         hlist_for_each_entry_rcu(t, head, hash_node) {
>>                 if (local == t->parms.iph.saddr &&
>>                     remote == t->parms.iph.daddr &&
>>                     link == t->parms.link &&
>>                     type == t->dev->type &&
>>                     ip_tunnel_key_match(&t->parms, flags, key))
>>                         break;
>>         }
>>
>> the dev of ip_tunnel *t may be null because of unregister_netdevice_queue
>> motioned above. so the panic will happen:
>
>
> Are you sure? We call ->ndo_uninit() in unregister path, and vti tunnel
> has ip_tunnel_uninit() which removes non-fb tunnel from that list.
>

Hmm, your fix is correct, but the description is wrong, we should just skip
the unregister of fb tunnel device like other tunnels. Without ->dellink()
the fb device is still removed from the global netdev list, this needs to skip,
otherwise ip_vti0 will disappear from your system.
