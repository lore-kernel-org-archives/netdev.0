From: Pravin Shelar <pshelar@nicira.com>
Subject: Re: [PATCH net-next v6 1/8] vxlan: Restructure vxlan socket apis.
Date: Mon, 5 Aug 2013 08:49:36 -0700
Message-ID: <CALnjE+oZkX6FkVaaJeYz2C9SgY0hcRi6xKjxsSh+5Q=PoH7qFQ@mail.gmail.com>
References: <1375382680-3137-1-git-send-email-pshelar@nicira.com>
	<20130804144215.640c9336@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog126.obsmtp.com ([74.125.149.155]:37684 "HELO
	na3sys009aog126.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1752547Ab3HEPtg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Aug 2013 11:49:36 -0400
Received: by mail-qc0-f175.google.com with SMTP id s11so1759147qcv.34
        for <netdev@vger.kernel.org>; Mon, 05 Aug 2013 08:49:36 -0700 (PDT)
In-Reply-To: <20130804144215.640c9336@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Aug 4, 2013 at 2:42 PM, Stephen Hemminger
<stephen@networkplumber.org> wrote:
> On Thu,  1 Aug 2013 11:44:40 -0700
> Pravin B Shelar <pshelar@nicira.com> wrote:
>
>> @@ -1642,59 +1651,56 @@ static struct vxlan_sock *vxlan_socket_create(struct net *net, __be16 port)
>>                        &vxlan_addr.sin_addr, ntohs(vxlan_addr.sin_port), rc);
>>               sk_release_kernel(sk);
>>               kfree(vs);
>> -             return ERR_PTR(rc);
>> +             return;
>>       }
>> +     atomic_set(&vs->refcnt, 0);
>>
>>       /* Disable multicast loopback */
>>       inet_sk(sk)->mc_loop = 0;
>> +     spin_lock(&vn->sock_lock);
>> +     hlist_add_head_rcu(&vs->hlist, vs_head(net, port));
>> +     spin_unlock(&vn->sock_lock);
>
> Overall I am fine with this set, except for this.
> The change causes a socket to be put into the hash list with a ref count
> of 0 and then you increment the ref count. If some other thread
> finds the socket and then decrements the ref count, it would go
> below zero and might leak, crash or delete it prematurely.
>
> This concerns me.

There is no code path which decrements ref-cnt after lookup. Therefore
above case is not possible.
But I agree this does not look good, so I will change it so not to
have refcnt zero vs on hash-table.
