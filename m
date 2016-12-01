From: Jason Wang <jasowang@redhat.com>
Subject: Re: [PATCH net] vhost_net: don't continue to call the recvmsg when
 meet errors
Date: Thu, 1 Dec 2016 11:37:01 +0800
Message-ID: <936954dd-c8a5-c0f6-c3b0-84a9d67329f5@redhat.com>
References: <1480507857-22976-1-git-send-email-wangyunjian@huawei.com>
 <20161130152004-mutt-send-email-mst@kernel.org>
 <34EFBCA9F01B0748BEB6B629CE643AE60B0A7B68@szxeml561-mbx.china.huawei.com>
 <20161201051207-mutt-send-email-mst@kernel.org>
 <ee70cb92-3fd9-4148-77ba-739af30b04b6@redhat.com>
 <20161201052657-mutt-send-email-mst@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit
Cc: wangyunjian <wangyunjian@huawei.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        caihe <caihe@huawei.com>
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20161201052657-mutt-send-email-mst@kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On 2016年12月01日 11:27, Michael S. Tsirkin wrote:
> On Thu, Dec 01, 2016 at 11:26:21AM +0800, Jason Wang wrote:
>> >
>> >
>> >On 2016年12月01日 11:21, Michael S. Tsirkin wrote:
>>> > >On Thu, Dec 01, 2016 at 02:48:59AM +0000, wangyunjian wrote:
>>>>> > > > >-----Original Message-----
>>>>> > > > >From: Michael S. Tsirkin [mailto:mst@redhat.com]
>>>>> > > > >Sent: Wednesday, November 30, 2016 9:41 PM
>>>>> > > > >To: wangyunjian
>>>>> > > > >Cc:jasowang@redhat.com;netdev@vger.kernel.org;linux-kernel@vger.kernel.org; caihe
>>>>> > > > >Subject: Re: [PATCH net] vhost_net: don't continue to call the recvmsg when meet errors
>>>>> > > > >
>>>>> > > > >On Wed, Nov 30, 2016 at 08:10:57PM +0800, Yunjian Wang wrote:
>>>>>> > > > > >When we meet an error(err=-EBADFD) recvmsg,
>>>>> > > > >How do you get EBADFD? Won't vhost_net_rx_peek_head_len
>>>>> > > > >return 0 in this case, breaking the loop?
>>>> > > >We started many guest VMs while attaching/detaching some virtio-net nics for loop.
>>>> > > >The soft lockup might happened. The err is -EBADFD.
>>>> > > >
>>> > >OK, I'd like to figure out what happened here. why don't
>>> > >we get 0 when we peek at the head?
>>> > >
>>> > >EBADFD is from here:
>>> > >          struct tun_struct *tun = __tun_get(tfile);
>>> > >...
>>> > >          if (!tun)
>>> > >                  return -EBADFD;
>>> > >
>>> > >but then:
>>> > >static int tun_peek_len(struct socket *sock)
>>> > >{
>>> > >
>>> > >...
>>> > >
>>> > >          struct tun_struct *tun;
>>> > >...
>>> > >          tun = __tun_get(tfile);
>>> > >          if (!tun)
>>> > >                  return 0;
>>> > >
>>> > >
>>> > >so peek len should return 0.
>>> > >
>>> > >then while will exit:
>>> > >          while ((sock_len = vhost_net_rx_peek_head_len(net, sock->sk)))
>>> > >...
>>> > >
>> >
>> >Consider this case: user do ip link del link tap0 before recvmsg() but after
>> >tun_peek_len() ?
> Sure, this can happen, but I think we'll just exit on the next loop,
> won't we?
>

Right, this is the only case I can image for -EBADFD, let's wait for the 
author to the steps.
