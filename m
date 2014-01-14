From: Daniel Borkmann <dborkman@redhat.com>
Subject: Re: [PATCH net-next 1/2] net: vxlan: when lower dev unregisters remove
 vxlan dev as well
Date: Tue, 14 Jan 2014 15:02:08 +0100
Message-ID: <52D54360.7070004@redhat.com>
References: <1389634880-4138-1-git-send-email-dborkman@redhat.com> <1389634880-4138-2-git-send-email-dborkman@redhat.com> <20140113182232.355f9d20@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:28587 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751318AbaANOCO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 14 Jan 2014 09:02:14 -0500
In-Reply-To: <20140113182232.355f9d20@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/14/2014 03:22 AM, Stephen Hemminger wrote:
> On Mon, 13 Jan 2014 18:41:19 +0100
> Daniel Borkmann <dborkman@redhat.com> wrote:
>
>> We can create a vxlan device with an explicit underlying carrier.
>> In that case, when the carrier link is being deleted from the
>> system (e.g. due to module unload) we should also clean up all
>> created vxlan devices on top of it since otherwise we're in an
>> inconsistent state in vxlan device. In that case, the user needs
>> to remove all such devices, while in case of other virtual devs
>> that sit on top of physical ones, it is usually the case that
>> these devices do unregister automatically as well and do not
>> leave the burden on the user.
>>
>> This work is not necessary when vxlan device was not created with
>> a real underlying device, as connections can resume in that case
>> when driver is plugged again. But at least for the other cases,
>> we should go ahead and do the cleanup on removal.
>>
>> We don't register the notifier during vxlan_newlink() here since
>> I consider this event rather rare, and therefore we should not
>> bloat vxlan's core structure unecessary. Also, we can simply make
>> use of unregister_netdevice_many() to batch that. fdb is flushed
>> upon ndo_stop().
>>
>> E.g. `ip -d link show vxlan13` after carrier removal before
>> this patch:
>>
>> 5: vxlan13: <BROADCAST,MULTICAST> mtu 1450 qdisc noop state DOWN mode DEFAULT group default
>>      link/ether 1e:47:da:6d:4d:99 brd ff:ff:ff:ff:ff:ff promiscuity 0
>>      vxlan id 13 group 239.0.0.10 dev 2 port 32768 61000 ageing 300
>>                                   ^^^^^
>> Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
>
> Since vxlan is running over UDP socket. I wonder if this could be
> done better by implementing something equivalent to SO_BINDTODEVICE.
>
> What happens to a user land application which has a UDP socket
> and has done SO_BINDTODEVICE and device is removed? Is there an asynchronous
> error, can the application recover? Why can't vxlan use the same mechanism?

Interesting point. What seems to happen with UDP sockets and SO_BINDTODEVICE
in case the device was present during the setsockopt(2), and module was
unloaded at time of sendto(2)/recvfrom(2), that at least senders give an
error of ENODEV in such cases while receivers seem not to notice as far as
I can tell. When we reload the module and device appears again with the
same name, then sendto(2), still fails with ENODEV, since we, of course,
work with indexes, that is, sk->sk_bound_dev_if. The only chance user space
would have is to try to redo the setsockopt(2) with SO_BINDTODEVICE on the
same device _name_, but different new index now, in the hope that this would
be the same underlying NIC. It seems, however not recommended to do so [1].
Anyway, so I'm not sure how useful this would be, I guess just doing what
this patch here does should be appropriate to do.

   [1] http://ftp.riken.go.jp/Linux/kernel/v2.0/patch-html/patch-2.0.31/linux_Documentation_networking_so_bindtodevice.txt.html
