From: Pravin Shelar <pshelar@nicira.com>
Subject: Re: [PATCH net-next v6 3/8] vxlan: Add vxlan recv demux.
Date: Mon, 5 Aug 2013 08:58:09 -0700
Message-ID: <CALnjE+pW-1R5jV+rwXJPZu=ANi+VB0885NDnA8TiTiiDXRphiQ@mail.gmail.com>
References: <1375382689-3218-1-git-send-email-pshelar@nicira.com>
	<20130804144526.4b2e189c@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog116.obsmtp.com ([74.125.149.240]:50088 "HELO
	na3sys009aog116.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1753734Ab3HEP6K (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Aug 2013 11:58:10 -0400
Received: by mail-qa0-f43.google.com with SMTP id cl20so1060795qab.9
        for <netdev@vger.kernel.org>; Mon, 05 Aug 2013 08:58:09 -0700 (PDT)
In-Reply-To: <20130804144526.4b2e189c@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Aug 4, 2013 at 2:45 PM, Stephen Hemminger
<stephen@networkplumber.org> wrote:
> On Thu,  1 Aug 2013 11:44:49 -0700
> Pravin B Shelar <pshelar@nicira.com> wrote:
>
>> +static struct vxlan_sock *vxlan_sock_add(struct net *net, __be16 port,
>> +                                      vxlan_rcv_t *rcv)
>>  {
>>       struct vxlan_net *vn = net_generic(net, vxlan_net_id);
>>       struct vxlan_sock *vs;
>>
>> -     vxlan_socket_create(net, port);
>> +     vxlan_socket_create(net, port, rcv);
>>
>>       spin_lock(&vn->sock_lock);
>>       vs = vxlan_find_sock(net, port);
>> -     if (vs)
>> -             atomic_inc(&vs->refcnt);
>> -     else
>> +     if (vs) {
>> +             if (vs->rcv == rcv)
>> +                     atomic_inc(&vs->refcnt);
>> +             else
>> +                     vs = ERR_PTR(-EBUSY);
>> +     }
>> +     spin_unlock(&vn->sock_lock);
>> +
>
> I think the ref counting needs to be the same for the
> kernel and OVS handling of a VXLAN.

Ref counting is same for ovs and vxlan.
In this patch ovs and vxlan module vxlan-rcv function pointers are
checked for port sharing.
