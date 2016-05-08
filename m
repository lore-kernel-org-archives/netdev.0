From: Dexuan Cui <decui@microsoft.com>
Subject: RE: [PATCH v9 net-next 1/2] hv_sock: introduce Hyper-V Sockets
Date: Sun, 8 May 2016 06:11:04 +0000
Message-ID: <BLUPR03MB141044B2FC50DE43401C8C17BF7F0@BLUPR03MB1410.namprd03.prod.outlook.com>
References: <1462381017-568-1-git-send-email-decui@microsoft.com>
 <20160506.130353.2082047339292515860.davem@davemloft.net>
 <BLUPR03MB1410F30AED34632F8F1268DEBF7E0@BLUPR03MB1410.namprd03.prod.outlook.com>
 <20160507.134048.139772599380708393.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "olaf@aepfle.de" <olaf@aepfle.de>,
 "gregkh@linuxfoundation.org" <gregkh@linuxfoundation.org>,
 "jasowang@redhat.com" <jasowang@redhat.com>,
 "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
 "joe@perches.com" <joe@perches.com>,
 "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
 "apw@canonical.com" <apw@canonical.com>,
 "devel@linuxdriverproject.org" <devel@linuxdriverproject.org>,
 Haiyang Zhang <haiyangz@microsoft.com>
To: David Miller <davem@davemloft.net>
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
In-Reply-To: <20160507.134048.139772599380708393.davem@davemloft.net>
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

> From: David Miller [mailto:davem@davemloft.net]
> Sent: Sunday, May 8, 2016 1:41
> To: Dexuan Cui <decui@microsoft.com>
> Cc: gregkh@linuxfoundation.org; netdev@vger.kernel.org; linux-
> kernel@vger.kernel.org; devel@linuxdriverproject.org; olaf@aepfle.de;
> apw@canonical.com; jasowang@redhat.com; cavery@redhat.com; KY
> Srinivasan <kys@microsoft.com>; Haiyang Zhang <haiyangz@microsoft.com>;
> joe@perches.com; vkuznets@redhat.com
> Subject: Re: [PATCH v9 net-next 1/2] hv_sock: introduce Hyper-V Sockets
>
> From: Dexuan Cui <decui@microsoft.com>
> Date: Sat, 7 May 2016 10:49:25 +0000
>
> > I should be able to make 'send', 'recv' here to pointers and use vmalloc()
> > to allocate the memory for them.  I will do this.
>
> That's still unswappable kernel memory.
Hi David,
My understanding is: kernel pages are not swappable in Linux, so it looks I
can't avoid unswappable kernel memory here?

> People can open N sockets, where N is something on the order of the FD
> limit the process has, per process.  This allows someone to quickly
> eat up a lot of memory and hold onto it nearly indefinitely.

Thanks for pointing this out!
I understand, so I think I should add a module parameter, e.g.,
"hv_sock.max_socket_number" with a default value, say, 1024?

1 established hv_sock connection takes less than 20 pages, including 10
pages for VMBus ringbuffer, 6 pages for send/recv buffers(I'll use
vmalloc() for this), etc.
Here the recv buf needs a size of 5 pages because potentially the host
can send the guest a VMBus packet with an up-to-5-page payload, i..e,
the VMBus inbound ringbuffer size.

1024 hv_sock connections take less than 20*4KB * 1K = 80MB memory.

A user who needs more connections can change the module parameter
without reboot.

hv_sock connection is designed  to work only between the host and the
guest. I think 1024 connections seem pretty enough.

BTW, a user can't create hv_sock connections without enough privilege.
Please see

+static int hvsock_create(struct net *net, struct socket *sock,
+                        int protocol, int kern)
+{
+       if (!capable(CAP_SYS_ADMIN) && !capable(CAP_NET_ADMIN))
+               return -EPERM;

David, does this make sense to you?

Thanks,
-- Dexuan
